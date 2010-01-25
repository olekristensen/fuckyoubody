//
//  _ExampleOutput.mm
//  openFrameworks
//
//  Created by Jonas Jongejan on 15/11/09.

#include "ProjectionSurfaces.h"
#include "Tracking.h"
#include "Lemmings.h"



@implementation Lemmings

@synthesize numberLemmings;

-(void) awakeFromNib{
	[super awakeFromNib];
}

-(void) initPlugin{
	screenLemmings = [[NSMutableArray array] retain];
	floorLemmings = [[NSMutableArray array] retain];
	userDefaults = [[NSUserDefaults standardUserDefaults] retain];
	screenDoorPos = new ofPoint(0.2,0.1);
	pthread_mutex_init(&mutex, NULL);
}

-(void) update:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	
	// add lemmings from door
	
	if ([screenEntranceDoor floatValue] > 0.65) {
		float lemmingInterval = fmodf(timeInterval, 1/([screenLemmingsAddRate floatValue]/60));
		if(lemmingInterval - lastLemmingInterval < 0.0){
			[screenLemmings addObject:[[[Lemming alloc]initWithX: screenDoorPos->x Y:screenDoorPos->y spawnTime:timeInterval]autorelease]];
		}
		lastLemmingInterval = lemmingInterval;
	}
	
	Lemming * lemming;
	
	// add screen gravity
	for(lemming in screenLemmings){
		*[lemming totalforce] += ofxPoint2f(0,[screenGravity floatValue]*(ofGetFrameRate()/60.0)/50.0);
	}
	
	//Add random force to lemmings on screen
	for(lemming in screenLemmings){
		*[lemming totalforce]  += ofxVec2f(ofRandom(-1, 1), ofRandom(-1, 1))*0.01;
	}
	
	
	//add motion from humans on the floor
	for (lemming in floorLemmings) {
		ofxPoint2f lemmingPosition = [GetPlugin(ProjectionSurfaces) convertToProjection:*[lemming position] surface:[GetPlugin(ProjectionSurfaces) getProjectionSurfaceByName:"Front" surface:"Floor"]];
		ofxVec2f p = [tracker([cameraControl selectedSegment]) flowAtX:lemmingPosition.x Y:lemmingPosition.y];
		if (p.length() > [motionTreshold floatValue]* 0.01) {
			*[lemming totalforce] -= p * [motionMultiplier floatValue];
			[lemming setRadius: [lemming radius] + 0.0025 ];
		}
	}
	
	
	
	[self updateLemmingArray:screenLemmings];
	[self updateLemmingArray:floorLemmings];
	
	//finally count the lemmings
	[self setValue:[[NSNumber alloc] initWithInt:([screenLemmings count] + [floorLemmings count])] forKey:@"numberLemmings"];
	
	cout << numberLemmings << endl;
	
}

