#include "ProjectionSurfaces.h"
#include "Tracking.h"
#include "Arkade.h"
#include "Stregkode.h"
#include "lineIntersection.h"
#include "Midi.h"
#include "Players.h"

double Angle2D(double x1, double y1, double x2, double y2)
{
	double dtheta,theta1,theta2;
	
	theta1 = atan2(y1,x1);
	theta2 = atan2(y2,x2);
	dtheta = theta2 - theta1;
	while (dtheta > PI)
		dtheta -= TWO_PI;
	while (dtheta < -PI)
		dtheta += TWO_PI;
	
	return(dtheta);
}

bool InsidePolygon(vector<ofxPoint2f> polygon,ofPoint p)
{
	int i;
	double angle=0;
	ofPoint p1,p2;
	int n= polygon.size();
	
	for (i=0;i<polygon.size();i++) {
		p1.x = polygon[i].x - p.x;
		p1.y = polygon[i].y - p.y;
		p2.x = polygon[(i+1)%n].x - p.x;
		p2.y = polygon[(i+1)%n].y - p.y;
		angle += Angle2D(p1.x,p1.y,p2.x,p2.y);
	}
	
	if (ABS(angle) < PI)
		return(FALSE);
	else
		return(TRUE);
}

@implementation Alien

-(void) draw{
	//	cout<<(int(ofGetElapsedTimeMillis()/1000.0) % 100)<<endl;
	if((int(ofGetElapsedTimeMillis()/1000.0) % 100) % 2 == 0){
		images[type*2]->draw(position->x, position->y+0.1, 0.2, 0.2);
	} else {
		images[type*2+1]->draw(position->x, position->y+0.1, 0.2, 0.2);
	}
}

@end


@implementation Rocket

-(id) initAtPosition:(ofxVec2f)position arkade:(Arkade*)ark{
	if([super init]){
		wallPosition = new ofxVec2f(position);
		wallVel = new ofxVec2f(0,1);
		onWall = YES;
		arkade = ark;
		age = 0;
		explodeAge = ofRandom(10, 100);
		wallRotation = new ofxVec2f(ofRandom(-0.1, 0.1), 0);
		dead = false;
		totalForce = new ofxVec2f();
		floorPosition = new ofxVec2f();
		floorVel = new ofxVec2f();
	}
	
	return self;
}

-(void) dealloc {
	delete wallPosition;
	delete wallVel;
	delete wallRotation;
	if(floorPosition)
		delete floorPosition;
	if(floorVel)
		delete floorVel;
	if(totalForce)
		delete totalForce;
	[super dealloc];
}

-(void) update:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	if(!dead){
		totalForce->set(0,0);
		age ++;
		if(onWall){
			*wallVel += *wallRotation;
			
			*wallPosition += 1.0/ofGetFrameRate() * *wallVel * 1.0/WallScaling;
			
			if(wallPosition->y > 1){
				onWall = NO;
				
				ofxVec2f p = [GetPlugin(ProjectionSurfaces) convertPoint:*wallPosition toProjection:"Front" fromSurface:"Backwall"];
				p = [GetPlugin(ProjectionSurfaces) convertPoint:p fromProjection:"Front" toSurface:"Floor"];
				floorPosition->set(p);
				
				ofxVec2f bottom1 = [GetPlugin(ProjectionSurfaces) convertPoint:[GetPlugin(ProjectionSurfaces) convertPoint:ofxVec2f(0,1) toProjection:"Front" fromSurface:"Backwall"] fromProjection:"Front" toSurface:"Floor"];
				ofxVec2f bottom2 = [GetPlugin(ProjectionSurfaces) convertPoint:[GetPlugin(ProjectionSurfaces) convertPoint:ofxVec2f([GetPlugin(ProjectionSurfaces) getAspectForProjection:"Front" surface:"Backwall"],1) toProjection:"Front" fromSurface:"Backwall"] fromProjection:"Front" toSurface:"Floor"];
				
				ofxVec2f bottom = bottom2-bottom1;
				
				ofxVec2f hat = ofxVec2f(-bottom.y, bottom.x).normalized();
				
				floorVel->set(hat * wallVel->length());
				
				floorVel->rotate(-wallVel->angle(ofxVec2f(0,1)));
			}
		} else {
			
			*totalForce += (ofxVec2f(0.5,0.5) - *floorPosition).normalized() * 0.03;
			if(age < explodeAge){
				for(int i=0;i<arkade->outerWall.size();i++){
					float distConstant = ofRandom(0.14, 0.25);
					float dist = arkade->outerWall[i].distance(*floorPosition);
					if(dist < distConstant){
						*totalForce += (ofxVec2f(arkade->outerWall[i] - *floorPosition)).normalized() * (dist - distConstant)*0.5;
						
					}
				}
			}
			
			*floorVel *= 0.998;
			*floorVel += *totalForce;
			
			
			
			
			*floorPosition += 1.0/ofGetFrameRate() * *floorVel;
			
			
			for(int i=0;i<arkade->outerWall.size();i++){
				float distConstant = 0.07;
				float dist = arkade->outerWall[i].distance(*floorPosition);
				if(dist < distConstant){
					/*if(ofRandom(0, 1) < 0.3){
						for(int j=0;j<arkade->wallPoints.size();j++){
							if(arkade->wallPoints[j].distance(arkade->outerWall[i]) < 0.03){
								arkade->wallPoints.erase(arkade->wallPoints.begin()+j);
							}
						}
						[arkade calculateOuterWall];
					}*/
					dead = true;
				}
			}
			/*
			 if(InsidePolygon(arkade->outerWall, *floorPosition)){
			 
			 }*/
		}
	}
}

-(void) draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime surf:(int)s{
	if(!dead){
		if(onWall && s == 1){
			[GetPlugin(ProjectionSurfaces) apply:"Front" surface:"Backwall"];{
				
				glPushMatrix();{
					glTranslated(wallPosition->x, wallPosition->y, 0);
					glRotated(ofxVec2f(1,0).angle(*wallVel), 0, 0, 1);
					glScaled(1.0/WallScaling, 1.0/WallScaling, 1);	
					[self drawRocket];
					
					
				} glPopMatrix();
			} glPopMatrix();
			
		}	else if(s == 0){
			[GetPlugin(ProjectionSurfaces) apply:"Front" surface:"Floor"];{
				glPushMatrix();{
					glTranslated(floorPosition->x, floorPosition->y, 0);
					glRotated(ofxVec2f(1,0).angle(*floorVel), 0, 0, 1);
					[self drawRocket];
					
				} glPopMatrix();
			} glPopMatrix();
			
			
			[GetPlugin(ProjectionSurfaces) apply:"Back" surface:"Floor"];{
				glPushMatrix();{
					glTranslated(floorPosition->x, floorPosition->y, 0);
					glRotated(ofxVec2f(1,0).angle(*floorVel), 0, 0, 1);
					
					
					[self drawRocket];
					
				}glPopMatrix();
			}glPopMatrix();
		}	
		
	}
}

