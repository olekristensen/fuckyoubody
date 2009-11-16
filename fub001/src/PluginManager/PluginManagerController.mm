//
//  PluginManagerController.m
//
//  Created by Jonas Jongejan on 13/11/09.
//

#import "PluginManagerController.h"
#include "Plugin.h"



@implementation PluginManagerController 
@synthesize viewItems;
-(id) initWithFrame:(NSRect)frameRect{
	NSLog(@"--- initWithFrame ---\n");		
	if (self = [super initWithFrame:frameRect])
    {
		viewItems = [[NSMutableArray alloc] init];			
    }
    return self;
	
}


-(void) awakeFromNib{
	NSLog(@"--- awake from nib ---\n");	
}

- (void)addPlugin:(ofPlugin*)obj {
	NSLog(@"Add plugin");
	[obj initWithController:self];
	[obj setHeader:[NSNumber numberWithBool:FALSE]];
	[[self viewItems] addObject:obj];
	
	[pluginListView reloadData];
}

- (void)addHeader:(NSString *)header {
	NSLog(@"Add header");
	ofPlugin * obj =  [[ofPlugin alloc]init];
	[obj setName:header];
	[obj setHeader:[NSNumber numberWithBool:YES]];
	[obj setEnabled:[NSNumber numberWithBool:TRUE]];
	[[self viewItems] addObject:obj];
	[pluginListView reloadData];
}


- (void)changeView:(int)row{
	ofPlugin * p = [viewItems objectAtIndex:row];
	if([p header] != [NSNumber numberWithBool:TRUE]){		
		NSEnumerator *enumerator = [[pluginView subviews] objectEnumerator];
		id anObject;		
		while (anObject = [enumerator nextObject]) {
			[anObject retain];
			[anObject removeFromSuperview];
		}
		
		if([p view] != nil){
			[[p view] setFrame:[pluginView bounds]];
			[pluginView addSubview:[p view]];
		}
	}
}


//-----
// START ListView stuff
//-----


- (id)tableView:(NSTableView *)aTableView
objectValueForTableColumn:(NSTableColumn *)aTableColumn
			row:(int)rowIndex
{
	int i;
	if(rowIndex < [[self viewItems] count]){
		i = rowIndex;
		
		ofPlugin * p = [[self viewItems] objectAtIndex:i];
		if([(NSString*)[aTableColumn identifier] isEqualToString:@"name"]){
			return [p name];		
		} else if([(NSString*)[aTableColumn identifier] isEqualToString:@"enable"]){
			return [p enabled];
		} else {
			return @"hmm?";
		}
	}
	
	
}


- (void)tableView:(NSTableView *)aTableView
   setObjectValue:anObject
   forTableColumn:(NSTableColumn *)aTableColumn
			  row:(int)rowIndex
{
	NSMutableArray * array;
	int i;
	if(rowIndex < [[self viewItems] count]){
		array = [self viewItems];
		i = rowIndex;
		
		ofPlugin * p = [[self viewItems] objectAtIndex:i];	
		if([(NSString*)[aTableColumn identifier] isEqualToString:@"name"]){
		}
		else if([(NSString*)[aTableColumn identifier] isEqualToString:@"enable"]){
			[p setEnabled:anObject];	
			//[userDefaults setValue:[p enabled] forKey:[NSString stringWithFormat:@"plugins.enable%d",i]];		
		} 
	}
	
	
	return;
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [[self viewItems] count];
}

-(IBAction) setListViewRow:(id)sender {
	[self changeView:[sender selectedRow]];
	NSLog(@"setlistviewrow %d",[sender selectedRow]);
}


//-----
// END ListView stuff
//-----


@end
