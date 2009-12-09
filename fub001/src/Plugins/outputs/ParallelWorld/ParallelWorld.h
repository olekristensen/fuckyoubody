#pragma once

#import "GLee.h"

#import <Cocoa/Cocoa.h>
#include "Plugin.h"
#include "ofMain.h"
#include "ofxVectorMath.h"
#include "PluginOpenGLControl.h"
#include "Tracking.h"
#define numFingers 3

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
	IBOutlet NSSlider * corridorSpeedControl;
	IBOutlet NSButton * corridorFrontProjectorControl;
	IBOutlet NSButton * corridorBackProjectorControl;
	IBOutlet NSButton * corridorFrontPerspectiveControl;
	IBOutlet NSButton * corridorBackPerspectiveControl;	
	
	NSMutableArray * lines;
	
}

-(IBAction) clear:(id)sender;

@end

@interface ParallelLine : NSObject
{
	float left;
	float right;
	double spawnTime;
	int drawingMode;
	
	NSMutableArray * links;
	
}
@property (readwrite) float left;
@property (readwrite) float right;
@property (readwrite) double spawnTime;
@property int drawingMode;
@property (assign) NSMutableArray * links;

@end

