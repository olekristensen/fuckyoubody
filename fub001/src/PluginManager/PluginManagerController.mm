//
//  PluginManagerController.m
//
//  Created by Jonas Jongejan on 13/11/09.
//  Copyright 2009 HalfdanJ. All rights reserved.
//

#import "PluginManagerController.h"
#include "Plugin.h"



//@implementation ofPlugin
//
//@synthesize name, enabled, header, plugin;
//
//- (id)init {
//	return [super init];
//}
//
//- (void) setEnabled:(NSNumber *) n {
//	enabled = n;
//	if(plugin != nil){
//		plugin->enabled = [n boolValue];
//	}
//}
//
//@end
//



@implementation PluginManagerController 


- (void)addPlugin:(ofPlugin*)p {
//	ofPlugin * obj =  [[ofPlugin alloc]init];
/*	[obj setName:objname];
	[obj setHeader:[NSNumber numberWithBool:header]];
	[obj setPlugin:p];
	[obj setEnabled:[NSNumber numberWithBool:TRUE]];*/
//	[viewItems addObject:p];
}

- (void)addHeader:(NSString *)header {
	ofPlugin * obj =  [[ofPlugin alloc]init];
	[obj setName:header];
	 [obj setHeader:[NSNumber numberWithBool:TRUE]];
	 [obj setEnabled:[NSNumber numberWithBool:TRUE]];
	[viewItems addObject:obj];
}


//-----
// START ListView stuff
//-----


- (id)tableView:(NSTableView *)aTableView
objectValueForTableColumn:(NSTableColumn *)aTableColumn
			row:(int)rowIndex
{
	NSLog(@"content");
	NSMutableArray * array;
	int i;
	if(rowIndex < [viewItems count]){
		array = viewItems;
		i = rowIndex;
	}
	/*
	ofPlugin * p = [array objectAtIndex:i];
	if(![(NSString*)[aTableColumn identifier] compare:@"name"]){
		return [p name];		
	} else if(![(NSString*)[aTableColumn identifier] compare:@"enable"]){
		return [p enabled];
	} else {
		return @"hmm?";
	}*/
	if(![(NSString*)[aTableColumn identifier] compare:@"name"]){
		return @"gaga";		
	} else if(![(NSString*)[aTableColumn identifier] compare:@"enable"]){
	//	return [p enabled];
		return 0;
	} else {
		return @"hmm?";
	}
}


- (void)tableView:(NSTableView *)aTableView
   setObjectValue:anObject
   forTableColumn:(NSTableColumn *)aTableColumn
			  row:(int)rowIndex
{
	NSLog(@"value");

	NSMutableArray * array;
	int i;
	if(rowIndex < [viewItems count]){
		array = viewItems;
		i = rowIndex;
	}
	
	/*ofPlugin * p = [array objectAtIndex:i];
	
	if(![(NSString*)[aTableColumn identifier] compare:@"name"]){
	} else if(![(NSString*)[aTableColumn identifier] compare:@"enable"]){
		[p setEnabled:anObject];	
		[userDefaults setValue:[p enabled] forKey:[NSString stringWithFormat:@"plugins.enable%d",i]];
		
		
	}  */
	return;
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
  return [viewItems count];
}

-(IBAction) setListViewRow:(id)sender {
//	[self changeView:[sender selectedRow]];
	NSLog(@"setlistviewrow %d",[sender selectedRow]);
}


//-----
// END ListView stuff
//-----


@end
