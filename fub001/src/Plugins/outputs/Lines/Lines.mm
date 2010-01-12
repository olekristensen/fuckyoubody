//
//  Lines.mm
//  openFrameworks
//
//  Created by Fuck You Buddy on 11/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Lines.h"
#import "Tracking.h"

@implementation LineBlobLink



@end


@implementation LineObject
@synthesize links;
-(id) init{
	if([super init]){
		links = [[NSMutableArray array] retain];
		
		
		leftFrontFilter = new Filter();	
		leftFrontFilter->setNl(9.413137469932821686e-04, 2.823941240979846506e-03, 2.823941240979846506e-03, 9.413137469932821686e-04);
		leftFrontFilter->setDl(1, -2.5818614306773719263, 2.2466666427559748864, -.65727470210265670262);
		
		rightFrontFilter = new Filter();	
		rightFrontFilter->setNl(9.413137469932821686e-04, 2.823941240979846506e-03, 2.823941240979846506e-03, 9.413137469932821686e-04);
		rightFrontFilter->setDl(1, -2.5818614306773719263, 2.2466666427559748864, -.65727470210265670262);
		
		leftBackFilter = new Filter();	
		leftBackFilter->setNl(9.413137469932821686e-04, 2.823941240979846506e-03, 2.823941240979846506e-03, 9.413137469932821686e-04);
		leftBackFilter->setDl(1, -2.5818614306773719263, 2.2466666427559748864, -.65727470210265670262);
		
		rightBackFilter = new Filter();	
		rightBackFilter->setNl(9.413137469932821686e-04, 2.823941240979846506e-03, 2.823941240979846506e-03, 9.413137469932821686e-04);
		rightBackFilter->setDl(1, -2.5818614306773719263, 2.2466666427559748864, -.65727470210265670262);
		
		
	} 
	
	return self;
}

-(void) setFrontLeft:(float)l frontRight:(float)r{
	frontLeft = leftFrontFilter->filter(l);			
	frontRight = rightFrontFilter->filter(r);			
	if(ofGetFrameRate()<50){
		frontLeft = leftFrontFilter->filter(l);			
		frontRight = rightFrontFilter->filter(r);			
	}
	frontLeft = leftFrontFilter->filter(l);			
	frontRight = rightFrontFilter->filter(r);			
	if(ofGetFrameRate()<50){
		frontLeft = leftFrontFilter->filter(l);			
		frontRight = rightFrontFilter->filter(r);			
	}
}

-(void) setBackLeft:(float)l backRight:(float)r{
	backLeft = leftBackFilter->filter(l);			
	backRight = rightBackFilter->filter(r);			
	if(ofGetFrameRate()<50){
		backLeft = leftBackFilter->filter(l);			
		backRight = rightBackFilter->filter(r);					
	}
	backLeft = leftBackFilter->filter(l);			
	backRight = rightBackFilter->filter(r);			
	if(ofGetFrameRate()<50){
		backLeft = leftBackFilter->filter(l);			
		backRight = rightBackFilter->filter(r);					
	}
	
}



-(void) drawWithBalance:(float)balance fromtAlpha:(float)frontA backAlpha:(float)backA{
	//ofLine(frontLeft, 0, frontLeft, 1);
	
	//ofLine(backLeft, 0, backLeft, 1);
	
	
	//Calculate floor points from projections
	ofxVec2f frontLeftP[2], frontRightP[2];
	ofxVec2f backLeftP[2], backRightP[2];
	ofxVec2f leftP[2], rightP[2];
	
	frontLeftP[0] = [GetPlugin(ProjectionSurfaces) convertPoint:ofPoint(frontLeft,0) fromProjection:"Front" toSurface:"Floor"];
	frontLeftP[1] = [GetPlugin(ProjectionSurfaces) convertPoint:ofPoint(frontLeft,1) fromProjection:"Front" toSurface:"Floor"];
	frontRightP[0] = [GetPlugin(ProjectionSurfaces) convertPoint:ofPoint(frontRight,0) fromProjection:"Front" toSurface:"Floor"];
	frontRightP[1] = [GetPlugin(ProjectionSurfaces) convertPoint:ofPoint(frontRight,1) fromProjection:"Front" toSurface:"Floor"];
	
	backLeftP[0] = [GetPlugin(ProjectionSurfaces) convertPoint:ofPoint(backLeft,0) fromProjection:"Back" toSurface:"Floor"];
	backLeftP[1] = [GetPlugin(ProjectionSurfaces) convertPoint:ofPoint(backLeft,1) fromProjection:"Back" toSurface:"Floor"];
	backRightP[0] = [GetPlugin(ProjectionSurfaces) convertPoint:ofPoint(backRight,0) fromProjection:"Back" toSurface:"Floor"];
	backRightP[1] = [GetPlugin(ProjectionSurfaces) convertPoint:ofPoint(backRight,1) fromProjection:"Back" toSurface:"Floor"];
	
	leftP[0] = (1.0-balance)*frontLeftP[0] + (balance)*backLeftP[1];
	leftP[1] = (1.0-balance)*frontLeftP[1] + (balance)*backLeftP[0];
	rightP[0] = (1.0-balance)*frontRightP[0] + (balance)*backRightP[1];
	rightP[1] = (1.0-balance)*frontRightP[1] + (balance)*backRightP[0];
	
	
	ofEnableAlphaBlending();
	
	ofSetColor(255, 255, 255, 255.0*frontA);
	[GetPlugin(ProjectionSurfaces) apply:"Front" surface:"Floor"];
	glBegin(GL_QUAD_STRIP);
	glVertex2f(leftP[0].x, leftP[0].y);
	glVertex2f(leftP[1].x, leftP[1].y);
	glVertex2f(rightP[0].x, rightP[0].y);
	glVertex2f(rightP[1].x, rightP[1].y);

	glEnd();
	glPopMatrix();
	
	ofSetColor(255, 255, 255, 255.0*backA);
	[GetPlugin(ProjectionSurfaces) apply:"Back" surface:"Floor"];
	glBegin(GL_QUAD_STRIP);
	glVertex2f(leftP[0].x, leftP[0].y);
	glVertex2f(leftP[1].x, leftP[1].y);
	glVertex2f(rightP[0].x, rightP[0].y);
	glVertex2f(rightP[1].x, rightP[1].y);

	glEnd();
	glPopMatrix();
	
}

