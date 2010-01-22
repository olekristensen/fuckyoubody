#pragma once

#import "GLee.h"

#import <Cocoa/Cocoa.h>
#include "Plugin.h"
#include "ofMain.h"
#define FLOORGRIDSIZE 8

@interface Arkade : ofPlugin {
	IBOutlet NSButton * floorSquaresButton;
		IBOutlet NSButton * leaveCookiesButton;
		IBOutlet NSButton * pacmanButton;
		IBOutlet NSSlider * pacmanSpeedSlider;
	
	float floorSquaresOpacity[ FLOORGRIDSIZE * FLOORGRIDSIZE ];
	
	vector<ofxPoint2f> cookies;
	
	ofxPoint2f * pacmanPosition;
	ofxVec2f * pacmanDir;
	float pacmanMouthValue;
	int pacmanMouthDir;
	
}

-(int) getIatX:(float)x Y:(float)y;

@end