-(void) updateLemmingArray:(NSMutableArray*) theLemmingArray{
	
	Lemming * lemming;
	
	//Kill lemmings that have died
	for(lemming in theLemmingArray){
		if ([lemming dying]) {
			[theLemmingArray removeObject:lemming];
		}
	}
	
	int i=0;
#pragma omp parallel for
	for(int i=0;i<[theLemmingArray count];i++){
		lemming =[theLemmingArray objectAtIndex:i];
#pragma omp parallel for
		for(int u=i+1;u<[theLemmingArray count];u++){
			Lemming * anotherLemming = [theLemmingArray objectAtIndex:u];
			ofxPoint2f l1 = *[lemming position];
			ofxPoint2f l2 = *[anotherLemming position];
			
			if(fabs(l1.x - l2.x) < 0.1){
				if(fabs(l1.y - l2.y) < 0.1){
					double distSq =	l1.distanceSquared(l2);
					if(distSq < RADIUS_SQUARED*1.02 ){
						ofxVec2f diff = *[lemming position] - *[anotherLemming position];
						diff.normalize();
						
						pthread_mutex_lock(&mutex);
						double iDist = ((double)RADIUS_SQUARED*1.1 - (double)distSq)/(double)(RADIUS_SQUARED*1.1); 
						diff *= MIN(iDist*3, 0.02);
						*[lemming totalforce] += diff;
						*[anotherLemming totalforce] -= diff;				
						pthread_mutex_unlock(&mutex);
					}
				}
			}
		}
		i++;
	}
	
	for (lemming in theLemmingArray) {
		PersistentBlob * nearestBlob;	
		float shortestDist = -1;
		
		PersistentBlob * blob;
		for(blob in [tracker([cameraControl selectedSegment]) persistentBlobs]){
			ofxPoint2f c = [GetPlugin(ProjectionSurfaces) convertFromProjection:*blob->centroid surface:[GetPlugin(ProjectionSurfaces) getProjectionSurfaceByName:"Front" surface:"Floor"]];
			if(shortestDist == -1 || c.distanceSquared(*[lemming position]) < shortestDist){
				shortestDist = c.distanceSquared(*[lemming position]);
				nearestBlob = blob;
			}
		}
		
		if(shortestDist != -1){	
			ofxPoint2f c = [GetPlugin(ProjectionSurfaces) convertFromProjection:*nearestBlob->centroid surface:[GetPlugin(ProjectionSurfaces) getProjectionSurfaceByName:"Front" surface:"Floor"]];
			
			*[lemming totalforce] += (c - *[lemming position])*([motionGravity floatValue]/100.0) ;
		}
		
	}
	
	
	
	//	id debugLemming = [theLemmingArray objectAtIndex:0];
	//cout<<"før: "<<[debugLemming position]->x<<"  "<<[debugLemming position]->y<<"  "<<[debugLemming totalforce]->x<<"  "<<[debugLemming totalforce]->y<<endl;
	
	
	//Move the lemming
	for(lemming in theLemmingArray){
		*[lemming vel] *= [damp floatValue]/100.0;
		*[lemming vel] += *[lemming totalforce];
		[lemming setTotalforce:new ofxVec2f()];
		
		*[lemming position] += *[lemming vel] * 1.0/ofGetFrameRate();
	}
	
	//Add Border
	for(lemming in theLemmingArray){
		if([lemming position]->x < 0 ){
			[lemming vel]->x *= -0.9;
			[lemming position]->x = 0.00001;
		}
		if([lemming position]->y < -0.0 ){
			[lemming vel]->y *= -0.9;
			[lemming position]->y = 0.00001;				
		}
		if([lemming position]->x > 1){
			[lemming vel]->x *= -0.9;
			[lemming position]->x = 0.99999;				
		}
		if([lemming position]->y > 1){
			[lemming vel]->y *= -0.9;
			[lemming position]->y = 0.99999;								
		}
		
		
	}
	
	//cout<<"efter: "<<[debugLemming position]->x<<"  "<<[debugLemming position]->y<<"  "<<[debugLemming totalforce]->x<<"  "<<[debugLemming totalforce]->y<<endl;
	
	
	
	
}


-(void) setup{
	
	
}

-(void) controlDraw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)timeStamp{
	/**
	 glPushMatrix();{
	 
	 ofScale(ofGetWidth(), ofGetHeight(), 1);
	 
	 ofEnableAlphaBlending();
	 ofSetColor(255, 255, 255,127);
	 ofFill();
	 Lemming * lemming;
	 for(lemming in lemmingList){
	 [lemming draw:timeInterval displayTime:timeStamp];
	 }
	 
	 ofNoFill();
	 PersistentBlob * blob;
	 
	 for(blob in [tracker([cameraControl selectedSegment]) persistentBlobs]){
	 int i=blob->pid%5;
	 switch (i) {
	 case 0:
	 ofSetColor(255, 0, 0,255);
	 break;
	 case 1:
	 ofSetColor(0, 255, 0,255);
	 break;
	 case 2:
	 ofSetColor(0, 0, 255,255);
	 break;
	 case 3:
	 ofSetColor(255, 255, 0,255);
	 break;
	 case 4:
	 ofSetColor(0, 255, 255,255);
	 break;
	 case 5:
	 ofSetColor(255, 0, 255,255);
	 break;
	 
	 default:
	 ofSetColor(255, 255, 255,255);
	 break;
	 }
	 Blob * b;
	 for(b in [blob blobs]){
	 glBegin(GL_LINE_STRIP);
	 for(int i=0;i<[b nPts];i++){
	 ofxPoint2f p =[GetPlugin(ProjectionSurfaces) convertFromProjection:[b pts][i] surface:[GetPlugin(ProjectionSurfaces) getProjectionSurfaceByName:"Front" surface:"Floor" ]];
	 glVertex2f(p.x, p.y);
	 }
	 glEnd();
	 }
	 }	
	 }glPopMatrix();
	 **/
}

