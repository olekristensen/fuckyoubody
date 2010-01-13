#import "GrowingShadow.h"
#import "Tracking.h"
	
@implementation ShadowLineSegment
@end


@implementation GrowingShadow

-(void) initPlugin{
	lines = [[NSMutableArray array] retain];
}
-(IBAction) startGrow:(id)sender{
	[lines removeAllObjects];
	
	if([tracker(0) numPersistentBlobs] > 0){
		PersistentBlob * pblob = [[tracker(0) persistentBlobs] objectAtIndex:0];
		Blob * blob = [[pblob blobs] objectAtIndex:0];
		
		ofxVec2f lastDir = ofxVec2f(1,0);
		ofxVec2f lastPos = ofxVec2f();
		for(int i=0;i<[blob nPts];i++){
			ShadowLineSegment * seg = [[ShadowLineSegment alloc]init] ;
			ofxVec2f pos = [blob pts][i];
			
			seg->locked = false;
			if(i == 0){
				seg->length = 0;
				seg->rotation = seg->intendedRotation = 0;
			} else {
				seg->length =  (pos-lastPos).length();
				seg->rotation = seg->intendedRotation = lastDir.angleRad((pos-lastPos));
			}
			
			cout<<seg->length<<endl;

			lastDir = (pos-lastPos).normalized();
			lastPos = pos;
			
			[lines addObject:seg];
		}
		cout<<"Num points: "<<[blob nPts]<<endl;
		
	}
}

-(void) draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	if([tracker(0) numPersistentBlobs] > 0){
		PersistentBlob * pblob = [[tracker(0) persistentBlobs] objectAtIndex:0];
		Blob * blob = [[pblob blobs] objectAtIndex:0];
		ofSetColor(255, 0, 0);
		glBegin(GL_LINE_STRIP);
		for(int i=0;i<[blob nPts];i++){
			glVertex2f([blob pts][i].x, [blob pts][i].y);

		}
		glEnd();
	}
	
	ShadowLineSegment * seg;
	ofxVec2f pos = ofxVec2f(0.5,0.5);
	float rot = 0;
	ofSetColor(255, 255, 255);
	glBegin(GL_LINE_STRIP);
	for(seg in lines){
		rot += seg->rotation;
		pos += ofxVec2f(seg->length,0).rotateRad(rot);
		//cout<<pos.x<<"  "<<pos.y<<"   "<<seg->rotation<<endl;
		glVertex2f(pos.x, pos.y);
	}
	glEnd();
}

@end
