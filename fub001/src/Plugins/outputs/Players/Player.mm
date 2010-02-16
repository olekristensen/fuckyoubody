//
//  Player.mm
//  openFrameworks
//
//  Created by Fuck You Buddy on 29/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Player.h"
#include "Tracking.h"
#include "CameraCalibration.h"

@implementation Player
@synthesize settingsView;

-(id) initWithN:(int)n{
	if([super init]){
		playerNumber = n;
		addNewBlob = NO;
		userDefaults = [[NSUserDefaults standardUserDefaults] retain];
		pointArray = new CvPoint[ 1024 ];
	}
	return self;
}


- (BOOL) loadNibFile {	
	if (![NSBundle loadNibNamed:@"Player"  owner:self]){
		NSLog(@"Warning! Could not load the nib for camera ");
		return NO;
	}
	
	[title setStringValue:[NSString stringWithFormat:@"Playah %d",playerNumber+1]];
	
	[name bind:@"value"
	  toObject:[NSUserDefaultsController sharedUserDefaultsController]
   withKeyPath:[NSString stringWithFormat:@"values.player.%i.name", playerNumber+1]
	   options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
										   forKey:@"NSContinuouslyUpdatesValue"]];
	
	[blobRedSlider bind:@"value"
			   toObject:blobcolor
			withKeyPath:[NSString stringWithFormat:@"red", playerNumber+1]
				options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
													forKey:@"NSContinuouslyUpdatesValue"]];
	[blobGreenSlider bind:@"value"
				 toObject:blobcolor
			  withKeyPath:[NSString stringWithFormat:@"green", playerNumber+1]
				  options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
													  forKey:@"NSContinuouslyUpdatesValue"]];
	[blobBlueSlider bind:@"value"
				toObject:blobcolor
			 withKeyPath:[NSString stringWithFormat:@"blue", playerNumber+1]
				 options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
													 forKey:@"NSContinuouslyUpdatesValue"]];
	
	[blobAlphaSlider bind:@"value"
				toObject:blobcolor
			 withKeyPath:[NSString stringWithFormat:@"alpha", playerNumber+1]
				 options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
													 forKey:@"NSContinuouslyUpdatesValue"]];
	
	
	NSColor * c = [NSColor colorWithCalibratedRed:[userDefaults floatForKey:[NSString stringWithFormat:@"player.%i.color.red",playerNumber+1]] green:[userDefaults floatForKey:[NSString stringWithFormat:@"player.%i.color.green",playerNumber+1]] blue:[userDefaults floatForKey:[NSString stringWithFormat:@"player.%i.color.blue",playerNumber+1]] alpha:1.0];
	[_ledColor setColor:c];
	
	c = [NSColor colorWithCalibratedRed:[userDefaults floatForKey:[NSString stringWithFormat:@"player.%i.projcolor.red",playerNumber+1]] green:[userDefaults floatForKey:[NSString stringWithFormat:@"player.%i.projcolor.green",playerNumber+1]] blue:[userDefaults floatForKey:[NSString stringWithFormat:@"player.%i.projcolor.blue",playerNumber+1]] alpha:1.0];
	[_projectorColor setColor:c];
	int i=12;
	
	[[addTopButton midi] setController: [[NSNumber alloc] initWithInt:i++ +(20*playerNumber+1)]];
	[[addTopButton midi] setLabel: [NSString stringWithFormat:@"Player %i - Tilføj top blob", playerNumber+1]];
	
	[[addRightButton midi] setController: [[NSNumber alloc] initWithInt:i++ +(20*playerNumber+1)]];
	[[addRightButton midi] setLabel: [NSString stringWithFormat:@"Player %i - Tilføj højre blob", playerNumber+1]];
	
	[[addBottomButton midi] setController: [[NSNumber alloc] initWithInt:i++ +(20*playerNumber+1)]];
	[[addBottomButton midi] setLabel: [NSString stringWithFormat:@"Player %i - Tilføj bund blob", playerNumber+1]];
	
	[[addLeftButton midi] setController: [[NSNumber alloc] initWithInt:i++ +(20*playerNumber+1)]];
	[[addLeftButton midi] setLabel: [NSString stringWithFormat:@"Player %i - Tilføj venstre blob", playerNumber+1]];
	
	[[resetBlobButton midi] setController: [[NSNumber alloc] initWithInt:i++ +(20*playerNumber+1)]];
	[[resetBlobButton midi] setLabel: [NSString stringWithFormat:@"Player %i - Reset blob", playerNumber+1]];
	
	[[colorBalanceSlider midi] setController: [[NSNumber alloc] initWithInt:i++ +(20*playerNumber+1)]];
	[[colorBalanceSlider midi] setLabel: [NSString stringWithFormat:@"Player %i - Blob color balance", playerNumber+1]];

	[[blobBlurSlider midi] setController: [[NSNumber alloc] initWithInt:i++ +(20*playerNumber+1)]];
	[[blobBlurSlider midi] setLabel: [NSString stringWithFormat:@"Player %i - Blob blur", playerNumber+1]];

	[_projectorColor setMidiControllersStartingWith:[[NSNumber alloc] initWithInt:i++ +(20*playerNumber+1)]];
	[_projectorColor setMidiLabelsPrefix:[NSString stringWithFormat:@"Player %i - Color", playerNumber+1]];
	i+=3;
	[blobcolor setMidiControllersStartingWith:[[NSNumber alloc] initWithInt:i++ +(20*playerNumber+1)]];
	[blobcolor setMidiLabelsPrefix:[NSString stringWithFormat:@"Player %i - Blob", playerNumber+1]];
	i+=3;	
	[_ledColor setMidiControllersStartingWith:[[NSNumber alloc] initWithInt:i++ +(20*playerNumber+1)]];
	[_ledColor setMidiLabelsPrefix:[NSString stringWithFormat:@"Player %i - Color", playerNumber+1]];
	i+=3;
	[[trackingPosition midi] setController: [[NSNumber alloc] initWithInt:i++ +(20*playerNumber+1)]];
	[[trackingPosition midi] setLabel: [NSString stringWithFormat:@"Player %i - Tracking Position", playerNumber+1]];

	return YES;
}


