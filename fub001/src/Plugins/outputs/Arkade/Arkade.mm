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
}

-(void) update:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	
	
	
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
	
	int i=0;
	float w = 1.0/FLOORGRIDSIZE;
	for(float y=0;y<1;y+=w){
		for(float x=0;x<1;x+=w){				
			if(floorSquaresOpacity[i] > 1){
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
	
	
	//Pacman
	if(cookies.size() > 0){
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
			pacmanDir->rotate(((ofxVec2f)(cookies[nearestCookie] - *pacmanPosition)).angle(*pacmanDir) * (30.0/ofGetFrameRate()) / 10.0);
			*pacmanPosition -= pacmanDir->normalized() * 0.01 * 30.0/ofGetFrameRate();
			
			if(pacmanPosition->distance(cookies[nearestCookie]) < 0.01){
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
	if([floorSquaresButton state] == NSOnState){
		int i=0;
		float w = 1.0/FLOORGRIDSIZE;
		for(float y=0;y<1;y+=w){
			for(float x=0;x<1;x+=w){				
				float s = floorSquaresOpacity[i];				
				ofRect(x+0.5*w*(1-s),y+0.5*w*(1-s),w*(s) , w*(s));
				i++;
			}
		}
	}
	
	//
	//Pacman
	//
	ofSetColor(255, 255, 0);
	ofEllipse(pacmanPosition->x, pacmanPosition->y, 0.08, 0.08);
	
	glPopMatrix();
}

-(int) getIatX:(float)x Y:(float)y{
	
	return ofClamp(int(x*FLOORGRIDSIZE) + int(y*FLOORGRIDSIZE)*FLOORGRIDSIZE,0, FLOORGRIDSIZE*FLOORGRIDSIZE-1);
	
}
@end
