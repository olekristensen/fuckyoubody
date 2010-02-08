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
	ofxPoint2f * center;
}

-(void) dealloc;

@end


@interface Strategi : ofPlugin {
	IBOutlet NSColorWell * player1Color;
	IBOutlet NSColorWell * player2Color;
	IBOutlet NSColorWell * player3Color;
	IBOutlet NSColorWell * player4Color;
	
	IBOutlet NSButton * player3ColorActive;
	IBOutlet NSButton * player4ColorActive;
	
	IBOutlet NSSlider * blurSlider;
	IBOutlet NSSlider * lineWidth;
	IBOutlet NSSlider * fade;
	IBOutlet NSButton * pause;
	
	IBOutlet NSSlider * outputBlurSlider;


	ofxCvGrayscaleImage * images[4];
	ofxCvContourFinder * contourFinder[4];
	NSMutableArray * blobs;
	float area[2];
	ofImage * texture;
	
	shaderBlur * blur;

	IBOutlet NSButton * lockPlayerButton;
	IBOutlet NSButton * player2Active;;
	
	vector< vector<vector< ofPoint > > > contourPoints;

}
-(IBAction) restart:(id)sender;
-(IBAction) asssignBottom:(id)sender;
-(IBAction) setVeryLow:(id)sender;
@end
