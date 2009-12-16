#pragma once

#import "GLee.h"

#import <Cocoa/Cocoa.h>
#include "Plugin.h"
#include "ofMain.h"
#include "ofxVectorMath.h"

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
	
	ofxCvGrayscaleImage * images[2];
	ofxCvContourFinder * contourFinder[2];
	NSMutableArray * blobs;
	float area[2];
}
-(IBAction) restart:(id)sender;

@end
