/*
 *  Lenses.h
 *  openFrameworks
 *
 *  Created by Fuck You Buddy on 03/12/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */


#pragma once

#import "GLee.h"

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

#include "Plugin.h"
#include "ofMain.h"
#include "Cameras.h"
#include "ofCvCameraCalibration.h"

@interface Lenses : ofPlugin {

	ofCvCameraCalibration * cameraCalibrator[3];
	
	IBOutlet NSLevelIndicator * imageCount1;
	IBOutlet NSLevelIndicator * imageCount2;
	IBOutlet NSLevelIndicator * imageCount3;
	
	IBOutlet NSForm * cameraMatrix1; //3x3 table views
	IBOutlet NSForm * cameraMatrix2;
	IBOutlet NSForm * cameraMatrix3;
	
	IBOutlet NSForm * cameraDistortion1; // 4x1 table view
	IBOutlet NSForm * cameraDistortion2;
	IBOutlet NSForm * cameraDistortion3;
	
	IBOutlet NSButton * addImageButton1;
	IBOutlet NSButton * addImageButton2;
	IBOutlet NSButton * addImageButton3;

	IBOutlet NSButton * calibrateButton1;
	IBOutlet NSButton * calibrateButton2;
	IBOutlet NSButton * calibrateButton3;

	IBOutlet NSButton * showCalibratedButton1;
	IBOutlet NSButton * showCalibratedButton2;
	IBOutlet NSButton * showCalibratedButton3;
	
	IBOutlet NSBox * box1;
	IBOutlet NSBox * box2;
	IBOutlet NSBox * box3;

	IBOutlet NSButton * reset1;
	IBOutlet NSButton * reset2;
	IBOutlet NSButton * reset3;
	
	IBOutlet PDFView * checkerBoardPDFView;
	
	pthread_mutex_t mutex;
	
	ofxCvColorImage * originalImage[3];
    ofxCvGrayscaleImage * undistortedImage[3];

	CvSize csize;
	
	BOOL justCaptured[3];
	BOOL justFailedToSeeChessboard[3];
	BOOL justCalibrated[3];
	
	CFTimeInterval captureTime[3];
	CFTimeInterval failedTime[3];
	CFTimeInterval calibrationTime[3];
	
	BOOL hasUndistortedImage[3];

	int cwidth;
    int cheight;
	
	int calibrationState[3];
	
	ofTrueTypeFont	* font;

	enum calibrationStates {
		CALIBRATION_VIRGIN,
		CALIBRATION_ADDEDIMAGES,
		CALIBRATION_CALIBRATED
	};
	
	NSSize boxSize;

}

-(void)updateInterfaceForCamera:(int)cameraId withCalibrator:(ofCvCameraCalibration*)theCameraCalibrator;

-(IBAction) addImage:(id)sender;
-(IBAction) calibrate:(id)sender;
-(IBAction) reset:(id)sender;
-(IBAction) printChessboard:(id)sender;

-(void) drawImage:(IplImage*)image atLocationX:(float)x Y:(float)y withWidth:(float)width height: (float)height;

-(ofxPoint2f) undistortPoint:(ofxPoint2f)point fromCameraId:(int)cameraId;
-(ofxCvGrayscaleImage*) getUndistortedImageFromCameraId:(int)cameraId;


@end