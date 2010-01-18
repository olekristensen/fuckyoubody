#import "GrowingShadow.h"
#import "Tracking.h"

@implementation ShadowLineSegment
@end


@implementation GrowingShadow

-(void) initPlugin{
	lines = [[NSMutableArray array] retain];
}


-(void) update:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	ShadowLineSegment * seg;
	ofxVec2f pos = ofxVec2f(0,0);
	ofxVec2f lastDir = ofxVec2f(1,0);
	ofxVec2f lastPos = ofxVec2f();
	float rot = 0;
	
	if([lines count] > 0){
		ShadowLineSegment * prevSeg = [lines lastObject];
		ShadowLineSegment * nextSeg;
		int i=0;
		for(seg in lines){
			i++;
			if(i >= [lines count])
				i = 0;
			
			nextSeg = [lines objectAtIndex:i];
			
			
			pos = *seg->pos;
			seg->rotation = (*prevSeg->pos-pos).angleRad((pos-*nextSeg->pos));
			seg->length = (pos-*prevSeg->pos).length();
			
			lastDir = (pos-*prevSeg->pos).normalized();
			lastPos = pos;
			
			seg->force = new ofxVec2f();
			
			prevSeg = seg;

		}		
		
		i=0;
		prevSeg = [lines lastObject];
		for(seg in lines){
			if(seg->intendedRotation - seg->rotation != 0){
				cout<<i<<"  "<<seg->intendedRotation<<"   "<<seg->rotation<<"   "<<360.0*(seg->intendedRotation - seg->rotation)/TWO_PI	<<endl;
			}
			if(seg->intendedLength - seg->length != 0){
				cout<<i<<" rot  "<<seg->intendedLength<<"   "<<seg->length<<"   "<<360.0*(seg->intendedRotation - seg->rotation)/TWO_PI	<<endl;
			}
			
			i++;
			if(i >= [lines count])
				i = 0;
			
			nextSeg = [lines objectAtIndex:i];
			
			
			
			
			ofxVec2f pdir = (*seg->pos - *prevSeg->pos).normalized();
			ofxVec2f ndir = (*nextSeg->pos - *seg->pos).normalized();
			
			ofxVec2f up = (ofxVec2f(-pdir.y, pdir.x) +  ofxVec2f(-ndir.y, ndir.x)).normalized();
			*seg->force += - up * (seg->intendedRotation - seg->rotation)*0.1;
			
			*seg->force += pdir * (seg->intendedLength - seg->length);
			
			
			prevSeg = seg;
		}
		
		for(seg in lines){
			*seg->pos += *seg->force * 1.0/ofGetFrameRate();
		}
	}
	
	
	
	if([growthSpeedSlider floatValue] != 0 && [lines count] > 0){
		if(ofRandom(0, 30) < 1){
			//			ShadowLineSegment * seg = [lines objectAtIndex:ofRandom(0, [lines count])];
			ShadowLineSegment * seg = [lines objectAtIndex:3];
			seg->intendedLength += [growthSpeedSlider floatValue]/5000.0;
		}
	}
	
	
}

-(IBAction) startGrow:(id)sender{
	[lines removeAllObjects];
	
	if([tracker(0) numPersistentBlobs] > 0){
		PersistentBlob * pblob = [[tracker(0) persistentBlobs] objectAtIndex:0];
		Blob * blob = [[pblob blobs] objectAtIndex:0];
		
		ofxVec2f lastDir = ofxVec2f(1,0);
		ofxVec2f lastPos = ofxVec2f();
		for(int i=-1;i<[blob nPts];i++){
			ShadowLineSegment * seg = [[ShadowLineSegment alloc]init] ;
			ofxVec2f pos;
			if(i==-1){
				pos = [blob pts][[blob nPts]-1];
			} else {
				pos = [blob pts][i];				
			}
			
			
			seg->locked = false;
			seg->pos = new ofxVec2f(pos);
			/*
			if(i == 0){
				seg->length = seg->intendedLength = 0;
				seg->rotation = seg->intendedRotation = 0;
			} else {
				seg->length = seg->intendedLength =  (pos-lastPos).length();
				seg->rotation = seg->intendedRotation = lastDir.angleRad((pos-lastPos));
			}
			
			lastDir = (pos-lastPos).normalized();
			lastPos = pos;
			*/
			[lines addObject:seg];
		}
	
		ShadowLineSegment * prevSeg = [lines lastObject];
		ShadowLineSegment * nextSeg, *seg;
		int i=0;
		for(seg in lines){
			i++;
			if(i >= [lines count])
				i = 0;
			
			nextSeg = [lines objectAtIndex:i];
			
			
			ofxVec2f pos = *seg->pos;
			seg->intendedRotation = (*prevSeg->pos-pos).angleRad((pos-*nextSeg->pos));
			seg->intendedLength = (pos-*prevSeg->pos).length();
			
			prevSeg = seg;

		}		
		
		
		cout<<"Num points: "<<[blob nPts]<<endl;
		
	}
}

-(void) draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	if([tracker(0) numPersistentBlobs] > 0){
		PersistentBlob * pblob = [[tracker(0) persistentBlobs] objectAtIndex:0];
		if([[pblob blobs] count] > 0){
			Blob * blob = [[pblob blobs] objectAtIndex:0];
			ofSetColor(255, 0, 0);
			glBegin(GL_LINE_STRIP);
			for(int i=0;i<[blob nPts];i++){
				glVertex2f([blob pts][i].x, [blob pts][i].y);
				
			}
			glEnd();
		}
	}
	
	ShadowLineSegment * seg;
	ofxVec2f pos = ofxVec2f(0,0);
	float rot = 0;
	ofSetColor(255, 255, 255);
	glBegin(GL_LINE_LOOP);
	for(seg in lines){
		rot += seg->rotation;
		//		pos += ofxVec2f(seg->length,0).rotateRad(rot);
		pos = *seg->pos;
		//cout<<pos.x<<"  "<<pos.y<<"   "<<seg->rotation<<endl;
		glVertex2f(pos.x, pos.y);
	}
	glEnd();
}

@end
