/*
 *  LensDistortion.h
 *  openFrameworks
 *
 *  Created by Fuck You Buddy on 03/12/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */


#pragma once

#import "GLee.h"

#import <Cocoa/Cocoa.h>

#include "Plugin.h"
#include "ofMain.h"
#include "Cameras.h"
#include "ofCvCameraCalibration.h"

@interface LensDistortion : ofPlugin {

	ofCvCameraCalibration * cameraCalibrator[3];
	
	IBOutlet NSTextField * imageCount1;
	IBOutlet NSTextField * imageCount2;
	IBOutlet NSTextField * imageCount3;
	
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

	IBOutlet NSButton * showCalibrated1;
	IBOutlet NSButton * showCalibrated2;
	IBOutlet NSButton * showCalibrated3;
	
}

-(IBAction) addImage:(id)sender;
-(IBAction) calibrate:(id)sender;

-undistortPoint:(ofxPoint2f)point fromCameraId:(int)cameraId;

@end