-(void) drawRocket{
	glScaled(0.5, 0.5, 1);
	ofSetColor(255, 255, 200, 255);
	ofRect(-0.05, -0.02, 0.1, 0.04);
	ofTriangle(0.05, -0.02, 0.07, 0, 0.05, 0.02);
	
	int red = ofRandom(100, 255);
	ofSetColor(red, ofRandom(0, red), 0);
	ofRect(-0.05, 0.02, ofRandom(-0.04, -0.06), -0.04);
}



@end



@implementation Arkade



-(void) initPlugin{
	for(int i=0;i<FLOORGRIDSIZE*FLOORGRIDSIZE;i++){
		floorSquaresOpacity[i] = 0;
	}
	[self resetScene];
	
}

-(void) setup{
	pongWallSound = new ofSoundPlayer();
	pongWallSound->loadSound("pongWallSound.aif");
	
	personFilterX = new Filter();	
	personFilterX->setNl(9.413137469932821686e-04, 2.823941240979846506e-03, 2.823941240979846506e-03, 9.413137469932821686e-04);
	personFilterX->setDl(1, -2.5818614306773719263, 2.2466666427559748864, -.65727470210265670262);
	
	personFilterY = new Filter();	
	personFilterY->setNl(9.413137469932821686e-04, 2.823941240979846506e-03, 2.823941240979846506e-03, 9.413137469932821686e-04);
	personFilterY->setDl(1, -2.5818614306773719263, 2.2466666427559748864, -.65727470210265670262);
	
	personPosition = new ofxPoint2f(0,0);
	
	doReset = false;
	
	[self resetScene];
	
	aliens = [[NSMutableArray array] retain];
	images[0] = new ofImage();
	images[0]->loadImage("spaceinvaders/space-11.png");
	images[1] = new ofImage();
	images[1]->loadImage("spaceinvaders/space-12.png");
	images[2] = new ofImage();
	images[2]->loadImage("spaceinvaders/space-21.png");
	images[3] = new ofImage();
	images[3]->loadImage("spaceinvaders/space-22.png");
	images[4] = new ofImage();
	images[4]->loadImage("spaceinvaders/space-31.png");
	images[5] = new ofImage();
	images[5]->loadImage("spaceinvaders/space-32.png");
	
	for(int i=0;i<4;i++){
		Alien * newAlien = [[Alien alloc] init];
		newAlien->images = images;
		newAlien->position = new ofxPoint2f(i/4.0,0);
		newAlien->type = 1;
		[aliens addObject:newAlien];
	}	
	for(int i=0;i<4;i++){
		Alien * newAlien = [[Alien alloc] init];
		newAlien->images = images;
		newAlien->position = new ofxPoint2f(i/4.0,1/4.0);
		newAlien->type = 0;
		[aliens addObject:newAlien];
	}	
	
	for(int i=0;i<4;i++){
		Alien * newAlien = [[Alien alloc] init];
		newAlien->images = images;
		newAlien->position = new ofxPoint2f(i/4.0,2/4.0);
		newAlien->type = 2;
		[aliens addObject:newAlien];
	}	

	
	
	rockets = [[NSMutableArray array] retain];
	
	blur = new shaderBlur();
	blur->setup(800, 800);
	
	
}

-(IBAction) reset:(id)sender{
	doReset = true;
}

-(void) resetScene{
	cookiesRemoveFactor = 0;
	
	ballPosition = new ofxPoint2f(0.2,0.2);
	ballDir = new ofxVec2f(00,1);
	
	pacmanPosition = new ofxPoint2f(-0.2,0.5);
	pacmanDir = new ofxVec2f(1,0);
	pacmanMouthValue = 0;
	pacmanMouthDir = 1;
	
	pongWallSound = new ofSoundPlayer();
	pongWallSound->loadSound("pongWallSound.aif");
	
	pacmanEntering = true;
	
	redChoisePosition = new ofxPoint2f(-1,-1);
	blueChoisePosition = new ofxPoint2f(-1,-1);
	choisesSize = 0;
	makeChoises = false;
	
	terminatorMode = false;
	blueScaleFactor = 1.0;
	blobLightFactor = 0;
	
	pacmanDieFactor = 0;
	
	cookies.clear();
	cookiesFadeIn.clear();
	spaceInvadersPosition = new ofxPoint2f(0,0);
	wallPoints.clear();
	
	[floorSquaresButton setState:NSOffState];
	[pacmanButton setState:NSOffState];
	[ballUpdateButton setState:NSOffState];
	[ballDrawButton setState:NSOffState];
	[leaveCookiesButton setState:NSOffState];
	
	[wallBuildSlider setFloatValue:0];
	[wallLockSlider setFloatValue:0];
	resolution = 1.0;
	
	[spaceFadeSlider setFloatValue:0];
	[spaceAlienFadeSlider setFloatValue:0];
	[spaceAutoLaunchSpeedSlider setFloatValue:0];
	[gardenFadeSlider setFloatValue:0];
	
	[spaceAlienFadeOutSlider setFloatValue:0];
	
	[self resetSpaceinvaders:self];
	[self generateWall:self];
	
	[self calculateOuterWall];
	
}

