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

@end

//--------------------
//-- Blob --
//--------------------

@implementation Blob
@synthesize cameraId;

-(id)initWithBlob:(ofxCvBlob*)_blob{
	if([super init]){
		blob = new ofxCvBlob();
		blob->area = _blob->area;
        blob->length = _blob->length ;
        blob->boundingRect = _blob->boundingRect;
        blob->centroid = _blob->centroid;
        blob->hole = _blob->hole;
		
        blob->pts = _blob->pts;   
        blob->nPts = _blob->nPts;
	} 
	return self;
}

-(void) normalize:(int)w height:(int)h{
	for(int i=0;i<blob->nPts;i++){
		blob->pts[i].x /= (float)w;
		blob->pts[i].y /= (float)h;
	}
	blob->area /= (float)w*h;
	blob->centroid.x /=(float) w;
	blob->centroid.y /= (float)h;
}
-(void) lensCorrect{
	Lenses * lenses = GetPlugin(Lenses);
	for(int i=0;i<blob->nPts;i++){
		blob->pts[i] = [lenses undistortPoint:(ofxPoint2f)blob->pts[i] fromCameraId:cameraId];
	}
	blob->centroid = [lenses undistortPoint:blob->centroid fromCameraId:cameraId];	
}
-(void) warp{
	CameraCalibrationObject* calibrator = ((CameraCalibrationObject*)[[GetPlugin(CameraCalibration) cameraCalibrations] objectAtIndex:cameraId]);
	
	for(int i=0;i<blob->nPts;i++){
		blob->pts[i] = calibrator->coordWarp->transform(blob->pts[i]);
	}
	blob->centroid = calibrator->coordWarp->transform(blob->centroid);
	/*blob->area /= (float)w*h;
	blob->centroid.x /=(float) w;
	blob->centroid.y /= (float)h;*/
	
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
@synthesize settingsView, controller, blobs, persistentBlobs;

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
		
		userDefaults = [[NSUserDefaults standardUserDefaults] retain];
		
		valuesLoaded = NO;
		pidCounter = 0;
		
		
	}
	
	return self;
}

-(void) setup{
	[blurSlider setFloatValue:[[userDefaults valueForKey:[NSString stringWithFormat:@"tracker%d.blur", trackerNumber]]floatValue]];
	[thresholdSldier setFloatValue:[[userDefaults valueForKey:[NSString stringWithFormat:@"tracker%d.threshold", trackerNumber]]floatValue]];
	[postBlurSlider setFloatValue:[[userDefaults valueForKey:[NSString stringWithFormat:@"tracker%d.postBlur", trackerNumber]]floatValue]];
	[postThresholdSlider setFloatValue:[[userDefaults valueForKey:[NSString stringWithFormat:@"tracker%d.postThreshold", trackerNumber]]floatValue]];
	[activeButton setState:[[userDefaults valueForKey:[NSString stringWithFormat:@"tracker%d.active", trackerNumber]]intValue]];
	[drawDebugButton setState:[[userDefaults valueForKey:[NSString stringWithFormat:@"tracker%d.debug", trackerNumber]]intValue]];

	valuesLoaded = YES;
	
	
	grayImage = new ofxCvGrayscaleImage();
	grayLastImage = new ofxCvGrayscaleImage();
	grayImageBlured = new ofxCvGrayscaleImage();		
	grayBgMask = new ofxCvGrayscaleImage();		
	grayBg = new ofxCvGrayscaleImage();
	grayDiff = new ofxCvGrayscaleImage();
	
	
	threadGrayDiff = new ofxCvGrayscaleImage();
	threadGrayImage = new ofxCvGrayscaleImage();
	threadGrayLastImage = new ofxCvGrayscaleImage();
	
	
	grayImageBlured->allocate(cw,ch);
	grayImage->allocate(cw,ch);
	grayLastImage->allocate(cw,ch);
	grayBg->allocate(cw,ch);
	grayBgMask->allocate(cw,ch);
	grayBgMask->set(255);
	grayDiff->allocate(cw,ch);	
	
	threadGrayDiff->allocate(cw,ch);
	threadGrayImage->allocate(cw,ch);
	threadGrayLastImage->allocate(cw,ch);
	
	contourFinder = new ofxCvContourFinder();
	
	[self loadBackground];
	
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
			glBegin(GL_POLYGON);
			for(int i=0;i<[blob nPts];i++){
				glVertex2f([blob pts][i].x, [blob pts][i].y);
			}
			glEnd();
		}
	}
}

