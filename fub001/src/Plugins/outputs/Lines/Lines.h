#pragma once

#import "GLee.h"

#import <Cocoa/Cocoa.h>
#include "Plugin.h"
#include "ofMain.h"
#include "ofxVectorMath.h"
#include "Filter.h"

@interface LineObject : NSObject
{
	float frontLeft, frontRight, backLeft, backRight;
	Filter * leftFrontFilter, *rightFrontFilter;
	Filter * leftBackFilter, *rightBackFilter;
	
	NSMutableArray * links;

}
@property (assign, readwrite) NSMutableArray * links;

-(void)drawWithBalance:(float)balance fromtAlpha:(float)frontA backAlpha:(float)backA;
-(void)setFrontLeft:(float)frontLeft frontRight:(float)frontRight;
-(void)setBackLeft:(float)backLeft backRight:(float)backtRight;


@end


@interface Lines : ofPlugin {
	IBOutlet NSSegmentedControl * trackingDirection;
	IBOutlet PluginUISlider * balanceSlider;
	
	
	NSMutableArray * lines;

}

@end



@interface LineBlobLink : NSObject
{
@public	
	int blobId;
	double linkTime;
	double lastConfirm;
}


@end