-(void) update:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	
	if([sendMidiGoButton state] == NSOnState){
		[GetPlugin(Midi) sendValue:1 forNote:1 onChannel:1];
	}
	
	if(doReset) {
		
		[self resetScene];
		
		doReset = false;
		
	}
	
	if(pleaseCalculateWall){
		[self calculateOuterWall];	
		pleaseCalculateWall = NO;
	}
	
	if(ofGetFrameRate() > 10){
		//
		//General person position
		//
		PersistentBlob * pblob;
		TrackerObject* t = tracker(0);
		
		for(pblob in [t persistentBlobs]){
			Blob * b;
			for(b in [pblob blobs]){
				ofxPoint2f p = [b getLowestPoint];
				p = ([GetPlugin(ProjectionSurfaces) convertPoint:p fromProjection:"Front" toSurface:"Floor"]);
				personPosition->x = personFilterX->filter(p.x);
				personPosition->y = personFilterY->filter(p.y);
				personPosition->x = personFilterX->filter(p.x);
				personPosition->y = personFilterY->filter(p.y);
				
				break;
			}
			break;
		}
		
		
		//
		//Floor squares
		//
		float w = 1.0/FLOORGRIDSIZE;
		
		
		pongSquareSize = ofClamp(pongSquareSize-0.1,0,1);
		if([floorSquaresButton state] == NSOnState){
			if([moveWithPerson state] == NSOffState){				
				PersistentBlob * pblob;
				TrackerObject* t = tracker(0);
				for(pblob in [t persistentBlobs]){
					Blob * b;
					for(b in [pblob blobs]){
						ofxPoint2f p = [b getLowestPoint];
						p = [GetPlugin(ProjectionSurfaces) convertPoint:p fromProjection:"Front" toSurface:"Floor"];
						floorSquaresOpacity[ [self getIatX:p.x Y:p.y] ] += 0.4;
					}
				}
				
			}else {
				pongSquareSize = ofClamp(0.4+pongSquareSize,0,1);
				
				if([lockToGrid state] == NSOffState){
					delete pongPos;
					pongPos = new ofxVec2f(*personPosition  - ofxPoint2f(w*0.8 , w));
					
				} else {
					ofxPoint2f goal = *personPosition*8;
					goal.x = roundf(goal.x);
					goal.y = roundf(goal.y);
					goal /= 8.0;
					
					
					*pongPos += (goal - *pongPos)*00.1;
				}
			}
		}
		
		if([leaveCookiesFootButton state] == NSOnState){
			Blob * b;
			for(b in [tracker(0) blobs]){
				ofxPoint2f bp = [GetPlugin(ProjectionSurfaces) convertPoint:[b centroid] fromProjection:"Front" toSurface:"Floor"];
				float x = bp.x;
				float y = bp.y;
				
				bool found = false;
				
				for(int c=0;c<cookies.size();c++){
					if(cookies[c].distance(bp) < 0.05 ){
						found = true;
					}
				}
				
				if(!found){
					cookies.push_back(ofPoint(x,y));
					cookiesFadeIn.push_back(0);
				}
			}
		}
		
		for(int c=0;c<cookiesFadeIn.size();c++){
			cookiesFadeIn[c] = ofClamp(cookiesFadeIn[c]+0.1,0,1);
		}
		
		
		
		int i=0;
		for(float y=0;y<1;y+=w){
			for(float x=0;x<1;x+=w){				
				//Leave cookies
				if(floorSquaresOpacity[i] > 0.8 && [leaveCookiesButton state] == NSOnState){
					bool notFound = true;
					for(int c=0;c<cookies.size();c++){
						if(cookies[c].x == x+w*0.5 && cookies[c].y == y+w*0.5){
							notFound = false;
						}
					}
					
					if(notFound){
						cookies.push_back(ofPoint(x+w*0.5,y+w*0.5));
						cookiesFadeIn.push_back(0);
					}
					
				}
				
				floorSquaresOpacity[i] -= 0.1;
				floorSquaresOpacity[i] = ofClamp(floorSquaresOpacity[i], 0, 1);
				
				i++;
			}
		}
		
		//
		//Ball
		//
		if([ballUpdateButton state] == NSOnState){
			*ballPosition += ([ballSpeedSlider floatValue]/100.0) * 1.0/ofGetFrameRate() * *ballDir;
			
			bool intersection = false;
			if(ballPosition->x < 0+0.05*[ballSizeSlider floatValue]/100.0){
				ballDir->x *= -1;
				intersection = true;
				ballPosition->x = 0+0.05*[ballSizeSlider floatValue]/100.0;
			}
			
			if(ballPosition->x > 1-0.05*[ballSizeSlider floatValue]/100.0){
				ballDir->x *= -1;
				intersection = true;
				ballPosition->x = 1-0.05*[ballSizeSlider floatValue]/100.0;
			}
			
			if(ballPosition->y < 0+0.05*[ballSizeSlider floatValue]/100.0){
				ballDir->y *= -1;
				intersection = true;
				ballPosition->y = 0+0.05*[ballSizeSlider floatValue]/100.0;
			}
			
			if(ballPosition->y > 1-0.05*[ballSizeSlider floatValue]/100.0){
				ballDir->y *= -1;
				intersection = true;
				ballPosition->y = 1-0.05*[ballSizeSlider floatValue]/100.0;
			}
			
			if(intersection){
				if(!pongWallSound->getIsPlaying()){
					pongWallSound->setPan(2*ballPosition->x-1);
					pongWallSound->play();
				}
			}	
			
			float r = 0.05*[ballSizeSlider floatValue]/100.0;
			
			float bx = ballPosition->x;
			float by = ballPosition->y;
			int i=0;
			float w = 1.0/FLOORGRIDSIZE;
			
			
			float s = pongSquareSize;	
			
			if(s > 0.01){
				float x = pongPos->x;
				float y = pongPos->y;
				ofxPoint2f points[4];
				points[0] = ofxPoint2f(  x+0.5*w*(1-s)		,	y+0.5*w*(1-s)	) - *ballPosition;
				points[1] = ofxPoint2f(  x+w-0.5*w*(1-s)	,	y+0.5*w*(1-s)	) - *ballPosition;
				points[2] = ofxPoint2f(  x+w-0.5*w*(1-s)	,	y+w-0.5*w*(1-s)	) - *ballPosition;
				points[3] = ofxPoint2f(  x+0.5*w*(1-s)		,	y	+w-0.5*w*(1-s)	) - *ballPosition;
				
				for(int i=0;i<4;i++){
					ofxPoint2f p1, p2;
					switch (i) {
						case 0:
							p1 = points[0];
							p2 = points[1];
							break;
						case 1:
							p1 = points[1];
							p2 = points[2];
							break;
						case 2:
							p1 = points[2];
							p2 = points[3];
							break;
						case 3:
							p1 = points[3];
							p2 = points[0];
							break;
							
						default:
							break;
					}
					float dx, dy;						
					dx = p2.x - p1.x;
					dy = p2.y - p1.y;
					
					float dr = sqrt(dx*dx +dy*dy);
					float D = p1.x*p2.y - p2.x*p1.y;
					
					float sgn = (dy < 0) ? -1.0 : 1.0;
					
					float ix1 = (D*dy + sgn*dx*sqrt(r*r*dr*dr-D*D))/(dr*dr);
					float iy1 = (-D*dx + fabs(dy)*sqrt(r*r*dr*dr-D*D))/(dr*dr);
					
					float ix2 = (D*dy - sgn*dx*sqrt(r*r*dr*dr-D*D))/(dr*dr);
					float iy2 = (-D*dx - fabs(dy)*sqrt(r*r*dr*dr-D*D))/(dr*dr);
					
					float A = r*r*dr*dr-D*D;
					
					//	cout<<A<<"  "<<r<<"  "<<dr<<"  "<<D<<"       "<<(dx*dx )<<endl;
					if(A >= 0){
						
						bool intersection = false;
						if(ix1 >= points[0].x && ix1 <= points[1].x && iy1 >= points[0].y && iy1 <= points[2].y){
							intersection = true;						
						}
						else if(ix2 >= points[0].x && ix2 <= points[1].x && iy2 >= points[0].y && iy2 <= points[2].y){
							intersection = true;
						}
						
						if(intersection){
							float randomF = ofRandom(-5, 5);
							switch (i) {
								case 0:
									ballDir->y = -1;
									break;
								case 1:
									ballDir->x = 1;
									break;
								case 2:
									ballDir->y = 1;
									break;
								case 3:
									ballDir->x = -1;
									break;
									
								default:
									break;
							}
							[GetPlugin(Stregkode) sound]->setPan(2*ballPosition->x-1);
							if(![GetPlugin(Stregkode) sound]->getIsPlaying())
								[GetPlugin(Stregkode) sound]->play();
							
							ballDir->rotate(randomF);
							ballDir->normalize();
							
						}
					}
				}
			}				
			
			
			/*for(float y=0;y<1;y+=w){
			 for(float x=0;x<1;x+=w){				
			 float s = floorSquaresOpacity[i];	
			 if(s > 0.01){
			 ofxPoint2f points[4];
			 points[0] = ofxPoint2f(  x+0.5*w*(1-s)		,	y+0.5*w*(1-s)	) - *ballPosition;
			 points[1] = ofxPoint2f(  x+w-0.5*w*(1-s)	,	y+0.5*w*(1-s)	) - *ballPosition;
			 points[2] = ofxPoint2f(  x+w-0.5*w*(1-s)	,	y+w-0.5*w*(1-s)	) - *ballPosition;
			 points[3] = ofxPoint2f(  x+0.5*w*(1-s)		,	y	+w-0.5*w*(1-s)	) - *ballPosition;
			 
			 for(int i=0;i<4;i++){
			 ofxPoint2f p1, p2;
			 switch (i) {
			 case 0:
			 p1 = points[0];
			 p2 = points[1];
			 break;
			 case 1:
			 p1 = points[1];
			 p2 = points[2];
			 break;
			 case 2:
			 p1 = points[2];
			 p2 = points[3];
			 break;
			 case 3:
			 p1 = points[3];
			 p2 = points[0];
			 break;
			 
			 default:
			 break;
			 }
			 float dx, dy;						
			 dx = p2.x - p1.x;
			 dy = p2.y - p1.y;
			 
			 float dr = sqrt(dx*dx +dy*dy);
			 float D = p1.x*p2.y - p2.x*p1.y;
			 
			 float sgn = (dy < 0) ? -1.0 : 1.0;
			 
			 float ix1 = (D*dy + sgn*dx*sqrt(r*r*dr*dr-D*D))/(dr*dr);
			 float iy1 = (-D*dx + fabs(dy)*sqrt(r*r*dr*dr-D*D))/(dr*dr);
			 
			 float ix2 = (D*dy - sgn*dx*sqrt(r*r*dr*dr-D*D))/(dr*dr);
			 float iy2 = (-D*dx - fabs(dy)*sqrt(r*r*dr*dr-D*D))/(dr*dr);
			 
			 float A = r*r*dr*dr-D*D;
			 
			 //	cout<<A<<"  "<<r<<"  "<<dr<<"  "<<D<<"       "<<(dx*dx )<<endl;
			 if(A >= 0){
			 
			 bool intersection = false;
			 if(ix1 >= points[0].x && ix1 <= points[1].x && iy1 >= points[0].y && iy1 <= points[2].y){
			 intersection = true;						
			 }
			 else if(ix2 >= points[0].x && ix2 <= points[1].x && iy2 >= points[0].y && iy2 <= points[2].y){
			 intersection = true;
			 }
			 
			 if(intersection){
			 float randomF = ofRandom(-5, 5);
			 switch (i) {
			 case 0:
			 ballDir->y = -1;
			 break;
			 case 1:
			 ballDir->x = 1;
			 break;
			 case 2:
			 ballDir->y = 1;
			 break;
			 case 3:
			 ballDir->x = -1;
			 break;
			 
			 default:
			 break;
			 }
			 [GetPlugin(Stregkode) sound]->setPan(ballPosition->x);
			 if(![GetPlugin(Stregkode) sound]->getIsPlaying())
			 [GetPlugin(Stregkode) sound]->play();
			 
			 ballDir->rotate(randomF);
			 ballDir->normalize();
			 
			 }
			 }
			 }
			 
			 
			 
			 }
			 
			 i++;
			 }
			 }*/
			
			
			ballDir->normalize();
			
			lastBallPositions.push_back(*ballPosition);
			while(lastBallPositions.size() > 20){
				lastBallPositions.erase(lastBallPositions.begin());
			}
			
		}
		
		
		
		//
		//Pacman
		//
		/*if(pacmanDieFactor > 0){
		 pacmanMouthValue += pacmanMouthDir*0.02*(1+pacmanDieFactor);
		 if(pacmanMouthValue > 0.3)
		 pacmanMouthDir = -1;
		 else if(pacmanMouthValue < 0){
		 pacmanMouthValue = 0;
		 pacmanMouthDir = 1;
		 }
		 
		 pacmanDir->rotate(pacmanDieFactor*30.0 * 60.0/ofGetFrameRate());
		 
		 
		 } else */
		if((cookies.size() > 0 && [pacmanButton state] == NSOnState) || [ballUpdateButton state] == NSOnState || terminatorMode){
			int nearestCookie = -1;
			for(int i=0;i<cookies.size();i++){
				if(nearestCookie == -1 || cookies[i].distance(*pacmanPosition) < cookies[nearestCookie].distance(*pacmanPosition)){
					nearestCookie = i;
				} else if( cookies[i].distance(*pacmanPosition) == cookies[nearestCookie].distance(*pacmanPosition)){
					float a1 = ((ofxVec2f)(cookies[i] - *pacmanPosition)).angle(*pacmanDir);
					float a2 = ((ofxVec2f)(cookies[nearestCookie] - *pacmanPosition)).angle(*pacmanDir);
					if(fabs(a1) > fabs(a2)){
						nearestCookie = i;
					}
				}
			}
			
			if(nearestCookie != -1 || [ballUpdateButton state] == NSOnState || terminatorMode){
				float a;	
				if(terminatorMode){
					a = ((ofxVec2f)(*pacmanPosition-ofxVec2f(-1,0.5))).angle(-*pacmanDir);						
				} else if([ballUpdateButton state] != NSOnState){
					a = ((ofxVec2f)(*pacmanPosition-cookies[nearestCookie])).angle(-*pacmanDir);	
				} else {
					a = ((ofxVec2f)(*pacmanPosition-*ballPosition)).angle(-*pacmanDir);	
					if(pacmanPosition->distance(*ballPosition) < 0.02){
						[sendMidiGoButton setState:NSOnState];
						[ballUpdateButton setState:NSOffState];
						[ballDrawButton setState:NSOffState];
					}
				}
				
				if([pacmanButton state] == NSOnState){
					pacmanDir->rotate( -a * 0.08* [pacmanSpeedSlider floatValue] / 5.0 * 60.0/ofGetFrameRate());
					*pacmanPosition += pacmanDir->normalized() * [pacmanSpeedSlider floatValue]*0.001 * 30.0/ofGetFrameRate();
					
					if(pacmanPosition->x > 0)
						pacmanEntering = false;
					
					if(!pacmanEntering && !terminatorMode){
						pacmanPosition->x = ofClamp(pacmanPosition->x, 0, 1);
						pacmanPosition->y = ofClamp(pacmanPosition->y, 0, 1);
					}
				}
				
				pacmanMouthValue += pacmanMouthDir*0.02;
				if(pacmanMouthValue > 0.3)
					pacmanMouthDir = -1;
				else if(pacmanMouthValue < 0){
					pacmanMouthValue = 0;
					pacmanMouthDir = 1;
				}
				
				
				if(nearestCookie != -1 && pacmanPosition->distance(cookies[nearestCookie]) < 0.02){
					cookies.erase(cookies.begin()+nearestCookie);
					cookiesFadeIn.erase(cookiesFadeIn.begin()+nearestCookie);
				}
			}
		}
		
		
		//
		//Choises
		//
		if(makeChoises){
			if(choisesSize == 0){
				delete redChoisePosition;
				redChoisePosition = new ofxVec2f(*personPosition*FLOORGRIDSIZE + ofxPoint2f(0,1));
				delete blueChoisePosition;
				blueChoisePosition = new ofxVec2f(*personPosition*FLOORGRIDSIZE - ofxPoint2f(1,0));
			}
			choisesSize += 0.1;
			choisesSize = ofClamp(choisesSize, 0, 1);		
		}
		
		
		//
		//Terminator
		//
		if(terminatorMode){
			makeChoises = false;
			choisesSize -= 0.1;
			
			lightRotation += [terminatorLightSpeedSlider floatValue]/10.0 * 30.0/ofGetFrameRate();
			if(lightRotation > 360)
				lightRotation -= 360;
			
			blobLightFactor -= [terminatorBlobLightSpeedSlider floatValue]/200.0 * 30.0/ofGetFrameRate();
			if(blobLightFactor < 0){
				blobLightFactor = 1.0;
			}
			
			cookiesRemoveFactor = ofClamp(cookiesRemoveFactor+0.1, 0, 1);
			
			pacmanDieFactor = ofClamp(pacmanDieFactor+0.002, 0, 1);
			
			if(personPosition->distance(*pacmanPosition) < 0.02 || pacmanPosition->x < -0.1){
				[pacmanButton setState:NSOffState];
			}
		}
		
		
		//
		//WALL
		//
		
		/*for(int i=0;i<wallPoints.size();i++){
		 if(wallPoints[i].distance(*personPosition) < 0.05){
		 wallPoints.erase(wallPoints.begin()+i);
		 }
		 }*/
		
		//
		//Rockets
		//
		Rocket * r;
		for(r in rockets){
			[r update:timeInterval displayTime:outputTime];
		}
		
		
		//
		//Space invaders
		//
		timeSinceLastLaunch += 60.0/ofGetFrameRate();
		if([spaceAutoLaunchSpeedSlider floatValue] > 0){
			if(100.0-[spaceAutoLaunchSpeedSlider floatValue] < timeSinceLastLaunch){
				[self spawnRocket:self];
			}
		}
		
		if([spaceSpeedSlider floatValue] > 0){
			*spaceInvadersPosition += ofxPoint2f(spaceInvadersDir,0)*[spaceSpeedSlider floatValue]/100.0 * 60.0/ofGetFrameRate();
			if(spaceInvadersPosition->x > 2*[GetPlugin(ProjectionSurfaces) getAspectForProjection:"Front" surface:"Backwall"]){
				spaceInvadersPosition->y += spaceInvadersYDir;
				spaceInvadersDir = -1;
			} else if(spaceInvadersPosition->x < 0){
				spaceInvadersDir = 1;
				spaceInvadersPosition->y += spaceInvadersYDir;
			}
			
			if(spaceInvadersPosition->y > 1){
				spaceInvadersYDir = -1;
			} else if(spaceInvadersPosition->y < 0){
				spaceInvadersYDir = 1;
			}
		}
	}
}

