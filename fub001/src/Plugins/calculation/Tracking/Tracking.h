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
	TrackerObject * trackerObj[1];
}

-(TrackerObject*) trackerNumber:(int)n;

-(void) mouseUpPoint:(NSPoint)theEvent;
-(void) mouseDownPoint:(NSPoint)theEvent;
-(void) mouseDraggedPoint:(NSPoint)theEvent;
@end
