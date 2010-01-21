#pragma once

#import "GLee.h"

#import <Cocoa/Cocoa.h>
#include "Plugin.h"
#include "ofMain.h"
#include "ofxVectorMath.h"
#include "shaderBlur.h"

#define StrategiW 600
#define StrategiH 600

#define StrategiBlobW 500
#define StrategiBlobH 500

@interface StrategiBlob : NSObject
{
	@public
	int pid;
	int player;
	int aliveCounter;
}

@end


@interface Strategi : ofPlugin {
	IBOutlet NSColorWell * player1Color;
	IBOutlet NSColorWell * player2Color;
	IBOutlet NSColorWell * player1LineColor;
	IBOutlet NSColorWell * player2LineColor;
	IBOutlet NSSlider * blurSlider;
	IBOutlet NSSlider * lineWidth;
	IBOutlet NSSlider * fade;
	IBOutlet NSButton * pause;
	
	IBOutlet NSSlider * outputBlurSlider;


	ofxCvGrayscaleImage * images[2];
	ofxCvContourFinder * contourFinder[2];
	NSMutableArray * blobs;
	float area[2];
	ofImage * texture;
	
	shaderBlur * blur;


}
-(IBAction) restart:(id)sender;

@end
