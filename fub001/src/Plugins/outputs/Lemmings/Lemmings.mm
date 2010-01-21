//
//  _ExampleOutput.mm
//  openFrameworks
//
//  Created by Jonas Jongejan on 15/11/09.

#include "ProjectionSurfaces.h"
#include "Tracking.h"
#include "Lemmings.h"

@implementation Lemmings

-(void) awakeFromNib{
	[super awakeFromNib];
}

-(void) initPlugin{
	screenLemmings = [[NSMutableArray array] retain];
	floorLemmings = [[NSMutableArray array] retain];
	userDefaults = [[NSUserDefaults standardUserDefaults] retain];
	pthread_mutex_init(&mutex, NULL);
}

-(void) update:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{

	/**
	[numberLemmingsControl setIntValue:[lemmingList count]];
	
	if(ofGetFrameRate() > 2){
		
		Lemming * lemming;
		
		while (lemmingDiff > 0) {
			//		[lemmingList addObject:[[[Lemming alloc]initWithX:ofRandom(0, 1) Y:ofRandom(0, 1) spawnTime:timeInterval]autorelease]];
			[lemmingList addObject:[[[Lemming alloc]initWithX:ofRandom(0, 1) Y:ofRandom(0, 1) spawnTime:timeInterval]autorelease]];
			lemmingDiff--;
			NSLog(@"adding a lemming");
		}
		while (lemmingDiff < 0) {
			[[lemmingList lastObject] setDying:YES];
			lemmingDiff++;
			NSLog(@"removing a lemming");
		}
		
		//Kill lemming
		for(lemming in lemmingList){
			if ([lemming dying]) {
				[lemmingList removeObject:lemming];
			}
		}
		
		
		int i=0;
#pragma omp parallel for
		for(int i=0;i<[lemmingList count];i++){
			lemming =[lemmingList objectAtIndex:i];
#pragma omp parallel for
			for(int u=i+1;u<[lemmingList count];u++){
				Lemming * otherLemming = [lemmingList objectAtIndex:u];
				ofxPoint2f l1 = *[lemming position];
				ofxPoint2f l2 = *[otherLemming position];
				double distSq =		l1.distanceSquared(l2);
				if(distSq < RADIUS_SQUARED*1.1 ){
					ofxVec2f diff = *[lemming position] - *[otherLemming position];
					diff.normalize();
					
					pthread_mutex_lock(&mutex);
					double iDist = ((double)RADIUS_SQUARED*1.1 - (double)distSq)/(double)(RADIUS_SQUARED*1.1); 
					diff *= MIN(iDist*3, 0.02);
					*[lemming totalforce] += diff;
					*[otherLemming totalforce] -= diff;				
					pthread_mutex_unlock(&mutex);
				}
			}
			i++;
		}
		
		//Add random force
		for(lemming in lemmingList){
			//			*[lemming totalforce]  += ofxVec2f(ofRandom(-1, 1), ofRandom(-1, 1))*0.01;
			//				*[lemming totalforce]  += ofxVec2f(0,-1)*0.01;
		}
		
		for (lemming in lemmingList) {
			ofxPoint2f lemmingPosition = [GetPlugin(ProjectionSurfaces) convertToProjection:*[lemming position] surface:[GetPlugin(ProjectionSurfaces) getProjectionSurfaceByName:"Front" surface:"Floor"]];
			ofxVec2f p = [tracker([cameraControl selectedSegment]) flowAtX:lemmingPosition.x Y:lemmingPosition.y];
			if (p.length() > [motionTreshold floatValue]* 0.01) {
				*[lemming totalforce] -= p * [motionMultiplier floatValue];
				[lemming setRadius: [lemming radius] + 0.0025 ];
			}
		}
		
		for (lemming in lemmingList) {
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
		
		
		
		lemming = [lemmingList objectAtIndex:99];
		
		//cout<<"før: "<<[lemming position]->x<<"  "<<[lemming position]->y<<"  "<<[lemming totalforce]->x<<"  "<<[lemming totalforce]->y<<endl;
		//Move the lemming
		for(lemming in lemmingList){
			*[lemming vel] *= [damp floatValue]/100.0;
			*[lemming vel] += *[lemming totalforce];
			[lemming setTotalforce:new ofxVec2f()];
			
			*[lemming position] += *[lemming vel] * 1.0/ofGetFrameRate();
		}
		
		//Add Border
		for(lemming in lemmingList){
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
		
		
		lemming = [lemmingList objectAtIndex:99];
		//cout<<"efter: "<<[lemming position]->x<<"  "<<[lemming position]->y<<"   -    "<<[lemming vel]->x<<"   "<<[lemming vel]->y<<endl;
	}
}

-(void) setup{
	
	lemmingDiff = 200;
	
}

-(void) controlDraw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)timeStamp{
	
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
}

-(void) draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	ofFill();
	ofEnableAlphaBlending();
	Lemming * lemming;
	
	[GetPlugin(ProjectionSurfaces) apply:"Front" surface:"Floor"];
	
	ofSetColor(0, 127,255,255);
	ofRect(0, 0, 1, 1);
	
	ofSetColor(255,255, 255,255);
	
	for(lemming in lemmingList){
		[lemming draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime];
	}
	
	glPopMatrix();
	
	[GetPlugin(ProjectionSurfaces) apply:"Back" surface:"Floor"];
	
	ofSetColor(0,127,255,255);
	ofRect(0, 0, 1, 1);
	
	ofSetColor(255, 255, 255,255);
	
	for(lemming in lemmingList){
		[lemming draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime];
	}
	
	
	glPopMatrix();
	
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
