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
		
		frontLeft = new ofxPoint2f();
		backLeft = new ofxPoint2f();
		frontRight = new ofxPoint2f();
		backRight = new ofxPoint2f();
		width = 0;
		
	} 
	
	return self;
}

-(void) dealloc {
	delete frontLeft;
	delete backLeft;
	delete frontLeft;
	delete backRight;
	delete leftFrontFilter;
	delete rightFrontFilter;
	delete leftBackFilter;
	delete rightBackFilter;
	[links release];
	[super dealloc];
}

-(void) setFrontLeft:(ofxPoint2f)l frontRight:(ofxPoint2f)r{
	frontLeft->y = l.y;
	frontRight->y = r.y;
	
	frontLeft->x = leftFrontFilter->filter(l.x);			
	frontRight->x = rightFrontFilter->filter(r.x);			
	if(ofGetFrameRate()<50){
		frontLeft->x = leftFrontFilter->filter(l.x);			
		frontRight->x = rightFrontFilter->filter(r.x);			
	}
	/*	frontLeft->x = leftFrontFilter->filter(l.x);			
	 frontRight->x = rightFrontFilter->filter(r.x);			
	 if(ofGetFrameRate()<50){
	 frontLeft->x = leftFrontFilter->filter(l.x);			
	 frontRight->x = rightFrontFilter->filter(r.x);			
	 }*/
}

-(void) setBackLeft:(ofxPoint2f)l backRight:(ofxPoint2f)r{
	backLeft->y = l.y;
	backRight->y = r.y;
	
	
	backLeft->x = leftBackFilter->filter(l.x);			
	backRight->x = rightBackFilter->filter(r.x);			
	if(ofGetFrameRate()<50){
		backLeft->x = leftBackFilter->filter(l.x);			
		backRight->x = rightBackFilter->filter(r.x);					
	}
	backLeft->x = leftBackFilter->filter(l.x);			
	backRight->x = rightBackFilter->filter(r.x);			
	if(ofGetFrameRate()<50){
		backLeft->x = leftBackFilter->filter(l.x);			
		backRight->x = rightBackFilter->filter(r.x);					
	}
	
}


