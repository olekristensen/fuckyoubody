//
//  Cameras.h
//  openFrameworks
//
//  Created by Jonas Jongejan on 02/12/09.
//  Copyright 2009 HalfdanJ. All rights reserved.
//

#pragma once

#import "GLee.h"

#import <Cocoa/Cocoa.h>

#include "Plugin.h"
#include "ofMain.h"
#include "Camera.h"



@interface Cameras : ofPlugin {
	IBOutlet NSView * cam0settings;
	IBOutlet NSView * cam1settings;
	IBOutlet NSView * cam2settings;
	Camera * cam[3];
	
	int width;
	int height;
}
@property (readonly) int width;
@property (readonly) int height;

- (Camera*)getCameraWithId:(int)cameraId;
- (ofTexture*)getTexture:(int)cameraId;
- (unsigned char*)getPixels:(int)cameraId;
- (BOOL) isFrameNew:(int)cameraId;
- (int) getWidth:(int)cameraId;
- (int) getHeight:(int)cameraId;

-(IBAction) recordAll:(id)sender;
@end
