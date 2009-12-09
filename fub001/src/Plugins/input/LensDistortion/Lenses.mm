/*
 *  Lenses.cpp
 *  openFrameworks
 *
 *  Created by Fuck You Buddy on 03/12/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include "Lenses.h"

@implementation Lenses

-(void) initPlugin{
	
	pthread_mutex_init(&mutex, NULL);
	boxSize = [box1 frame].size;
	
	NSBundle *bundle = [NSBundle bundleForClass:[Lenses class]];
	
	NSURL * anUrl = [NSURL fileURLWithPath:[bundle pathForResource:@"chessboard" ofType:@"pdf"]];
	
	PDFDocument * aPdfDocument;
	aPdfDocument = [[[PDFDocument alloc] initWithURL:anUrl ] retain];
	
	[checkerBoardPDFView setDocument:aPdfDocument];
	
	
}

-(void) setup{
	cwidth = [GetPlugin(Cameras) width];
    cheight = [GetPlugin(Cameras) height];
    csize = cvSize( cwidth,cheight );
	
	for(int i=0;i<3;i++){
		cameraCalibrator[i] = new ofCvCameraCalibration();
		cameraCalibrator[i]->allocate(csize, 7,7);
		originalImage[i] = new ofxCvColorImage();
		originalImage[i]->allocate( cwidth,cheight );
		undistortedImage[i] = new ofxCvGrayscaleImage();
		undistortedImage[i]->allocate( cwidth,cheight );
		originalImageGreyscale[i] = new ofxCvGrayscaleImage();
		originalImageGreyscale[i]->allocate( cwidth,cheight );
		calibrationState[i] = CALIBRATION_VIRGIN;
		
		NSUserDefaults *userDefaults = [[NSUserDefaults standardUserDefaults] retain];
		
		for (int j = 0; j < 4; j++) {
			cameraCalibrator[i]->distortionCoeffs[j] = [userDefaults floatForKey:[NSString stringWithFormat:@"Lenses.%d.distortion.%d",i+1, j]];
		}
		
		for (int j = 0; j < 9; j++) {
			cameraCalibrator[i]->camIntrinsics[j] = [userDefaults floatForKey:[NSString stringWithFormat:@"Lenses.%d.matrix.%d",i+1, j]];
		}
		
		[userDefaults release];
		
		justCaptured[i] = NO;
		justFailedToSeeChessboard[i] = YES;
	}
	
	for(int i=0;i<3;i++){
		[self updateInterfaceForCamera:i+1 withCalibrator:cameraCalibrator[i]];
	}
	[showCalibratedButton1 setState:NSOffState];
	[showCalibratedButton2 setState:NSOffState];
	[showCalibratedButton3 setState:NSOffState];
	
	font = new ofTrueTypeFont();
	font->loadFont("LucidaGrande.ttc",18, true, true, true);
}

-(void) update:(const CVTimeStamp *)outputTime{	
	for(int i=0;i<3;i++){
		if([[GetPlugin(Cameras) getCameraWithId:i] camInited] || ![[GetPlugin(Cameras) getCameraWithId:i] live]){
			pthread_mutex_lock(&mutex);
			unsigned char * somePixel = [[GetPlugin(Cameras) getCameraWithId:i] getPixels];
			originalImageGreyscale[i]->setFromPixels(somePixel, cwidth, cheight );
			hasUndistortedImage[i] = NO;
			originalImage[i]->setFromGrayscalePlanarImages(*originalImageGreyscale[i], *originalImageGreyscale[i], *originalImageGreyscale[i] );
			pthread_mutex_unlock(&mutex);
		}
	}
}

-(void) controlDraw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)timeStamp{
	NSButton * showCalibratedButton;
	
	ofSetColor(255, 255, 255, 255);
	ofEnableAlphaBlending();
	
	float w = ofGetWidth() / 3.0;
	float h = w * (480.0/640.0);
	float windowHeight = ofGetHeight();
	
	h = fminf(h,windowHeight);
	
	glPushMatrix();{
		for(int i=0;i<3;i++){
			
			if (i == 0) {
				showCalibratedButton = showCalibratedButton1;
			}
			if (i == 1) {
				showCalibratedButton = showCalibratedButton2;
			}
			if (i == 2) {
				showCalibratedButton = showCalibratedButton3;
			}
			
			if(calibrationState[i] == CALIBRATION_CALIBRATED && [showCalibratedButton state] == NSOnState && timeInterval - calibrationTime[i] > 4 ){
				if (!hasUndistortedImage[i]) {
					pthread_mutex_lock(&mutex);
					cvCvtColor( originalImage[i]->getCvImage(), undistortedImage[i]->getCvImage(), CV_RGB2GRAY );
					undistortedImage[i]->flagImageChanged();
					undistortedImage[i]->undistort( cameraCalibrator[i]->distortionCoeffs[0], cameraCalibrator[i]->distortionCoeffs[1],
												   cameraCalibrator[i]->distortionCoeffs[2], cameraCalibrator[i]->distortionCoeffs[3],
												   cameraCalibrator[i]->camIntrinsics[0], cameraCalibrator[i]->camIntrinsics[4],
												   cameraCalibrator[i]->camIntrinsics[2], cameraCalibrator[i]->camIntrinsics[5] );   
					hasUndistortedImage[i] = YES;
					pthread_mutex_unlock(&mutex);
				}
				undistortedImage[i]->draw(0, 0,w,h);
			} else {
				originalImage[i]->draw(0, 0,w,h);
			}
			
			
			double drawSeconds = timeInterval;
			
			{ // just captured an image
				
				if(justCaptured[i]){
					captureTime[i] = drawSeconds;
					justCaptured[i] = NO;
				}
				
				int numImages = cameraCalibrator[i]->colorImages.size();
				
				if(numImages > 0 && calibrationState[i] != CALIBRATION_CALIBRATED){ 
					
					double captureSeconds = captureTime[i];
					double secondsSinceCapture = drawSeconds - captureSeconds;
					
					if(secondsSinceCapture < 2.0 ){
						ofxCvColorImage anImage;
						anImage.allocate(cwidth, cheight);
						anImage = cameraCalibrator[i]->colorImages[numImages-1];
						anImage.setAnchorPoint(0,0);
						if(secondsSinceCapture > 0.5){
							ofSetColor(0, 0, 0, 255-(255*(((drawSeconds-0.5) - captureSeconds))));
							ofRect(0, 0, w, h);
							ofSetColor(255, 255, 255, 255-(255*(((drawSeconds-1.0) - captureSeconds)*3)));
							float xPos = 90.0;
							float xStep = (w - (xPos + 15.0))/11.0;
							float scaler = 1.0-sqrtf(1.0-fminf(1.0,fmaxf(0.0,(((drawSeconds-0.5) - captureSeconds)*1.5))));
							float scalerFaster = 1.0-sqrtf(1.0-fminf(1.0,fmaxf(0.0,(((drawSeconds-0.5) - captureSeconds)*2))));
							anImage.draw((xPos+(xStep*fmin(numImages, 10)))*scalerFaster,
										 h*scaler,
										 w-((w-(xStep))*scalerFaster),
										 h*(1.0-scaler));
						} else {
							anImage.draw(0, 0, w, h);
						}
						ofFill();
						ofSetColor(128, 255, 64, 128-(128*((drawSeconds - captureSeconds)*5)));
						ofRect(0, 0, w, h);
					}
					
					ofSetColor(255, 255, 255, 255);
				}
			} // end just captured image
			
			
			
			{ // just failed to see the chessboard
				
				if(justFailedToSeeChessboard[i]){
					failedTime[i] = drawSeconds;
					justFailedToSeeChessboard[i] = NO;
				}
				
				if(calibrationState[i] != CALIBRATION_CALIBRATED){ 
					
					double failedSeconds = failedTime[i];
					double secondsSinceFailed = drawSeconds - failedSeconds;
					
					if(secondsSinceFailed < 1.0 ){
						ofFill();
						ofSetColor(255, 0, 255, 128-(128*((drawSeconds - failedSeconds)*5)));
						ofRect(0, 0, w, h);
					}
					
					if(secondsSinceFailed < 2.0 ){
						string text = "No Chessboard";
						ofSetColor(255, 0, 255, 255-(255*((drawSeconds-1 - failedSeconds)*3)));
						font->drawString(text, 
										 (w*0.5) - (font->stringWidth(text)/2.0),
										 (h*0.95) - (font->stringHeight(text)/2.0)
										 );
						
					}
					
					
					ofSetColor(255, 255, 255, 255);
				}
			} // end failed to see the chessboard
			
			
			{ // just calibrated
				
				if(justCalibrated[i]){
					calibrationTime[i] = drawSeconds;
					justCalibrated[i] = NO;
				}
				
				int numImages = cameraCalibrator[i]->undistortedImg.size();
				
				if(numImages > 0 && calibrationState[i] == CALIBRATION_CALIBRATED){ 
					
					double calibrationSeconds = calibrationTime[i];
					double secondsSinceCalibration = drawSeconds - calibrationSeconds;
					
					if(secondsSinceCalibration < 5.5 ){
						ofFill();
						if(secondsSinceCalibration > 4.5){
							ofSetColor(0, 0, 0, 255-(255.0*(((drawSeconds-5) - calibrationSeconds)*3)));
						} else {
							ofSetColor(0, 0, 0, (255*((drawSeconds - calibrationSeconds)*3)));
						}
						ofRect(0, 0, w, h);
						
						
						ofxCvColorImage anImage;
						anImage.allocate(cwidth, cheight);
						anImage = cameraCalibrator[i]->colorImages[numImages-1];
						
						ofxCvColorImage aCalibratedImage;
						aCalibratedImage.allocate(cwidth, cheight);
						aCalibratedImage = cameraCalibrator[i]->undistortedImg[numImages-1];
						
						if(secondsSinceCalibration < 4 && 1.0 < secondsSinceCalibration){
							ofSetColor(255, 255, 255, (255*((drawSeconds-1.5 - calibrationSeconds)*3)));
							anImage.draw(0, 0, w, h);
						}
						if(secondsSinceCalibration < 4 && 0.5 < secondsSinceCalibration){
							ofSetColor(255, 255, 255, (255*((drawSeconds-1.0 - calibrationSeconds)*3)));
							string text = "Calibrating...";
							font->drawString(text, 
											 (w*0.5) - (font->stringWidth(text)/2.0),
											 (h*0.95) - (font->stringHeight(text)/2.0)
											 );
							
							
						}
						if(secondsSinceCalibration > 2.5){
							ofSetColor(255, 255, 255, (255*(((drawSeconds-3) - calibrationSeconds)*3)));
							if(secondsSinceCalibration > 4){
								ofSetColor(255, 255, 255, 255-(255.0*(((drawSeconds-4.5) - calibrationSeconds)*3)));
							} 
							aCalibratedImage.draw(0, 0, w, h);
							string text = "Calibrated";
							font->drawString(text, 
											 (w*0.5) - (font->stringWidth(text)/2.0),
											 (h*0.95) - (font->stringHeight(text)/2.0)
											 );
						} 
					}
					
					ofSetColor(255, 255, 255, 255);
				}
			}// end just calibrated
			
			glTranslated(w, 0, 0);
		}
	}glPopMatrix();
}


-(IBAction) addImage:(id)sender{
	int cameraId = -1;
	
	NSLevelIndicator * imageCount;
	
	if (sender == addImageButton1) {
		cameraId = 1;
		imageCount = imageCount1;
	}
	
	if (sender == addImageButton2) {
		cameraId = 2;
		imageCount = imageCount2;
	}
	
	if (sender == addImageButton3) {
		cameraId = 3;
		imageCount = imageCount3;
	}
	
	if(cameraId > 0){
		pthread_mutex_lock(&mutex);
		if(cameraCalibrator[cameraId-1]->addImage(originalImage[cameraId-1]->getCvImage())){
			justCaptured[cameraId-1] = YES;
			[self updateInterfaceForCamera:(int)cameraId withCalibrator:(ofCvCameraCalibration*)cameraCalibrator[cameraId-1]];	
		} else {
			justFailedToSeeChessboard[cameraId-1] = YES;
		}
		
		pthread_mutex_unlock(&mutex);
	}
}

-(IBAction) calibrate:(id)sender{
	int cameraId = -1;
	
	if (sender == calibrateButton1) {
		cameraId = 1;
	}
	
	if (sender == calibrateButton2) {
		cameraId = 2;
	}
	
	if (sender == calibrateButton3) {
		cameraId = 3;
	}
	
	if(cameraId > 0){
		cameraCalibrator[cameraId-1]->calibrate();
		cameraCalibrator[cameraId-1]->undistort();
		justCalibrated[cameraId-1] = YES;
		[self updateInterfaceForCamera:(int)cameraId withCalibrator:(ofCvCameraCalibration*)cameraCalibrator[cameraId-1]];
		if(cameraId == 1)
			[showCalibratedButton1 setState:NSOnState];
		if(cameraId == 2)
			[showCalibratedButton2 setState:NSOnState];
		if(cameraId == 3)
			[showCalibratedButton3 setState:NSOnState];
	}
}

-(IBAction) reset:(id)sender{
	int cameraId = -1;
	
	if (sender == reset1) {
		cameraId = 1;
	}
	
	if (sender == reset2) {
		cameraId = 2;
	}
	
	if (sender == reset3) {
		cameraId = 3;
	}
	
	if(cameraId > 0){
		
		int choice = NSAlertDefaultReturn;
		
		NSString *title = [NSString stringWithFormat:NSLocalizedString(@"Do you want to reset the Lens Calibration?", @"Title of alert panel which comes up when user chooses Quit")];
		choice = NSRunAlertPanel(title, 
								 NSLocalizedString(@"Resetting is not undoable\n\nIf you reset the calibration you will have to do the Chessboard Dance again.", @"Warning in the alert panel which comes up when user chooses Quit and there are unsaved documents."), 
								 NSLocalizedString(@"Reset", @"Choice (on a button) given to user which allows him/her to quit the application even though there are unsaved documents."),
								 NSLocalizedString(@"Cancel", @"Choice (on a button) given to user which allows him/her to review all unsaved documents if he/she quits the application without saving them all first."),     // ellipses
								 nil);
		
		if (choice == NSAlertDefaultReturn){           /* Cancel */
			
			
			cameraCalibrator[cameraId-1] = new ofCvCameraCalibration();
			cameraCalibrator[cameraId-1]->allocate(csize, 7,7);
			[self updateInterfaceForCamera:(int)cameraId withCalibrator:(ofCvCameraCalibration*)cameraCalibrator[cameraId-1]];	
			
		}
	}
	
}

