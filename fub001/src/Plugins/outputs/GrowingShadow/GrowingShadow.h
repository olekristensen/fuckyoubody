#pragma once

#import "GLee.h"

#import <Cocoa/Cocoa.h>
#include "Plugin.h"
#include "ofMain.h"
#include "ofxOpenCv.h"
#include "ofxVectorMath.h"
#include "shaderBlur.h"


#define  ShadowSizeX 800
#define  ShadowSizeY 800
#define  BufferLength 100


@interface GrowingShadow : ofPlugin {
	
	
	ofxCvColorImageAlpha * shadow; //The one we draw
	ofxCvColorImageAlpha * shadowTemp; //For effects
	
	ofxCvColorImageAlpha * newestShadowTemp; //the one we create the current blob in
	
	vector<ofxCvColorImageAlpha> history;
	int histPos;
	
	ofImage * gradient;
	ofxVec2f * scalePoint;
	
	
	IBOutlet NSSlider * fadeSlider;
	IBOutlet NSSlider * blurSlider;
	IBOutlet NSSlider * thresholdSlider;
	IBOutlet NSSlider * delaySlider;
	IBOutlet NSSlider * scaleSlider;
	IBOutlet NSSlider * distanceBlurAngleSlider;
	IBOutlet NSSlider * distanceBlurPassesSlider;
	IBOutlet NSSlider * invertSlider;
	IBOutlet NSSlider * morphSlider;
	
	IBOutlet NSTextField * coordinateX;
	IBOutlet NSTextField * coordinateY;
	
}
@property (readonly) NSTextField * coordinateX;
@property (readonly) NSTextField * coordinateY;

-(IBAction) startGrow:(id)sender;

@end
