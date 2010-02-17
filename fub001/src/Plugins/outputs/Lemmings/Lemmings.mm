//
//  _ExampleOutput.mm
//  openFrameworks
//
//  Created by Jonas Jongejan on 15/11/09.

#include "ProjectionSurfaces.h"
#include "Tracking.h"
#include "GrowingShadow.h"
#include "Lemmings.h"


@implementation Lemmings

@synthesize numberLemmings, parachuteImage;

-(void) awakeFromNib{
	[super awakeFromNib];
}

-(void) initPlugin{
	
	screenLemmings = [[NSMutableArray arrayWithCapacity:1000] retain];
	floorLemmings = [[NSMutableArray arrayWithCapacity:1000] retain];
	userDefaults = [[NSUserDefaults standardUserDefaults] retain];
	screenDoorPos = new ofPoint(0.5*[GetPlugin(ProjectionSurfaces) getAspectForProjection:"Front" surface:"Backwall"],0.08);
	[screenFloor setState:NSOnState];
	doReset = false;
	doClearAllLemmings = false;
	didKillAllLemmings = false;
	doKillAllLemmings = false;
	screenBottomIntersection = new ofxVec2f();
	blobCentroid = new ofxVec2f();
	screenBottomOnFloorLeft = new ofxVec2f();
	screenBottomOnFloorRight = new ofxVec2f();
	screenBottomOnFloor = new ofxVec2f();
	screenBottomOnFloorHat = new ofxVec2f();
	
	pthread_mutex_init(&mutex, NULL);
}

-(NSMutableArray*) makeElements:(int*) list {
	
	NSMutableArray* elements = [[NSMutableArray array] retain];
	
	int xResolution=20;
	int yResolution=15;
	
	for (int i = 0; i < xResolution*yResolution; i++) {
		if (list[i] == 1) {
			ScreenElement * block = [[ScreenElement alloc] initWithX:([GetPlugin(ProjectionSurfaces) getAspectForProjection:"Front" surface:"Backwall"]/xResolution)*(i%xResolution)
																   Y:(1.0/yResolution)*(i/xResolution) 
																size:[GetPlugin(ProjectionSurfaces) getAspectForProjection:"Front" surface:"Backwall"]/xResolution];
			[elements addObject:block];
		}
	}
	
	return elements;
}

-(void) reset{
	doReset = true;
}

-(void) update:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	
	screenBottomOnFloorLeft->set([GetPlugin(ProjectionSurfaces) convertPoint:[GetPlugin(ProjectionSurfaces) convertPoint:ofxVec2f(0,1) toProjection:"Front" fromSurface:"Backwall"] fromProjection:"Front" toSurface:"Floor"]);
	screenBottomOnFloorRight->set([GetPlugin(ProjectionSurfaces) convertPoint:[GetPlugin(ProjectionSurfaces) convertPoint:ofxVec2f([GetPlugin(ProjectionSurfaces) getAspectForProjection:"Front" surface:"Backwall"],1) toProjection:"Front" fromSurface:"Backwall"] fromProjection:"Front" toSurface:"Floor"]);
	screenBottomOnFloor->set(*screenBottomOnFloorRight - *screenBottomOnFloorLeft);
	screenBottomOnFloorHat->set(ofxVec2f(-screenBottomOnFloor->y, screenBottomOnFloor->x).normalized());
	
#pragma mark reset
	
	if(doReset || doClearAllLemmings){
		[screenLemmings removeAllObjects];
		[floorLemmings removeAllObjects];
		doClearAllLemmings = false;
	}
	
	if(doReset){
		delete screenTrackingLeftFilter;
		screenTrackingLeftFilter = new Filter();	
		screenTrackingLeftFilter->setNl(9.413137469932821686e-04, 2.823941240979846506e-03, 2.823941240979846506e-03, 9.413137469932821686e-04);
		screenTrackingLeftFilter->setDl(1, -2.5818614306773719263, 2.2466666427559748864, -.65727470210265670262);
		
		delete screenTrackingRightFilter;
		screenTrackingRightFilter = new Filter();	
		screenTrackingRightFilter->setNl(9.413137469932821686e-04, 2.823941240979846506e-03, 2.823941240979846506e-03, 9.413137469932821686e-04);
		screenTrackingRightFilter->setDl(1, -2.5818614306773719263, 2.2466666427559748864, -.65727470210265670262);
		
		delete screenTrackingHeightFilter;
		screenTrackingHeightFilter = new Filter();	
		screenTrackingHeightFilter->setNl(9.413137469932821686e-04, 2.823941240979846506e-03, 2.823941240979846506e-03, 9.413137469932821686e-04);
		screenTrackingHeightFilter->setDl(1, -2.5818614306773719263, 2.2466666427559748864, -.65727470210265670262);
		
		screenTrackingLeft = 0.5;
		screenTrackingRight = 0.5;
		screenTrackingHeight = 0.0;
		
		doReset = false;
	}
	
#pragma mark Kill (explode) all lemmings
	
	if(doKillAllLemmings){
		Lemming * lemming;
		for (lemming in screenLemmings) {
			[lemming setDeathTime:timeInterval];
		}
		for (lemming in floorLemmings) {
			[lemming setDeathTime:timeInterval];
		}
		doKillAllLemmings = NO;
		didKillAllLemmings  = YES;
	}
	
#pragma mark add rumiko's lemming
	
	if(doAddRumikosLemming){
		
		//Lemming * rumikosLemming = [[[Lemming alloc]initWithX: [[GetPlugin(GrowingShadow) coordinateX] floatValue] Y:[[GetPlugin(GrowingShadow) coordinateY] floatValue] spawnTime:timeInterval]autorelease];
		
		Lemming * rumikosLemming = [[[Lemming alloc]initWithX: homePos->x Y:homePos->y spawnTime:timeInterval]autorelease];
		
		[rumikosLemming setScaleFactor:0.5];
		
		[floorLemmings addObject:rumikosLemming];
		doAddRumikosLemming = NO;
	}
	
