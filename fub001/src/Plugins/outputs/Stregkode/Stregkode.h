#pragma once

#import "GLee.h"

#import <Cocoa/Cocoa.h>
#include "Plugin.h"
#include "ofMain.h"
#include "ofxVectorMath.h"

@interface StregkodePlayer : NSObject
{
@public
	int pid;
	float r, g, b;
	float t;
	float startM, whiteAdd;
}



@end


@interface Stregkode : ofPlugin {
	IBOutlet NSSlider * speedSlider;
	IBOutlet NSSlider * flashSpeedSlider;

	ofSoundPlayer * sound[4];
	NSMutableArray * players;
	
	float percent;
	bool going;
	int num;
}
@property (readwrite) float percent;
@property (readwrite) bool going;
@property (assign, readwrite) NSMutableArray * players;

-(IBAction) go:(id)sender;

@end