-(void) draw:(int)side{
	
	ofSetColor(255, 255, 255,255);
	ofFill();
	float w = 1.0/FLOORGRIDSIZE;
	
	
	//
	//Cookies
	//
	
	if(cookiesRemoveFactor < 1 && [gardenFadeSlider floatValue] < 99){
		glPopMatrix();
		
		
		blur->beginRender();
		blur->setupRenderWindow();		
		for(int c=0;c<cookies.size();c++){	
			ofSetColor(155.0*(1-cookiesRemoveFactor), 0*(1-cookiesRemoveFactor), 255.0*(1-cookiesRemoveFactor), cookiesFadeIn[c]*255);

			ofEllipse(cookies[c].x, cookies[c].y, 0.03 + (1-cookiesFadeIn[c])*0.1, 0.03+ (1-cookiesFadeIn[c])*0.1);		
		}		
		blur->endRender();
		//		blur->blur(2, cookiesRemoveFactor*3.0);		
		glViewport(0,0,ofGetWidth(),ofGetHeight());	
		ofSetupScreen();
		glScaled(ofGetWidth(), ofGetHeight(), 1);
		ofEnableAlphaBlending();
		glBlendFunc(GL_SRC_ALPHA, GL_ONE);		
		
		if(side == 0){
			[GetPlugin(ProjectionSurfaces) apply:"Front" surface:"Floor"];	
		} else {
			[GetPlugin(ProjectionSurfaces) apply:"Back" surface:"Floor"];		
		}
		
		blur->draw(0, 0, 1, 1, true);
		
	}
	
	
	
	//
	//White floor square
	//
	
	ofSetColor(255*[alpha floatValue], 255*[alpha floatValue], 255*[alpha floatValue],255);
	int i=0;
	for(float y=0;y<1;y+=w){
		for(float x=0;x<1;x+=w){				
			float s = floorSquaresOpacity[i];				
			ofRect(x+0.5*w*(1-s),y+0.5*w*(1-s),w*(s) , w*(s));
			i++;
		}
	}
	
	if(pongSquareSize > 0){
		ofRect(pongPos->x+0.5*w*(1-pongSquareSize),pongPos->y+0.5*w*(1-pongSquareSize),w*(pongSquareSize) , w*(pongSquareSize));
		
	}
	
	
	
	
	//
	//Choises
	//
	
	
	if(choisesSize > 0){
		ofSetColor(255, 0, 0);
		ofxPoint2f p;
		p.x = floor(redChoisePosition->x)/(float)FLOORGRIDSIZE;
		p.y = floor(redChoisePosition->y)/(float)FLOORGRIDSIZE;
		ofRect(p.x+0.5*w*(1-choisesSize),p.y+0.5*w*(1-choisesSize),w*(choisesSize) , w*(choisesSize));
		
		ofSetColor(0, 0, 255);		
		p.x = floor(blueChoisePosition->x)/(float)FLOORGRIDSIZE;
		p.y = floor(blueChoisePosition->y)/(float)FLOORGRIDSIZE;
		ofRect(
			   ofClamp(p.x+0.5*w*(1-choisesSize*blueScaleFactor),0,1),
			   ofClamp(p.y+0.5*w*(1-choisesSize*blueScaleFactor), 0, 1),
			   ofClamp(w*(choisesSize*blueScaleFactor), 0 , 1) , 
			   ofClamp(w*(choisesSize*blueScaleFactor), 0,1) );
		
	}
	
	
	
	//
	//Ball
	//
	if([ballDrawButton state] == NSOnState){
		ofSetColor(255, 255, 255);
		ofCircle(ballPosition->x, ballPosition->y, 0.05*[ballSizeSlider floatValue]/100.0);
	}
	
	//
	//Pacman
	//
	
	if([pacmanButton state] == NSOnState){
		/*	float r = MAX(255-4.0*pacmanDieFactor*255.0 ,0);
		 float g = MIN(MAX(2*255-2.0*pacmanDieFactor*255.0 ,0), 255);
		 float b = MIN(255.0*pacmanDieFactor*2, 255)   -    MAX(pacmanDieFactor*2-1, 0)*255.0;
		 */	
		
		float r = 255;
		float g = 255;
		float b = 0;
		
		ofSetColor(r, g, b);
		int k = 0;
		float circlePtsScaled[OF_MAX_CIRCLE_PTS*2];
		int numCirclePts = 100;
		int start = pacmanMouthValue*numCirclePts/2.0;
		int stop = numCirclePts-start;
		
		glPushMatrix();{
			glTranslated(pacmanPosition->x ,  pacmanPosition->y, 0);
			glRotated(-pacmanDir->angle(ofxVec2f(1,0)), 0, 0, 1);
			glBegin(GL_TRIANGLE_FAN);
			glVertex2f(0 , 0);
			
			for(int i = start; i < stop; i++){
				float a = TWO_PI*(float)i/numCirclePts;
				glVertex2f(cos(a) * 0.08  * 0.5,sin(a) * 0.08 * 0.5);
			}
			
			glEnd();
			
		}glPopMatrix();
		
		ofEnableAlphaBlending();
		ofSetColor(0, 0, 0, 255);
		ofRect(0, 0, -2, 1);
		
		//ofEllipse(pacmanPosition->x, pacmanPosition->y, 0.08, 0.08);
	}
	
	
	
	
	//
	//Wall
	//
	float sides[4];
	for(int i=0;i<4;i++){
		sides[i] = ofClamp(4.0*[wallBuildSlider floatValue]/100.0 - i, 0 , 1);
		sides[i] = sides[i] * (FLOORGRIDSIZE-1);
	}
	float sidesLock[4];
	for(int i=0;i<4;i++){
		sidesLock[i] = ofClamp(4.0*[wallLockSlider floatValue]/100.0 - i, 0 , 1);
		sidesLock[i] = sidesLock[i] * (FLOORGRIDSIZE-1);
	}
	
	ofDisableAlphaBlending();
	for(int u=0;u<4;u++){
		if( (u > 1 && side == 0) || (u < 2 && side == 1)){
			
			for(int i=0;i<FLOORGRIDSIZE-1;i++){
				float s = ofClamp(sides[u]-i, 0,1);				
				float c = ofClamp(sidesLock[u]-i, 0,1)*[alpha floatValue];				
				ofSetColor(255, 255*c, 255*c,255);
				float x,y;
				switch (u) {
					case 0:
						x = 0;
						y = (float)(FLOORGRIDSIZE-1- i)*w;
						ofRect(x+0.5*w*(1-s),y+0.5*w*(1-s),w*(s) , w*(s));					
						break;
					case 1:
						x = (float)(i)*w;
						y = 0;
						ofRect(x+0.5*w*(1-s),y+0.5*w*(1-s),w*(s) , w*(s));
						
						break;
					case 2:
						x = 1-w;
						y = (float)(i)*w;
						ofRect(x+0.5*w*(1-s),y+0.5*w*(1-s),w*(s) , w*(s));
						
						break;
					case 3:
						x = (float)(FLOORGRIDSIZE-1-i)*w;
						y = 1-w;
						ofRect(x+0.5*w*(1-s),y+0.5*w*(1-s),w*(s) , w*(s));
						break;
				}
			}
		}
		
	}
	
	//
	//Garden
	//
	if([gardenFadeSlider floatValue] > 0){
		ofEnableAlphaBlending();
		
		NSColor * c = [GetPlugin(Players) playerColor:2];
		ofSetColor([c redComponent]*255, [c greenComponent]*255, [c blueComponent]*255, 255*[gardenFadeSlider floatValue]*0.01);
		ofBeginShape();
		
		for(int i=innerWall.size()-1;i>=0;i--){
			ofVertex(innerWall[i].x, innerWall[i].y);
		}
		ofEndShape();
		
		
		ofSetColor(255, 255, 255,255*[spaceFadeSlider floatValue]/100.0);
		
		if(outerWall.size() > 0){
			ofBeginShape();
			for(int i=0;i<outerWall.size();i++){
				ofVertex(outerWall[i].x, outerWall[i].y);
			}
			ofVertex(outerWall[0].x, outerWall[0].y);
			for(int i=innerWall.size()-1;i>=0;i--){
				ofVertex(innerWall[i].x, innerWall[i].y);
			}
			ofVertex(innerWall[innerWall.size()-1].x, innerWall[innerWall.size()-1].y);
			
			ofEndShape(true);	
		}
	}
	
	
	
	
	
	
	
	//
	//Terminator mode
	//
	ofEnableAlphaBlending();
	if(terminatorMode){
		ofxPoint2f center = *personPosition;
		ofxVec2f dir = ofxVec2f(1,0);
		ofxVec2f hat = ofxVec2f(0,1);
		dir.rotate(lightRotation);
		hat.rotate(lightRotation);
		
		float v = 0.25;
		
		ofxPoint2f points[4];
		
		points[0] = center+dir+hat*v;
		points[1] = center+dir-hat*v;
		
		points[2] = center-dir+hat*v;
		points[3] = center-dir-hat*v;
		
		
		for(int i=0;i<4;i++){
			//Find intersection with border
			double x,y;
			if(lineSegmentIntersection(points[i].x, points[i].y, center.x, center.y, 0, 0, 1, 0, &x, &y)){
				points[i].x = x;
				points[i].y = y;
			}
			if(lineSegmentIntersection(points[i].x, points[i].y, center.x, center.y, 1, 0, 1, 1, &x, &y)){
				points[i].x = x;
				points[i].y = y;
			}
			if(lineSegmentIntersection(points[i].x, points[i].y, center.x, center.y, 1, 1, 0, 1, &x, &y)){
				points[i].x = x;
				points[i].y = y;
			}
			if(lineSegmentIntersection(points[i].x, points[i].y, center.x, center.y, 0, 1, 0, 0, &x, &y)){
				points[i].x = x;
				points[i].y = y;
			}
		}
		
		ofxPoint2f cornerPoint[2];
		cornerPoint[0] = points[0];
		cornerPoint[1] = points[2];
		
		for(int i=0;i<2;i++){
			if(fabs(points[i*2].x - points[i*2+1].x) > 0.005 && fabs(points[i*2].y - points[i*2+1].y) > 0.005){
				if(points[i*2].x > 0.5){
					cornerPoint[i].x = 1;
				} else {
					cornerPoint[i].x = 0;	
				}
				if(points[i*2].y > 0.5){
					cornerPoint[i].y = 1;
				} else {
					cornerPoint[i].y = 0;	
				}
			}
		}
		
		
		
		ofSetColor(0, 0, 255,[terminatorLightFadeSlider floatValue]*2.5);
		glBegin(GL_POLYGON);
		glVertex2f(center.x, center.y);
		glVertex2f(points[0].x, points[0].y);
		glVertex2f(cornerPoint[0].x, cornerPoint[0].y);
		glVertex2f(points[1].x, points[1].y);
		glEnd();
		
		glBegin(GL_POLYGON);
		glVertex2f(center.x, center.y);
		glVertex2f(points[2].x, points[2].y);
		glVertex2f(cornerPoint[1].x, cornerPoint[1].y);
		glVertex2f(points[3].x, points[3].y);
		glEnd();	
		
		
		
		glPopMatrix();
		
		ofEnableAlphaBlending();
		glBlendFunc(GL_SRC_ALPHA, GL_ONE);
		
		blur->beginRender();
		blur->setupRenderWindow();
		
		//Blob light
		PersistentBlob * pblob;
		for(pblob in [tracker(0) persistentBlobs]){
			Blob * blob;
			for(blob in [pblob blobs]){
				ofSetColor(255, 255, 255, 2.5*blobLightFactor*[terminatorBlobLightFadeSlider floatValue]);
				ofBeginShape();
				for(int i=0;i<[blob nPts];i++){
					ofVertex([blob pts][i].x, [blob pts][i].y);
				}
				ofEndShape(true);				
			}
		}  
		
		
		blur->endRender();
		blur->blur(2, (1-blobLightFactor)*0.5 + [terminatorBlobLightBlurSlider floatValue]/100.0);
		
		glViewport(0,0,ofGetWidth(),ofGetHeight());	
		ofSetupScreen();
		glScaled(ofGetWidth(), ofGetHeight(), 1);
		ofEnableAlphaBlending();
		glBlendFunc(GL_SRC_ALPHA, GL_ONE);		
		
		
		blur->draw(0, 0, 1, 1, true);
		
		if(side == 0){
			[GetPlugin(ProjectionSurfaces) apply:"Front" surface:"Floor"];	
		} else {
			[GetPlugin(ProjectionSurfaces) apply:"Back" surface:"Floor"];		
		}
		
	}
	
	
}

