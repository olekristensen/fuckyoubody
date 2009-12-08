#pragma once

#import "GLee.h"

#import <Cocoa/Cocoa.h>

#include "Plugin.h"
#include "ofMain.h"
#include "Libdc1394Grabber.h"
#include "videoplayerWrapper.h"

@interface Camera : NSObject {
	Libdc1394Grabber * videoGrabber;
	BOOL live;

	videoplayerWrapper * videoPlayer;
	NSMutableArray * movies;
	BOOL loadMoviePlease;
	NSString * loadMovieString;
	float millisSinceLastMovieEvent;
	
	ofTexture * tex;
	unsigned char* pixels;

	int width, height;
	BOOL camInited;
	BOOL camIsIniting;
	BOOL camWasInited;
	BOOL isClosing;
	BOOL bIsFrameNew;
	uint64_t camGUID;
	int camNumber;
	
	IBOutlet NSView * settingsView;
	
	IBOutlet NSTextField * guidTextField;
	IBOutlet PluginUISlider * shutterSlider;
	IBOutlet PluginUISlider * exposureSlider;
	IBOutlet PluginUISlider * gainSlider;
	IBOutlet PluginUISlider * gammaSlider;
	IBOutlet PluginUISlider * brightnessSlider;
	
	IBOutlet NSSegmentedControl * sourceSelector;
	IBOutlet NSPopUpButton * movieSelector;
	IBOutlet NSButton * recordButton;
	
	float mytimeNow, mytimeThen;
	int myframes;
	float myfps,frameRate;
	pthread_mutex_t mutex;
	
	NSUserDefaults *userDefaults;

}

@property (assign, readonly) NSView * settingsView;
@property (assign, readonly) float mytimeNow;
@property (assign, readonly) float mytimeThen;
@property (assign, readonly) int width;
@property (assign, readonly) int height;
@property (assign, readonly) BOOL camInited;
@property (assign, readonly) BOOL live;
@property (readwrite) 	uint64_t camGUID;
@property (readwrite) 	int camNumber;

-(float) framerate;
-(ofTexture*) getTexture;
-(unsigned char*) getPixels;
-(BOOL) isFrameNew;


-(void) setup:(int)camNumber withGUID:(uint64_t)camGUID;
-(void) update;
-(BOOL) loadNibFile;
-(void) aWillTerminate:(NSNotification *)notification;


-(void) updateMovieList;
-(void) loadMovie:(NSString*) name;

-(IBAction) setShutter:(id)sender;
-(IBAction) setExposure:(id)sender;
-(IBAction) setGain:(id)sender;
-(IBAction) setGamma:(id)sender;
-(IBAction) setBrightness:(id)sender;
-(IBAction) setSource:(id)sender;
-(IBAction) setMovieFile:(id)sender;
-(IBAction) toggleRecord:(id)sender;


+ (float)aCameraWillRespawnAt;
+ (BOOL)aCameraIsRespawning;
+ (BOOL)allCamerasAreRespawning;
+ (BOOL)thisCameraIsRespawning;
+ (float)setCamera:(int)respawningCameraNumber willRespawningAt:(float)timeStamp;
+ (float)setCamera:(int)respawningCameraNumber isRespawning:(BOOL)isRespawning;

@end
