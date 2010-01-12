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
		
		width = 0;
		
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



-(void) drawWithBalance:(float)balance fromtAlpha:(float)frontA backAlpha:(float)backA width:(float)w timeout:(bool)timeout{
	LineBlobLink * link;
	bool okLinkFound = !timeout;
	for(link in links){
		//		cout<<link->timeSinceLastConfirm <<endl;
		if(link->timeSinceLastConfirm < 20000000 || !timeout){
			okLinkFound  = true;			
		} 
		
	}
	if(!okLinkFound){
		if(timeout){
			width += (0.0-width) * 0.011;
			if(width < 0)
				width = 0;	
		}
	} else {
		width += (w-width) * 0.011;
		/*if(width > w)
		 width = w;			*/
	}
	
	//cout<<width<<"   "<<okLinkFound<<endl;
	//ofLine(frontLeft, 0, frontLeft, 1);
	
	//ofLine(backLeft, 0, backLeft, 1);
	
	
	//Calculate floor points from projections
	ofxVec2f frontLeftP[2], frontRightP[2];
	ofxVec2f backLeftP[2], backRightP[2];
	ofxVec2f leftP[2], rightP[2];
	
	frontLeftP[0] = [GetPlugin(ProjectionSurfaces) convertPoint:ofPoint(frontLeft+(1.0-width)*(frontRight-frontLeft)*0.5,0) fromProjection:"Front" toSurface:"Floor"];
	frontLeftP[1] = [GetPlugin(ProjectionSurfaces) convertPoint:ofPoint(frontLeft+(1.0-width)*(frontRight-frontLeft)*0.5,1) fromProjection:"Front" toSurface:"Floor"];
	frontRightP[0] = [GetPlugin(ProjectionSurfaces) convertPoint:ofPoint(frontRight-(1.0-width)*(frontRight-frontLeft)*0.5,0) fromProjection:"Front" toSurface:"Floor"];
	frontRightP[1] = [GetPlugin(ProjectionSurfaces) convertPoint:ofPoint(frontRight-(1.0-width)*(frontRight-frontLeft)*0.5,1) fromProjection:"Front" toSurface:"Floor"];
	
	backLeftP[0] = [GetPlugin(ProjectionSurfaces) convertPoint:ofPoint(backLeft+(1.0-width)*(backRight-backLeft)*0.5,0) fromProjection:"Back" toSurface:"Floor"];
	backLeftP[1] = [GetPlugin(ProjectionSurfaces) convertPoint:ofPoint(backLeft+(1.0-width)*(backRight-backLeft)*0.5,1) fromProjection:"Back" toSurface:"Floor"];
	backRightP[0] = [GetPlugin(ProjectionSurfaces) convertPoint:ofPoint(backRight-(1.0-width)*(backRight-backLeft)*0.5,0) fromProjection:"Back" toSurface:"Floor"];
	backRightP[1] = [GetPlugin(ProjectionSurfaces) convertPoint:ofPoint(backRight-(1.0-width)*(backRight-backLeft)*0.5,1) fromProjection:"Back" toSurface:"Floor"];
	
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
			if([timeoutLinesButton state] == NSOffState || [trackingButton state] == NSOffState){
				link->lastConfirm = outputTime->videoTime;
				
			}
			link->timeSinceLastConfirm = outputTime->videoTime - link->lastConfirm;
			//See if blob is linked to line
			if(outputTime->videoTime - link->lastConfirm < 500000000){
				
				die = NO;					
				
			}
		}
		if(die){
			if([timeoutLinesButton state] == NSOnState){
				[lines removeObjectAtIndex:i];
			}
		}
	}
	
	
	
	if([trackingButton state] == NSOnState){
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
						if(link->blobId == pblob->pid && link->projId == [[[pblob blobs] objectAtIndex:0] cameraId]){
							
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
					link->projId = [trackingDirection selectedSegment];
					link->linkTime = outputTime->videoTime;
					link->lastConfirm = outputTime->videoTime;
					[[newLine links] addObject:link];
					[lines addObject:newLine];
				}
			}
		}
	}	
}