-(void) draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	[GetPlugin(ProjectionSurfaces) apply:"Front" surface:"Floor"];{		
		[self draw:0];
	}glPopMatrix();		
	
	[GetPlugin(ProjectionSurfaces) apply:"Back" surface:"Floor"];{		
		[self draw:1];	
	}glPopMatrix();	
	
	//
	//Rockets
	//
	Rocket * r;
	for(int i=0;i<[rockets count]; i++){
		r = [rockets objectAtIndex:i];
		[r draw:timeInterval displayTime:outputTime surf:0];
	}
	
	[GetPlugin(ProjectionSurfaces) apply:"Front" surface:"Backwall"];{		
		ofSetColor(0, 0, 0, [mask floatValue]*255);
		ofRect(-0.085, -0.085, 2*([GetPlugin(ProjectionSurfaces) getAspect]+0.085), 1+(2*0.085));
	}glPopMatrix();
	
	for(int i=0;i<[rockets count]; i++){
		r = [rockets objectAtIndex:i];
		[r draw:timeInterval displayTime:outputTime surf:1];
	}

	
	//
	//Aliens
	//
	if([spaceAlienFadeSlider floatValue] > 0){
		ofEnableAlphaBlending();
		[GetPlugin(ProjectionSurfaces) apply:"Front" surface:"Backwall"];{
			float r;
			r = ofRandom(1-[spaceAlienFadeOutSlider floatValue]/100.0, 1 );
			
			ofSetColor(255, 255, 255, 255*([spaceAlienFadeSlider floatValue]/100.0) * r);
			//glTranslated((round(spaceInvadersPosition->x*12)/12.0) / 8.0, spaceInvadersPosition->y / 8.0, 0);
			glTranslated(0.2, 0, 0);
			Alien *alien;
			for(alien in aliens){
				[alien draw];
			}
		}glPopMatrix();	
	}
	
	
	ofEnableAlphaBlending();
	glViewport(0, 0, ofGetWidth(), ofGetHeight());
	ofFill();
	ofSetColor(0, 0, 0,255*(1-[alpha floatValue]));
	ofRect(0, 0, 1, 1);
}