-(void) controlDraw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	float h = 200;
	float w = h * 640.0/480.0;
	pthread_mutex_lock(&mutex);		
	ofSetColor(255, 255, 255);
	[GetPlugin(Cameras) getTexture:trackerNumber]->draw(0,0,w,h);
	grayBg->draw(w,0,w,h);
	ofSetColor(64, 128, 220);
	ofSetColor(150, 171, 219);
	grayDiff->draw(w*2,0,w,h);
	grayDiff->draw(w*3,0,w,h);
	contourFinder->draw(w*3,0,w,h);
	pthread_mutex_unlock(&mutex);				
}

-(void) update:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	
	if ([GetPlugin(Cameras) isFrameNew:trackerNumber] && [activeButton state] == NSOnState){
		//	int t = ofGetElapsedTimeMillis();
		//if(thread.lock()){
		pthread_mutex_lock(&drawingMutex);
		
		grayImage->setFromPixels([GetPlugin(Cameras) getPixels:trackerNumber], [GetPlugin(Cameras) width],[GetPlugin(Cameras) height]);
		
		/*
		 int nPoints = 4;
		 CvPoint _cp[4]= {{blackCorners[0].x,blackCorners[0].y}, {blackCorners[1].x,blackCorners[1].y},{blackCorners[2].x,blackCorners[2].y},{blackCorners[3].x,blackCorners[3].y}};			
		 CvPoint* cp = _cp; cvFillPoly(grayImage.getCvImage(), &cp, &nPoints, 1, cvScalar(0));
		 */
		*grayImageBlured = *grayImage;
		
		int blur = [blurSlider intValue];
		if(blur % 2 == 0) blur += 1;
		
		grayImageBlured->blur(blur);
		/*
		 if (!bVideoPlayerWasActive && getPlugin<Cameras*>(controller)->videoPlayerActive(cameraId) ) {
		 bLearnBakground = true;
		 }
		 
		 if (bVideoPlayerWasActive && !getPlugin<Cameras*>(controller)->videoPlayerActive(cameraId) ) {
		 loadBackground();
		 }
		 */
		if ([learnBackgroundButton state] == NSOnState){
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
		
		grayDiff->absDiff(*grayBg, *grayImageBlured);
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
		
		
		*threadGrayDiff = *grayDiff;
		*threadGrayImage = *grayImage;
		*threadGrayLastImage = *grayLastImage;
		threadUpdateContour = YES;
		
		
		
		
		
		// contourFinder.findContours(grayDiff, 20, (getPlugin<Cameras*>(controller)->getWidth()*getPlugin<Cameras*>(controller)->getHeight())/3, 10, false, true);	
		
		
		*grayLastImage = *grayImage;
		
		/* 
		 postBlur = 0;
		 postThreshold = 0; 
		 
		 bVideoPlayerWasActive = getPlugin<Cameras*>(controller)->videoPlayerActive(cameraId);
		 
		 }
		 }
		 */
		PersistentBlob * pblob;		
		
		//Clear blobs
		for(pblob in persistentBlobs){
			ofxPoint2f p = pblob->centroid - pblob->lastcentroid;
			pblob->centroidV = new ofxVec2f(p.x, p.y);
			pblob->lastcentroid = pblob->centroid ;
			[pblob->blobs removeAllObjects];
		}
		
		
		pthread_mutex_unlock(&mutex);
		
		[blobs removeAllObjects];
		for(int i=0;i<contourFinder->nBlobs;i++){
			ofxCvBlob * blob = &contourFinder->blobs[i];
			Blob * blobObj = [[Blob alloc] initWithBlob:blob] ;
			[blobObj setCameraId:trackerNumber];
			[blobObj lensCorrect];
			[blobObj normalize:cw height:ch];
			[blobObj warp];
			[blobs addObject:blobObj];
			
		}
		
		Blob * blob;
		for(blob in blobs){
			bool blobFound = false;
			float shortestDist = 0;
			int bestId = -1;
			ofxPoint2f centroid = ofxPoint2f([blob centroid].x, [blob centroid].y);
			
			//Går igennem alle grupper for at finde den nærmeste gruppe som blobben kan tilhøre
			//Magisk høj dist: 0.3
			for(int u=0;u<[persistentBlobs count];u++){
				float dist = centroid.distance(*((PersistentBlob*)[persistentBlobs objectAtIndex:u])->centroid);
				if(dist < 0.2 && (dist < shortestDist || bestId == -1)){
					bestId = u;
					shortestDist = dist;
					blobFound = true;
				}
			}
			
			if(blobFound){		
				PersistentBlob * bestBlob = ((PersistentBlob*)[persistentBlobs objectAtIndex:bestId]);
				//Fandt en gruppe som den her blob kan tilhøre.. Pusher blobben ind
				bestBlob->timeoutCounter = 0;
				[bestBlob->blobs addObject:blob];
				
				//regner centroid ud fra alle blobs i den
				bestBlob->centroid = new ofxPoint2f();
				for(int g=0;g<[bestBlob->blobs count];g++){
					ofxPoint2f blobCentroid = ofxPoint2f([[bestBlob->blobs objectAtIndex:g] centroid].x, [[bestBlob->blobs objectAtIndex:g] centroid].y);
					*bestBlob->centroid += blobCentroid;					
				}
				*bestBlob->centroid /= (float)[bestBlob->blobs count];
			}
			
			if(!blobFound){
				//Der var ingen gruppe til den her blob, så vi laver en
				PersistentBlob * newB = [[[PersistentBlob alloc] init] retain];
				[newB->blobs addObject:blob];
				*newB->centroid = centroid;
				newB->pid = pidCounter++;
				[persistentBlobs addObject:newB];		
			}
		}		
		for(int i=0; i< [persistentBlobs count] ; i++){
			PersistentBlob * blob = [persistentBlobs objectAtIndex:i];		
			
			blob->timeoutCounter ++;
			if(blob->timeoutCounter > 10){
				[persistentBlobs removeObject:blob];
				[blob release];
			} else {
				
				
			}			
		}
		
		
		
		
	}	
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
	saveImg.saveImage("blobTracker" +ofToString(trackerNumber)+"Background-" + ofToString(0) + ".png");
	
}
-(void) loadBackground{
	ofImage loadImg;
	if (loadImg.loadImage("blobTracker" +ofToString(trackerNumber)+"Background-" + ofToString(0) + ".png")) {
		grayBg->setFromPixels(loadImg.getPixels(), loadImg.getWidth(), loadImg.getHeight());
//		return true;
	} else {
//		return false;
	}
	
}


