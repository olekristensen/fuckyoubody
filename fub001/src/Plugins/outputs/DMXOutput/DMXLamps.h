#pragma once

#import "GLee.h"

#import <Cocoa/Cocoa.h>
#include "Plugin.h"
#include "ofMain.h"
#include "ofxVectorMath.h"


#define BLENDING_OVER 0
#define BLENDING_ADD 1
#define BLENDING_HIGHEST 2
#define BLENDING_MULT 3



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

