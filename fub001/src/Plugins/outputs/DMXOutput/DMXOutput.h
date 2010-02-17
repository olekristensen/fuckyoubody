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
	IBOutlet PluginUISegmentedControl * backgroundTakeColor;
	IBOutlet PluginUISlider * topCrop;

	IBOutlet PluginUIColorWell * generalNumberColor;
	IBOutlet PluginUISlider * generalNumberValue;	
	IBOutlet PluginUISegmentedControl * generalNumberBlendmode;
	IBOutlet PluginUISegmentedControl * generalNumberTakeColor;

	IBOutlet PluginUISlider * generalNumberColorR;
	IBOutlet PluginUISlider * generalNumberColorG;
	IBOutlet PluginUISlider * generalNumberColorB;
	IBOutlet PluginUISlider * generalNumberColorA;

	//Noise
	IBOutlet PluginUIColorWell * noiseColor1;	
	IBOutlet PluginUIColorWell * noiseColor2;	
	IBOutlet PluginUISlider * noiseThreshold;
	IBOutlet PluginUISlider * noiseSpeed;

	IBOutlet PluginUISegmentedControl * noiseBlendMode;
	
	IBOutlet PluginUIButton * patchButton;
	
	IBOutlet NSView * settingsView;
	int number;
	
	float noiseValues[3][5];
	float noiseNextUpdate[3][5];
}
@property (assign,readwrite) NSSlider * backgroundColorR;
@property (assign,readwrite) NSView * settingsView;
@property (assign, readwrite) int number;
@property (assign, readwrite) PluginUIColorWell * generalNumberColor;

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
	
	IBOutlet NSSlider * GTAEffect;
	IBOutlet NSSlider * GTATower;

	IBOutlet NSSlider * GTAUlykke;
	IBOutlet NSSlider * rainbowAlpha;
	IBOutlet NSSlider * bokseringPale;
	IBOutlet NSSlider * bokseringGreen;
	IBOutlet NSSlider * bokseringBlue;
	IBOutlet NSSlider * bokseringOffset;
	IBOutlet NSSlider * bokseringVerticalEffect;
	IBOutlet NSSlider * bokseringWaveformEffect;
	IBOutlet NSButton * bokseringBeatButton;
	IBOutlet NSButton * combatBeatButton;
	IBOutlet NSSlider * combatWaveformEffect;

	IBOutlet NSSlider * ArrowAlpha;
	IBOutlet NSSlider * ArrowAnimation;
	
	vector<int> bokseringTime;
	float volCounter;
	float timeSinceLastVolChange;
	float bokseringCurValue;
	int bokseringCounter;

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
	
	vector<ofxPoint3f> gtaPositions;
	vector<BOOL> gtaTower;

	float ulykkePos[4];
	
	float rainbowadd;
	
	ofSoundPlayer * music;
	ofSoundPlayer * combatMusic;

}

-(DMXEffectColumn*) effectColumn:(int)n;
-(void) updateDmx:(id)param;
-(void) makeNumber:(int)n intoArray:(bool*) array;

-(IBAction) setBackgroundRed:(id)sender;
-(IBAction) setBackgroundGreen:(id)sender;
-(IBAction) setBackgroundBlue:(id)sender;
-(IBAction) setBackground:(id)sender;

-(IBAction) bokseringStepTime:(id)sender;

-(void) setup;
-(void)addColor:(NSColor*)c forCoordinate:(ofxPoint3f)coord withBlending:(int)blending;



//-(LedLamp*) getLamp:(int)x y:(int)y;

@end
