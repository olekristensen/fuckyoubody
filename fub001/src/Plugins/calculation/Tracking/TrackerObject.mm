//
//  TrackerObject.mm
//  openFrameworks
//
//  Created by Jonas Jongejan on 07/12/09.
//  Copyright 2009 HalfdanJ. All rights reserved.
//

#import "TrackerObject.h"
#include "Cameras.h"
#include "Lenses.h"
#include "CameraCalibration.h"
/*
 unsigned long int PersistentBlob::idCounter = 0;
 
 PersistentBlob::PersistentBlob(){
 this->id = PersistentBlob::idCounter++;
 timeoutCounter = 0;
 }
 
 ofxPoint2f PersistentBlob::getLowestPoint(){
 ofxPoint2f low;
 for(int i=0;i<blobs.size();i++){
 for(int u=0;u<blobs[i].nPts;u++){
 if(blobs[i].pts[u].y > low.y){
 low = blobs[i].pts[u];
 }
 }
 }
 return low;
 }
 */

@implementation PersistentBlob
@synthesize blobs;
-(id) init{
	if([super init]){
		timeoutCounter = 0;
		centroid = new ofxPoint2f;
		lastcentroid = new ofxPoint2f;
		centroidV = new ofxVec2f;
		blobs = [[NSMutableArray array] retain];
	}
	return self;
}

-(ofxPoint2f) getLowestPoint{
	ofxPoint2f low;
	Blob * blob;
	for(blob in blobs){
		for(int u=0;u< [blob nPts];u++){
			if([blob pts][u].y > low.y){
				low = [blob pts][u];
			}
		}
	}
	return low;
}

-(void) dealloc {
	delete centroid;
	delete lastcentroid;
	delete centroidV;
	[blobs removeAllObjects];
	[blobs release];
	[super dealloc];
}

@end

//--------------------
//-- Blob --
//--------------------

@implementation Blob
@synthesize cameraId, originalblob, floorblob;

-(id)initWithMouse:(ofPoint*)point{
	if([super init]){
		blob = new ofxCvBlob();
		floorblob = new ofxCvBlob();
		
		originalblob = new ofxCvBlob();
		//		originalblob->area = blob->area = _blob->area;
		//      originalblob->length = blob->length = _blob->length ;
		//       originalblob->boundingRect = blob->boundingRect = _blob->boundingRect;
        floorblob->centroid = originalblob->centroid = blob->centroid = *point;
		//        originalblob->hole = blob->hole = _blob->hole;
		
		floorblob->nPts = originalblob->nPts = blob->nPts = 30;
		for(int i=0;i<30;i++){
			float a = TWO_PI*i/30.0;
			blob->pts.push_back(ofPoint(cos(a)*0.05+point->x, sin(a)*0.05+point->y)); 
		}
		floorblob->pts =  originalblob->pts = blob->pts ;
		
		
	} 
	return self;
}


-(ofxPoint2f) getLowestPoint{
	ofxPoint2f low;
	for(int u=0;u< [self nPts];u++){
		if([self pts][u].y > low.y){
			low = [self pts][u];
		}
	}
	
	return low;
	
}

-(id)initWithBlob:(ofxCvBlob*)_blob{
	if([super init]){
		blob = new ofxCvBlob();
		floorblob = new ofxCvBlob();
		
		originalblob = new ofxCvBlob();
		originalblob->area = blob->area = _blob->area;
        originalblob->length = blob->length = _blob->length ;
        originalblob->boundingRect = blob->boundingRect = _blob->boundingRect;
        originalblob->centroid = blob->centroid = _blob->centroid;
        originalblob->hole = blob->hole = _blob->hole;
		
		floorblob->nPts = originalblob->nPts = blob->nPts = _blob->nPts;
		floorblob->pts =  originalblob->pts = blob->pts = _blob->pts; 
		
	} 
	return self;
}

- (void)dealloc {
	delete blob;
	delete floorblob;
	delete originalblob;
    [super dealloc];
}

-(void) normalize:(int)w height:(int)h{
	for(int i=0;i<blob->nPts;i++){
		blob->pts[i].x /= (float)w;
		blob->pts[i].y /= (float)h;
	}
	blob->area /= (float)w*h;
	blob->centroid.x /=(float) w;
	blob->centroid.y /= (float)h;
	blob->boundingRect.width /= (float)w; 
	blob->boundingRect.height /= (float)h; 
	blob->boundingRect.x /= (float)w; 
	blob->boundingRect.y /= (float)h; 
	
	originalblob->pts = blob->pts;
	originalblob->area = blob->area;
	originalblob->centroid = blob->centroid;
	originalblob->boundingRect = blob->boundingRect;
}