-(int) getIatX:(float)x Y:(float)y{
	float w = 1.0/FLOORGRIDSIZE;
	return ofClamp(floor(x*FLOORGRIDSIZE) + floor(y*FLOORGRIDSIZE)*FLOORGRIDSIZE,0, FLOORGRIDSIZE*FLOORGRIDSIZE-1);
}



-(IBAction) makeChoises:(id)sender{
	makeChoises = true;
}



-(IBAction) activateTerminator:(id)sender{
	terminatorMode = true;	
}
-(IBAction) deactivateTerminator:(id)sender{
	terminatorMode = false;		
}

-(IBAction) generateWall:(id)sender{
	wallPoints.clear();
	wallPointsDietime.clear();
	for(float y =0;y<=	FLOORGRIDSIZE;y+=resolution){		
		for(float x =0;x<=	FLOORGRIDSIZE;x+=resolution){
			ofxPoint2f p = ofxPoint2f(x/(float)FLOORGRIDSIZE,y/(float)FLOORGRIDSIZE);
			wallPointsDietime.push_back(ofRandom(0,0.1) + p.distance(ofPoint(0.5,0.5)));
			wallPoints.push_back(p);
		}
	}
	
	[self calculateOuterWall];
	
}

-(void) calculateOuterWall{
	outerWall.clear();
	wallPointsTemp.clear();
	innerWall.clear();
	
	ofxPoint2f point = ofxPoint2f(0.5,0.5);
	point *= FLOORGRIDSIZE * 1.0/resolution;
	
	ofxVec2f dir = ofxVec2f(1,0);
	
	bool yep = true;
	while(yep){
		if([self wallPointExist:point-ofxPoint2f(1,0)]){
			point.x -= 1;			
		} else {
			yep = false;
			break;
		}
	}
	
	
	//cout<<"Start point "<<point.x<<","<<point.y<<endl;
	
	outerWall.push_back([self wallPoint:point]);
	[self walkDirection:dir fromPosition:point];
	
	if(outerWall.size() > 1){
		ofxVec2f d = outerWall.back() - outerWall.front();
		
		ofxPoint2f lastPoint = outerWall.back()*(FLOORGRIDSIZE * 1.0/resolution);
		ofxVec2f lastPointDir =  -(outerWall.at(outerWall.size()-2)*(FLOORGRIDSIZE * 1.0/resolution) - lastPoint);
		[self findInnerPointsWithD:d lastPoint:lastPoint lastPointDir:lastPointDir];
		
	}
	
	
	
	/*	bool looped = false;
	 int n= 0;
	 while(!looped && n < 400){
	 
	 n++;
	 }
	 */	
	
	
	
	
	
	
	
}

