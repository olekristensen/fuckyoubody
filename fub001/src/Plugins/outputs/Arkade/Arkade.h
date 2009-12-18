#pragma once

#import "GLee.h"

#import <Cocoa/Cocoa.h>
#include "Plugin.h"
#include "ofMain.h"

@interface Arkade : ofPlugin {
	ofVideoPlayer * wall;
		ofVideoPlayer * floor;
}

@end
