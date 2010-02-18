//
//  TestAppController.h
//
//  Created by Jonas Jongejan on 03/11/09.
//
#import "GLee.h"

#import <Cocoa/Cocoa.h>
#include "PluginManagerController.h"
#include "ofBaseApp.h"
#include "ofAppBaseWindow.h"


@interface ControlPanel : NSObject {
	IBOutlet PluginManagerController * controller;
	
	
	IBOutlet NSTextField * cameraFps1;
	IBOutlet NSButton * cameraStatus1;
	IBOutlet NSButton * hardwareStatus;
	IBOutlet NSButton * xbeeStatus;	
	IBOutlet NSLevelIndicator * xbeeStrength;
	
	IBOutlet NSButton * midiStatus;
	
	IBOutlet BWInsetTextField * statusTextField;
	IBOutlet NSProgressIndicator * statusBusy;
	
	IBOutlet NSButton * testDmxButton;
	IBOutlet NSButton * testFloorButton;
	IBOutlet NSButton * testScreenButton;
	IBOutlet NSButton * laserButton;
	IBOutlet NSButton * ledButton;
	
	IBOutlet NSTextField * fpsTextField;
}


@property (assign, readonly) NSTextField * fpsTextField;
@property (assign, readonly) NSTextField * cameraFps1;
@property (assign, readonly) NSButton * cameraStatus1;
@property (assign, readonly) NSButton * midiStatus;
@property (assign, readonly) BWInsetTextField * statusTextField;
@property (assign, readonly) NSProgressIndicator * statusBusy;
@property (assign, readonly) NSButton * hardwareStatus;
@property (assign, readonly) NSButton * xbeeStatus;	
@property (assign, readonly) NSLevelIndicator * xbeeStrength;
@property (assign, readonly) NSButton * testDmxButton;
@property (assign, readonly) NSButton * testFloorButton;
@property (assign, readonly) NSButton * testScreenButton;
@property (assign, readonly) NSButton * laserButton;
@property (assign, readonly) NSButton * ledButton;



@end