-(void) lensCorrect{
	Lenses * lenses = GetPlugin(Lenses);
	for(int i=0;i<blob->nPts;i++){
		blob->pts[i] = [lenses undistortPoint:(ofxPoint2f)blob->pts[i] fromCameraId:cameraId];
	}
	blob->centroid = [lenses undistortPoint:blob->centroid fromCameraId:cameraId];
	
	//originalblob->pts = blob->pts;
	//originalblob->centroid = blob->centroid;
	
}
-(void) warp{
	CameraCalibrationObject* calibrator = ((CameraCalibrationObject*)[[GetPlugin(CameraCalibration) cameraCalibrations] objectAtIndex:cameraId]);
	
	ProjectionSurfacesObject * projection = [calibrator surface];//((ProjectionSurfacesObject*)[GetPlugin(ProjectionSurfaces) getProjectionSurfaceByName:"Front" surface:"Floor"]);
	
	for(int i=0;i<blob->nPts;i++){
		blob->pts[i] = calibrator->coordWarp->transform(blob->pts[i]);
	}
	blob->centroid = calibrator->coordWarp->transform(blob->centroid);
	
	
	//Convert the blob to floor space, for better sizing 
	for(int i=0;i<blob->nPts;i++){
		floorblob->pts[i] = [GetPlugin(ProjectionSurfaces) convertFromProjection:blob->pts[i] surface:projection];
	}
	floorblob->centroid = [GetPlugin(ProjectionSurfaces) convertFromProjection:blob->centroid surface:projection];
}

-(vector <ofPoint>)pts{
	return blob->pts;
}
-(int)nPts{
	return blob->nPts;	
}
-(ofPoint)centroid{
	return blob->centroid;		
}
-(float) area{
	return blob->area;		
}
-(float)length{
	return blob->length;		
}
-(ofRectangle) boundingRect{
	return blob->boundingRect;	
}
-(BOOL) hole{
	return blob->hole;		
}

@end


//--------------------
//-- Tracker object --
//--------------------

@implementation TrackerObject
@synthesize settingsView, controller, blobs, persistentBlobs, opticalFlow,learnBackgroundButton,calibrator,projector, mouseEvent, mousePosition;

-(id) initWithId:(int)num{
	if([super init]){
		trackerNumber = num;
		
		cw = 640;
		ch = 480;
		
		thread = [[NSThread alloc] initWithTarget:self
										 selector:@selector(performBlobTracking:)
										   object:nil];
		
		persistentBlobs = [[NSMutableArray array] retain];
		blobs = [[NSMutableArray array] retain];
		
		pthread_mutex_init(&mutex, NULL);
		pthread_mutex_init(&drawingMutex, NULL);
		threadUpdateContour = NO;
		threadUpdateOpticalFlow = NO;
		
		userDefaults = [[NSUserDefaults standardUserDefaults] retain];
		
		valuesLoaded = NO;
		pidCounter = 0;
		setMaskCorner = -1;
		
		mouseEvent = NO;
		
		loadBackgroundNow = NO;
		
	}
	
	return self;
}

-(void) setup{
	calibrator = ((CameraCalibrationObject*)[[GetPlugin(CameraCalibration) cameraCalibrations] objectAtIndex:trackerNumber]);
	valuesLoaded = YES;
	
	grayImage = new ofxCvGrayscaleImage();
	grayImageBlured = new ofxCvGrayscaleImage();		
	grayBgMask = new ofxCvGrayscaleImage();		
	grayBg = new ofxCvGrayscaleImage();
	grayDiff = new ofxCvGrayscaleImage();
	
	flowImage = new ofxCvGrayscaleImage();
	flowLastImage = new ofxCvGrayscaleImage();
	
	threadGrayDiff = new ofxCvGrayscaleImage();
	threadGrayImage = new ofxCvGrayscaleImage();
	threadFlowLastImage = new ofxCvGrayscaleImage();
	threadFlowImage = new ofxCvGrayscaleImage();
	
	grayImageBlured->allocate(cw,ch);
	grayImage->allocate(cw,ch);
	grayBg->allocate(cw,ch);
	grayBgMask->allocate(cw,ch);
	grayBgMask->set(255);
	grayDiff->allocate(cw,ch);	
	
	flowImage->allocate(cw/2,ch/2);
	flowLastImage->allocate(cw/2,ch/2);
	
	threadGrayDiff->allocate(cw,ch);
	threadGrayImage->allocate(cw,ch);
	threadFlowLastImage->allocate(cw/2,ch/2);
	threadFlowLastImage->set(0);
	threadFlowImage->allocate(cw/2,ch/2);
	threadFlowImage->set(0);
	
	contourFinder = new ofxCvContourFinder();
	opticalFlow = new ofxCvOpticalFlowLK();
	
	opticalFlow->allocate(cw/2, ch/2);
	opticalFlow->setCalcStep(5,5);
	
	[[learnBackgroundButton midi] setLabel: [NSString stringWithFormat:@"Tracker %i Grab Background", trackerNumber]];
	[[learnBackgroundButton midi] setController: [[NSNumber alloc] initWithInt:60+(20*trackerNumber)]];
	
	[[learnBackgroundMaskButton midi] setLabel: [NSString stringWithFormat:@"Tracker %i Grab Part Background", trackerNumber]];
	[[learnBackgroundMaskButton midi] setController: [[NSNumber alloc] initWithInt:61+(20*trackerNumber)]];
	
	
	[[presetPicker midi] setLabel: [NSString stringWithFormat:@"Tracker %i Pick preset", trackerNumber]];
	[[presetPicker midi] setController: [[NSNumber alloc] initWithInt:64+(20*trackerNumber)]];
	
	[[presetMaskPicker midi] setLabel: [NSString stringWithFormat:@"Tracker %i Pick Mask preset", trackerNumber]];
	[[presetMaskPicker midi] setController: [[NSNumber alloc] initWithInt:67+(20*trackerNumber)]];
	
	[[activeButton midi] setLabel: [NSString stringWithFormat:@"Tracker %i Active", trackerNumber]];
	[[activeButton midi] setController: [[NSNumber alloc] initWithInt:65+(20*trackerNumber)]];
	
	
	[self loadPreset:[[userDefaults valueForKey:[NSString stringWithFormat:@"tracker%d.preset", trackerNumber]]intValue]];
	
	[thread start];
	
}

