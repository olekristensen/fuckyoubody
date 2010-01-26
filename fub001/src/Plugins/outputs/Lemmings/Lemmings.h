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


#define RADIUS 0.05
#define DEATH_DURATION 0.5
#define SPLAT_DURATION 0.5
#define RADIUS_SQUARED 0.0025


@interface Lemmings : ofPlugin {

	NSUserDefaults	*userDefaults;

	bool			doReset;
	
	ofImage			*coinImage;
	ofPoint			*screenDoorPos;
		
	IBOutlet NSSegmentedControl * cameraControl;
	IBOutlet NSButton * trackingActive;

	int numberLemmings;
	float lastLemmingInterval;
	
	// screen world
	
	NSMutableArray	* screenLemmings;
	NSMutableArray	* screenColliders;

	IBOutlet NSSlider * screenElementsAlpha;		//	0 ... 1 black ... white

	IBOutlet NSSlider * screenEntranceDoor;			//	0 ... 1 closed ... open
	IBOutlet NSSlider * screenLemmingsAddRate;		//	0 ... 1 none ... fast
	
	IBOutlet NSSlider * screenGravity;				// -1 ... 2

	IBOutlet NSButton * screenSeeSawTracking;		//	BOOL
	IBOutlet NSSlider * screenSeeSawDamping;		//	0 ... 1

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
@property (assign) NSMutableArray * lemmingList;

-(void) draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime;


@end