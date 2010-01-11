#pragma once

#import "GLee.h"

#import <Cocoa/Cocoa.h>
#include "Plugin.h"
#include "ofMain.h"
#include "ofxVectorMath.h"
#include "PluginOpenGLControl.h"
#include "Tracking.h"
#define numFingers 3

#include "Filter.h"

enum DrawFlags {
	DrawFrontProjector = 1,
	DrawBackProjector = 2,
	DrawFrontPerspective = 4,
	DrawBackPerspective = 8
};

@interface BlobLink : NSObject
{
@public	
	int blobId;
	double linkTime;
	double lastConfirm;
}
@end





@interface ParallelWorld : ofPlugin {
	IBOutlet NSSegmentedControl * modeControl;	


	IBOutlet NSSlider * adderSpeedControl;
	IBOutlet NSSlider * adderWidthControl;
	IBOutlet NSSlider * adderRotateControl;
	IBOutlet NSButton * adderAddControl;
	IBOutlet NSSegmentedControl * adderModeControl;	

	IBOutlet NSSlider * corridorSpeedControl;
	IBOutlet NSButton * corridorFrontProjectorControl;
	IBOutlet NSButton * corridorBackProjectorControl;
	IBOutlet NSButton * corridorFrontPerspectiveControl;
	IBOutlet NSButton * corridorBackPerspectiveControl;	
	IBOutlet NSSegmentedControl * cameraControl;	
	IBOutlet NSTextField * numberLinesControl;

	NSMutableArray * lines;
	NSUserDefaults *userDefaults;
	

}

-(IBAction) clear:(id)sender;
-(IBAction) removeOldest:(id)sender;

-(void) rotate:(float)rotate;

@end

@interface ParallelLine : NSObject
{
	float left;
	float right;
	double spawnTime;
	int drawingMode;
	
	Filter * leftFilter, *rightFilter;

	
	NSMutableArray * links;
	
}
@property (readwrite) float left;
@property (readwrite) float right;
@property (readwrite) double spawnTime;
@property (readwrite) 	Filter * leftFilter;
@property (readwrite) 	Filter * rightFilter;

@property int drawingMode;
@property (assign) NSMutableArray * links;

@end

