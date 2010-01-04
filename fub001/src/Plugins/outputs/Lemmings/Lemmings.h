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


#define RADIUS 0.01
#define RADIUS_SQUARED 0.001


@interface Lemmings : ofPlugin {

	NSMutableArray	*lemmingList;
	NSUserDefaults	*userDefaults;

	IBOutlet NSSegmentedControl * cameraControl;
	IBOutlet NSTextField * numberLemmingsControl;
	
	IBOutlet NSSlider * damp;
	IBOutlet NSSlider * motionTreshold;
	IBOutlet NSSlider * motionMultiplier;
		IBOutlet NSSlider * motionGravity;

	int lemmingDiff;
	pthread_mutex_t mutex;
	
}

-(IBAction) addLemming:(id)sender;
-(IBAction) removeOldestLemming:(id)sender;

@end

@interface Lemming : NSObject {

	
	float			radius;
	ofxVec2f		*position;
	ofxVec2f		*vel;
		ofxVec2f		*totalforce;
	double			spawnTime;
	BOOL			dying;
	double			deathTime;
	NSMutableArray * lemmingList;

}

-(id) initWithX:(float)xPosition Y:(float)yPosition spawnTime:(CFTimeInterval)timeInterval;

@property (readwrite) float radius;
@property (assign, readwrite) ofxVec2f *position;
@property (assign, readwrite) ofxVec2f *totalforce;
@property (assign, readwrite) ofxVec2f *vel;
@property (readwrite) double spawnTime;
@property (assign) NSMutableArray * lemmingList;
@property (assign) BOOL	dying;

-(void) draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime;

@end