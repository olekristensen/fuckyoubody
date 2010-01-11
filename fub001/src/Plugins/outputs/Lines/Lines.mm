//
//  Lines.mm
//  openFrameworks
//
//  Created by Fuck You Buddy on 11/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Lines.h"
#import "Tracking.h"

@implementation Lines

-(void) draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	PersistentBlob * pblob;
	TrackerObject* t = tracker([trackingDirection selectedSegment]);
	for(pblob in [t persistentBlobs]){
		Blob * b;
		float frontLeft=-1, backLeft=-1;
		for(b in [pblob blobs]){
			if(strcmp([[t calibrator] projector]->name->c_str(), "Front") == 0){
				for(int i=0;i<[b nPts];i++){
					if(frontLeft == -1 || [b pts][i].x < frontLeft){
						frontLeft = [b pts][i].x;
					}
				}
			} else {				
				for(int i=0;i<[b nPts];i++){
					if(frontLeft == -1 || [b pts][i].x < frontLeft){
						frontLeft = [b pts][i].x;
					}
				}				
			}

		}
		
		ofSetColor(255, 255, 255);
		ofLine(frontLeft, 0, frontLeft, 1);
		
	}	
}


@end