- (BOOL) loadNibFile {	
	if (![NSBundle loadNibNamed:@"TrackerObject"  owner:self]){
		NSLog(@"Warning! Could not load the nib for tracker ");
		return NO;
	}
	return YES;
}

-(void) draw{
	if([drawDebugButton state] == NSOnState){
		Blob * blob;
		ofSetColor(255, 255, 255,255);
		for(blob in blobs){
			glBegin(GL_LINE_STRIP);
			for(int i=0;i<[blob nPts];i++){
				glVertex2f([blob pts][i].x, [blob pts][i].y);
			}
			glVertex2f([blob pts][0].x, [blob pts][0].y);
			
			glEnd();
		}
		
		CameraCalibrationObject* calibrator = ((CameraCalibrationObject*)[[GetPlugin(CameraCalibration) cameraCalibrations] objectAtIndex:trackerNumber]);
		
		/*	[calibrator applyWarp];
		 for(int i=0;i<640;i++){
		 ofLine(i/640.0, 0, i/640.0, 1);
		 }
		 
		 glPopMatrix();
		 */	
		if ([opticalFlowActiveButton state] == NSOnState){
			glPushMatrix();{
				
				CameraCalibrationObject* calibrator = ((CameraCalibrationObject*)[[GetPlugin(CameraCalibration) cameraCalibrations] objectAtIndex:trackerNumber]);
				
				[calibrator applyWarp];
				
				glScaled(1.0/320.0, 1.0/240.0, 1);
				
				ofSetColor(255, 255, 255,127);
				
				opticalFlow->draw();
				
				glPopMatrix();
				
			}glPopMatrix();
		}
	}
	
}

-(void) controlDraw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	float h = 200;
	float w = h * 640.0/480.0;
	pthread_mutex_lock(&mutex);		
	ofSetColor(255, 255, 255);
	//	[GetPlugin(Cameras) getTexture:trackerNumber]->draw(0,0,w,h);
	grayImage->draw(0,0,w,h);
	
	grayBg->draw(w,0,w,h);
	ofSetColor(255, 0,0,255);
	
	ofPoint maskPoints[4];
	[self getMaskPoints:maskPoints];
	glPushMatrix();
	glTranslated(0, 0, 0);
	glBegin(GL_LINE_STRIP);
	for(int i=0;i<4;i++){
		glVertex2f(w*maskPoints[i].x/640.0, h*maskPoints[i].y/480.0);
	}
	glVertex2f(w*maskPoints[0].x/640.0, h*maskPoints[0].y/480.0);

	glEnd();
	glPopMatrix();
	
	ofSetColor(64, 128, 220);
	ofSetColor(150, 171, 219);
	grayDiff->draw(w*2,0,w,h);
	
	
	ofEnableAlphaBlending();
	ofFill();
	ofSetColor(0, 0, 0,255);
	ofRect(w*3,0,w,h);	
	ofSetColor(100, 100, 100,255);
	grayImage->draw(w*3,0,w,h);
	
	
	//	contourFinder->draw(w*3,0,w,h);
	
	PersistentBlob * blob;
	
	for(blob in persistentBlobs){
		int i=blob->pid%5;
		switch (i) {
			case 0:
				ofSetColor(255, 0, 0,255);
				break;
			case 1:
				ofSetColor(0, 255, 0,255);
				break;
			case 2:
				ofSetColor(0, 0, 255,255);
				break;
			case 3:
				ofSetColor(255, 255, 0,255);
				break;
			case 4:
				ofSetColor(0, 255, 255,255);
				break;
			case 5:
				ofSetColor(255, 0, 255,255);
				break;
				
			default:
				ofSetColor(255, 255, 255,255);
				break;
		}
		Blob * b;
		for(b in [blob blobs]){
			glBegin(GL_LINE_STRIP);
			for(int i=0;i<[b nPts];i++){
				ofxVec2f p = [b pts][i];
				//				p = [GetPlugin(ProjectionSurfaces) convertPoint:[b pts][i] fromProjection:"Front" surface:"Floor"];
				p = [b originalblob]->pts[i];
				glVertex2f(w*3+p.x*w, p.y*h);
				
				//glVertex2f(w*3+p.x/640.0*w, p.y/480.0*h);
				//cout<<p.x<<"  "<<p.y<<endl;
				
			}
			glEnd();
		}
	}
	
	if ([opticalFlowActiveButton state] == NSOnState){
		
		glPushMatrix();{
			
			glTranslated(w*3, 0, 0);
			glScaled(320.0/w, 240.0/h, 1);
			
			ofSetColor(255, 255, 255,127);
			
			opticalFlow->draw();
			
		}glPopMatrix();
	}
	
	pthread_mutex_unlock(&mutex);				
}

