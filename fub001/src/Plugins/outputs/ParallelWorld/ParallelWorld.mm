#import "ParallelWorld.h"



@implementation ParallelWorld
-(void) initPlugin{
	for(int i=0;i<numFingers;i++){
		fingerActive[i] = false;	
		fingerPositions[i] = ofxPoint2f();
	}
}

-(void) draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)timeStamp{
	ofSetColor(255, 255, 255);
	for(int i=0;i<numFingers;i++){
		if(fingerActive[i]){
			ofCircle(fingerPositions[i].x, fingerPositions[i].y, 0.05);
		}
	}
}
@end





@implementation TouchField
-(void) awakeFromNib{
	[self setAcceptsTouchEvents:YES];
}
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
					world->fingerPositions[i].x = [touch normalizedPosition].x; 
					world->fingerPositions[i].y = 1.0-[touch normalizedPosition].y;
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

@end
