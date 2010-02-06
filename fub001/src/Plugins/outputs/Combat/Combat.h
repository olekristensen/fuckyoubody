#pragma once

#import "GLee.h"

#import <Cocoa/Cocoa.h>
#include "Plugin.h"
#include "ofMain.h"


@interface Combat : ofPlugin {
	IBOutlet NSSlider * rotation;
	float rot;
}

@end
