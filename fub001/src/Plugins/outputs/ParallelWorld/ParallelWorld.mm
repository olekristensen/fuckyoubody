#import "PluginIncludes.h"

@implementation BlobLink



@end


@implementation ParallelWorld
-(void) initPlugin{
	lines = [[NSMutableArray array] retain];
	userDefaults = [[NSUserDefaults standardUserDefaults] retain];
	
}

-(void) update:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	
	if([modeControl selectedSegment] == 0){
		PersistentBlob * blob;
		for(blob in [tracker([cameraControl selectedSegment]) persistentBlobs]){
			BOOL lineFound = NO;
			
			float optimalLeft = NULL;
			float optimalRight = NULL;
			
			Blob * b;
			BOOL anyBlobs = NO;
			for(b in [blob blobs]){
				anyBlobs = YES;
				for(int i=0;i<[b nPts];i+= 5){
					if(optimalLeft == NULL || [b pts][i].x < optimalLeft){
						optimalLeft = [b pts][i].x;
					}
					if(optimalRight == NULL || [b pts][i].x > optimalRight){
						optimalRight = [b pts][i].x;
					}
				}
			}
			
			optimalLeft -= [userDefaults floatForKey:@"parallel.corridor.width"]/200.0;
			optimalRight += [userDefaults floatForKey:@"parallel.corridor.width"]/200.0;			
			
			
			if(anyBlobs){
				ParallelLine * line;
				for(line in lines){
					BlobLink * link;
					for(link in [line links]){
						//See if blob is linked to line
						if(link->blobId == blob->pid){
							[line setLeft:([line left] + (optimalLeft - [line left])*[corridorSpeedControl floatValue]*0.01)];
							[line setRight:([line right] + (optimalRight - [line right])*[corridorSpeedControl floatValue]*0.01)];
							link->lastConfirm = outputTime->videoTime;
							lineFound = YES;
						}
					}
				}
				
				if(lineFound == NO){
					ParallelLine * newLine = [[ParallelLine alloc] init];
					BlobLink * link = [[BlobLink alloc] init]; 
					[newLine setLeft:optimalLeft];
					[newLine setRight:optimalRight];
					
					link->blobId = blob->pid;
					link->linkTime = outputTime->videoTime;
					link->lastConfirm = outputTime->videoTime;
					[[newLine links] addObject:link];
					[lines addObject:newLine];
				}
			}
		}
		
		
		for(int i=0;i<[lines count];i++){
			ParallelLine * line = [lines objectAtIndex:i];
			
			BOOL die = YES;
			BlobLink * link;
			for(link in [line links]){
				//See if blob is linked to line
				if(outputTime->videoTime - link->lastConfirm < 100000000 ){
					die = NO;					
				}
			}
			if(die){
				[lines removeObjectAtIndex:i];
			}
		}
		
		
		
	} else if([modeControl selectedSegment] == 1){ 
		if([adderRotateControl floatValue] != 0){
			float rotate = [adderRotateControl floatValue];
			[self rotate:rotate];
		}
		
		ParallelLine * line;
		for(line in lines){
			float w = [line right] - [line left];
			
			
			[line setLeft:[line left]  + ((([line left]+[line right])/2.0 - [adderWidthControl floatValue] - [line left])*[adderSpeedControl floatValue]*0.01) ];
			[line setRight:[line right]  + ((([line left]+[line right])/2.0 + [adderWidthControl floatValue] - [line right])*[adderSpeedControl floatValue]*0.01) ];
		}
		
		PersistentBlob * blob;
		for(blob in [tracker([cameraControl selectedSegment]) persistentBlobs]){
			BOOL lineFound = NO;
			if(blob->timeoutCounter < 2){
				ParallelLine * line;
				for(line in lines){
					BlobLink * link;
					for(link in [line links]){
						//See if blob is linked to line
						if(link->blobId == blob->pid){
							/*
							 [line setLeft:[line left]+blob->centroidV->x];
							 [line setRight:[line right]+blob->centroidV->x];*/
							if([adderModeControl selectedSegment] == 1){
								[line setLeft:([line left] + (blob->centroid->x-[adderWidthControl floatValue] - [line left])*[adderSpeedControl floatValue]*0.01)];
								[line setRight:([line right] + (blob->centroid->x+[adderWidthControl floatValue] - [line right])*[adderSpeedControl floatValue]*0.01)];
							} else {
								[self rotate:((blob->centroid->x - ([line left]+[line right])/2.0)*[adderSpeedControl floatValue]*0.01)]; 
							}
							
							link->lastConfirm = outputTime->videoTime;
							lineFound = YES;
						}
					}
				}
				
				BOOL oldLineFound = NO;
				if ( lineFound == NO) {
					ParallelLine * line;
					for(line in lines){
						if(blob->centroid->x > [line left] && blob->centroid->x < [line right]){
							oldLineFound = YES;
							BlobLink * link = [[BlobLink alloc] init]; 
							link->blobId = blob->pid;
							link->linkTime = outputTime->videoTime;
							link->lastConfirm = outputTime->videoTime;
							[[line links] addObject:link];
							
						}
					}
				}
				
				if(!oldLineFound && [adderAddControl state] == NSOnState && lineFound == NO){
					ParallelLine * newLine = [[ParallelLine alloc] init];
					BlobLink * link = [[BlobLink alloc] init]; 
					[newLine setLeft:blob->centroid->x];
					[newLine setRight:blob->centroid->x];
					
					link->blobId = blob->pid;
					link->linkTime = outputTime->videoTime;
					link->lastConfirm = outputTime->videoTime;
					[[newLine links] addObject:link];
					[lines addObject:newLine];
				}
				
			}
		}
		
		
	}
	
	[numberLinesControl setIntValue:[lines count]];
}


