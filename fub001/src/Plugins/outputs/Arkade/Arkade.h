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

	
	IBOutlet NSButton * ballUpdateButton;
	IBOutlet NSButton * ballDrawButton;
	IBOutlet NSSlider * ballSpeedSlider;
	IBOutlet NSSlider * ballSizeSlider;
	
	float floorSquaresOpacity[ FLOORGRIDSIZE * FLOORGRIDSIZE ];
	
	vector<ofxPoint2f> cookies;
	
	ofxPoint2f * ballPosition;
	ofxVec2f * ballDir;
	vector<ofxPoint2f> lastBallPositions;
	
	ofxPoint2f * pacmanPosition;
	ofxVec2f * pacmanDir;
	float pacmanMouthValue;
	int pacmanMouthDir;
	bool pacmanEntering;
	

	ofSoundPlayer * pongWallSound;
}

-(IBAction) reset:(id)sender;


-(int) getIatX:(float)x Y:(float)y;

@end