-(ofxPoint2f) getLeft{
	return *frontLeft;	
}
-(ofxPoint2f) getRight{
	return *frontRight;	
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
	
	if(true || balance == 0){
		[GetPlugin(ProjectionSurfaces) apply:"Front" surface:"Projector"];
		ofSetColor(215*frontA, 221*frontA, 248*frontA, 255);
		glBegin(GL_POLYGON);
		glVertex2f(frontLeft->x+(1.0-width)*(frontRight->x-frontLeft->x)*0.5,0);
		glVertex2f(frontRight->x-(1.0-width)*(frontRight->x-frontLeft->x)*0.5,0);
		glVertex2f(frontRight->x-(1.0-width)*(frontRight->x-frontLeft->x)*0.5,1);
		glVertex2f(frontLeft->x+(1.0-width)*(frontRight->x-frontLeft->x)*0.5,1);
		glEnd();
		glPopMatrix();
	} else if(balance == 1){
		[GetPlugin(ProjectionSurfaces) apply:"Back" surface:"Projector"];
		ofSetColor(215*backA, 221*backA, 248*backA, 255);
		glBegin(GL_POLYGON);
		glVertex2f(backLeft->x+(1.0-width)*(backRight->x-backLeft->x)*0.5,0);
		glVertex2f(backRight->x-(1.0-width)*(backRight->x-backLeft->x)*0.5,0);
		glVertex2f(backRight->x-(1.0-width)*(backRight->x-backLeft->x)*0.5,1);
		glVertex2f(backLeft->x+(1.0-width)*(backRight->x-backLeft->x)*0.5,1);
		glEnd();
		glPopMatrix();
	} else {
		
		//cout<<width<<"   "<<okLinkFound<<endl;
		//ofLine(frontLeft, 0, frontLeft, 1);
		
		//ofLine(backLeft, 0, backLeft, 1);
		
		//Calculate floor points from projections
		ofxVec2f frontLeftP[2], frontRightP[2];
		ofxVec2f backLeftP[2], backRightP[2];
		ofxVec2f leftP[2], rightP[2];
		
		//TODO: This could use some automatic on the finding on points .. If they are to far from floor it fucks up!
		frontLeftP[0] = [GetPlugin(ProjectionSurfaces) convertPoint:ofPoint(frontLeft->x+(1.0-width)*(frontRight->x-frontLeft->x)*0.5,frontLeft->y) fromProjection:"Front" toSurface:"Floor"];
		frontLeftP[1] = [GetPlugin(ProjectionSurfaces) convertPoint:ofPoint(frontLeft->x+(1.0-width)*(frontRight->x-frontLeft->x)*0.5,frontLeft->y+0.1) fromProjection:"Front" toSurface:"Floor"];
		frontRightP[0] = [GetPlugin(ProjectionSurfaces) convertPoint:ofPoint(frontRight->x-(1.0-width)*(frontRight->x-frontLeft->x)*0.5,frontRight->y) fromProjection:"Front" toSurface:"Floor"];
		frontRightP[1] = [GetPlugin(ProjectionSurfaces) convertPoint:ofPoint(frontRight->x-(1.0-width)*(frontRight->x-frontLeft->x)*0.5,frontRight->y+0.1) fromProjection:"Front" toSurface:"Floor"];
		
		backLeftP[0] = [GetPlugin(ProjectionSurfaces) convertPoint:ofPoint(backLeft->x+(1.0-width)*(backRight->x-backLeft->x)*0.5,backLeft->y) fromProjection:"Back" toSurface:"Floor"];
		backLeftP[1] = [GetPlugin(ProjectionSurfaces) convertPoint:ofPoint(backLeft->x+(1.0-width)*(backRight->x-backLeft->x)*0.5,backLeft->y+0.1) fromProjection:"Back" toSurface:"Floor"];
		backRightP[0] = [GetPlugin(ProjectionSurfaces) convertPoint:ofPoint(backRight->x-(1.0-width)*(backRight->x-backLeft->x)*0.5,backLeft->y) fromProjection:"Back" toSurface:"Floor"];
		backRightP[1] = [GetPlugin(ProjectionSurfaces) convertPoint:ofPoint(backRight->x-(1.0-width)*(backRight->x-backLeft->x)*0.5,backLeft->y+0.1) fromProjection:"Back" toSurface:"Floor"];
		
		leftP[0] = (1.0-balance)*frontLeftP[0] + (balance)*backLeftP[1];
		leftP[1] = (1.0-balance)*frontLeftP[1] + (balance)*backLeftP[0];
		rightP[0] = (1.0-balance)*frontRightP[0] + (balance)*backRightP[1];
		rightP[1] = (1.0-balance)*frontRightP[1] + (balance)*backRightP[0];
		
		ofxPoint2f frontPoints[4];
		for(int i=0;i<2;i++){
			frontPoints[i] = [GetPlugin(ProjectionSurfaces) convertPoint:leftP[i] toProjection:"Front" fromSurface:"Floor"];
		}
		for(int i=0;i<2;i++){
			frontPoints[i+2] = [GetPlugin(ProjectionSurfaces) convertPoint:rightP[i] toProjection:"Front" fromSurface:"Floor"];
		}
		
		ofxPoint2f backPoints[4];
		for(int i=0;i<2;i++){
			backPoints[i] = [GetPlugin(ProjectionSurfaces) convertPoint:leftP[i] toProjection:"Back" fromSurface:"Floor"];
		}
		for(int i=0;i<2;i++){
			backPoints[i+2] = [GetPlugin(ProjectionSurfaces) convertPoint:rightP[i] toProjection:"Back" fromSurface:"Floor"];
		}
		
		frontPoints[0].y -= 1;
		frontPoints[2].y -= 1;
		frontPoints[1].y += 1;
		frontPoints[3].y += 1;
		
		backPoints[0].y -= 1;
		backPoints[2].y -= 1;
		backPoints[1].y += 1;
		backPoints[3].y += 1;
		
		ofEnableAlphaBlending();
		ofFill();
		
		
		ofxVec2f dir1 = (leftP[1] - leftP[0]).normalized();
		ofxVec2f dir2 = (rightP[1] - rightP[0]).normalized();
		ofSetColor(215*frontA, 221*frontA, 248*frontA, 255);
		/*	[GetPlugin(ProjectionSurfaces) apply:"Front" surface:"Floor"];
		 glBegin(GL_QUAD_STRIP);	
		 glVertex2f(leftP[0].x-dir1.x, leftP[0].y-dir1.y);
		 glVertex2f(leftP[1].x, leftP[1].y);
		 glVertex2f(rightP[0].x, rightP[0].y);
		 glVertex2f(rightP[1].x, rightP[1].y);
		 
		 glEnd();
		 glPopMatrix();*/
		
		glBegin(GL_QUAD_STRIP);
		for(int i=0;i<4;i++){
			glVertex2f(frontPoints[i].x, frontPoints[i].y);
		}
		glEnd();
		
		ofSetColor(215*backA, 221*backA, 248*backA, 255);
		/*[GetPlugin(ProjectionSurfaces) apply:"Back" surface:"Floor"];
		 glBegin(GL_QUAD_STRIP);
		 glVertex2f(leftP[0].x, leftP[0].y);
		 glVertex2f(leftP[1].x, leftP[1].y);
		 glVertex2f(rightP[0].x, rightP[0].y);
		 glVertex2f(rightP[1].x, rightP[1].y);
		 
		 glEnd();
		 glPopMatrix();*/
		glBegin(GL_QUAD_STRIP);
		for(int i=0;i<4;i++){
			glVertex2f(backPoints[i].x, backPoints[i].y);
		}
		glEnd();
		
		glViewport(0, 0, ofGetWidth(), ofGetHeight());
	}	
}