-(ofxPoint2f) undistortPoint:(ofxPoint2f)point fromCameraId:(int)cameraId{
	if (cameraId <= 2 && 0 <= cameraId) {
		if (calibrationState[cameraId] == CALIBRATION_CALIBRATED) {
			ofxPoint2f p = cameraCalibrator[cameraId]->undistortPoint(point.x, point.y);
			return p;
		}
	}
	return point;
}

-(ofxPoint2f) distortPoint:(ofxPoint2f)point fromCameraId:(int)cameraId{
	if (cameraId <= 2 && 0 <= cameraId) {
		if (calibrationState[cameraId] == CALIBRATION_CALIBRATED) {
			ofxPoint2f p = cameraCalibrator[cameraId]->distortPoint(point.x, point.y);
			return p;
		}
	}
	return point;
}

-(ofxCvGrayscaleImage*) getUndistortedImageFromCameraId:(int)cameraId{
	
	int i = cameraId;
	
	if(calibrationState[i] == CALIBRATION_CALIBRATED){
		if (!hasUndistortedImage[i]) {
			pthread_mutex_lock(&mutex);
			cvCvtColor( originalImage[i]->getCvImage(), undistortedImage[i]->getCvImage(), CV_RGB2GRAY );
			undistortedImage[i]->flagImageChanged();
			undistortedImage[i]->undistort( cameraCalibrator[i]->distortionCoeffs[0], cameraCalibrator[i]->distortionCoeffs[1],
										   cameraCalibrator[i]->distortionCoeffs[2], cameraCalibrator[i]->distortionCoeffs[3],
										   cameraCalibrator[i]->camIntrinsics[0], cameraCalibrator[i]->camIntrinsics[4],
										   cameraCalibrator[i]->camIntrinsics[2], cameraCalibrator[i]->camIntrinsics[5] );   
			hasUndistortedImage[i] = YES;
			pthread_mutex_unlock(&mutex);
		}
	return undistortedImage[i];
	}
	return originalImageGreyscale[i];
}