-(void) setup{
	light = new ofxCvColorImageAlpha();
	light->allocate(800,800);
	light->set(0,0,0,0);
	lightTemp = new ofxCvColorImageAlpha();
	lightTemp->allocate(800,800);
	lightTemp->set(0,0,0,0);
	lightTemp2 = new ofxCvColorImageAlpha();
	lightTemp2->allocate(800,800);
	lightTemp2->set(0,0,0,0);
	
	blur = new shaderBlur();
	blur->setup(800, 800);
	
}
-(void) draw{
	//glViewport(0, 0, ofGetWidth()/2.0, ofGetHeight());
	if(pblobs.size() > 0 && [blobAlphaSlider floatValue] > 0){
		NSColor * c = [[blobcolor color] blendedColorWithFraction:(1-[colorBalanceSlider floatValue]/100.0) ofColor:[_projectorColor color] ];

		[GetPlugin(CameraCalibration) applyWarpOnCam:[trackingPosition selectedSegment]];
		ofSetColor([c redComponent]*255.0, [c greenComponent]*255.0, [c blueComponent]*255.0,[c alphaComponent]*255.0* [blobAlphaSlider floatValue]);
		light->draw(0, 0,1,1);
		
		glPopMatrix();
	}
	
	
}



-(void) update{
	PersistentBlob * pblob;
	
	
	for(int i=0;i<pblobs.size();i++){
		BOOL pblobFound = NO;
		for(pblob in [tracker(0) persistentBlobs]){
			if(pblob->pid == pblobs[i])
				pblobFound = YES;
		}
		
		if(!pblobFound){
			pblobs.erase(pblobs.begin()+i);
			[numberPBlobs setIntValue:pblobs.size()];
		}
	}
	
	if(addNewBlob){
		
		int bestPblob = -1;
		ofxPoint2f bestPoint;
		
		for(pblob in [tracker([trackingPosition selectedSegment]) persistentBlobs]){
			BOOL pblobFound = NO;
			for(int i=0;i<pblobs.size();i++){
				if(pblobs[i] == pblob->pid){
					pblobFound = YES;
					break;
				}
			}
			
			if(!pblobFound){
				ofxPoint2f p = [GetPlugin(ProjectionSurfaces) convertPoint:[pblob getLowestPoint] fromProjection:"Front" toSurface:"Floor"];
				
				if(addRule->x > 0 || bestPblob == -1){
					if(p.x > bestPoint.x){
						bestPblob = pblob->pid;
						bestPoint = p;
					}
				}
				if(addRule->x < 0 || bestPblob == -1){
					if(p.x < bestPoint.x){
						bestPblob = pblob->pid;
						bestPoint = p;
					}
				}
				if(addRule->y > 0 || bestPblob == -1){
					if(p.y > bestPoint.y){
						bestPblob = pblob->pid;
						bestPoint = p;
					}
				}
				if(addRule->y < 0 || bestPblob == -1){
					if(p.y < bestPoint.y){
						bestPblob = pblob->pid;
						bestPoint = p;
					}
				}
			}
			
		}
		
		if(bestPblob != -1){
			pblobs.push_back(bestPblob);
		}
		[numberPBlobs setIntValue:pblobs.size()];
		
		addNewBlob = NO;
	}
	
	
	if(pblobs.size() > 0 && [blobAlphaSlider floatValue] > 0){
		lightTemp->set(0,0,0,0);
		lightTemp2->set(0,0,0,0);
		
		PersistentBlob * pb;
		int t = 0;
		for(pb in [tracker([trackingPosition selectedSegment]) persistentBlobs]){
			BOOL found = NO;
			for(int i=0;i<pblobs.size();i++){
				if(pb->pid == pblobs[i])
					found = YES;
			}
			
			if(found){
				Blob * b;
				for(b in [pb blobs]){						
					
					for( int u = 0; u < [b nPts]; u++){
						
						float pointPercent = (float)u/[b nPts];
						ofxPoint2f p = [GetPlugin(CameraCalibration) convertPoint:[b pts][u] toCamera:[trackingPosition selectedSegment]]  ;
						
						ofxVec2f blobP;
						blobP.x = int(p.x*800);
						blobP.y = int(p.y*800);				
						
						
						ofxVec2f point = blobP;
						pointArray[u].x  = point.x;
						pointArray[u].y  = point.y;
						
						//				cout<<pointArray[u].x<<"  "<<pointArray[u].y<<endl;
					}
					int nPts = [b nPts];					
					cvFillPoly(lightTemp->getCvImage(),&pointArray , &nPts, 1, cvScalar(255, 255, 255, 255.0));			
					lightTemp->flagImageChanged();
					
				}			
				
				
			}
		}
		light = lightTemp;			
		light->blur([blobBlurSlider floatValue]/20.0);
		light->flagImageChanged();
	} 
}



