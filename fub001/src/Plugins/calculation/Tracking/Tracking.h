#pragma once

#import "GLee.h"

#import <Cocoa/Cocoa.h>

#include "Plugin.h"
#include "ofMain.h"
//#include "BlobTracking.h"
#include "TrackerObject.h"

@interface Tracking : ofPlugin {
	IBOutlet NSView * tracker0settings;
	IBOutlet NSView * tracker1settings;
	IBOutlet NSView * tracker2settings;
	TrackerObject * trackerObj[3];
	
}

-(TrackerObject*) trackerNumber:(int)n;

@end