#pragma mark add lemmings from door
	
	if ([screenEntranceDoor floatValue] > 0.65) {
		float lemmingInterval = fmodf(timeInterval, 1/([screenLemmingsAddRate floatValue]/60));
		if(lemmingInterval - lastLemmingInterval < 0.0){
			Lemming * lemming = [[Lemming alloc]initWithX: screenDoorPos->x Y:screenDoorPos->y spawnTime:timeInterval];
			[lemming vel]->y = 0.45;
			[screenLemmings addObject:[lemming autorelease]];
		}
		lastLemmingInterval = lemmingInterval;
	}
	
#pragma mark add lemmings from dancer's feet
	
	if ([floorAddLemmingsFromFront state] == NSOnState) {
		float lemmingInterval = fmodf(timeInterval, 1/([floorLemmingsAddRate floatValue]/60));
		if(lemmingInterval - lastFloorLemmingInterval < 0.0){
			
			PersistentBlob * blob;
			
			for(blob in [tracker([cameraControl selectedSegment]) persistentBlobs]){
				
				ofxPoint2f p;
				
				p = [GetPlugin(ProjectionSurfaces) convertPoint:*blob->centroid fromProjection:"Front" toSurface:"Floor"]
				* (1.0-[blobAddPoint floatValue]);
				p += [GetPlugin(ProjectionSurfaces) convertPoint:[blob getLowestPoint] fromProjection:"Front" toSurface:"Floor"]
				* [blobAddPoint floatValue];
				
				if (p.x > 0 && p.y > 0) {
					Lemming * floorLemming = [[[Lemming alloc]initWithX:p.x Y:p.y spawnTime:timeInterval]autorelease];
					[floorLemming setScaleFactor:0.5];
					[floorLemming vel]->y = -0.01*ofRandom(0, 0.15);
					[floorLemming vel]->x = -0.01*ofRandom(0, 0.15);
					[floorLemmings addObject:floorLemming];
				}
			}
		}
		lastFloorLemmingInterval = lemmingInterval;
		if ([floorLemmings count] > 700) {
			[floorAddLemmingsFromFront setState:NSOffState];
		}
	}
	
	Lemming * lemming;
	
	for(int i=0;i<[screenLemmings count];i++){
		lemming =[screenLemmings objectAtIndex:i];
#pragma mark splat the collided lemmings and delete the exploded lemmings
		if ([lemming splatTime] > 0) {
			if (timeInterval - [lemming splatTime] > SPLAT_DURATION) {
				[screenLemmings removeObject:lemming];
			}
		} else if ([lemming deathTime] > 0) {
			if (timeInterval - [lemming deathTime] > DEATH_DURATION) {
				[screenLemmings removeObject:lemming];
			}
		}
	}
	
	for(int i=0;i<[floorLemmings count];i++){
		lemming =[floorLemmings objectAtIndex:i];
#pragma mark delete the exploded lemmings
		if ([lemming deathTime] > 0) {
			if (timeInterval - [lemming deathTime] > DEATH_DURATION) {
				[floorLemmings removeObject:lemming];
			}
		}
	}

	/*
	 #pragma mark make screen box from blobs
	 
	 float left = [GetPlugin(ProjectionSurfaces) getAspectForProjection:"Front" surface:"Backwall"];
	 float right = 0;
	 float height = 1.0;
	 
	 
	 if([trackingActive state] == NSOnState){
	 
	 float shortestDist = -1;
	 
	 PersistentBlob * blob;
	 
	 //screenPosition = &[GetPlugin(ProjectionSurfaces) convertPoint:ofxVec2f([GetPlugin(ProjectionSurfaces) getAspectForProjection:"Front" surface:"Backwall"]/2.0, 1.0) toProjection:"Front" fromSurface:"Backwall"];
	 //screenPosition = new ofxPoint2f([GetPlugin(ProjectionSurfaces) convertPoint:*screenPosition fromProjection:"Front" toSurface:"Floor"]);
	 
	 for(blob in [tracker([cameraControl selectedSegment]) persistentBlobs]){
	 
	 ofxPoint2f c;
	 
	 c = [GetPlugin(ProjectionSurfaces) convertPoint:*blob->centroid fromProjection:"Front" toSurface:"Floor"]
	 * (1.0-[blobPoint floatValue]);
	 c += [GetPlugin(ProjectionSurfaces) convertPoint:[blob getLowestPoint] fromProjection:"Front" toSurface:"Floor"]
	 * [blobPoint floatValue];
	 
	 ofxVec2f pf11 = *screenBottomOnFloorLeft;
	 ofxVec2f pf12 = *screenBottomOnFloorRight;
	 ofxVec2f pf21 = c;
	 ofxVec2f pf22 = c+*screenBottomOnFloorHat;
	 
	 //B i y = a+bx
	 float bf1 =((float)pf12.y-pf11.y)/(pf12.x-pf11.x);
	 float bf2 =((float)pf22.y-pf21.y)/(pf22.x-pf21.x);
	 
	 //A i y = a+bx <=> a = y - bx
	 float af1 = pf11.y - bf1*pf11.x;
	 float af2 = pf21.y - bf2*pf21.x;
	 
	 //intersection xi = - (a1 - a2) / (b1 - b2) yi = a1 + b1xi
	 ofxPoint2f cIntesectsScreenBottom = ofxPoint2f(-(af1 - af2)/(bf1-bf2) , af1 + bf1*(-(af1 - af2)/(bf1-bf2)));
	 
	 screenBottomIntersection->set(cIntesectsScreenBottom);
	 blobCentroid->set(c);
	 
	 if(c.distance(cIntesectsScreenBottom) < 0.4){
	 
	 ofxPoint2f * cIntesectsScreenBottomOnScreen = new ofxPoint2f([GetPlugin(ProjectionSurfaces) convertPoint:cIntesectsScreenBottom toProjection:"Front" fromSurface:"Floor"]);
	 cIntesectsScreenBottomOnScreen->set([GetPlugin(ProjectionSurfaces) convertPoint:*cIntesectsScreenBottomOnScreen fromProjection:"Front" toSurface:"Backwall"]);
	 
	 if (cIntesectsScreenBottomOnScreen->x > 0.0 && cIntesectsScreenBottomOnScreen->x < [GetPlugin(ProjectionSurfaces) getAspectForProjection:"Front" surface:"Backwall"] ) {
	 
	 if (cIntesectsScreenBottomOnScreen->x < left) {
	 left = fmaxf(cIntesectsScreenBottomOnScreen->x-0.1,0.0);
	 }
	 
	 if (cIntesectsScreenBottomOnScreen->x > right) {
	 right = fminf(cIntesectsScreenBottomOnScreen->x+0.1,[GetPlugin(ProjectionSurfaces) getAspectForProjection:"Front" surface:"Backwall"]);
	 }
	 
	 if (c.distance(cIntesectsScreenBottom)*(0.8/0.4) < height) {
	 height = 0.6;//fminf((c.distance(cIntesectsScreenBottom)*(0.8/0.35))+0.1,1.0);
	 }
	 }
	 delete cIntesectsScreenBottomOnScreen;
	 }
	 }
	 }
	 
	 screenTrackingLeft = screenTrackingLeftFilter->filter(left);			
	 screenTrackingRight = screenTrackingRightFilter->filter(right);			
	 screenTrackingHeight = screenTrackingHeightFilter->filter(height);
	 if(ofGetFrameRate()<50){
	 screenTrackingLeft = screenTrackingLeftFilter->filter(left);			
	 screenTrackingRight = screenTrackingRightFilter->filter(right);			
	 screenTrackingHeight = screenTrackingHeightFilter->filter(height);
	 }
	 screenTrackingLeft = screenTrackingLeftFilter->filter(left);			
	 screenTrackingRight = screenTrackingRightFilter->filter(right);			
	 screenTrackingHeight = screenTrackingHeightFilter->filter(height);
	 if(ofGetFrameRate()<50){
	 screenTrackingLeft = screenTrackingLeftFilter->filter(left);			
	 screenTrackingRight = screenTrackingRightFilter->filter(right);			
	 screenTrackingHeight = screenTrackingHeightFilter->filter(height);
	 }
	 
	 **/
	
	screenTrackingHeight = 0.6;
	screenTrackingLeft = (([screenPlayerSquarePosition floatValue] + 0.5) * [GetPlugin(ProjectionSurfaces) getAspectForProjection:"Front" surface:"Backwall"]) - 0.1;
	screenTrackingRight = (([screenPlayerSquarePosition floatValue] + 0.5) * [GetPlugin(ProjectionSurfaces) getAspectForProjection:"Front" surface:"Backwall"] ) + 0.1;
	
	/**
	 ScreenElement * element;
	 for (element in screenElements){
	 BOOL active = NO;
	 if ([element position]->y > screenTrackingHeight) {
	 if ([element position]->x > screenTrackingLeft && [element position]->x < screenTrackingRight ) {
	 active = YES;
	 }
	 }
	 [element setActive:active];
	 }
	 **/
	
