#pragma once

#import "GLee.h"

#import <Cocoa/Cocoa.h>
#include "Plugin.h"
#include "ofMain.h"
#include "ofxVectorMath.h"

#define BLENDING_OVER 0
#define BLENDING_ADD 1
#define BLENDING_HIGHEST 2

@interface Lamp : NSObject
{
	@public
	ofxPoint2f * pos;
	int channel;
}

-(bool) updateDmx:(vector<unsigned char> *) serialBuffer mutex:(pthread_mutex_t)mutex;

@end


@interface LedLamp : Lamp
{
@public
	int r, g, b, a;
	int sentR, sentG, sentB, sentA;
	
	bool isOldAndSucks;
	
	
}

-(void) setLamp:(float)_r g:(float)_g b:(float)_b a:(float)_a;
-(NSColor*) getColor;
@end



@interface NormalLamp : Lamp
{
@public
	int value;
	int sentValue;	
}
-(void) setLamp:(float)_v;
@end

@interface DiodeBox : NSObject
{
	NSArray * lamps;
	int startAddress;
	
}
@property (assign, readwrite) NSArray * lamps;

-(id) initWithStartaddress:(int) address;
-(void) addColor:(NSColor*)color onLamp:(ofPoint)lamp withBlending:(int)blending;
-(LedLamp*) getLampAtPoint:(ofPoint)point;
-(void) reset;
@end




@interface DMXOutput : ofPlugin {
	NSThread * thread;
	NSMutableArray * diodeboxes;
	ofSerial * serial;
	bool ok;
	bool connected;
	
	pthread_mutex_t mutex;
	
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



//-(LedLamp*) getLamp:(int)x y:(int)y;

@end
