#pragma once

#import "GLee.h"

#import <Cocoa/Cocoa.h>

#include "Plugin.h"
#include "ofMain.h"
//#include "BlobTracking.h"
#include "TrackerObject.h"
#include "Filter.h"


@interface Tracking : ofPlugin {
	IBOutlet NSView * tracker0settings;
	IBOutlet NSView * tracker1settings;
	IBOutlet NSView * tracker2settings;
	TrackerObject * trackerObj[3];
	
	
	IBOutlet NSButton * wallTracking;
	IBOutlet NSSlider* wallTrackingC1X;
	IBOutlet NSSlider* wallTrackingC1Y;
	Filter * wallTracking[8];

}

-(TrackerObject*) trackerNumber:(int)n;

-(void) mouseUpPoint:(NSPoint)theEvent;
-(void) mouseDownPoint:(NSPoint)theEvent;
-(void) mouseDraggedPoint:(NSPoint)theEvent;
@end