-(void) controlMousePressed:(float)x y:(float)y button:(int)button{
	if(setMaskCorner >= 0){
		float h = 200;
		float w = h * 640.0/480.0;
		
		if(x < w){
			ofPoint p = ofPoint((float)x/w, (float)y/h);
			[userDefaults setValue:[NSNumber numberWithFloat:p.x] forKey:[NSString stringWithFormat:@"tracker%d.preset%d.mask%d.p%d.x", trackerNumber,preset, [presetMaskPicker selectedSegment], setMaskCorner]];
			[userDefaults setValue:[NSNumber numberWithFloat:p.y] forKey:[NSString stringWithFormat:@"tracker%d.preset%d.mask%d.p%d.y", trackerNumber,preset, [presetMaskPicker selectedSegment], setMaskCorner]];
			
			setMaskCorner ++;
			if(setMaskCorner == 1){
				[maskText setStringValue:@"Select top-right corner"];	
			}
			if(setMaskCorner == 2){
				[maskText setStringValue:@"Select bottom-right corner"];	
			}
			if(setMaskCorner == 3){
				[maskText setStringValue:@"Select bottom-left corner"];	
			}
			
			
			if(setMaskCorner == 4){
				[activeButton setHidden:NO];
				[activeButton setNeedsDisplay:YES];
				
				[opticalFlowActiveButton setHidden:NO];
				[opticalFlowActiveButton setNeedsDisplay:YES];
				
				[drawDebugButton setHidden:NO];
				[drawDebugButton setNeedsDisplay:YES];
				
				[setMaskButton setHidden:NO];
				[setMaskButton setNeedsDisplay:YES];
				
				[presetMenu setHidden:NO];
				[presetMenu setNeedsDisplay:YES];
				
				setMaskCorner = -1;
				[maskText setStringValue:@""];
				[setMaskButton setState:NSOffState];
			}
			
		}
	}
}
-(void) update:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	if(loadBackgroundNow){
		loadBackgroundNow= NO;
		[self loadBackground];	
	}
	
	if([setMaskButton state] == NSOnState && setMaskCorner == -1){
		[activeButton setHidden:YES];
		[activeButton setNeedsDisplay:YES];
		
		[opticalFlowActiveButton setHidden:YES];
		[opticalFlowActiveButton setNeedsDisplay:YES];
		
		[drawDebugButton setHidden:YES];
		[drawDebugButton setNeedsDisplay:YES];
		
		[setMaskButton setHidden:YES];
		[setMaskButton setNeedsDisplay:YES];
		
		[presetMenu setHidden:YES];
		[presetMenu setNeedsDisplay:YES];
		
		setMaskCorner = 0;
		[maskText setStringValue:@"Select first top-left corner of mask, and go counterwise around"];
	}
	
	
	if (([GetPlugin(Cameras) isFrameNew:trackerNumber] && ( [opticalFlowActiveButton state] == NSOnState || [activeButton state] == NSOnState)) || mouseEvent) {
		
		pthread_mutex_lock(&drawingMutex);
		
		*flowLastImage = *flowImage;
		
		grayImage->setFromPixels([GetPlugin(Cameras) getPixels:trackerNumber], [GetPlugin(Cameras) width],[GetPlugin(Cameras) height]);
		
		flowImage->scaleIntoMe(*grayImage, CV_INTER_AREA);
		
		

		
		
		//	[userDefaults setValue:[NSNumber numberWithFloat:p.x] forKey:[NSString stringWithFormat:@"tracker%d.preset%d.mask.p%d.x", trackerNumber,preset, setMaskCorner]];
		
		
		
		
		
		*grayImageBlured = *grayImage;
		
		int blur = [blurSlider intValue];
		if(blur % 2 == 0) blur += 1;
		
		grayImageBlured->blur(blur);
		
		pthread_mutex_unlock(&drawingMutex);
		
		if ([activeButton state] == NSOnState){
			
			pthread_mutex_lock(&drawingMutex);
			
			/*
			 if (!bVideoPlayerWasActive && getPlugin<Cameras*>(controller)->videoPlayerActive(cameraId) ) {
			 bLearnBakground = true;
			 }
			 
			 if (bVideoPlayerWasActive && !getPlugin<Cameras*>(controller)->videoPlayerActive(cameraId) ) {
			 loadBackground();
			 }
			 */
			if ([learnBackgroundButton state] == NSOnState){
				
				NSLog(@"Tracker %i Learn Background", trackerNumber);
				/*		 if (bUseBgMask) {
				 cvCopy(grayImageBlured.getCvImage(), grayBg.getCvImage(), grayBgMask.getCvImage());
				 grayBg.flagImageChanged();
				 } else {*/
				*grayBg = *grayImageBlured;
				/*		 }
				 if (!getPlugin<Cameras*>(controller)->videoPlayerActive(cameraId)) {
				 saveBackground();
				 }
				 bLearnBakground = false;*/
				[self saveBackground];
				[learnBackgroundButton setState:NSOffState];
			}
			
			if ([learnBackgroundMaskButton state] == NSOnState){
				
				NSLog(@"Tracker %i Learn Background part", trackerNumber);
				grayBgMask->set(255);
				ofPoint maskPoints[4];
				[self getMaskPoints:maskPoints];
				
				
				int nPoints = 4;
				CvPoint _cp[4];
				for(int i=0;i<4;i++){
					_cp[i].x = maskPoints[i].x;
					_cp[i].y = maskPoints[i].y;
				}

				CvPoint* cp = _cp; 
				cvFillPoly(grayBgMask->getCvImage(), &cp, &nPoints, 1, cvScalar(0,0,0,10));
				
								
				 cvCopy(grayImageBlured->getCvImage(), grayBg->getCvImage(), grayBgMask->getCvImage());
				 grayBg->flagImageChanged();
				
//				*grayBg = *grayImageBlured;
				/*		 }
				 if (!getPlugin<Cameras*>(controller)->videoPlayerActive(cameraId)) {
				 saveBackground();
				 }
				 bLearnBakground = false;*/
				[self saveBackground];
				[learnBackgroundMaskButton setState:NSOffState];
			}
			

			
			
			grayDiff->absDiff(*grayBg, *grayImageBlured);

			ofPoint maskPoints[4];
			[self getMaskPoints:maskPoints];
			
			
			int nPoints = 4;
			CvPoint _cp[4]= {{0,0}, {640,0},{maskPoints[1].x,maskPoints[1].y},{maskPoints[0].x,maskPoints[0].y}};			
			CvPoint* cp = _cp; 
			cvFillPoly(grayDiff->getCvImage(), &cp, &nPoints, 1, cvScalar(0,0,0,10));
			
			CvPoint _cp2[4] = {{640,0}, {640,480},{maskPoints[2].x,maskPoints[2].y},{maskPoints[1].x,maskPoints[1].y}};			
			cp = _cp2; 
			cvFillPoly(grayDiff->getCvImage(), &cp, &nPoints, 1, cvScalar(0));
			
			CvPoint _cp3[4] = {{640,480}, {0,480},{maskPoints[3].x,maskPoints[3].y},{maskPoints[2].x,maskPoints[2].y}};			
			cp = _cp3; 
			cvFillPoly(grayDiff->getCvImage(), &cp, &nPoints, 1, cvScalar(0));
			
			CvPoint _cp4[4] = {{0,480}, {0,0},{maskPoints[0].x,maskPoints[0].y},{maskPoints[3].x,maskPoints[3].y}};			
			cp = _cp4; 
			cvFillPoly(grayDiff->getCvImage(), &cp, &nPoints, 1, cvScalar(0));
			grayDiff->flagImageChanged();
			
			grayDiff->threshold([thresholdSldier intValue]);
			
			int postBlur = [postBlurSlider intValue];
			if(postBlur % 2 == 0) postBlur += 1;
			
			if(postBlur > 0){
				grayDiff->blur(postBlur);
				if([postThresholdSlider intValue] > 0){
					grayDiff->threshold([postThresholdSlider intValue], false);
				}
			}
			pthread_mutex_unlock(&drawingMutex);
			
			pthread_mutex_lock(&mutex);
			*threadGrayImage = *grayImage;
			*threadGrayDiff = *grayDiff;
			threadUpdateContour = YES;
			
			// contourFinder.findContours(grayDiff, 20, (getPlugin<Cameras*>(controller)->getWidth()*getPlugin<Cameras*>(controller)->getHeight())/3, 10, false, true);	
			
			/**
			 postBlur = 0;
			 postThreshold = 0; 
			 
			 bVideoPlayerWasActive = getPlugin<Cameras*>(controller)->videoPlayerActive(cameraId);
			 
			 }
			 }
			 **/
			PersistentBlob * pblob;		
			
			//Clear blobs
			for(pblob in persistentBlobs){
				ofxPoint2f p = pblob->centroid - pblob->lastcentroid;
				pblob->centroidV->x = p.x;
				pblob->centroidV->y = p.y;
				pblob->lastcentroid = pblob->centroid ;
				[pblob->blobs removeAllObjects];
			}
			
			
			
			[blobs removeAllObjects];
			if(!mouseEvent){
				for(int i=0;i<contourFinder->nBlobs;i++){
					ofxCvBlob * blob = &contourFinder->blobs[i];
					Blob * blobObj = [[[Blob alloc] initWithBlob:blob] autorelease];
					[blobObj setCameraId:trackerNumber];
					[blobObj lensCorrect];
					[blobObj normalize:cw height:ch];
					[blobObj warp];
					[blobs addObject:blobObj];
					
				}
			} else {
				Blob * blobObj = [[[Blob alloc] initWithMouse:mousePosition] autorelease];
				[blobObj setCameraId:trackerNumber];
				//	[blobObj normalize:cw height:ch];
				
				//					[blobObj warp];
				[blobs addObject:blobObj];
				
			}
			
			[blobCounter2 setIntValue:contourFinder->blobs.size()];
			
			pthread_mutex_unlock(&mutex);
			
			
			[currrentPblobCounter setIntValue:0];
			
			Blob * blob;
			for(blob in blobs){
				bool blobFound = false;
				float shortestDist = 0;
				int bestId = -1;
				ProjectionSurfacesObject * projection = [calibrator surface];//((ProjectionSurfacesObject*)[GetPlugin(ProjectionSurfaces) getProjectionSurfaceByName:"Front" surface:"Floor"]);
				
				ofxPoint2f centroid = ofxPoint2f([blob centroid].x, [blob centroid].y);
				//				ofxPoint2f floorCentroid = [GetPlugin(ProjectionSurfaces) convertPoint:centroid fromProjection:"Front" surface:"Floor"];
				ofxPoint2f floorCentroid = [GetPlugin(ProjectionSurfaces) convertFromProjection:centroid surface:projection];
				
				//Går igennem alle grupper for at finde den nærmeste gruppe som blobben kan tilhøre
				//Magisk høj dist: 0.3
				
				/*for(int u=0;u<[persistentBlobs count];u++){
				 //Giv forrang til døde persistent blobs
				 if(((PersistentBlob*)[persistentBlobs objectAtIndex:u])->timeoutCounter > 5){
				 float dist = centroid.distance(*((PersistentBlob*)[persistentBlobs objectAtIndex:u])->centroid);
				 if(dist < [persistentSlider floatValue]*0.5 && (dist < shortestDist || bestId == -1)){
				 bestId = u;
				 shortestDist = dist;
				 blobFound = true;
				 }
				 }
				 }*/
				if(!blobFound){						
					for(int u=0;u<[persistentBlobs count];u++){
						//						ofxPoint2f centroidPoint = [GetPlugin(ProjectionSurfaces) convertPoint:*((PersistentBlob*)[persistentBlobs objectAtIndex:u])->centroid fromProjection:"Front" surface:"Floor"];
						ofxPoint2f centroidPoint = [GetPlugin(ProjectionSurfaces) convertFromProjection:*((PersistentBlob*)[persistentBlobs objectAtIndex:u])->centroid surface:projection];
						float dist = floorCentroid.distance(centroidPoint);
						if(dist < [persistentSlider floatValue] && (dist < shortestDist || bestId == -1)){
							bestId = u;
							shortestDist = dist;
							blobFound = true;
						}
					}
				}
				
				if(blobFound){	
					[currrentPblobCounter setIntValue:[currrentPblobCounter intValue] +1];
					
					PersistentBlob * bestBlob = ((PersistentBlob*)[persistentBlobs objectAtIndex:bestId]);
					
					//					[bestBlob->blobs removeAllObjects];
					
					//Fandt en gruppe som den her blob kan tilhøre.. Pusher blobben ind
					bestBlob->timeoutCounter = 0;
					[bestBlob->blobs addObject:blob];
					
					//regner centroid ud fra alle blobs i den
					bestBlob->centroid->set(0, 0);
					for(int g=0;g<[bestBlob->blobs count];g++){
						ofxPoint2f blobCentroid = ofxPoint2f([[bestBlob->blobs objectAtIndex:g] centroid].x, [[bestBlob->blobs objectAtIndex:g] centroid].y);
						*bestBlob->centroid += blobCentroid;					
					}
					*bestBlob->centroid /= (float)[bestBlob->blobs count];
				}
				
				if(!blobFound){
					//Der var ingen gruppe til den her blob, så vi laver en
					PersistentBlob * newB = [[PersistentBlob alloc] init];
					[newB->blobs addObject:blob];
					*newB->centroid = centroid;
					newB->pid = pidCounter++;
					[persistentBlobs addObject:newB];		
					
					[newestId setIntValue:pidCounter];
				}
			}		
			
			//Delete all the old pblobs
			for(int i=0; i< [persistentBlobs count] ; i++){
				PersistentBlob * blob = [persistentBlobs objectAtIndex:i];
				blob->timeoutCounter ++;
				if(blob->timeoutCounter > 10){
					[persistentBlobs removeObject:blob];
				}			
			}
		}
		
		if ([opticalFlowActiveButton state] == NSOnState){
			
			pthread_mutex_lock(&mutex);
			
			*threadFlowImage = *flowImage;
			*threadFlowLastImage = *flowLastImage;
			threadUpdateOpticalFlow = YES;
			
			pthread_mutex_unlock(&mutex);
			
		}
	}	
	
	[blobCounter setIntValue:[self numBlobs]];
	
	[pblobCounter setIntValue:[self numPersistentBlobs]];
}

