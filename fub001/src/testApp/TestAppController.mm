//
//  TestAppController.m
//
//  Created by Jonas Jongejan on 03/11/09.
//  Copyright 2009 HalfdanJ. All rights reserved.
//

#import "TestAppController.h"

@implementation TestAppController


-(void) awakeFromNib {
	NSLog(@"Awake from nib");
	[pluginManagerController addHeader:@"Test"];
	
	
	[pluginManagerController setFrame:[mainView bounds]];
	[mainView addSubview:pluginManagerController];
	
	
}

@end
