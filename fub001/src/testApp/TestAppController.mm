//
//  TestAppController.m
//
//  Created by Jonas Jongejan on 03/11/09.
//

#import "TestAppController.h"
#include "PluginIncludes.h"
#include "testApp.h"
#include "ofAppCocoaWindow.h"

extern testApp * OFSAptr;
extern ofAppBaseWindow * window;

@implementation TestAppController


-(void) awakeFromNib {
	
	NSLog(@"Awake from nib");
	
	[pluginManagerController setFrame:[mainView bounds]];
	[mainView addSubview:pluginManagerController];
	
	baseApp = OFSAptr;
	cocoaWindow = window;
	((ofAppCocoaWindow*)cocoaWindow)->windowController = self;
	((ofAppCocoaWindow*)cocoaWindow)->setup();
	
	ofSetBackgroundAuto(false);
	
}

-(void) setupPlugins{
	[pluginManagerController addHeader:@"Input"];
	[pluginManagerController addPlugin:[[Cameras alloc] init]];
	[pluginManagerController addPlugin:[[Lenses alloc] init]];
	
	[pluginManagerController addHeader:@"Calculation"];
	[pluginManagerController addPlugin:[[Tracking alloc] init]];
	[pluginManagerController addPlugin:[[ProjectionSurfaces alloc] init]];
	[pluginManagerController addPlugin:[[CameraCalibration alloc] init]];
	
	[pluginManagerController addHeader:@"Output"];
	[pluginManagerController addPlugin:[[_ExampleOutput alloc] init]];
	[pluginManagerController addPlugin:[[DanceSteps alloc] init]];
	[pluginManagerController addPlugin:[[ParallelWorld alloc] init]];
	[pluginManagerController addPlugin:[[Lemmings alloc] init]];
	[pluginManagerController addPlugin:[[GTA alloc] init]];
	[pluginManagerController addPlugin:[[Strategi alloc] init]];
	[pluginManagerController addPlugin:[[DMXOutput alloc] init]];
	
	//	[pluginManagerController addPlugin:[[_ExampleOutputAgain alloc] init]];
}

@end