#pragma omp parallel for
	for(lemming in screenLemmings){
#pragma mark collide with elements
		ScreenElement * element;
		for (element in screenElements){
			if([element active]){
				if([lemming vel]->y >= 0 ){
					if([lemming position]->y+(RADIUS*[lemming scaleFactor]) > [element position]->y){
						if([lemming position]->y+(RADIUS*[lemming scaleFactor]) < [element position]->y+0.032 ){
							// just in height of surface
							if([lemming position]->x+(RADIUS*[lemming scaleFactor]) > [element position]->x){
								if([lemming position]->x-(RADIUS*[lemming scaleFactor]) < [element position]->x+[element size]){
									[lemming vel]->y *= -0.5;
									[lemming vel]->x *= 1.01;
									[lemming position]->y = [element position]->y-(RADIUS*[lemming scaleFactor]);
								}
							}
						}
					}
				}
			}
		}
		
#pragma mark bless with dancer box
		if([screenPlayerSquareAlpha floatValue] > 0){
			if([lemming vel]->y >= 0 ){
				if([lemming position]->y+(RADIUS*[lemming scaleFactor]) > screenTrackingHeight){
					if([lemming position]->y+(RADIUS*[lemming scaleFactor]) < screenTrackingHeight+0.03 ){
						if([lemming position]->x+(RADIUS*[lemming scaleFactor]) > screenTrackingLeft){
							if([lemming position]->x-(RADIUS*[lemming scaleFactor]) < screenTrackingRight){
								[lemming vel]->y *= -0.15;
								[lemming vel]->x *= 0.9;
								[lemming setBlessed:YES];
								[lemming position]->y = screenTrackingHeight-(RADIUS*[lemming scaleFactor]);
							}
						}
					}
				}
			}
		}
		
#pragma mark add screen gravity
		if([lemming blessed]){
			[lemming vel]->y = [screenGravity floatValue]*0.1;
			if([lemming position]->y > 0.45)
				[lemming vel]->x = sinf((timeInterval-[lemming spawnTime])*PI*0.5)*0.2;
		} else {
			*[lemming totalforce] += ofxPoint2f(0,[screenGravity floatValue]/50.0);
		}
#pragma mark add random force to lemmings on screen
		*[lemming totalforce]  += ofxVec2f(ofRandom(-1, 1), ofRandom(-1, 1))*0.005;
	}
	
