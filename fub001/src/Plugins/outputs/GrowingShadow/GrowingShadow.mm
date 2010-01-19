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
			
			seg->force = new ofxVec2f();
			
			prevSeg = seg;
		}		
		
		i=0;
		prevSeg = [lines lastObject];
		for(seg in lines){
			i++;
			if(i >= [lines count])
				i = 0;
			
			nextSeg = [lines objectAtIndex:i];
					
			
			ofxVec2f pdir = (*seg->pos - *prevSeg->pos).normalized();
			ofxVec2f ndir = (*nextSeg->pos - *seg->pos).normalized();
			
//			ofxVec2f up = (ofxVec2f(-pdir.y, pdir.x) +  ofxVec2f(-ndir.y, ndir.x)).normalized();
			ofxVec2f up = pdir.rotateRad(-HALF_PI + seg->rotation*0.5);
			*seg->force += up * (seg->intendedRotation - seg->rotation)*00.005;
			
			*seg->force -= pdir * (seg->intendedLength - seg->length)*0.1;
			
			
			prevSeg = seg;
		}
		
		for(seg in lines){
			if(!seg->locked){
				*seg->vel *= 0.8;
				*seg->vel += *seg->force * 1.0/ofGetFrameRate();
				*seg->pos += *seg->vel;
			}
		}
	}
	
	
	
	if([growthSpeedSlider floatValue] != 0 && [lines count] > 0){
		if(ofRandom(0, 30) < 1){
						ShadowLineSegment * seg = [lines objectAtIndex:ofRandom(0, [lines count])];
			//ShadowLineSegment * seg = [lines objectAtIndex:3];
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
		for(int i=0;i<[blob nPts];i++){
			ShadowLineSegment * seg = [[ShadowLineSegment alloc]init] ;
			ofxVec2f pos = [blob pts][i];
			seg->locked = false;
			if(i == 0 || i == [blob nPts]-1){
				seg->locked = true;				
			}
			seg->vel = new ofxVec2f();
			seg->pos = new ofxVec2f(pos);
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