-(int) numBlobs{
	return [blobs count];
}

-(Blob*) getBlob:(int)n{
	return [blobs objectAtIndex:n];
}

-(int) numPersistentBlobs{
	return [persistentBlobs count];
}
-(PersistentBlob*) getPersistentBlob:(int)n{
	return [persistentBlobs objectAtIndex:n];
	
}

-(void) saveBackground{
	//	ofLog(OF_LOG_NOTICE, "<<<<<<<< gemmer billede " + ofToString(cameraId));
	ofImage saveImg;
	saveImg.allocate(grayBg->getWidth(), grayBg->getHeight(), OF_IMAGE_GRAYSCALE);
	saveImg.setFromPixels(grayBg->getPixels(), grayBg->getWidth(), grayBg->getHeight(), false);
	saveImg.saveImage("blobTracker" +ofToString(trackerNumber)+"Background-" + ofToString(preset) + ".png");	
}

-(void) loadBackground{
	ofImage loadImg;
	if (loadImg.loadImage("blobTracker" +ofToString(trackerNumber)+"Background-" + ofToString(preset) + ".png")) {
		grayBg->setFromPixels(loadImg.getPixels(), loadImg.getWidth(), loadImg.getHeight());
		//		return true;
	} else {
		//		return false;
	}
}