-(IBAction) addTopButton:(id)sender{
	addRule = new ofxVec2f(0,-1);
	addNewBlob = YES;	
}
-(IBAction) addRightButton:(id)sender{
	addRule = new ofxVec2f(1,0);
	addNewBlob = YES;
}
-(IBAction) addBottomButton:(id)sender{
	addRule = new ofxVec2f(0,1);
	addNewBlob = YES;
}
-(IBAction) addLeftButton:(id)sender{
	addRule = new ofxVec2f(-1,0);
	addNewBlob = YES;	
}
-(IBAction) resetBlobButton:(id)sender{
	pblobs.clear();
	[numberPBlobs setIntValue:pblobs.size()];
}
-(IBAction) setColorWell:(id)sender{
	[userDefaults setFloat:[[sender color] redComponent] forKey:[NSString stringWithFormat:@"player.%i.color.red",playerNumber+1]];
	[userDefaults setFloat:[[sender color] greenComponent] forKey:[NSString stringWithFormat:@"player.%i.color.green",playerNumber+1]];
	[userDefaults setFloat:[[sender color] blueComponent] forKey:[NSString stringWithFormat:@"player.%i.color.blue",playerNumber+1]];
}
-(IBAction) setColorWellProjector:(id)sender{
	[userDefaults setFloat:[[sender color] redComponent] forKey:[NSString stringWithFormat:@"player.%i.projcolor.red",playerNumber+1]];
	[userDefaults setFloat:[[sender color] greenComponent] forKey:[NSString stringWithFormat:@"player.%i.projcolor.green",playerNumber+1]];
	[userDefaults setFloat:[[sender color] blueComponent] forKey:[NSString stringWithFormat:@"player.%i.projcolor.blue",playerNumber+1]];
}


-(NSColor*) projectorColor{
	return [_projectorColor color];
}
-(NSColor*) ledColor{
	return [_ledColor color];
}

@end
