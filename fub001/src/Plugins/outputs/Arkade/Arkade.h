#pragma once

#import "GLee.h"

#import <Cocoa/Cocoa.h>
#include "Plugin.h"
#include "ofMain.h"
#define FLOORGRIDSIZE 8
#include "Filter.h"

@interface Arkade : ofPlugin {
	IBOutlet NSButton * floorSquaresButton;
		IBOutlet NSButton * leaveCookiesButton;
		IBOutlet NSButton * pacmanButton;
		IBOutlet NSSlider * pacmanSpeedSlider;

	
	IBOutlet NSButton * ballUpdateButton;
	IBOutlet NSButton * ballDrawButton;
	IBOutlet NSSlider * ballSpeedSlider;
	IBOutlet NSSlider * ballSizeSlider;

	IBOutlet NSSlider * terminatorLightFadeSlider;
	IBOutlet NSSlider * terminatorLightSpeedSlider;
	
	float floorSquaresOpacity[ FLOORGRIDSIZE * FLOORGRIDSIZE ];
	
	vector<ofxPoint2f> cookies;
	ofxPoint2f * personPosition;
	Filter * personFilterX, * personFilterY;

	
	//Ball
	ofxPoint2f * ballPosition;
	ofxVec2f * ballDir;
	vector<ofxPoint2f> lastBallPositions;
	
	//Pacman
	ofxPoint2f * pacmanPosition;
	ofxVec2f * pacmanDir;
	float pacmanMouthValue;
	int pacmanMouthDir;
	bool pacmanEntering;
	ofSoundPlayer * pongWallSound;
	
	//Choises
	ofxPoint2f * redChoisePosition;
	ofxPoint2f * blueChoisePosition;
	float choisesSize;
	bool makeChoises;
	
	//terminator
	bool terminatorMode;
	float blueScaleFactor;
	float lightRotation;
	
	
}

-(IBAction) reset:(id)sender;
-(IBAction) makeChoises:(id)sender;
-(IBAction) activateTerminator:(id)sender;

-(int) getIatX:(float)x Y:(float)y;

@end