-(void) performBlobTracking:(id)param{
	while(1){
		
		pthread_mutex_lock(&mutex);			
		
		if(threadUpdateContour){
			contourFinder->findContours(*threadGrayDiff, 20, (cw*ch)/30, 10, false, true);	
			threadUpdateContour = false;			
			
			/*	int l = -1;
			 if(contourFinder->nBlobs > 0){
			 for(int i=0;i<contourFinder->blobs[0]->
			 
			 }
			 */
		}
		
		if(threadUpdateOpticalFlow){
			opticalFlow->calc(*threadFlowLastImage, *threadFlowImage, 11);
			threadUpdateOpticalFlow = false;			
		}
		
		pthread_mutex_unlock(&mutex);
		
		[NSThread sleepForTimeInterval:0.03];
	}
	
}

-(IBAction) setBlurSliderValue:(id)sender{
	if(valuesLoaded){
		[userDefaults setValue:[NSNumber numberWithFloat:[sender floatValue]] forKey:[NSString stringWithFormat:@"tracker%d.preset%d.blur", trackerNumber,preset]];
	}
}
-(IBAction) setThresholdSliderValue:(id)sender{
	if(valuesLoaded){
		[userDefaults setValue:[NSNumber numberWithFloat:[sender floatValue]] forKey:[NSString stringWithFormat:@"tracker%d.preset%d.threshold", trackerNumber,preset]];
	}
}
-(IBAction) setPostBlurSliderValue:(id)sender{
	if(valuesLoaded){
		[userDefaults setValue:[NSNumber numberWithFloat:[sender floatValue]] forKey:[NSString stringWithFormat:@"tracker%d.preset%d.postBlur", trackerNumber,preset]];
	}
}
-(IBAction) setPostThresholdSliderValue:(id)sender{
	if(valuesLoaded){
		[userDefaults setValue:[NSNumber numberWithFloat:[sender floatValue]] forKey:[NSString stringWithFormat:@"tracker%d.preset%d.postThreshold", trackerNumber,preset]];
	}
}

