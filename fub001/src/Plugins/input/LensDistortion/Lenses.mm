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
	
	userDefaults = [[NSUserDefaults standardUserDefaults] retain];

	boxSize = [box1 frame].size;
	
}

-(void) setup{
	cwidth = [GetPlugin(Cameras) width];
    cheight = [GetPlugin(Cameras) height];
    csize = cvSize( cwidth,cheight );
	
	for(int i=0;i<3;i++){
		cameraCalibrator[i] = new ofCvCameraCalibration();
		cameraCalibrator[i]->allocate(csize, 7,7);

		for (int j = 0; j < 4; j++) {
			cameraCalibrator[i]->distortionCoeffs[j] = [userDefaults floatForKey:[NSString stringWithFormat:@"Lenses.%d.distortion.%d",i+1, j]];
		}
		
		for (int j = 0; j < 9; j++) {
			cameraCalibrator[i]->camIntrinsics[j] = [userDefaults floatForKey:[NSString stringWithFormat:@"Lenses.%d.matrix.%d",i+1, j]];
		}
	}
	
	for(int i=0;i<3;i++){
		[self updateInterfaceForCamera:i+1 withCalibrator:cameraCalibrator[i]];
	}	
}

-(void) update:(const CVTimeStamp *)outputTime{
	

}

-(void) controlDraw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)timeStamp{
	
}


-(IBAction) addImage:(id)sender{
	int cameraId = -1;
	
	if (sender == addImageButton1) {
		cameraId = 1;
	}
	
	if (sender == addImageButton2) {
		cameraId = 2;
	}
	
	if (sender == addImageButton3) {
		cameraId = 3;
	}
}

-(IBAction) calibrate:(id)sender{
	
}

-(IBAction) reset:(id)sender{
	
}

-(void) drawImage:(IplImage*)image atLocationX:(float)x Y:(float)y withWidth:(float)width height: (float)height{
	
}

-(ofxPoint2f) undistortPoint:(ofxPoint2f)point fromCameraId:(int)cameraId{
	
}

-(void)updateInterfaceForCamera:(int)cameraId withCalibrator:(ofCvCameraCalibration*)theCameraCalibrator{

	
	NSLog(@"Lenses updateInterfaceForCamera:%d withCalibrator:", cameraId);

	NSForm * distortionForm;
	NSForm * matrixForm;
	NSButton * resetButton;
	NSButton * calibrateButton;
	NSButton * addImageButton;
	NSButton * showCalibratedButton;
	NSBox * box;
	
	int calibrationState = 0;
	
	enum calibrationStates {
		CALIBRATION_VIRGIN,
		CALIBRATION_ADDEDIMAGES,
		CALIBRATION_CALIBRATED
	};
	
	BOOL calibrationDone;
	
	
	if (cameraId == 1) {
		distortionForm = cameraDistortion1;
		matrixForm = cameraMatrix1;
		resetButton = reset1;
		calibrateButton = calibrateButton1;
		addImageButton = addImageButton1;
		showCalibratedButton = showCalibrated1;
		box = box1;
	}
	if (cameraId == 2) {
		distortionForm = cameraDistortion2;
		matrixForm = cameraMatrix2;
		distortionForm = cameraDistortion2;
		matrixForm = cameraMatrix2;
		resetButton = reset2;
		calibrateButton = calibrateButton2;
		addImageButton = addImageButton2;
		showCalibratedButton = showCalibrated2;
		box = box2;
	}
	if (cameraId == 3) {
		distortionForm = cameraDistortion3;
		matrixForm = cameraMatrix3;
		distortionForm = cameraDistortion3;
		matrixForm = cameraMatrix3;
		resetButton = reset3;
		calibrateButton = calibrateButton3;
		addImageButton = addImageButton3;
		showCalibratedButton = showCalibrated3;
		box = box3;
	}
	
	float sumForCalibration = 0;
	
	for (int i = 0; i < 4; i++) {
		[[distortionForm cellWithTag:i] setFloatValue:theCameraCalibrator->distortionCoeffs[i]];
		sumForCalibration += theCameraCalibrator->distortionCoeffs[i];
	}

	for (int i = 0; i < 9; i++) {
		[[matrixForm cellWithTag:i] setFloatValue:theCameraCalibrator->camIntrinsics[i]];
		sumForCalibration += theCameraCalibrator->camIntrinsics[i];
	}
	
	if (sumForCalibration == 0.0) {
		calibrationState = CALIBRATION_VIRGIN;
	}
		
	if (calibrationState == CALIBRATION_VIRGIN) {
		if (![box isHidden]) {
			[[box animator] setHidden:YES];
		}
	}

}

@end