#pragma mark let lemmings into the floor
	if([screenFloor state] == NSOffState){
		for(int i = 0;i < [screenLemmings count];i++){
			lemming = [screenLemmings objectAtIndex:i];
			if ([lemming splatTime] < 0) {
				if([lemming position]->y + (RADIUS) > 0.9999){
					
					ofxVec2f lemmingPosition = [GetPlugin(ProjectionSurfaces) convertPoint:*[lemming position] toProjection:"Front" fromSurface:"Backwall"];
					lemmingPosition= [GetPlugin(ProjectionSurfaces) convertPoint:lemmingPosition fromProjection:"Front" toSurface:"Floor"];
					
					[lemming position]->x = lemmingPosition.x;
					[lemming position]->y = lemmingPosition.y-0.001;	
					
					[lemming vel]->y *= -1.0;
					ofxVec2f wallVel = ofxVec2f(*[lemming vel]);
					
					[lemming vel]->set(*screenBottomOnFloorHat * wallVel.length());
					[lemming vel]->rotate(-wallVel.angle(ofxVec2f(0,1)));
					[lemming setScaleFactor:0.5];
					*[lemming vel] *= 0.35;
					[lemming setBlessed:NO];
					[floorLemmings addObject:lemming];
					[screenLemmings removeObjectAtIndex:i];
				}		
			}
		}
	}
	
	if([trackingActive state] == NSOnState){
		//add motion from humans on the floor
		/**
		 for (lemming in floorLemmings) {
		 ofxPoint2f lemmingPosition = [GetPlugin(ProjectionSurfaces) convertToProjection:*[lemming position] surface:[GetPlugin(ProjectionSurfaces) getProjectionSurfaceByName:"Front" surface:"Floor"]];
		 ofxVec2f p = [tracker([cameraControl selectedSegment]) flowAtX:lemmingPosition.x Y:lemmingPosition.y];
		 if (p.length() > [motionTreshold floatValue]* 0.01) {
		 *[lemming totalforce] -= p * [motionMultiplier floatValue];
		 [lemming setRadius: [lemming radius] + 0.0025 ];
		 }
		 }
		 **/
		
#pragma mark add forces from humans on the floor
		
		for (lemming in floorLemmings) {
			PersistentBlob * nearestBlob;
			float shortestDist = -1;
			
			if ([floorLemmingsGoToHome state] == NSOnState) {
				
				*[lemming totalforce] += (*homePos - *[lemming position])*(1.0/33.0);
				
			} else {
				
				PersistentBlob * blob;
				for(blob in [tracker([cameraControl selectedSegment]) persistentBlobs]){
					
					ofxPoint2f c;
					
					c = [GetPlugin(ProjectionSurfaces) convertPoint:*blob->centroid fromProjection:"Front" toSurface:"Floor"]
					* (1.0-[blobPoint floatValue]);
					c += [GetPlugin(ProjectionSurfaces) convertPoint:[blob getLowestPoint] fromProjection:"Front" toSurface:"Floor"]
					* [blobPoint floatValue];
					
					if(c.y > 1.0-[floorBlobMask floatValue]){
						if(shortestDist == -1 || c.distanceSquared(*[lemming position]) < shortestDist){
							shortestDist = c.distanceSquared(*[lemming position]);
							nearestBlob = blob;
						}
					}
				}
				
				if(shortestDist != -1){	
					
					ofxPoint2f c;
					
					c = [GetPlugin(ProjectionSurfaces) convertPoint:*nearestBlob->centroid fromProjection:"Front" toSurface:"Floor"]
					* (1.0-[blobPoint floatValue]);
					c += [GetPlugin(ProjectionSurfaces) convertPoint:[nearestBlob getLowestPoint] fromProjection:"Front" toSurface:"Floor"]
					* [blobPoint floatValue];
					
					if (shortestDist < [floorBlobFarForceThreshold floatValue]){
						*[lemming totalforce] += (c - *[lemming position])*([floorBlobFarForce floatValue]/50.0) ;
					}
					if (shortestDist < [floorBlobNearForceThreshold floatValue]*0.25){
						*[lemming totalforce] += (c - *[lemming position])*([floorBlobNearForce floatValue]/5.0) ;
					}
					
					[lemming setAlpha:fmaxf(0.0,1.0-(shortestDist*30.0*[floorLemmingsDistanceAlpha floatValue]))];
				}
			}
			
			[lemming setCoinyness:[floorLemmingsCoins floatValue]];
			
		}
	}
	
	[self updateLemmingArray:screenLemmings timeInterval:timeInterval];
	[self updateLemmingArray:floorLemmings timeInterval:timeInterval];
	
	
#pragma mark screen edge collision
	for(lemming in screenLemmings){
		if([lemming position]->x - (RADIUS) < 0 ){
			[lemming vel]->x *= -0.9;
			[lemming position]->x = 0.00001 + (RADIUS);
		}
		if([lemming position]->y - (RADIUS) < -0.0 ){
			[lemming vel]->y *= -0.9;
			[lemming position]->y = 0.00001 + (RADIUS);				
		}
		if([lemming position]->x + (RADIUS) > [GetPlugin(ProjectionSurfaces) getAspectForProjection:"Front" surface:"Backwall"]){
			[lemming vel]->x *= -0.5;
			[lemming position]->x = [GetPlugin(ProjectionSurfaces) getAspectForProjection:"Front" surface:"Backwall"] - (0.0001 + (RADIUS));				
		}
		if([screenFloor state] == NSOffState){
			if([lemming position]->y + (RADIUS) > 1+(SCREEN_MARGIN)){
				[lemming collision:timeInterval];
				[lemming vel]->y *= -0.5;
				[lemming position]->y = (0.99999+SCREEN_MARGIN) - (RADIUS);								
			}
		} else {
			if([lemming position]->y + (RADIUS) > 1.0){
				[lemming collision:timeInterval];
				[lemming vel]->y *= -0.5;
				[lemming position]->y = 0.99999 - (RADIUS);								
			}
		}
		
	}
	
	