-(IBAction) setActiveButtonValue:(id)sender{
	if(valuesLoaded){
		[userDefaults setValue:[NSNumber numberWithInt:[sender intValue]] forKey:[NSString stringWithFormat:@"tracker%d.preset%d.active", trackerNumber,preset]];
	}
}

-(IBAction) setOpticalFlowActiveButtonValue:(id)sender{
	if(valuesLoaded){
		[userDefaults setValue:[NSNumber numberWithInt:[sender intValue]] forKey:[NSString stringWithFormat:@"tracker%d.preset%d.opticalFlowActive", trackerNumber,preset]];
	}
}

-(IBAction) setPersistentSliderValue:(id)sender{
	if(valuesLoaded){
		[userDefaults setValue:[NSNumber numberWithFloat:[sender floatValue]] forKey:[NSString stringWithFormat:@"tracker%d.preset%d.persistentSlider", trackerNumber,preset]];
	}	
}

-(IBAction) loadPresetControl:(id)sender{
	[self loadPreset:[sender indexOfSelectedItem]];
	cout<<"Load preset "<<[sender indexOfSelectedItem]<<endl;
}

-(void) loadPreset:(int)n{
	preset = n;
	[userDefaults setValue:[NSNumber numberWithInt:preset] forKey:[NSString stringWithFormat:@"tracker%d.preset", trackerNumber]];
	
	[blurSlider setFloatValue:[[userDefaults valueForKey:[NSString stringWithFormat:@"tracker%d.preset%d.blur", trackerNumber,preset]]floatValue]];
	[thresholdSldier setFloatValue:[[userDefaults valueForKey:[NSString stringWithFormat:@"tracker%d.preset%d.threshold", trackerNumber,preset]]floatValue]];
	[postBlurSlider setFloatValue:[[userDefaults valueForKey:[NSString stringWithFormat:@"tracker%d.preset%d.postBlur", trackerNumber,preset]]floatValue]];
	[postThresholdSlider setFloatValue:[[userDefaults valueForKey:[NSString stringWithFormat:@"tracker%d.preset%d.postThreshold", trackerNumber,preset]]floatValue]];
	[activeButton setState:[[userDefaults valueForKey:[NSString stringWithFormat:@"tracker%d.preset%d.active", trackerNumber,preset]]intValue]];
	[drawDebugButton setState:[[userDefaults valueForKey:[NSString stringWithFormat:@"tracker%d.preset%d.debug", trackerNumber,preset]]intValue]];
	[persistentSlider setFloatValue:[[userDefaults valueForKey:[NSString stringWithFormat:@"tracker%d.preset%d.persistentSlider", trackerNumber,preset]]floatValue]];
	// NONO infinite recursion 
	// [presetMenu selectItemAtIndex:[[userDefaults valueForKey:[NSString stringWithFormat:@"tracker%d.preset", trackerNumber]]intValue]];
	[opticalFlowActiveButton setState:[[userDefaults valueForKey:[NSString stringWithFormat:@"tracker%d.preset%d.opticalFlowActive", trackerNumber,preset]]intValue]];
	
	
		[[[GetPlugin(Cameras) getCameraWithId:0] shutterSlider] setFloatValue:1024];
	if(n ==0){
		[[[GetPlugin(Cameras) getCameraWithId:0] gainSlider] setFloatValue:566];
		[[[GetPlugin(Cameras) getCameraWithId:0] gammaSlider] setFloatValue:875.9];	
	}
	if(n == 1){
		[[[GetPlugin(Cameras) getCameraWithId:0] gainSlider] setFloatValue:1280];	
		[[[GetPlugin(Cameras) getCameraWithId:0] gammaSlider] setFloatValue:535.2];	
	}
	if(n == 2){
		[[[GetPlugin(Cameras) getCameraWithId:0] gainSlider] setFloatValue:788];	
		[[[GetPlugin(Cameras) getCameraWithId:0] gammaSlider] setFloatValue:535.2];	
	}
	
	loadBackgroundNow = YES;
}