-(void) draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	ofFill();
	ofEnableAlphaBlending();
	Lemming * lemming;
	
	[GetPlugin(ProjectionSurfaces) apply:"Front" surface:"Floor"];
	
	ofSetColor(255.0*[floorColor floatValue],255.0*[floorColor floatValue], 255.0*[floorColor floatValue],255);
	ofRect(0, 0, 1, 1);
	
	ofSetColor(255.0*[floorLemmingsColor floatValue],255.0*[floorLemmingsColor floatValue], 255.0*[floorLemmingsColor floatValue],255);
	
	for(lemming in floorLemmings){
		[lemming draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime];
	}
	
	glPopMatrix();
	
	[GetPlugin(ProjectionSurfaces) apply:"Back" surface:"Floor"];
	
	ofSetColor(255.0*[floorColor floatValue],255.0*[floorColor floatValue], 255.0*[floorColor floatValue],255);
	ofRect(0, 0, 1, 1);
	
	ofSetColor(255.0*[floorLemmingsColor floatValue],255.0*[floorLemmingsColor floatValue], 255.0*[floorLemmingsColor floatValue],255);
	
	for(lemming in floorLemmings){
		[lemming draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime];
	}
	
	glPopMatrix();
	
	[GetPlugin(ProjectionSurfaces) apply:"Front" surface:"Backwall"];{
		
		//background
		ofSetColor(0,100,0,255);
		ofRect(0, 0, 1, 1);
		
		//lemmings
		ofSetColor(255, 255, 255,255);
		
		for(lemming in screenLemmings){
			[lemming draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime];
		}
		
		// elements
		ofSetColor(255, 255, 255, 255.0*[screenElementsAlpha floatValue]);
		
		glPushMatrix(); {
			glTranslated(screenDoorPos->x, screenDoorPos->y, 0);
			
			//left Door
			glPushMatrix(); {
				glTranslatef(-0.1, 0, 0);
				glRotatef([screenEntranceDoor floatValue]*0.25*360, 0, 0, 1);
				ofRect(0, 0, 0.1, 0.02);
			} glPopMatrix();
			
			//left Door
			glPushMatrix(); {
				glTranslatef(0.1, 0, 0);
				glRotatef([screenEntranceDoor floatValue]*-0.25*360, 0, 0, 1);
				ofRect(0, 0, -0.1, 0.02);
			} glPopMatrix();
			
			
		} glPopMatrix();
		
	} glPopMatrix();
	
	
	/*[GetPlugin(ProjectionSurfaces) apply:"Back" surface:"Floor"];
	 
	 for(lemming in lemmingList){
	 [lemming draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime];
	 }
	 
	 glPopMatrix();
	 */
}

-(IBAction) addLemming:(id)sender{
	lemmingDiff++;
}

-(IBAction) removeOldestLemming:(id)sender{
	lemmingDiff--;
}

-(IBAction) resetLemmings:(id)sender{
	;
}


@end

@implementation Lemming
@synthesize radius, position, spawnTime, lemmingList, dying, vel, totalforce;

-(id) initWithX:(float)xPosition Y:(float)yPosition spawnTime:(CFTimeInterval)timeInterval{
	
	if ([super init]){
		
		position = new ofxVec2f();
		vel = new ofxVec2f();
		//		*vel *= 0.00001;
		totalforce = new ofxVec2f();
		radius = RADIUS;
		
		
		position->x = xPosition;
		position->y = yPosition;
		
		
		spawnTime = timeInterval;
	}
	
	return self;
}



-(void) draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	//	*position += (*destination - *position) * lagFactor;
	
	/*if (position->x < 0.0 || position->x > 1.0 || position->y < 0.0 || position->y > 1.0 ) {
	 
	 
	 position->x = ofRandom(0, 1);
	 position->y = 0.0;
	 
	 }*/
	
	radius -= (radius - RADIUS) *0.01;
	ofCircle(position->x, position->y, radius);
}

@end