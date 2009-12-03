#pragma once

#import "GLee.h"

#import <Cocoa/Cocoa.h>

#include "Plugin.h"
#include "ofMain.h"
#include "Libdc1394Grabber.h"

@interface Camera : NSObject {
	Libdc1394Grabber *videoGrabber;
	
	ofTexture * tex;
	unsigned char* pixels;
	
	int width, height;
	bool camInited ;
	BOOL bIsFrameNew;
	
	IBOutlet NSView * settingsView;
	
	IBOutlet NSTextField * guidTextField;
	IBOutlet PluginUISlider * shutterSlider;
	IBOutlet PluginUISlider * exposureSlider;
	IBOutlet PluginUISlider * gainSlider;
	IBOutlet PluginUISlider * gammaSlider;
	IBOutlet PluginUISlider * brightnessSlider;
	
	float mytimeNow, mytimeThen;
	int myframes;
	float myfps,frameRate;
}

@property (assign, readonly) NSView * settingsView;
@property (assign, readonly) float mytimeNow;
@property (assign, readonly) float mytimeThen;
@property (assign, readonly) int width;
@property (assign, readonly) int height;

-(ofTexture*) getTexture;
-(float) framerate;
-(void) setup:(int)camNumber;
-(void) update;
-(BOOL) loadNibFile;
-(void) aWillTerminate:(NSNotification *)notification ;

-(IBAction) setShutter:(id)sender;
-(IBAction) setExposure:(id)sender;
-(IBAction) setGain:(id)sender;
-(IBAction) setGamma:(id)sender;
-(IBAction) setBrightness:(id)sender;

@end
