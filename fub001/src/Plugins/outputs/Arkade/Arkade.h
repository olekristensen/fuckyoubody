#pragma once

#import "GLee.h"

#import <Cocoa/Cocoa.h>
#include "Plugin.h"
#include "ofMain.h"
#define FLOORGRIDSIZE 8

@interface Arkade : ofPlugin {
	IBOutlet NSButton * floorSquaresButton;
	float floorSquaresOpacity[ FLOORGRIDSIZE * FLOORGRIDSIZE ];
	
	vector<ofxPoint2f> cookies;
	
	ofxPoint2f * pacmanPosition;
	ofxVec2f * pacmanDir;
}

-(int) getIatX:(float)x Y:(float)y;

@end
