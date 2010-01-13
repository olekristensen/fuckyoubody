#include "Ulykke.h"

#include "ProjectionSurfaces.h"
#include "Tracking.h"

@implementation Ulykke
-(void) draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	vector<ofxPoint2f> points;
	Blob *b;
	[GetPlugin(ProjectionSurfaces) apply:"Front" surface:"Floor"];

	for(b in [tracker(1) blobs]){
		glBegin(GL_LINE_STRIP);
		for (int i=0; i<[b nPts]; i++) {
			ofxPoint2f p = [GetPlugin(ProjectionSurfaces) convertFromProjection:[b pts][i]  surface:Surf("Front","Floor")];
			glVertex2f(p.x, p.y);
		}
		glEnd();

		ofBeginShape();
			for (int i=0; i<[b nPts]; i++) {
			ofxPoint2f p = [GetPlugin(ProjectionSurfaces) convertFromProjection:[b pts][i]  surface:Surf("Front","Floor")];
			ofVertex(p.x, p.y);
		}
		ofEndShape(true);
		
	}
	
	glPopMatrix();
	
	[GetPlugin(ProjectionSurfaces) apply:"Back" surface:"Floor"];
	
	for(b in [tracker(1) blobs]){
		glBegin(GL_LINE_STRIP);
		for (int i=0; i<[b nPts]; i++) {
			ofxPoint2f p = [GetPlugin(ProjectionSurfaces) convertFromProjection:[b pts][i]  surface:Surf("Front","Floor")];
			glVertex2f(p.x, p.y);
		}
		glEnd();

		ofBeginShape();
		for (int i=0; i<[b nPts]; i++) {
			ofxPoint2f p = [GetPlugin(ProjectionSurfaces) convertFromProjection:[b pts][i]  surface:Surf("Front","Floor")];
			ofVertex(p.x, p.y);
		}
		ofEndShape(true);
	}
	
	glPopMatrix();
	
}
@end
