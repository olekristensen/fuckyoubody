#include "ProjectionSurfaces.h"
#include "Tracking.h"
#include "Arkade.h"
#include "Stregkode.h"



@implementation Arkade

-(void) initPlugin{
	for(int i=0;i<FLOORGRIDSIZE*FLOORGRIDSIZE;i++){
		floorSquaresOpacity[i] = 0;
	}
	
}

-(void) setup{
	pongWallSound = new ofSoundPlayer();
	pongWallSound->loadSound("pongWallSound.aif");
	
	[self reset:self];
}

-(IBAction) reset:(id)sender{
	ballPosition = new ofxPoint2f(0.2,0.2);
	ballDir = new ofxVec2f(00,1);
	
	pacmanPosition = new ofxPoint2f(-0.2,0.5);
	pacmanDir = new ofxVec2f(1,0);
	pacmanMouthValue = 0;
	pacmanMouthDir = 1;
	
	pongWallSound = new ofSoundPlayer();
	pongWallSound->loadSound("pongWallSound.aif");
	
	pacmanEntering = true;
	
	[pacmanButton setState:NSOffState];
	[ballUpdateButton setState:NSOffState];
	[ballDrawButton setState:NSOffState];
}

-(void) update:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	
	if(ofGetFrameRate() > 10){
		//
		//Floor squares
		//
		if([floorSquaresButton state] == NSOnState){
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
		}
		
		int i=0;
		float w = 1.0/FLOORGRIDSIZE;
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
			//		*ballPosition += ([ballSpeedSlider floatValue]/100.0) * 1.0/ofGetFrameRate() * *ballDir;
			*ballPosition += ([ballSpeedSlider floatValue]/100.0) * 1.0/ofGetFrameRate() * *ballDir;
			
			bool intersection = false;
			if(ballPosition->x < 0+0.05*[ballSizeSlider floatValue]/100.0){
				ballDir->x *= -1;
				//			ballDir->y *= ofRandom(0.5, 1.5);
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
					pongWallSound->setPan(ballPosition->x);
					pongWallSound->play();
				}
			}	
			
			float r = 0.05*[ballSizeSlider floatValue]/100.0;
			
			float bx = ballPosition->x;
			float by = ballPosition->y;
			int i=0;
			float w = 1.0/FLOORGRIDSIZE;
			for(float y=0;y<1;y+=w){
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
			}
			
			
			ballDir->normalize();
			
			lastBallPositions.push_back(*ballPosition);
			while(lastBallPositions.size() > 20){
				lastBallPositions.erase(lastBallPositions.begin());
			}
			
		}
		
		
		
		//
		//Pacman
		//
		if((cookies.size() > 0 && [pacmanButton state] == NSOnState) || [ballUpdateButton state] == NSOnState){
			int nearestCookie = -1;
			for(int i=0;i<cookies.size();i++){
				if(nearestCookie == -1 || cookies[i].distance(*pacmanPosition) < cookies[nearestCookie].distance(*pacmanPosition)){
					nearestCookie = i;
				} else if( cookies[i].distance(*pacmanPosition) == cookies[nearestCookie].distance(*pacmanPosition)){
					float a1 = ((ofxVec2f)(cookies[i] - *pacmanPosition)).angle(*pacmanDir);
					float a2 = ((ofxVec2f)(cookies[nearestCookie] - *pacmanPosition)).angle(*pacmanDir);
					cout<<"Choose "<<a1<<"  "<<a2<<endl;
					if(fabs(a1) > fabs(a2)){
						nearestCookie = i;
					}
				}
			}
			
			if(nearestCookie != -1 || [ballUpdateButton state] == NSOnState){
				float a;
				
				if([ballUpdateButton state] != NSOnState){
					a = ((ofxVec2f)(*pacmanPosition-cookies[nearestCookie])).angle(-*pacmanDir);	
				} else {
					a = ((ofxVec2f)(*pacmanPosition-*ballPosition)).angle(-*pacmanDir);	
					if(pacmanPosition->distance(*ballPosition) < 0.02){
						[ballUpdateButton setState:NSOffState];
						[ballDrawButton setState:NSOffState];
					}
				}
				
				if([pacmanButton state] == NSOnState){
					pacmanDir->rotate( -a * 0.08* [pacmanSpeedSlider floatValue] / 5.0 * 60.0/ofGetFrameRate());
					*pacmanPosition += pacmanDir->normalized() * [pacmanSpeedSlider floatValue]*0.001 * 30.0/ofGetFrameRate();
					
					if(pacmanPosition->x > 0)
						pacmanEntering = false;
					
					if(!pacmanEntering){
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
				}
			}
		}
	}
}

-(void) draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	
	[GetPlugin(ProjectionSurfaces) apply:"Front" surface:"Floor"];
	ofSetColor(255, 255, 255,255);
	ofFill();
	
	
	//
	//Cookies
	//
	for(int c=0;c<cookies.size();c++){
		ofSetColor(155, 0, 255);
		ofEllipse(cookies[c].x, cookies[c].y, 0.03, 0.03);
	}
	
	
	//
	//White floor square
	//
	ofSetColor(255, 255, 255,255);
	//	if([floorSquaresButton state] == NSOnState){
	int i=0;
	float w = 1.0/FLOORGRIDSIZE;
	for(float y=0;y<1;y+=w){
		for(float x=0;x<1;x+=w){				
			float s = floorSquaresOpacity[i];				
			ofRect(x+0.5*w*(1-s),y+0.5*w*(1-s),w*(s) , w*(s));
			i++;
		}
	}
	//}
	
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
		ofSetColor(255, 255, 0);
		int k = 0;
		float circlePtsScaled[OF_MAX_CIRCLE_PTS*2];
		int numCirclePts = 100;
		int start = pacmanMouthValue*numCirclePts/2.0;
		int stop = numCirclePts-start;
		
		glPushMatrix();
		glTranslated(pacmanPosition->x ,  pacmanPosition->y, 0);
		glRotated(-pacmanDir->angle(ofxVec2f(1,0)), 0, 0, 1);
		glBegin(GL_TRIANGLE_FAN);
		glVertex2f(0 , 0);
		
		for(int i = start; i < stop; i++){
			float a = TWO_PI*(float)i/numCirclePts;
			glVertex2f(cos(a) * 0.08  * 0.5,sin(a) * 0.08 * 0.5);
		}
		
		glEnd();
		
		glPopMatrix();
		
		//ofEllipse(pacmanPosition->x, pacmanPosition->y, 0.08, 0.08);
	}
	glPopMatrix();
}

-(int) getIatX:(float)x Y:(float)y{
	float w = 1.0/FLOORGRIDSIZE;
	return ofClamp(floor(x*FLOORGRIDSIZE) + floor(y*FLOORGRIDSIZE)*FLOORGRIDSIZE,0, FLOORGRIDSIZE*FLOORGRIDSIZE-1);
}
@end