-(void) rotate:(float)rotate{
	ParallelLine * line;
	for(line in lines){
		[line setLeft:[line left]+rotate*50.0/ofGetFrameRate()];
		[line setRight:[line right]+rotate*50.0/ofGetFrameRate()];
		if(rotate > 0 && [line left] > 0.5 && [line right] > 0.5){
			[line setLeft:[line left]-0.55];
			[line setRight:[line right]-0.55];
		}
		if(rotate < 0 &&[line left] < 0 && [line right] < 0){
			[line setLeft:[line left]+0.55];
			[line setRight:[line right]+0.55];
		}			
	}
}


-(void) draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	ParallelLine * line;
	ofSetColor(255, 255, 255,255);
	for(line in lines){
		glBegin(GL_QUADS);
		glVertex2f(MIN([line left],0.5), 0);
		glVertex2f(MIN([line left],0.5), 1);
		glVertex2f(MIN([line right],0.5), 1);
		glVertex2f(MIN([line right],0.5), 0);
		glEnd();
	}	
}

-(void) controlDraw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)timeStamp{
	ofBackground(0, 0, 0);
	ofSetColor(255, 255, 255,255);
	ofLine(200, 0, 200, 200);
	
	ParallelLine * line;
	for(line in lines){
		glBegin(GL_QUADS);
		glVertex2f([line left]*200, 0);
		glVertex2f([line left]*200, 200);
		glVertex2f([line right]*200, 200);
		glVertex2f([line right]*200, 0);
		glEnd();
	}
	
	
}	

-(IBAction) clear:(id)sender{
	[lines removeAllObjects];
}

-(IBAction) removeOldest:(id)sender{
	if([lines count] > 0){
		[lines removeObjectAtIndex:0];
	}
}
@end



//--------------
//----Lines-----
//--------------



@implementation ParallelLine
@synthesize left, right, spawnTime, drawingMode, links;

-(id)init{
	if([super init]){
		links = [[NSMutableArray array] retain];
	}	
	return self;
}


@end

/*
 @implementation TouchField
 -(void) awakeFromNib{
 [self setAcceptsTouchEvents:YES];
 [self setWantsRestingTouches:YES];
 [super awakeFromNib];
 }*/
/*
 - (void)touchesBeganWithEvent:(NSEvent *)event{
 //	NSLog(@"Began");
 NSSet *touches = [event touchesMatchingPhase:NSTouchPhaseBegan    inView:self];
 NSArray * array = [touches allObjects];
 NSTouch * touch;	
 for(touch in array){
 if([touch phase] == NSTouchPhaseBegan){
 for(int i=0;i<numFingers;i++){
 if(world->fingerActive[i] == false){
 world->fingerActive[i] = true;
 world->identity[i] = [touch identity];
 world->fingerPositions[i]->x = [touch normalizedPosition].x; 
 world->fingerPositions[i]->y = 1.0-[touch normalizedPosition].y;
 
 break;
 }
 }			
 }
 }
 
 }
 - (void)touchesMovedWithEvent:(NSEvent *)event{
 //	NSLog(@"Moved");	
 NSSet *touches = [event touchesMatchingPhase:NSTouchPhaseMoved    inView:self];
 NSArray * array = [touches allObjects];
 NSTouch * touch;	
 for(touch in array){
 for(int i=0;i<numFingers;i++){
 if(world->fingerActive[i]){
 if([world->identity[i] isEqual:[touch identity]]){
 world->fingerPositions[i]->x = [touch normalizedPosition].x; 
 world->fingerPositions[i]->y = 1.0-[touch normalizedPosition].y;
 break;
 }
 }
 }
 }
 }
 - (void)touchesEndedWithEvent:(NSEvent *)event{
 
 //	NSLog(@"Ended");
 NSSet *touches = [event touchesMatchingPhase:NSTouchPhaseEnded   inView:self];
 NSArray * array = [touches allObjects];
 NSTouch * touch;	
 for(touch in array){
 for(int i=0;i<numFingers;i++){
 if(world->fingerActive[i]){
 if([world->identity[i] isEqual:[touch identity]]){
 world->fingerActive[i] = false;
 break;
 
 }
 }			
 
 }
 }
 }
 */
//@end
