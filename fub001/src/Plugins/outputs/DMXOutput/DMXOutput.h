#pragma once

#import "GLee.h"

#import <Cocoa/Cocoa.h>
#include "Plugin.h"
#include "ofMain.h"
#include "ofxVectorMath.h"
#include "DMXLamps.h"

@interface DMXEffectColumn : NSObject
{
	IBOutlet PluginUIColorWell * backgroundColor;
	IBOutlet PluginUISlider * backgroundColorR;
	IBOutlet PluginUISlider * backgroundColorG;
	IBOutlet PluginUISlider * backgroundColorB;
	IBOutlet PluginUISlider * backgroundColorA;
	
	IBOutlet PluginUIColorWell * generalNumberColor;
	IBOutlet PluginUISlider * generalNumberValue;	
	IBOutlet PluginUISegmentedControl * generalNumberBlendmode;
	IBOutlet PluginUISlider * generalNumberColorR;
	IBOutlet PluginUISlider * generalNumberColorG;
	IBOutlet PluginUISlider * generalNumberColorB;
	IBOutlet PluginUISlider * generalNumberColorA;

	//Noise
	IBOutlet PluginUIColorWell * noiseColor1;	
	IBOutlet PluginUIColorWell * noiseColor2;	
	IBOutlet PluginUISegmentedControl * noiseBlendMode;
	
	IBOutlet PluginUIButton * patchButton;
	
	IBOutlet NSView * settingsView;
	int number;
}
@property (assign,readwrite) NSSlider * backgroundColorR;
@property (assign,readwrite) NSView * settingsView;
@property (assign, readwrite) int number;

- (id) initWithNumber:(int)aNumber;
-(BOOL) loadNibFile;
-(void)addColorForLamp:(ofPoint)lamp box:(DiodeBox*)box;
@end



@interface DMXOutput : ofPlugin {
	NSThread * thread;
	NSMutableArray * diodeboxes;
	ofSerial * serial;
	bool ok;
	bool connected;
	
	pthread_mutex_t mutex;
	
	IBOutlet NSView * column0;
	IBOutlet NSView * column1;
	IBOutlet NSView * column2;
	IBOutlet NSView * column3;
	IBOutlet NSView * column4;
	
	DMXEffectColumn * columns[5];
	
	IBOutlet NSColorWell * backgroundColor;
	IBOutlet NSSlider * backgroundRedColor;
	IBOutlet NSSlider * backgroundGreenColor;
	IBOutlet NSSlider * backgroundBlueColor;
	
	IBOutlet NSSlider * generalNumberAlpha;
	IBOutlet NSSlider * generalNumber1;	
	IBOutlet NSSlider * generalNumber2;		
	IBOutlet NSSlider * generalNumber3;	
	IBOutlet NSSlider * generalNumber4;	
	
	IBOutlet NSSlider * noiseAlpha;
	IBOutlet NSSegmentedControl * noiseBlending;
	IBOutlet NSColorWell * noiseColor1;
	IBOutlet NSColorWell * noiseColor2;
	
	float r,g,b;
	float r2,g2,b2;
	float master;
	float sentMaster;
	
	int shownNumber;
	
	NSColor * color;
	
	
	IBOutlet NSButton * backgroundGradient;
	IBOutlet NSSlider * backgroundGradientSpeed;
	IBOutlet NSSlider * backgroundGradientRotation;
	
	IBOutlet NSButton * ledCounter;
	IBOutlet NSButton * ledCounterFade;	
	IBOutlet NSColorWell * ledCounterColor;
	
	IBOutlet NSSlider * worklight;
	IBOutlet NSButton * trackingLight;
	
	vector<unsigned char> * serialBuffer;
}

-(void) updateDmx:(id)param;
-(void) makeNumber:(int)n intoArray:(bool*) array;

-(IBAction) setBackgroundRed:(id)sender;
-(IBAction) setBackgroundGreen:(id)sender;
-(IBAction) setBackgroundBlue:(id)sender;
-(IBAction) setBackground:(id)sender;

-(void) setup;

//-(LedLamp*) getLamp:(int)x y:(int)y;

@end