@end




@implementation Lines

-(void) initPlugin{
	lines = [[NSMutableArray array] retain];
	
}

-(void) setup{
	for(int i=1;i<=NUMLINESOUNDS;i++){
	//	clicks[i-1] = new ofSoundPlayer();
	//	clicks[i-1]->loadSound("Samples/small click#"+ofToString(i, 0)+".aif", false);		
	}
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
			ofxPoint2f * frontLeft=new ofxPoint2f(-1,-1);
			ofxPoint2f*  frontRight=new ofxPoint2f(-1,-1);
			for(b in [pblob blobs]){
				//if(strcmp([[t calibrator] projector]->name->c_str(), "Front") == 0){
				for(int i=0;i<[b nPts];i++){
					ofxPoint2f p = [GetPlugin(ProjectionSurfaces) convertPoint:[b pts][i] fromProjection:"Front" toSurface:"Projector"];
					if(frontLeft->x == -1 || p.x < frontLeft->x){
						*frontLeft = p;
					}
					if(frontRight->x == -1 || p.x > frontRight->x){
						*frontRight = p;
					}
				}
				/*} else {				
				 for(int i=0;i<[b nPts];i++){
				 ofxPoint2f p = [GetPlugin(ProjectionSurfaces) convertPoint:[b pts][i] fromProjection:"Front" toSurface:"Projector"];
				 
				 ofxPoint2f floorP = [GetPlugin(ProjectionSurfaces) convertPoint:p fromProjection:"Back" toSurface:"Floor"];
				 ofxPoint2f frontP = [GetPlugin(ProjectionSurfaces) convertPoint:floorP toProjection:"Front" fromSurface:"Floor"];
				 if(frontLeft->x == -1 || frontP.x < frontLeft->x){
				 *frontLeft = frontP;
				 }
				 if(frontRight->x == -1 || frontP.x > frontRight->x){
				 *frontRight = frontP;
				 }
				 }				
				 }*/
			}
			
			if(frontLeft->x != -1 && frontRight->x != -1){
				BOOL lineFound = NO;
				
				LineObject * line;
				for(line in lines){
					LineBlobLink * link;
					for(link in [line links]){
						//See if blob is linked to line
						if(link->blobId == pblob->pid && link->projId == [[[pblob blobs] objectAtIndex:0] cameraId]){
							float avg = (frontLeft->x + frontRight->x)/2.0;							
							if([timeoutLinesButton state] == NSOffState){
								float w = 0.01;
								frontLeft->x = avg-w;
								frontRight->x = avg+w;
							}
							
							[line setFrontLeft:*frontLeft+ofxPoint2f(link->offset,0) frontRight:*frontRight+ofxPoint2f(link->offset,0)];
							//[line setBackLeft:*backLeft backRight:*backRight];
							
							//[line setLeft:([line left] + (optimalLeft - [line left])*[corridorSpeedControl floatValue]*0.01)];
							//[line setRight:([line right] + (optimalRight - [line right])*[corridorSpeedControl floatValue]*0.01)];
							link->lastConfirm = outputTime->videoTime;
							lineFound = YES;
						}
					}
				}
				
				if(lineFound == NO){
					BOOL noNearLineFound = YES;
					LineObject * line;
					for(line in lines){
						float d = 0.05;
						if([addButton state] == NSOnState){
							d = 0.000;
						}
						if(fabs([line getLeft].x - frontLeft->x) < d || fabs([line getRight].x - frontRight->x) < d ){
							LineBlobLink * link = [[LineBlobLink alloc] init]; 
							link->blobId = pblob->pid;
							link->projId = [trackingDirection selectedSegment];
							link->linkTime = outputTime->videoTime;
							link->lastConfirm = outputTime->videoTime;
							link->offset = 0; //(([line getLeft].x - frontLeft->x) + ([line getRight].x - frontRight->x)) / 2.0;
							[[line links] addObject:link];	
							noNearLineFound = NO;
						}					
					}
					
					if(noNearLineFound && [addButton state] == NSOnState){
						
						LineObject * newLine = [[LineObject alloc] init];
						LineBlobLink * link = [[LineBlobLink alloc] init]; 
						
						for(int i=0;i<100;i++){
							float avg = (frontLeft->x + frontRight->x)/2.0;							
							if([timeoutLinesButton state] == NSOffState){
								float w = 0.01;
								frontLeft->x = avg-w;
								frontRight->x = avg+w;
							}
							
							
							[newLine setFrontLeft:*frontLeft frontRight:*frontRight];
							//						[newLine setBackLeft:*backLeft backRight:*backRight];
						}
						
						
//						int sound = (int)round(ofRandom(0, NUMLINESOUNDS-1));
//						cout<<"Play sound "<<sound<<endl;
//						clicks[sound]->play();
						
						link->blobId = pblob->pid;
						link->projId = [trackingDirection selectedSegment];
						link->linkTime = outputTime->videoTime;
						link->lastConfirm = outputTime->videoTime;
						link->offset = 0;
						[[newLine links] addObject:link];
						[lines addObject:newLine];
					}
				} else if(lineFound == NO){
					
				}
			}
			delete frontLeft;
			delete frontRight;
		}
	}	
}