-(void) performBlobTracking:(id)param{
	while(1){
		
		if(threadUpdateContour){
			pthread_mutex_lock(&mutex);			
			contourFinder->findContours(*threadGrayDiff, 20, (cw*ch)/3, 10, false, true);	
			threadUpdateContour = false;			
			pthread_mutex_unlock(&mutex);
		}
		
		[NSThread sleepForTimeInterval:0.01];
	}
	
}

-(IBAction) setBlurSliderValue:(id)sender{
	if(valuesLoaded){
		[userDefaults setValue:[NSNumber numberWithFloat:[sender floatValue]] forKey:[NSString stringWithFormat:@"tracker%d.blur", trackerNumber]];
	}
}
-(IBAction) setThresholdSliderValue:(id)sender{
	if(valuesLoaded){
		[userDefaults setValue:[NSNumber numberWithFloat:[sender floatValue]] forKey:[NSString stringWithFormat:@"tracker%d.threshold", trackerNumber]];
	}
}
-(IBAction) setPostBlurSliderValue:(id)sender{
	if(valuesLoaded){
		[userDefaults setValue:[NSNumber numberWithFloat:[sender floatValue]] forKey:[NSString stringWithFormat:@"tracker%d.postBlur", trackerNumber]];
	}
}
-(IBAction) setPostThresholdSliderValue:(id)sender{
	if(valuesLoaded){
		[userDefaults setValue:[NSNumber numberWithFloat:[sender floatValue]] forKey:[NSString stringWithFormat:@"tracker%d.postThreshold", trackerNumber]];
	}
}
-(IBAction) setActiveButtonValue:(id)sender{
	if(valuesLoaded){
		[userDefaults setValue:[NSNumber numberWithInt:[sender intValue]] forKey:[NSString stringWithFormat:@"tracker%d.active", trackerNumber]];
	}
}



@end