@end




@implementation Lines

-(void) initPlugin{
	lines = [[NSMutableArray array] retain];
	
}

-(void) update:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	for(int i=0;i<[lines count];i++){
		LineObject * line = [lines objectAtIndex:i];
		
		BOOL die = YES;
		LineBlobLink * link;
		for(link in [line links]){
			//See if blob is linked to line
			if(outputTime->videoTime - link->lastConfirm < 100000000 ){
				die = NO;					
			}
		}
		if(die){
			[lines removeObjectAtIndex:i];
		}
	}
	
	
	PersistentBlob * pblob;
	TrackerObject* t = tracker([trackingDirection selectedSegment]);
	
	for(pblob in [t persistentBlobs]){
		Blob * b;
		float frontLeft=-1, backLeft=-1;
		float frontRight=-1, backRight=-1;
		for(b in [pblob blobs]){
			if(strcmp([[t calibrator] projector]->name->c_str(), "Front") == 0){
				for(int i=0;i<[b nPts];i++){
					if(frontLeft == -1 || [b pts][i].x < frontLeft){
						frontLeft = [b pts][i].x;
					}
					if(frontRight == -1 || [b pts][i].x > frontRight){
						frontRight = [b pts][i].x;
					}
				}
			} else {				
				for(int i=0;i<[b nPts];i++){
					ofxPoint2f floorP = [GetPlugin(ProjectionSurfaces) convertPoint:[b pts][i] fromProjection:"Back" toSurface:"Floor"];
					ofxPoint2f frontP = [GetPlugin(ProjectionSurfaces) convertPoint:floorP toProjection:"Front" fromSurface:"Floor"];
					if(frontLeft == -1 || frontP.x < frontLeft){
						frontLeft = frontP.x;
					}
					if(frontRight == -1 || frontP.x > frontRight){
						frontRight = frontP.x;
					}
				}				
			}
			
			if(strcmp([[t calibrator] projector]->name->c_str(), "Back") == 0){
				for(int i=0;i<[b nPts];i++){
					if(backLeft == -1 || [b pts][i].x > backLeft){
						backLeft = [b pts][i].x;
					}
					if(backRight == -1 || [b pts][i].x < backRight){
						backRight = [b pts][i].x;
					}
				}
			} else {				
				for(int i=0;i<[b nPts];i++){
					ofxPoint2f floorP = [GetPlugin(ProjectionSurfaces) convertPoint:[b pts][i] fromProjection:"Front" toSurface:"Floor"];
					ofxPoint2f backP = [GetPlugin(ProjectionSurfaces) convertPoint:floorP toProjection:"Back" fromSurface:"Floor"];
					if(backLeft == -1 || backP.x > backLeft){
						backLeft = backP.x;
					}
					if(backRight == -1 || backP.x < backRight){
						backRight = backP.x;
					}
				}				
			}			
		}
		
		if(frontLeft != -1 && backLeft != -1 && frontRight != -1 && backRight != -1){
			BOOL lineFound = NO;
			
			LineObject * line;
			for(line in lines){
				LineBlobLink * link;
				for(link in [line links]){
					//See if blob is linked to line
					if(link->blobId == pblob->pid){
						
						[line setFrontLeft:frontLeft frontRight:frontRight];
						[line setBackLeft:backLeft backRight:backRight];
						
						//[line setLeft:([line left] + (optimalLeft - [line left])*[corridorSpeedControl floatValue]*0.01)];
						//[line setRight:([line right] + (optimalRight - [line right])*[corridorSpeedControl floatValue]*0.01)];
						link->lastConfirm = outputTime->videoTime;
						lineFound = YES;
					}
				}
			}
			
			if(lineFound == NO){
				LineObject * newLine = [[LineObject alloc] init];
				LineBlobLink * link = [[LineBlobLink alloc] init]; 
				
				for(int i=0;i<100;i++){
					[newLine setFrontLeft:frontLeft frontRight:frontRight];
					[newLine setBackLeft:backLeft backRight:backRight];
				}
				
				link->blobId = pblob->pid;
				link->linkTime = outputTime->videoTime;
				link->lastConfirm = outputTime->videoTime;
				[[newLine links] addObject:link];
				[lines addObject:newLine];
			}
		}
		
	}	
}

-(void) draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	LineObject * line;
	for(line in lines){
		[line drawWithBalance:[balanceSlider floatValue] fromtAlpha:(1.0-[balanceSlider floatValue])  backAlpha:[balanceSlider floatValue] ];
	}
}


@end


