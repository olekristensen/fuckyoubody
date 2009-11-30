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
	ofImage * img;
	NSString * GUID;
	
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
	
	float cameraBrightness[3];
	float cameraExposure[3];
	float cameraShutter[3];
	float cameraGamma[3];
	float cameraGain[3];

	ofTrueTypeFont * lucidaGrande;

}
@property (assign, readwrite) FrostCameras * c;

-(IBAction) pressButton:(id)sender;

@end
