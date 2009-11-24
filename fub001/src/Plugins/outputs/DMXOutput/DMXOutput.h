#pragma once

#import "GLee.h"

#import <Cocoa/Cocoa.h>
#include "Plugin.h"
#include "ofMain.h"
#include "ofxVectorMath.h"


@interface LedLamp : NSObject
{
@public
	int r, g, b, a;
	ofxPoint2f * pos;
	int channel;
	
	int sentR, sentG, sentB, sentA;
	
	bool isOldAndSucks;
	
	
}
-(void) update;
-(void) setLamp:(float)_r g:(float)_g b:(float)_b a:(float)_a;
@end


@interface DMXOutput : ofPlugin {
	NSThread * thread;
	NSMutableArray * lamps;
	ofSerial * serial;
	bool ok;
	
	pthread_mutex_t mutex;

	float r,g,b;
	float r2,g2,b2;
	float master;
	float sentMaster;
	
	int shownNumber;
	
	NSColor * color;


}

-(void) updateDmx:(id)param;
-(void) makeNumber:(int)n r:(float)_r g:(float)_g b:(float)_b;
-(LedLamp*) getLamp:(int)x y:(int)y;

@end