-(BOOL) isCalibratedFromCameraId:(int)cameraId{
	return (calibrationState[cameraId] == CALIBRATION_CALIBRATED);
}

-(void)updateInterfaceForCamera:(int)cameraId withCalibrator:(ofCvCameraCalibration*)theCameraCalibrator{
	
	
	NSLog(@"Lenses updateInterfaceForCamera:%d withCalibrator:", cameraId);
	
	NSForm * distortionForm;
	NSForm * matrixForm;
	NSButton * resetButton;
	NSButton * calibrateButton;
	NSButton * addImageButton;
	NSButton * showCalibratedButton;
	NSLevelIndicator * imageCount;
	NSBox * box;
	
	BOOL calibrationDone;
	
	
	if (cameraId == 1) {
		distortionForm = cameraDistortion1;
		matrixForm = cameraMatrix1;
		resetButton = reset1;
		calibrateButton = calibrateButton1;
		addImageButton = addImageButton1;
		showCalibratedButton = showCalibratedButton1;
		box = box1;
		imageCount = imageCount1;
	}
	if (cameraId == 2) {
		distortionForm = cameraDistortion2;
		matrixForm = cameraMatrix2;
		distortionForm = cameraDistortion2;
		matrixForm = cameraMatrix2;
		resetButton = reset2;
		calibrateButton = calibrateButton2;
		addImageButton = addImageButton2;
		showCalibratedButton = showCalibratedButton2;
		box = box2;
		imageCount = imageCount2;
		
	}
	if (cameraId == 3) {
		distortionForm = cameraDistortion3;
		matrixForm = cameraMatrix3;
		distortionForm = cameraDistortion3;
		matrixForm = cameraMatrix3;
		resetButton = reset3;
		calibrateButton = calibrateButton3;
		addImageButton = addImageButton3;
		showCalibratedButton = showCalibratedButton3;
		box = box3;
		imageCount = imageCount3;
	}
	
	float sumForCalibration = 0;
	
	NSUserDefaults *userDefaults = [[NSUserDefaults standardUserDefaults] retain];
	
	for (int i = 0; i < 4; i++) {
		[[distortionForm cellWithTag:i] setFloatValue:theCameraCalibrator->distortionCoeffs[i]];
		[[distortionForm cellWithTag:i] setEnabled:NO];
		[userDefaults setValue:[NSNumber numberWithDouble:theCameraCalibrator->distortionCoeffs[i]] forKey:[NSString stringWithFormat:@"Lenses.%d.distortion.%d",cameraId, i]];
		sumForCalibration += theCameraCalibrator->distortionCoeffs[i];
	}
	[distortionForm setNeedsDisplay:YES];
	
	for (int i = 0; i < 9; i++) {
		[[matrixForm cellWithTag:i] setFloatValue:theCameraCalibrator->camIntrinsics[i]];
		[[matrixForm cellWithTag:i] setEnabled:NO];
		[userDefaults setValue:[NSNumber numberWithDouble:theCameraCalibrator->camIntrinsics[i]] forKey:[NSString stringWithFormat:@"Lenses.%d.matrix.%d",cameraId, i]];
		sumForCalibration += theCameraCalibrator->camIntrinsics[i];
	}
	[matrixForm setNeedsDisplay:YES];
	
	[userDefaults release];	
	
	if (sumForCalibration == 0.0) {
		calibrationState[cameraId-1] = CALIBRATION_VIRGIN;
	} else {
		calibrationState[cameraId-1] = CALIBRATION_CALIBRATED;
	}
	
	if (calibrationState[cameraId-1] == CALIBRATION_VIRGIN) {
		if (![box isHidden]) {
			[[box animator] setHidden:YES];
		}
		[addImageButton setEnabled:YES];
		[addImageButton setHidden:NO];
		[calibrateButton setEnabled:NO];
		[calibrateButton setHidden:YES];
		[showCalibratedButton setEnabled:NO];
		[showCalibratedButton setHidden:YES];
	}
	
	[NSAnimationContext beginGrouping];
	
	[[NSAnimationContext currentContext] setDuration:2.0];
	
	[[imageCount animator] setHidden:YES];
	[imageCount setIntValue: theCameraCalibrator->colorImages.size()];
	[[imageCount animator] setHidden:NO];
	[imageCount setNeedsDisplay:YES];
	
	[NSAnimationContext endGrouping];
	
	if(theCameraCalibrator->colorImages.size() > 0 &&  calibrationState[cameraId-1] != CALIBRATION_CALIBRATED ){
		calibrationState[cameraId-1] = CALIBRATION_ADDEDIMAGES;
		if(theCameraCalibrator->colorImages.size() > [imageCount warningValue]){
			[calibrateButton setEnabled:YES];
			[[calibrateButton animator] setHidden:NO];
			
		}
	}
	
	if (calibrationState[cameraId-1] == CALIBRATION_CALIBRATED) {
		[addImageButton setEnabled:NO];
		[addImageButton setHidden:YES];
		[showCalibratedButton setEnabled:YES];
		[showCalibratedButton setHidden:NO];
		[calibrateButton setEnabled:NO];
		[resetButton setEnabled:YES];
		
		if ([box isHidden]) {
			[[box animator] setHidden:NO];
		}
		
	}
	
}

@end
