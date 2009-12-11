#pragma once

#import "GLee.h"

#import <Cocoa/Cocoa.h>
#include "Plugin.h"
#include "ofMain.h"
#include "ofxVectorMath.h"



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
@end



@interface NormalLamp : Lamp
{
@public
	int value;
	int sentValue;	
}
-(void) setLamp:(float)_v;
@end



@interface DMXOutput : ofPlugin {
	NSThread * thread;
	NSMutableArray * lamps;
	ofSerial * serial;
	bool ok;
	bool connected;
	
	pthread_mutex_t mutex;

	float r,g,b;
	float r2,g2,b2;
	float master;
	float sentMaster;
	
	int shownNumber;
	
	NSColor * color;
	
	IBOutlet NSColorWell * backgroundColor;
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
-(void) makeNumber:(int)n r:(float)_r g:(float)_g b:(float)_b a:(float)_a;
-(LedLamp*) getLamp:(int)x y:(int)y;

@end