-(void) draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	ofEnableAlphaBlending();
	glViewport(0, 0, ofGetWidth(), ofGetHeight());
	
	
	//cout<<ofGetWidth()<<endl;
	LineObject * line;
	float gamma = 3.5;
	bool t = false;
	if([timeoutLinesButton state] == NSOnState){
		t = true;
	}
	for(line in lines){
		[line drawWithBalance:[balanceSlider floatValue] fromtAlpha:(powf(1.0-[balanceSlider floatValue],1.0/gamma))*[alpha floatValue]  backAlpha:powf([balanceSlider floatValue],1.0/gamma)*[alpha floatValue] width:[lineWidthSlider floatValue] timeout:t  ];
	}
	
	//[self drawDiagonal];
	
	// MASK
	
	ofSetColor(0, 0, 0, [mask floatValue]*255);
	
	[GetPlugin(ProjectionSurfaces) apply:"Front" surface:"Floor"];{
		
		// bottom mask
		ofRect(-1, 1, 3, 2);
		// left mask
		ofRect(1, -1, 2, 2);
		
		//KS mask
		ofRect(0-[ksMask floatValue], -30, -20, 60);
		
	} glPopMatrix();
	
}

-(void) drawDiagonal{
	
	
	
	
	ofxVec2f pf11 = [GetPlugin(ProjectionSurfaces) convertPoint:ofxPoint2f(0.15,0.6) fromProjection:"Front" toSurface:"Floor"];
	ofxVec2f pf12 = [GetPlugin(ProjectionSurfaces) convertPoint:ofxPoint2f(0.15,0.4) fromProjection:"Front" toSurface:"Floor"];
	ofxVec2f pf21 = [GetPlugin(ProjectionSurfaces) convertPoint:ofxPoint2f(0.45,0.6) fromProjection:"Front" toSurface:"Floor"];
	ofxVec2f pf22 = [GetPlugin(ProjectionSurfaces) convertPoint:ofxPoint2f(0.45,0.4) fromProjection:"Front" toSurface:"Floor"];
	
	
	ofxVec2f pb11 = [GetPlugin(ProjectionSurfaces) convertPoint:ofxPoint2f(0.55,0.6) fromProjection:"Back" toSurface:"Floor"];
	ofxVec2f pb21 = [GetPlugin(ProjectionSurfaces) convertPoint:ofxPoint2f(0.95,0.6) fromProjection:"Back" toSurface:"Floor"];
	ofxVec2f pb12 = [GetPlugin(ProjectionSurfaces) convertPoint:ofxPoint2f(0.55,0.4) fromProjection:"Back" toSurface:"Floor"];
	ofxVec2f pb22 = [GetPlugin(ProjectionSurfaces) convertPoint:ofxPoint2f(0.95,0.4) fromProjection:"Back" toSurface:"Floor"];
	/*
	 ofSetColor(255, 0, 255);
	 ofCircle(0.25, 0.5, 0.02);
	 ofLine(0.151, 1, 0.151, 0);*/
	
	/*[GetPlugin(ProjectionSurfaces) apply:"Front" surface:"Floor"];
	 ofSetColor(0, 255, 255);
	 ofCircle([GetPlugin(ProjectionSurfaces) convertPoint:ofxPoint2f(0.25,0.5) fromProjection:"Front" toSurface:"Floor"].x, [GetPlugin(ProjectionSurfaces) convertPoint:ofxPoint2f(0.25,0.5) fromProjection:"Front" toSurface:"Floor"].y, 0.01);
	 ofLine(pf11.x, pf11.y, pf12.x, pf12.y);
	 glPopMatrix();
	 */
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
	glViewport(0, 0, ofGetWidth(), ofGetHeight());
	ofSetColor(255, 120, 0);
}



-(IBAction) removeAllLines:(id)sender{
	[lines removeAllObjects];
}

@end