#pragma mark floor edge collision
	for(lemming in floorLemmings){
		if ([lemming isAlive]) {
			if([lemming position]->x - (RADIUS*[lemming scaleFactor]) < 0 ){
				[lemming vel]->x *= -0.95;
				[lemming position]->x = 0.00001 + (RADIUS*[lemming scaleFactor]);
			}
			if([lemming position]->y - (RADIUS*[lemming scaleFactor]) < -0.0 ){
				[lemming vel]->y *= -0.95;
				[lemming position]->y = 0.00001 + (RADIUS*[lemming scaleFactor]);				
			}
			if([lemming position]->x + (RADIUS*[lemming scaleFactor]) > [GetPlugin(ProjectionSurfaces) getAspectForProjection:"Front" surface:"Floor"]){
				[lemming vel]->x *= -0.95;
				[lemming position]->x = [GetPlugin(ProjectionSurfaces) getAspectForProjection:"Front" surface:"Floor"] - (0.00001 + (RADIUS*[lemming scaleFactor]));				
			}
			if([lemming position]->y + (RADIUS*[lemming scaleFactor]) > 1){
				[lemming vel]->y *= -0.95;
				[lemming position]->y = 0.99999 - (RADIUS*[lemming scaleFactor]);								
			}
		}
	}
	
	//finally count the lemmings
	[self setValue:[NSNumber numberWithInt:([screenLemmings count] + [floorLemmings count])] forKey:@"numberLemmings"];
	
}

-(void) updateLemmingArray:(NSMutableArray*) theLemmingArray timeInterval:(CFTimeInterval)timeInterval{
	
	Lemming * lemming;
	
	if([theLemmingArray count] > 1){ // not making threads to collide unless neccesary
		
		int i=0;
		
		float collisionRadius = RADIUS * [lemmingCollisionThreshold floatValue];
		
		for(lemming in theLemmingArray){
			if ([lemming isAlive]) {
				Lemming * anotherLemming;
				NSUInteger index = 0;
#pragma omp parallel for
				for(anotherLemming in theLemmingArray){
					if (index > i && [anotherLemming isAlive]) {
						ofxPoint2f l1 = *[lemming position];
						ofxPoint2f l2 = *[anotherLemming position];
						double dist = l1.squareDistance(l2);
						double radiusToBeSquared = (collisionRadius*[lemming scaleFactor])+(collisionRadius*[anotherLemming scaleFactor]);
						if(dist < radiusToBeSquared*radiusToBeSquared ){
							ofxVec2f diff = *[lemming position] - *[anotherLemming position];
							diff.normalize();
							
							diff *= fminf(sqrt(dist)*0.75, radiusToBeSquared*0.9);
							
							//pthread_mutex_lock(&mutex);
							
							*[lemming totalforce] += diff;
							*[anotherLemming totalforce] -= diff;
							
							//pthread_mutex_unlock(&mutex);
						}
					}
					index++;
				}
			}
			i++;
		}
	}
	
	//	id debugLemming = [theLemmingArray objectAtIndex:0];
	//cout<<"før: "<<[debugLemming position]->x<<"  "<<[debugLemming position]->y<<"  "<<[debugLemming totalforce]->x<<"  "<<[debugLemming totalforce]->y<<endl;
	
	
	//Move the lemming
	for(lemming in theLemmingArray){
		//if([lemming deathTime] <=0){
		*[lemming vel] += *[lemming totalforce];
		*[lemming totalforce] *= 0;
		*[lemming vel] *= (100.0-[damp floatValue])/100.0;
		//} else {
		//	*[lemming vel] *= (DEATH_DURATION-[lemming deathTime])/DEATH_DURATION;
		//}
		*[lemming position] += *[lemming vel] * 1.0/ofGetFrameRate();
	}
	
	//cout<<"efter: "<<[debugLemming position]->x<<"  "<<[debugLemming position]->y<<"  "<<[debugLemming totalforce]->x<<"  "<<[debugLemming totalforce]->y<<endl;
	
	
	
}

