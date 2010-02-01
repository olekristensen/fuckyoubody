#pragma once

#import "GLee.h"

#import <Cocoa/Cocoa.h>
#include "Plugin.h"
#include "ofMain.h"
#include "ofxVectorMath.h"
#include "Filter.h"

@interface LineObject : NSObject
{
	ofxPoint2f * frontLeft, *frontRight, *backLeft, *backRight;
	Filter * leftFrontFilter, *rightFrontFilter;
	Filter * leftBackFilter, *rightBackFilter;
		float width;
	NSMutableArray * links;
	

}
@property (assign, readwrite) NSMutableArray * links;

-(void)drawWithBalance:(float)balance fromtAlpha:(float)frontA backAlpha:(float)backA width:(float)w timeout:(bool)timeout;
-(void)setFrontLeft:(ofxPoint2f)frontLeft frontRight:(ofxPoint2f)frontRight;
-(void)setBackLeft:(ofxPoint2f)backLeft backRight:(ofxPoint2f)backtRight;


@end


@interface Lines : ofPlugin {
	IBOutlet NSSegmentedControl * trackingDirection;
	IBOutlet PluginUISlider * balanceSlider;
	IBOutlet PluginUISlider * lineWidthSlider;
	IBOutlet NSButton * trackingButton;
	IBOutlet NSButton * timeoutLinesButton;
	
	NSMutableArray * lines;
	

}

-(IBAction) removeAllLines:(id)sender;

@end



@interface LineBlobLink : NSObject
{
@public	
	int blobId;
	int projId;
	double linkTime;
	double lastConfirm;

	double timeSinceLastConfirm;
}


@end
