//
//  TestAppController.m
//
//  Created by Jonas Jongejan on 03/11/09.
//

#import "TestAppController.h"
#include "PluginIncludes.h"

@implementation TestAppController


-(void) awakeFromNib {
	NSLog(@"Awake from nib");
	[pluginManagerController addHeader:@"Test"];
	[pluginManagerController addPlugin:[[_ExampleOutput alloc] init]];
	[pluginManagerController addHeader:@"Test2"];

	
	[pluginManagerController setFrame:[mainView bounds]];
	[mainView addSubview:pluginManagerController];
	
	
}

@end
