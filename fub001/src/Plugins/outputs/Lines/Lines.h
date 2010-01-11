#pragma once

#import "GLee.h"

#import <Cocoa/Cocoa.h>
#include "Plugin.h"
#include "ofMain.h"
#include "ofxVectorMath.h"

@interface Lines : ofPlugin {
	IBOutlet NSSegmentedControl * trackingDirection;
}

@end
