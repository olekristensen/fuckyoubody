#pragma once

#import "GLee.h"

#import <Cocoa/Cocoa.h>
#include "Plugin.h"
#include "ofMain.h"
#include "ofxVectorMath.h"


@interface ShadowLineSegment : NSObject
{
@public
	bool locked;
	float length;
	float intendedRotation;
	float rotation;	
}
@end


@interface GrowingShadow : ofPlugin {
	IBOutlet NSSlider * growthSpeedSlider;
	NSMutableArray * lines;
}

-(IBAction) startGrow:(id)sender;

@end
