#include "ProjectionSurfaces.h"
#include "Tracking.h"
#include "Arkade.h"

@implementation Arkade

-(void) initPlugin{
	for(int i=0;i<FLOORGRIDSIZE*FLOORGRIDSIZE;i++){
		floorSquaresOpacity[i] = 0;
	}
	
}

-(void) setup{
	pacmanPosition = new ofxPoint2f();
	pacmanDir = new ofxVec2f(1,0);
	pacmanMouthValue = 0;
	pacmanMouthDir = 1;
}

-(void) update:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	
	
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
				
				//			int x = p.x*FLOORGRIDSIZE;
				//			int y = p.y*FLOORGRIDSIZE;
				
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
	//Pacman
	//
	if(cookies.size() > 0 && [pacmanButton state] == NSOnState){
		int nearestCookie = -1;
		for(int i=0;i<cookies.size();i++){
			if(nearestCookie == -1 || cookies[i].distance(*pacmanPosition) < cookies[nearestCookie].distance(*pacmanPosition)){
				nearestCookie = i;
			} else if( cookies[i].distance(*pacmanPosition) == cookies[nearestCookie].distance(*pacmanPosition)){
				float a1 = ((ofxVec2f)(cookies[i] - *pacmanPosition)).angle(*pacmanDir);
				float a2 = ((ofxVec2f)(cookies[nearestCookie] - *pacmanPosition)).angle(*pacmanDir);
				
				if(a1 < a2){
					nearestCookie = i;
				}
			}
		}
		
		if(nearestCookie != -1){
			float a = ((ofxVec2f)(*pacmanPosition-cookies[nearestCookie])).angle(-*pacmanDir);
			
			
			pacmanDir->rotate( -a * 0.08* [pacmanSpeedSlider floatValue] / 5.0 * 60.0/ofGetFrameRate());
			*pacmanPosition += pacmanDir->normalized() * [pacmanSpeedSlider floatValue]*0.001 * 30.0/ofGetFrameRate();

			pacmanMouthValue += pacmanMouthDir*0.02;
			if(pacmanMouthValue > 0.3)
				pacmanMouthDir = -1;
			else if(pacmanMouthValue < 0){
				pacmanMouthValue = 0;
				pacmanMouthDir = 1;
			}
			
			if(pacmanPosition->distance(cookies[nearestCookie]) < 0.02){
				cookies.erase(cookies.begin()+nearestCookie);
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
	
	return ofClamp(int(x*FLOORGRIDSIZE) + int(y*FLOORGRIDSIZE)*FLOORGRIDSIZE,0, FLOORGRIDSIZE*FLOORGRIDSIZE-1);
	
}
@end
