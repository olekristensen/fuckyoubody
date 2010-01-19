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


	ofxCvGrayscaleImage * shadow; //The one we draw
	ofxCvGrayscaleImage * shadowTemp; //For effects

	ofxCvGrayscaleImage * newestShadowTemp; //the one we create the current blob in
	
	vector<ofxCvGrayscaleImage> history;
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

}

-(IBAction) startGrow:(id)sender;

@end