-(BOOL) walkDirection:(ofxVec2f)dir fromPosition:(ofxPoint2f)pos{
	
	for(int a=-135;a<=135;a+=45){
		ofxVec2f d = dir.rotated(a);
		ofxPoint2f p = [self pointFromDir:d position:pos];
		//cout<<" -    "<<p.x<<","<<p.y<<","<<a<<","<<d.x<<","<<d.y<<"    ";
		
		if([self wallPointExist:p]){
			if(outerWall[0].distance(p / (FLOORGRIDSIZE * 1.0/resolution)) < 0.01){
				return YES;
			}
			for(int u=0;u<wallPointsTemp.size();u++){
				if(wallPointsTemp[u].distance(p) < 0.1){
					return NO;
				}
			}
			wallPointsTemp.push_back(p);
			if([self walkDirection:d fromPosition:p]){
				wallPointsTemp.pop_back();
				
				if(wallPointsTemp.size()>0){
					ofxPoint2f lastPoint = wallPointsTemp.back();
					ofxVec2f lastPointDir =  wallPointsTemp[wallPointsTemp.size()-2] - lastPoint;
					[self findInnerPointsWithD:d lastPoint:lastPoint lastPointDir:lastPointDir];
				}
				
				outerWall.push_back(p / (FLOORGRIDSIZE * 1.0/resolution));
				return TRUE;
				
				/*point = p;
				 
				 
				 if(!looped){
				 outerWall.push_back(point / (FLOORGRIDSIZE * 1.0/resolution));
				 //cout<<endl<<"Add point "<<point.x<<","<<point.y<<"  angle: "<<a<<endl;
				 dir.rotate(a);
				 }
				 break;*/
			} else {
				/*for(int i=0;i<wallPoints.size();i++){
					if(wallPoints[i].distance(p / (FLOORGRIDSIZE * 1.0/resolution)) < 0.01){
						wallPoints.erase(wallPoints.begin()+i);
						wallPointsDietime.erase(wallPointsDietime.begin()+i);
					}
				}*/
				
				wallPointsTemp.pop_back();
			}
		}
	}
	
	return NO;
}

