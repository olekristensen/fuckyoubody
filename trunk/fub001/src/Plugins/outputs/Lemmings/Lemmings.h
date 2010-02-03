//
//  _ExampleOutput.h
//  openFrameworks
//
//  Created by Jonas Jongejan on 15/11/09.
//

#pragma once

#import "GLee.h"

#import <Cocoa/Cocoa.h>
#include "Plugin.h"
#include "ofMain.h"
#include "Filter.h"
#include "Players.h"


#define RADIUS 0.03
#define DEATH_DURATION 0.5
#define SPLAT_DURATION 0.5
#define RADIUS_SQUARED 0.0009


@interface Lemmings : ofPlugin {

	NSUserDefaults	*userDefaults;

	bool			doReset;
	
	IBOutlet PluginUIColorWell * testColor;

	float			screenTrackingLeft;
	float			screenTrackingRight;
	float			screenTrackingHeight;
	
	Filter *		screenTrackingLeftFilter;
	Filter *		screenTrackingRightFilter;
	Filter *		screenTrackingHeightFilter;
	
	ofImage			*coinImage;
	ofPoint			*screenDoorPos;
	
	ofxVec2f		* screenBottomOnFloorLeft;
	ofxVec2f		* screenBottomOnFloorRight;
	ofxVec2f		* screenBottomOnFloor;
	ofxVec2f		* screenBottomOnFloorHat;

	ofxVec2f		* screenBottomIntersection;
	ofxVec2f		* blobCentroid;

	IBOutlet NSSegmentedControl * cameraControl;
	IBOutlet NSButton * trackingActive;

	int numberLemmings;
	float lastLemmingInterval;
	
	// screen world

	ofxPoint2f		* screenPosition;
	
	NSMutableArray	* screenLemmings;
	NSMutableArray	* screenElements;

	IBOutlet NSSlider * screenElementsAlpha;		//	0 ... 1 black ... white

	IBOutlet NSSlider * screenEntranceDoor;			//	0 ... 1 closed ... open
	IBOutlet NSSlider * screenLemmingsAddRate;		//	0 ... 1 none ... fast
	
	IBOutlet NSSlider * screenGravity;				// -1 ... 2
	IBOutlet NSSlider * screenSplatVelocity;		//	0 ... 1

	IBOutlet NSSlider * screenLemmingsBrightness;	//	0 ... 1 black ... white

	IBOutlet NSButton * screenFloor;				//	BOOL

	// floor world
	
	NSMutableArray	* floorLemmings;

	IBOutlet NSSlider * floorBlobNearForce;			// -1 ... 1
	IBOutlet NSSlider * floorBlobNearForceThreshold;//	0 ... 1

	IBOutlet NSSlider * floorBlobFarForce;			// -1 ... 1
	IBOutlet NSSlider * floorBlobFarForceThreshold;	//	0 ... 1

	IBOutlet NSSlider * floorLemmingsColor;			//	0 ... 1 black ... white
	IBOutlet NSSlider * floorColor;					//	0 ... 1 black ... white

	IBOutlet NSSlider * floorLemmingsCoins;			//	0 ... 1 transparent ... visible

	IBOutlet NSSlider * floorBlobMask;				//  0 ... 1
	
	// intra-lemming
	
	IBOutlet NSSlider * damp;
	IBOutlet NSSlider * motionTreshold;
	IBOutlet NSSlider * motionMultiplier;
	IBOutlet NSSlider * motionGravity;

	IBOutlet NSSlider * lemmingSize;

	int lemmingDiff;
	pthread_mutex_t mutex;
	
}

@property (readonly) int numberLemmings;
@property (readonly) float screenGravityAsFloat;


-(IBAction) addFloorLemming:(id)sender;
-(IBAction) addScreenLemming:(id)sender;
-(IBAction) resetLemmings:(id)sender;
-(IBAction) killAllLemmings:(id)sender;
-(void) updateLemmingArray:(NSMutableArray*) theLemmingArray timeInterval:(CFTimeInterval)timeInterval;
-(void) makeFloorLemmingFromShadowAtX:(float)xPosition Y: (float)yPosition;
-(void) reset;
-(float) getScreenGravityAsFloat;
-(float) getScreenSplatVelocityAsFloat;
-(float) getScreenElementsAlphaAsFloat;

@end

@interface Lemming : NSObject {

	float			radius;
	float			scaleFactor;
	ofxVec2f		*position;
	ofxVec2f		*vel;
	ofxVec2f		*totalforce;
	double			spawnTime;
	double			deathTime;
	double			splatTime;
	bool			blessed;
	NSMutableArray * lemmingList;

}

-(id) initWithX:(float)xPosition Y:(float)yPosition spawnTime:(CFTimeInterval)timeInterval;

@property (readwrite) float radius;
@property (readwrite) float scaleFactor;
@property (assign, readwrite) ofxVec2f *position;
@property (assign, readwrite) ofxVec2f *totalforce;
@property (assign, readwrite) ofxVec2f *vel;
@property (readwrite) double spawnTime;
@property (readwrite) double deathTime;
@property (readwrite) double splatTime;
@property (readwrite) bool blessed;
@property (assign) NSMutableArray * lemmingList;

-(void) draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime;

@end

@interface ScreenElement : NSObject {
	
	float			size;
	ofxVec2f		*position;
	bool			active;

}

-(id) initWithX:(float)xPosition Y:(float)yPosition size:(float)aSize;

@property (readwrite) float size;
@property (assign, readwrite) ofxVec2f *position;
@property (readwrite) bool active;

-(void) draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime;

@end