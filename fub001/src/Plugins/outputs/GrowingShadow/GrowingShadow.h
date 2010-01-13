#pragma once

#import "GLee.h"

#import <Cocoa/Cocoa.h>
#include "Plugin.h"
#include "ofMain.h"
#include "ofxVectorMath.h"


@interface ShadowLineSegment : NSObject
{
	
}
@end


@interface GrowingShadow : ofPlugin {
	IBOutlet NSSlider * growthSpeedSlider;
}

-(IBAction) startGrow:(id)sender;

@end