-(void) setup{
	
	int elementsList[] = {
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 
		0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0, 
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 
		
	};
	
	screenElements = [self makeElements:elementsList];
	parachuteImage = new ofImage;
	parachuteImage->loadImage("lemmings/parachute.png");
	
	homePos = new ofxVec2f(0.85,0.85);
	
	[self reset];
	
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
	
	NSColor * playerColor = [GetPlugin(Players) playerColor:3];
	
	Lemming * lemming;
	
	[GetPlugin(ProjectionSurfaces) apply:"Front" surface:"Floor"];{
		
		ofSetColor(215.0*[floorColor floatValue],221.0*[floorColor floatValue], 248.0*[floorColor floatValue],255*[alpha floatValue]);
		ofRect(0, 0, 1, 1);
		
		/** floor box
		 ofSetColor([playerColor redComponent]*255, [playerColor greenComponent]*255, [playerColor blueComponent]*255,[screenPlayerSquareAlpha floatValue]*255);
		 glPushMatrix();{
		 glTranslated(screenBottomOnFloorLeft->x, screenBottomOnFloorLeft->y, 0);
		 glRotatef(-screenBottomOnFloorHat->angle(ofxVec2f(0,1)), 0,0,1);
		 
		 glScaled(screenBottomOnFloor->length()/[GetPlugin(ProjectionSurfaces) getAspectForProjection:"Front" surface:"Backwall"],
		 screenBottomOnFloor->length()/[GetPlugin(ProjectionSurfaces) getAspectForProjection:"Front" surface:"Backwall"],
		 0);
		 
		 ofRect(screenTrackingLeft, 
		 0, 
		 screenTrackingRight- screenTrackingLeft, 
		 screenTrackingHeight);
		 
		 }glPopMatrix();
		 **/
		
	}glPopMatrix();
	
	[GetPlugin(ProjectionSurfaces) apply:"Back" surface:"Floor"];{
		
		ofSetColor(215.0*[floorColor floatValue],221.0*[floorColor floatValue], 248.0*[floorColor floatValue],255*[alpha floatValue]);
		ofRect(0, 0, 1, 1);
		
		/** floor box
		 ofSetColor([playerColor redComponent]*255, [playerColor greenComponent]*255, [playerColor blueComponent]*255,[screenPlayerSquareAlpha floatValue]*255);
		 glPushMatrix();{
		 glTranslated(screenBottomOnFloorLeft->x, screenBottomOnFloorLeft->y, 0);
		 glRotatef(-screenBottomOnFloorHat->angle(ofxVec2f(0,1)), 0,0,1);
		 
		 glScaled(screenBottomOnFloor->length()/[GetPlugin(ProjectionSurfaces) getAspectForProjection:"Front" surface:"Backwall"],
		 screenBottomOnFloor->length()/[GetPlugin(ProjectionSurfaces) getAspectForProjection:"Front" surface:"Backwall"],
		 0);
		 
		 ofRect(screenTrackingLeft, 
		 0, 
		 screenTrackingRight- screenTrackingLeft, 
		 screenTrackingHeight);
		 
		 }glPopMatrix();
		 **/
		
	}glPopMatrix();
	
	[GetPlugin(ProjectionSurfaces) apply:"Front" surface:"Floor"];{
		
		ofSetColor(215.0*[floorLemmingsColor floatValue],221.0*[floorLemmingsColor floatValue], 248.0*[floorLemmingsColor floatValue],255*[alpha floatValue]);
		
		for(lemming in floorLemmings){
			[lemming draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime];
		}
		
		/* normal between dancer and screen
		 
		 ofPushStyle();{
		 ofSetColor(255, 0,0);
		 ofNoFill();
		 ofSetLineWidth(1);
		 ofLine(screenBottomIntersection->x, screenBottomIntersection->y, blobCentroid->x, blobCentroid->y);
		 }ofPopStyle();
		 //*/
		
		// MASK
		ofSetColor(0,0,0,255*[mask floatValue]);
		ofRect(-1, 1, 3, 1); // stage front
		ofRect(1, 0, 1, 1); // stage right
		ofRect(0, 0, -1, 1); // stage left
		ofRect(-1, 0, 3, -1); // stage back
		
	}glPopMatrix();
	
	[GetPlugin(ProjectionSurfaces) apply:"Back" surface:"Floor"];{
		
		ofSetColor(215.0*[floorLemmingsColor floatValue],221.0*[floorLemmingsColor floatValue], 248.0*[floorLemmingsColor floatValue],255*[alpha floatValue]);
		
		for(lemming in floorLemmings){
			[lemming draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime];
		}
		
		//MASK
		ofSetColor(0,0,0,255*[mask floatValue]);
		ofRect(-1, 1, 3, 1); // stage front
		ofRect(1, 0, 1, 1); // stage right
		ofRect(0, 0, -1, 1); // stage left
		ofRect(-1, 0, 3, -1); // stage back
		
	}glPopMatrix();
	
	[GetPlugin(ProjectionSurfaces) apply:"Front" surface:"Backwall"];{
		
		//background
		ofSetColor(0,0,0,255*[alpha floatValue]);
		ofRect(0, 0, [GetPlugin(ProjectionSurfaces) getAspect], 1);
		
		//dancers' mask
		/**
		 ofSetColor([playerColor redComponent]*255, [playerColor greenComponent]*255, [playerColor blueComponent]*255,[screenPlayerSquareAlpha floatValue]*255);
		 ofRect(screenTrackingLeft, screenTrackingHeight, screenTrackingRight-screenTrackingLeft, 1.0-screenTrackingHeight);
		 **/
		
		if((1.0-screenTrackingHeight) > SCREEN_MARGIN){
			ofSetColor(215.0, 221.0, 248.0,[screenPlayerSquareAlpha floatValue]*255*[alpha floatValue]);
		} else {
			ofSetColor(215.0, 221.0, 248.0,[screenPlayerSquareAlpha floatValue]*0*[alpha floatValue]);
		}
		
		ofRect(screenTrackingLeft, screenTrackingHeight, screenTrackingRight-screenTrackingLeft, 0.03);
		
		//Screen Elements
		ScreenElement * element;
		
		for(element in screenElements){
			[element draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime];
		}
		
		//lemmings
		ofSetColor(215.0*[screenLemmingsBrightness floatValue], 221.0*[screenLemmingsBrightness floatValue], 248.0*[screenLemmingsBrightness floatValue],255.0*[alpha floatValue]);
		
		for(lemming in screenLemmings){
			[lemming draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime];
		}
		
		// Door
		ofSetColor(215, 221, 248, 255.0*[screenElementsAlpha floatValue]*[alpha floatValue]);
		
		glPushMatrix(); {
			glTranslated(screenDoorPos->x, screenDoorPos->y, 0);
			
			//left Door
			glPushMatrix(); {
				glTranslatef(-0.15, 0, 0);
				glRotatef([screenEntranceDoor floatValue]*0.25*360, 0, 0, 1);
				ofRect(0, 0, 0.15, 0.03);
			} glPopMatrix();
			
			//left Door
			glPushMatrix(); {
				glTranslatef(0.15, 0, 0);
				glRotatef([screenEntranceDoor floatValue]*-0.25*360, 0, 0, 1);
				ofRect(0, 0, -0.15, 0.03);
			} glPopMatrix();
			
		} glPopMatrix();
		
	} glPopMatrix();
	
}

