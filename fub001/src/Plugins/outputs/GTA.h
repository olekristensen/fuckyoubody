#pragma once

#import "GLee.h"

#import <Cocoa/Cocoa.h>
#include "Plugin.h"
#include "ofMain.h"
#include "ofxVectorMath.h"
#include "shaderBlur.h"


@interface WallObject : NSObject
{
	ofxPoint3f * pos;
	ofxPoint3f * offset;
	BOOL obstacle;
	ofTexture * texture;
}
@property (readwrite) ofxPoint3f * pos;
@property (readwrite) ofxPoint3f * offset;
@property (readwrite) BOOL obstacle;
@property (readwrite) ofTexture * texture;
-(ofxPoint3f*) position;

@end


@interface GTA : ofPlugin {
	IBOutlet NSSlider * wallAlphaControl;

	IBOutlet NSSlider * wallSpeedControl;
	IBOutlet NSSlider * wallSizeControl;
	IBOutlet NSSlider * wallZScaleControl;
	IBOutlet NSButton * wallBrakeControl;
	IBOutlet NSSlider * wallCamXControl;
	IBOutlet NSSlider * wallBlurControl;
	IBOutlet NSSlider * wallNoiseControl;
	IBOutlet NSSlider * wallZAlphaControl;
	IBOutlet NSSlider * wallStreetSizeControl;
	
	IBOutlet NSSlider * floorSpeedControl;
	IBOutlet NSSlider * floorXControl;

	IBOutlet NSSlider * freakOutControl;

	
	IBOutlet NSButton * floorActiveControl;
	IBOutlet NSButton * floorToothControl;

	float camXPos;
	float zscale;
	
	NSMutableArray * wallObjects;
	float aspect;
	
	shaderBlur * blur;
	
	ofxShader * shaderH;
	ofxShader *  shaderV;
	
	float floorPos;
	float hajPos;
	
	int numLayers;
	int numPerLayer;


}

-(void) generateObjects;
-(IBAction) reset:(id)sender;
@end