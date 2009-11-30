#import "PluginIncludes.h"



@implementation ParallelWorld
-(void) initPlugin{
	for(int i=0;i<numFingers;i++){
		fingerActive[i] = false;	
		fingerPositions[i] = new ofxPoint2f();
		identity[i] = nil;
	}
	min = 0.05;
	max = 0.09;
	[self remake:self];
	
}
-(IBAction) remake:(id)sender{
	lines = new vector<float>;
	float x = 0;
	while(x < 1.3){
		lines->push_back(x);
		x += ofRandom(min,max);
	}
}
-(IBAction) setMinSize:(id)sender{
	min = [sender floatValue];
}
-(IBAction) setMaxSize:(id)sender{
	max = [sender floatValue];	
}

-(void) draw{

//	[GetPlugin(ProjectionSurfaces) apply:"Front" surface:"Floor"];
	if([rotating state] != NSOnState){
	glPushMatrix();
	glTranslated(fingerPositions[0]->x, 0, 0);
	for(int i=1;i<lines->size();i+=2){
		ofSetColor(255, 255, 255);
		glBegin(GL_POLYGON);
		glVertex2f(lines->at(i), 0);
		glVertex2f(lines->at(i-1), 0);
		glVertex2f(lines->at(i-1), 1);
		glVertex2f(lines->at(i), 1);		
		glEnd();
	}
	glPopMatrix();
	glPushMatrix();
	glTranslated(fingerPositions[1]->x, 0, 0);
	for(int i=2;i<lines->size();i+=2){
		ofSetColor(255, 255, 255);
		glBegin(GL_POLYGON);
		glVertex2f(lines->at(i), 0);
		glVertex2f(lines->at(i-1), 0);
		glVertex2f(lines->at(i-1), 1);
		glVertex2f(lines->at(i), 1);		
		glEnd();
	}
	glPopMatrix();
	
	} else {
		float t = ofGetElapsedTimeMillis()/4000.0;
		glTranslated(t, 0, 0);
		for(int i=2;i<lines->size();i+=2){
			if(lines->at(i) + t > 1.1){
				lines->at(i) -= 1.3;
				lines->at(i-1) -= 1.3;
			}
			ofSetColor(255, 255, 255);
			glBegin(GL_POLYGON);
			glVertex2f(lines->at(i), 0);
			glVertex2f(lines->at(i-1), 0);
			glVertex2f(lines->at(i-1), 1);
			glVertex2f(lines->at(i), 1);		
			glEnd();
		}
	}
}

-(void) controlDraw{
	ofBackground(0, 0, 0);
	ofSetColor(255, 255, 255);
	for(int i=0;i<numFingers;i++){
		if(fingerActive[i]){
			ofCircle(fingerPositions[i]->x*ofGetWidth(), fingerPositions[i]->y*ofGetHeight(), 20);
		}
	}
}
@end


@implementation TouchField
-(void) awakeFromNib{
	[super awakeFromNib];
	[self setAcceptsTouchEvents:YES];
	[self setWantsRestingTouches:YES];
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

@end