-(float) getScreenGravityAsFloat{
	return [screenGravity floatValue];
}

-(float) getScreenSplatVelocityAsFloat{
	return [screenSplatVelocity floatValue];
}

-(float) getScreenElementsAlphaAsFloat{
	return [screenElementsAlpha floatValue];
}

-(float) getLemmingsSizeAsFloat {
	return [lemmingSize floatValue];
}

-(IBAction) addRumikosLemming:(id)sender{
	doAddRumikosLemming = YES;
}

-(IBAction) resetLemmings:(id)sender{
	[self reset];
}

-(IBAction) clearAllLemmings:(id)sender{
	doClearAllLemmings = YES;
}

-(IBAction) killAllLemmings:(id)sender{
	 ofSoundPlayer * die = new ofSoundPlayer();
	//pop->loadSound("lemmings/pop/" + ofToString(round(random*69)+1,0) + ".aif");
	die->loadSound("lemmings/org/OHNO.wav");
	die->play();
	 doKillAllLemmings = YES;
}
@end

@implementation Lemming
@synthesize radius, scaleFactor, random, position, spawnTime, splatTime, lemmingList, deathTime, vel, totalforce, blessed, coinyness, alpha;

-(id) initWithX:(float)xPosition Y:(float)yPosition spawnTime:(CFTimeInterval)timeInterval{
	
	if ([super init]){
		
		position = new ofxVec2f();
		vel = new ofxVec2f();
		deathTime = -1.0;
		splatTime = -1.0;
		//		*vel *= 0.00001;
		totalforce = new ofxVec2f();
		radius = RADIUS;
		scaleFactor = 1.0;
		coinyness = 0.0;
		alpha = 1.0;
		blessed = false;
		position->x = xPosition;
		position->y = yPosition;
		spawnTime = timeInterval;
		random = ofRandom(0, 1.0);
		
		pop = new ofSoundPlayer();
		popPlayed = false;
		//pop->loadSound("lemmings/pop/" + ofToString(round(random*69)+1,0) + ".aif");
		pop->loadSound("lemmings/fx/" + ofToString(round(ofRandom(0, 1)*15)+1,0) + ".wav");
		//pop->loadSound("lemmings/org/DIE.wav");
		
		splat = new ofSoundPlayer();
		splatPlayed = false;
		splat->loadSound("lemmings/splat/" + ofToString(round(random*104)+1,0) + ".aif");
		
	}
	
	return self;
}

-(void) dealloc {
	delete position;
	delete vel;
	delete totalforce;
	delete pop;
	delete splat;
	[super dealloc];
}

-(bool) isAlive{
	return (splatTime < 0 && deathTime < 0);
}