-(ofPoint) flowAtX:(float) pointX Y: (float) pointY{
	
	CameraCalibrationObject* calibrator = ((CameraCalibrationObject*)[[GetPlugin(CameraCalibration) cameraCalibrations] objectAtIndex:trackerNumber]);
	
	ofPoint inPoint = calibrator->coordWarp->inversetransform(pointX, pointY);
	ofPoint returnPoint = inPoint;//opticalFlow->flowAtPoint(inPoint.x*320, inPoint.y*240);
	
	returnPoint.x *= 1.0/320; 
	returnPoint.y *= 1.0/240;
	
	return returnPoint;
}

-(ofPoint) flowInRegionX:(float) regionX Y: (float) regionY width: (float) regionWidth height: (float) regionHeight{
	
	//	opticalFlow->flowInRegion(<#int x#>, <#int y#>, <#int w#>, <#int h#>);
}

-(void) getMaskPoints:(ofPoint*)maskPoints{
	for(int i=0;i<4;i++){
		maskPoints[i] = ofPoint(640.0*[[userDefaults valueForKey:[NSString stringWithFormat:@"tracker%d.preset%d.mask%d.p%d.x", trackerNumber,preset,[presetMaskPicker selectedSegment], i]] floatValue], 480.0*[[userDefaults valueForKey:[NSString stringWithFormat:@"tracker%d.preset%d.mask%d.p%d.y", trackerNumber,preset, [presetMaskPicker selectedSegment],i]] floatValue]);
	}	
}

@end
