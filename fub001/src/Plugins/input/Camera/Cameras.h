/*
 *  Camera.h
 *  openFrameworks
 *
 *  Created by Fuck You Buddy on 23/11/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#pragma once

#import "GLee.h"

#import <Cocoa/Cocoa.h>
#include "Plugin.h"
#include "ofMain.h"
#include "FrostCameras.h"


@interface Cameras: ofPlugin {
	
	FrostCameras * c; 

	NSUserDefaults * userDefaults;

	int cameraThreadTimer;
	int cameraTimer;
	int numCameras;
	bool cameraSetupCalled;
	unsigned long int cameraLastBlinkCount[3];
	
	uint64_t cameraGUIDs[3];
	
	enum camera_states {
		camera_state_running,
		camera_state_closing,
		camera_state_starting
	};
	
	int camera_state;
	
	IBOutlet NSTextField * CameraGUID1;
	IBOutlet NSTextField * CameraGUID2;
	IBOutlet NSTextField * CameraGUID3;
	
	IBOutlet NSSlider * cameraShutter1;
	IBOutlet NSSlider * cameraShutter2;
	IBOutlet NSSlider * cameraShutter3;
	
	IBOutlet NSSlider * cameraExposure1;
	IBOutlet NSSlider * cameraExposure2;
	IBOutlet NSSlider * cameraExposure3;
	
	IBOutlet NSSlider * cameraGain1;
	IBOutlet NSSlider * cameraGain2;
	IBOutlet NSSlider * cameraGain3;
	
	IBOutlet NSSlider * cameraGamma1;
	IBOutlet NSSlider * cameraGamma2;
	IBOutlet NSSlider * cameraGamma3;
	
	IBOutlet NSSlider * cameraBrightness1;
	IBOutlet NSSlider * cameraBrightness2;
	IBOutlet NSSlider * cameraBrightness3;
	
	ofTrueTypeFont * lucidaGrande;

}
@property (assign, readwrite) FrostCameras * c;

-(IBAction) pressButton:(id)sender;

-(IBAction)		cameraBindGuid1:(id)sender;
-(IBAction)		cameraBindGuid2:(id)sender;
-(IBAction)		cameraBindGuid3:(id)sender;

-(void)			cameraUpdateGUIDs;

@end