-(void) draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	
	ofColor theColor = ofGetStyle().color;
	
	ofPushStyle();
	ofEnableAlphaBlending();
	
	theColor.a *= alpha;
	
	float computedAlpha = [[GetPlugin(Lemmings) alpha] floatValue]*alpha;
	
	NSColor * playerColor = [NSColor orangeColor];// [GetPlugin(Players) playerColor:1];
	
	if(splatTime > 0){
		float timeScale = ((timeInterval-splatTime)/SPLAT_DURATION);
		ofPushStyle();
		ofSetColor(215, 221, 248, 127.0*sinf((0.5*timeScale)+2.0)*computedAlpha);
		ofEllipse(position->x, position->y+(radius*0.5)+(sinf(timeScale*50.0)*0.01*(1.0-timeScale))+(radius*0.5*timeScale), ((radius*1.25)-(radius*((4.0*timeScale)+(SPLAT_DURATION/2.0)))), (radius*0.75)-(0.5*radius*timeScale));
		ofSetColor(215, 221, 248, 127.0*sinf((0.5*timeScale)+2.0)*computedAlpha);
		ofEllipse(position->x, position->y+radius, ((radius*1.25)+(radius*((2.0*timeScale)+(SPLAT_DURATION/2.0)))), (radius*0.5)+(0.5*radius*timeScale));
		ofSetColor(215, 221, 248, 255.0*(1.0-(fmaxf(0,timeScale-0.5)*2.0))*computedAlpha);
		ofEllipse(position->x+(0.25*radius), position->y+(radius*2.5*timeScale)+(radius*0.75)+(random*radius*0.5), (radius)-(radius*timeScale*0.5),(radius*0.5)+(ofClamp(random, 0.25, 0.75)*radius*((0.5*timeScale)+(SPLAT_DURATION/2.0))));
		ofEllipse(position->x-(0.25*radius), position->y+(radius*3.0*timeScale)+(radius*0.5)-(random*radius*0.5), (radius*0.5)-(radius*timeScale*0.5),(radius*0.5)+(ofClamp(random, 0.25, 0.75)*radius*((0.5*timeScale)+(SPLAT_DURATION/2.0))));
		ofEllipse(position->x, position->y+(radius*0.5*timeScale)+(radius*0.5), (radius*0.5)-(radius*timeScale*0.5),(radius*0.5)+(ofClamp(random, 0.25, 0.75)*radius*((0.5*timeScale)+(SPLAT_DURATION/2.0))));
		ofPopStyle();
	} else if (deathTime > 0) {
		ofPushStyle();
		float timeScale = ((timeInterval-deathTime)/DEATH_DURATION)*(1.0+(random*2.0));
		glPushMatrix();{
			
			
			if(timeScale > 0.5 && timeScale <= 1.0){
				
				//if(!popPlayed){
				//	pop->setSpeed(ofRandom(0.66, 1.0));
				//	pop->setVolume((1.0-fmodf(random*23565.3,0.5)));
				//	pop->play();
				//	popPlayed = true;
				//}
				
				timeScale = (timeScale-0.5)*(1.0/0.5);
				
				ofSetColor(theColor.r, theColor.g, theColor.b, 255*computedAlpha);// (1.0-((timeScale-0.5)*2.0))*computedAlpha*255.0);
				
				glPushMatrix();{
					glTranslated(position->x, position->y, 0);
					for (int i=0; i< 10; i++) {
						glRotatef(((random+i)*233), 0,0,1);
						ofCircle(0, (1.0-random)*timeScale*radius*2.0*i, (1.0-timeScale)*radius*0.5);
					}
				}glPopMatrix();
				
				if(timeScale < 0.2){
					ofSetColor(255.0-theColor.r, (255.0-theColor.g)*(fmodf(random*2356345.0,1.0)), theColor.b, (1.0-((timeScale-0.5)*2.0))*computedAlpha*255.0);
					float rectWidth = (radius*scaleFactor)*(sin(timeScale*PI*5.0)*1.5);
					ofCircle(position->x, position->y, rectWidth);
				}
				
				
				
			} else if (timeScale <= 1.0){
				ofCircle(position->x+ofRandom(0, timeScale*radius*scaleFactor), position->y+ofRandom(0, timeScale*radius*scaleFactor), radius*scaleFactor);
			
				if(timeScale > 0.2){
					if(!splatPlayed){
						//splat->loadSound("lemmings/org/OHNO.wav");
						//splat->setVolume((0.5-fmodf(random*23565.3,0.1)));
						//splat->play();
						//splatPlayed = true;
					}
				}
				
			
			}
			
		}glPopMatrix();
		ofPopStyle();
	} else {
		glPushMatrix();{
			if (blessed && vel->y > 0.02) {
				glPushMatrix();{
					ofPushStyle();
					ofSetColor([playerColor redComponent]*255.0, [playerColor redComponent]*255.0, [playerColor redComponent]*255.0,255*computedAlpha);
					//ofCircle(position->x, position->y-(radius*7.5*vel->y), (vel->y*0.27)+(radius*0.33));
					glTranslated(position->x, position->y, 0);
					glRotatef((atan2(-vel->y, -vel->x)*20)+40, 0, 0, 1);
					glTranslated(-position->x, -position->y, 0);
					[GetPlugin(Lemmings) parachuteImage]->draw(position->x-((vel->y*0.33)+(radius*0.33)), (position->y-((vel->y*0.33)+(radius*0.33)))-(radius*15.0*vel->y), ((vel->y*0.33)+(radius*0.33))*2, ((vel->y*0.33)+(radius*0.33))*2);
					ofPopStyle();
				}glPopMatrix();
			}
			/**
			 glTranslated(position->x, position->y, 0);
			 glRotatef(atan2(-vel->y, vel->x), 0, 0, 1);
			 glTranslated(-position->x, -position->y, 0);
			 **/
			ofSetColor((theColor.r*(1.0-coinyness))+(coinyness*ofRandom(200, 220)), 
					   (theColor.g*(1.0-coinyness))+(coinyness*ofRandom(127, 200)), 
					   (theColor.b*(1.0-coinyness))+(coinyness*ofRandom(0, 127)),
					   theColor.a);
			ofCircle(position->x, position->y, (radius*scaleFactor)+[GetPlugin(Lemmings) getLemmingsSizeAsFloat]);
			//ofEllipse(position->x, position->y, radius/*-(0.001*vel->length()*[GetPlugin(Lemmings) getScreenGravityAsFloat])*/, (0.015*vel->length()*[GetPlugin(Lemmings) getScreenGravityAsFloat])+radius);
		}glPopMatrix();
		//ofCircle(position->x, position->y, radius);
	}
	ofPopStyle();
	
	
}

-(void) collision:(CFTimeInterval)timeInterval{
	if(vel->length() > [GetPlugin(Lemmings) getScreenSplatVelocityAsFloat] && [self isAlive] && (!blessed)){
		vel->set(0,0);
		splatTime = timeInterval;
		if(!splatPlayed){
			//	splat->play();
			splatPlayed = true;
		}
	}
	if(blessed){
		vel->y = 0;
		blessed = false;
	}
}

@end

@implementation ScreenElement
@synthesize position, size, active;

-(id) initWithX:(float)xPosition Y:(float)yPosition size:(float)aSize{
	
	if ([super init]){
		size = aSize;
		position = new ofxVec2f();
		position->x = xPosition;
		position->y = yPosition;
		active = true;
	}
	return self;
	
}

-(void) draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	if([self active]){
		ofSetColor(215, 221, 248, 255.0*[GetPlugin(Lemmings) getScreenElementsAlphaAsFloat]*[[GetPlugin(Lemmings) alpha] floatValue]);
	} else {
		ofSetColor(48, 48, 48, 255.0*[GetPlugin(Lemmings) getScreenElementsAlphaAsFloat]*[[GetPlugin(Lemmings) alpha] floatValue]);
	}
	ofRect(position->x, position->y, size, 0.03);
}

@end