-(void) findInnerPointsWithD:(ofxVec2f)d lastPoint:(ofxPoint2f)lastPoint lastPointDir:(ofxVec2f)lastPointDir{
	
	
	ofxVec2f startDir = lastPointDir.normalized();
	ofxVec2f endDir = d.normalized();
	
	startDir.rotate(-45);
	endDir.rotate(45);
	
	if(fabs(startDir.x) > 0.1 && fabs(startDir.y) > 0.1){
		startDir.rotate(-45);
	}
	if(fabs(endDir.x) > 0.1 && fabs(endDir.y) > 0.1){
		endDir.rotate(45);
	}
	
	endDir.x = round(endDir.x);
	endDir.y = round(endDir.y);
	startDir.x = round(startDir.x);
	startDir.y = round(startDir.y);
	
	/*ofSetColor(0, 255, 0);
	 ofLine(lastPoint.x / (FLOORGRIDSIZE * 1.0/resolution), lastPoint.y / (FLOORGRIDSIZE * 1.0/resolution), 
	 lastPoint.x / (FLOORGRIDSIZE * 1.0/resolution) + startDir.x*0.05 , lastPoint.y / (FLOORGRIDSIZE * 1.0/resolution)+ startDir.y*0.05);
	 
	 ofSetColor(0, 0, 255);
	 ofLine(lastPoint.x / (FLOORGRIDSIZE * 1.0/resolution), lastPoint.y / (FLOORGRIDSIZE * 1.0/resolution), 
	 lastPoint.x / (FLOORGRIDSIZE * 1.0/resolution) + endDir.x*0.04 , lastPoint.y / (FLOORGRIDSIZE * 1.0/resolution)+ endDir.y*0.04);
	 
	 */	
	
	int angleBetweenDirs = endDir.angle(startDir);
	if(angleBetweenDirs >= 0){
		for(int an= -angleBetweenDirs; an<=0; an+=90){
			ofxPoint2f checkPoint = [self pointFromDir:startDir.rotated(an) position:lastPoint];
			BOOL pointAdded = NO;
			
			
			for(int u=0;u<outerWall.size();u++){
				if(outerWall[u].distance(checkPoint / (FLOORGRIDSIZE * 1.0/resolution)) < 0.01){
					pointAdded = YES;
				}
			}
			for(int u=0;u<wallPointsTemp.size();u++){
				if(wallPointsTemp[u].distance(checkPoint) < 0.1){
					pointAdded = YES;
				}
			}
			
			if(!pointAdded){
				/*
				 ofSetColor(255, 255, 0);
				 ofCircle(checkPoint.x/ (FLOORGRIDSIZE * 1.0/resolution), checkPoint.y/ (FLOORGRIDSIZE * 1.0/resolution), 0.01);
				 
				 ofSetColor(0, 255, 255,200);
				 ofLine(lastPoint.x / (FLOORGRIDSIZE * 1.0/resolution), lastPoint.y / (FLOORGRIDSIZE * 1.0/resolution), 
				 lastPoint.x / (FLOORGRIDSIZE * 1.0/resolution) + startDir.rotated(an).x*0.03 , lastPoint.y / (FLOORGRIDSIZE * 1.0/resolution)+ startDir.rotated(an).y*0.03);
				 */
				if([self wallPointExist:checkPoint]){
					for(int u=0;u<innerWall.size();u++){
						if(innerWall[u].distance(checkPoint) < 0.1){
							pointAdded = YES;
							break;
						}
					}
					
					if(!pointAdded){
						//innerWall.push_back(checkPoint / (FLOORGRIDSIZE * 1.0/resolution));
						innerWall.insert(innerWall.begin(), checkPoint / (FLOORGRIDSIZE * 1.0/resolution));
					}
					
				}
			}
		}	
	}	
}

-(BOOL) wallPointExist:(ofxPoint2f)p{
	BOOL r = NO;
	for(int i=0;i<wallPoints.size();i++){
		if(wallPointsDietime[i] < [gardenSmashSlider floatValue]/100.0 && fabs(wallPoints[i].x * FLOORGRIDSIZE * 1.0/resolution - p.x) < 0.01 && fabs(wallPoints[i].y * FLOORGRIDSIZE * 1.0/resolution - p.y) < 0.01){
			r = YES;
			break;
		}
	}
	return r;
}

-(ofxPoint2f) wallPoint:(ofxPoint2f)p{
	ofxPoint2f r;
	for(int i=0;i<wallPoints.size();i++){
		if(wallPointsDietime[i] < [gardenSmashSlider floatValue]/100.0 && fabs(wallPoints[i].x * FLOORGRIDSIZE * 1.0/resolution - p.x) < 0.01 && fabs(wallPoints[i].y * FLOORGRIDSIZE * 1.0/resolution - p.y) < 0.01){
			r = wallPoints[i];
			break;
		}
	}
	return r;
	
}
-(ofxPoint2f) pointFromDir:(ofxVec2f) dir position:(ofxPoint2f)pos{
	if(dir.x > 0.1)
		dir.x = 1;
	if(dir.y > 0.1)
		dir.y = 1;
	
	if(dir.x < -0.1)
		dir.x = -1;
	if(dir.y < -0.1)
		dir.y = -1;
	
	return pos+dir;
}

-(IBAction) spawnRocket:(id)sender{
	ofxPoint2f p = 	ofxPoint2f((round(spaceInvadersPosition->x*12)/12.0) / 8.0, spaceInvadersPosition->y / 8.0) + *((Alien*)[aliens objectAtIndex:int(ofRandom(0, [aliens count]-2))])->position + ofxPoint2f(0,0.1);
	
	Rocket * newRocket = [[Rocket alloc] initAtPosition:p+ofxPoint2f(0,0.04) arkade:self];
	[rockets addObject:newRocket];
	timeSinceLastLaunch = 0;
}

-(IBAction) resetSpaceinvaders:(id)sender{
	spaceInvadersPosition->set(0,0);	
	spaceInvadersDir = 1;
	spaceInvadersYDir = 1;
	timeSinceLastLaunch = 0;
	[rockets removeAllObjects];
	[self calculateOuterWall];
	
}

-(void) updateWall:(id)sender{
	pleaseCalculateWall = YES;
}

@end
