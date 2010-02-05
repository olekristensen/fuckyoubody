#include "Ulykke.h"

#include "ProjectionSurfaces.h"
#include "Tracking.h"

@implementation Ulykke
-(void) draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	if([fill state] == NSOnState){
		ofFill();
	} else {
		ofNoFill();
	}
	
	
	vector<ofxPoint2f> points;
	Blob *b;
	[GetPlugin(ProjectionSurfaces) apply:"Front" surface:"Floor"];
	
	for(b in [tracker(0) blobs]){
		ofBeginShape();
		for (int i=0; i<[b nPts]; i++) {
			ofxPoint2f p = [GetPlugin(ProjectionSurfaces) convertPoint:[b pts][i] fromProjection:"Front" toSurface:"Floor"];
			ofVertex(p.x, p.y);
		}
		ofEndShape(true);
		
	}
	
	glPopMatrix();
	
	[GetPlugin(ProjectionSurfaces) apply:"Back" surface:"Floor"];
	for(b in [tracker(0) blobs]){
		ofBeginShape();
		for (int i=0; i<[b nPts]; i++) {
			ofxPoint2f p = [GetPlugin(ProjectionSurfaces) convertPoint:[b pts][i] fromProjection:"Front" toSurface:"Floor"];
			ofVertex(p.x, p.y);
		}
		ofEndShape(true);
		
	}
	
	
	glPopMatrix();
	
}
@end
