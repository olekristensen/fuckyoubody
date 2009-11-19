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
}

-(void) setupPlugins{
	[pluginManagerController addHeader:@"Test"];
	[pluginManagerController addPlugin:[[_ExampleOutput alloc] init]];
	[pluginManagerController addHeader:@"Test2"];
	//	[pluginManagerController addPlugin:[[_ExampleOutputAgain alloc] init]];



}

@end
