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


@interface Camera: ofPlugin {
	ofImage * img;
	NSString * GUID;
	
	float cameraBrightness;
	float cameraExposure;
	float cameraShutter;
	float cameraGamma;
	float cameraGain;

}

-(IBAction) pressButton:(id)sender;

@end