-(void) draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{


	LineObject * line;
	float gamma = 3.5;
	bool t = false;
	if([timeoutLinesButton state] == NSOnState){
		t = true;
	}
	for(line in lines){
		[line drawWithBalance:[balanceSlider floatValue] fromtAlpha:(powf(1.0-[balanceSlider floatValue],1.0/gamma))  backAlpha:powf([balanceSlider floatValue],1.0/gamma) width:[lineWidthSlider floatValue] timeout:t  ];
	}
	
	[self drawDiagonal];
}

-(void) drawDiagonal{
	
	
	
	ofxVec2f pf11 = [GetPlugin(ProjectionSurfaces) convertPoint:ofxPoint2f(0.15,1) fromProjection:"Front" toSurface:"Floor"];
	ofxVec2f pf12 = [GetPlugin(ProjectionSurfaces) convertPoint:ofxPoint2f(0.15,0) fromProjection:"Front" toSurface:"Floor"];
	ofxVec2f pf21 = [GetPlugin(ProjectionSurfaces) convertPoint:ofxPoint2f(0.45,1) fromProjection:"Front" toSurface:"Floor"];
	ofxVec2f pf22 = [GetPlugin(ProjectionSurfaces) convertPoint:ofxPoint2f(0.45,0) fromProjection:"Front" toSurface:"Floor"];


	ofxVec2f pb11 = [GetPlugin(ProjectionSurfaces) convertPoint:ofxPoint2f(0.55,1) fromProjection:"Back" toSurface:"Floor"];
	ofxVec2f pb21 = [GetPlugin(ProjectionSurfaces) convertPoint:ofxPoint2f(0.95,1) fromProjection:"Back" toSurface:"Floor"];
	ofxVec2f pb12 = [GetPlugin(ProjectionSurfaces) convertPoint:ofxPoint2f(0.55,0) fromProjection:"Back" toSurface:"Floor"];
	ofxVec2f pb22 = [GetPlugin(ProjectionSurfaces) convertPoint:ofxPoint2f(0.95,0) fromProjection:"Back" toSurface:"Floor"];
	
	//B i y = a+bx
	float bf1 =((float)pf12.y-pf11.y)/(pf12.x-pf11.x);
	float bf2 =((float)pf22.y-pf21.y)/(pf22.x-pf21.x);

	float bb1 =((float)pb12.y-pb11.y)/(pb12.x-pb11.x);
	float bb2 =((float)pb22.y-pb21.y)/(pb22.x-pb21.x);

	
	//A i y = a+bx <=> a = y - bx
	float af1 = pf11.y - bf1*pf11.x;
	float af2 = pf21.y - bf2*pf21.x;

	float ab1 = pb11.y - bb1*pb11.x;
	float ab2 = pb21.y - bb2*pb21.x;
	
	//intersection xi = - (a1 - a2) / (b1 - b2) yi = a1 + b1xi
	ofxPoint2f iFront = ofxPoint2f(-(af1 - af2)/(bf1-bf2) , af1 + bf1*(-(af1 - af2)/(bf1-bf2)));

	ofxPoint2f iBack = ofxPoint2f(-(ab1 - ab2)/(bb1-bb2) , ab1 + bb1*(-(ab1 - ab2)/(bb1-bb2)));

	
	ofSetColor(255, 255, 0);
	[GetPlugin(ProjectionSurfaces) apply:"Front" surface:"Floor"];
	glBegin(GL_LINE_STRIP);
	glVertex2f(iFront.x, iFront.y);
	glVertex2f(iBack.x, iBack.y);
	glEnd();
	glPopMatrix();

	ofSetColor(255, 120, 0);
/*
	ofLine(0.5*0.5, 0, 0.5*0.5, 1);
	ofLine(0.75, 0, 0.75, 1);*/
}



-(IBAction) removeAllLines:(id)sender{
	[lines removeAllObjects];
}

@end


