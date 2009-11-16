//
//  PluginManagerController.h
//
//  Created by Jonas Jongejan on 13/11/09.
//
#pragma once
#import "GLee.h"


#import <Cocoa/Cocoa.h>
#include "testApp.h"
#include "Plugin.h"
@class ofPlugin;

#include "PluginListView.h"

/*
@interface ofPlugin : NSObject 
{
	NSString * name;
	NSNumber * enabled;
	NSNumber * header;
	
	FrostPlugin * plugin;
	
}
@property (retain, readwrite) NSString *name;
@property (retain, readwrite) NSNumber *enabled;
@property (retain, readwrite) NSNumber *header;
@property (assign, readwrite) NSNumber *settingsViewNumber;
@property (assign, readwrite) FrostPlugin * plugin;


@end
*/


@interface PluginManagerController : NSView {
@public

	NSMutableArray * viewItems;

	IBOutlet PluginListView * pluginListView;
	IBOutlet NSView * pluginView;

}	
@property (assign, readwrite) NSMutableArray *viewItems;


-(IBAction) setListViewRow:(id)sender;
- (void)addHeader:(NSString *)header;
- (void)addPlugin:(ofPlugin *)obj;
- (void)changeView:(int)row;


@end


