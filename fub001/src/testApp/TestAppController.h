//
//  TestAppController.h
//
//  Created by Jonas Jongejan on 03/11/09.
//
#import "GLee.h"

#import <Cocoa/Cocoa.h>
#include "PluginManagerController.h"

@interface TestAppController : NSWindow/* Specify a superclass (eg: NSObject or NSView) */ {
	IBOutlet NSView * mainView;
	IBOutlet PluginManagerController * pluginManagerController;
}

@end
