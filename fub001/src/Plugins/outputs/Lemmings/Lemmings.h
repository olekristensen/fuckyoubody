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


@interface Lemmings : ofPlugin {

	NSMutableArray	*lemmingList;
	NSUserDefaults	*userDefaults;

	IBOutlet NSSegmentedControl * cameraControl;
	IBOutlet NSTextField * numberLemmingsControl;

	int lemmingDiff;
	
}

-(IBAction) addLemming:(id)sender;
-(IBAction) removeOldestLemming:(id)sender;

@end

@interface Lemming : NSObject {

	
	float			radius;
	ofxVec2f		*position;
	double			spawnTime;
	BOOL			dying;
	double			deathTime;
	NSMutableArray * lemmingList;

}

-(id) initWithX:(float)xPosition Y:(float)yPosition;

@property (readwrite) float radius;
@property (assign, readwrite) ofxVec2f *position;
@property (readwrite) double spawnTime;
@property (assign) NSMutableArray * lemmingList;
@property (assign) BOOL	dying;

-(void) draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime;

@end