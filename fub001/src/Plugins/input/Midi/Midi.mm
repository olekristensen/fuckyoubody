/*
 *  Midi.cpp
 *  openFrameworks
 *
 *  Created by ole kristensen on 11/01/10.
 *  Copyright 2010 Recoil Performance Group. All rights reserved.
 *
 */

#include "Midi.h"

@implementation Midi

-(void) initPlugin{
	
	pthread_mutex_init(&mutex, NULL);

	userDefaults = [[NSUserDefaults standardUserDefaults] retain];
	
	manager = [PYMIDIManager sharedInstance];
	endpoint = new PYMIDIRealEndpoint;
	[endpoint retain];
	
	boundControls = [[[NSMutableArray alloc] initWithCapacity:2] retain];
	
	[midiMappingsList setDataSource:self];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(midiSetupChanged) name:@"PYMIDISetupChanged" object:nil];
	
	[self buildMidiInterfacePopUp];
	
}

-(void) setup{
	;
}

-(void) update:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	
	updateTimeInterval = timeInterval;
	
	id theControl;
	int rowIndex = 0;
	bool updateView = false;
	NSRect updateRect = NSZeroRect;
	
	pthread_mutex_lock(&mutex);

	for (theControl in boundControls){
		[[theControl midi] update:timeInterval displayTime:outputTime];
		if(timeInterval - [[theControl midi] lastTimeChanged] > ofRandom(0.1, 5.0)){
			[[theControl midi] setSmoothingValue:[[NSNumber alloc] initWithInt:round(ofRandom(0, 1.0)*127)] withTimeInterval: timeInterval];
		}
		
		// mark row for update
		if([[theControl midi] hasChanged]){
			updateRect = NSUnionRect(updateRect, [midiMappingsList rectOfRow:rowIndex]);
			updateView = true;
		}
		
		rowIndex++;
	}

	pthread_mutex_unlock(&mutex);

	if(updateView){
		//[midiMappingsList setNeedsDisplayInRect:updateRect];
		[midiMappingsList reloadData];
	}
}

-(void) controlDraw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)timeStamp{
	;
}

-(void) buildMidiInterfacePopUp{
	
	id endpointIterator;
	
	[midiInterface selectItem:nil];
	[midiInterface removeAllItems];
	[midiInterface setAutoenablesItems:NO];
	
	for (endpointIterator in [manager realSources]) {
        [midiInterface addItemWithTitle:[endpointIterator displayName]];
        [[midiInterface lastItem] setRepresentedObject:endpointIterator];
		[[midiInterface lastItem] setEnabled:YES];
		if ([userDefaults stringForKey:@"midi.interface"] != nil) {
			if([[endpointIterator displayName] isEqualToString:[userDefaults stringForKey:@"midi.interface"]]){
				[midiInterface selectItem:[midiInterface lastItem]];
			}
		}
	}
	
	if([midiInterface numberOfItems] == 0){
		[midiInterface addItemWithTitle:@"No midi interfaces found"];
		[midiInterface selectItem:[midiInterface lastItem]];
		[midiInterface setEnabled:NO];
	} else {
		if ([userDefaults stringForKey:@"midi.interface"] != nil) {
			if([midiInterface indexOfItemWithTitle:[userDefaults stringForKey:@"midi.interface"]] == -1){
				[midiInterface addItemWithTitle: [[userDefaults stringForKey:@"midi.interface"] stringByAppendingString:@" (offline)"] ];
				[[midiInterface lastItem] setEnabled:NO];
				[midiInterface selectItem:[midiInterface lastItem]];
			}
		}
		[midiInterface setEnabled:YES];
	}
}

-(IBAction) selectMidiInterface:(id)sender{
	endpoint = [[sender selectedItem] representedObject];
	[userDefaults setValue:[sender titleOfSelectedItem] forKey:@"midi.interface"];
}


-(void)midiSetupChanged {
	[self buildMidiInterfacePopUp];
}


-(id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    id theControl, theValue;
	
	//NSLog([[aTableColumn headerCell] stringValue]);
	
    NSParameterAssert(rowIndex >= 0 && rowIndex < [boundControls count]);
	pthread_mutex_lock(&mutex);
    theControl = [boundControls objectAtIndex:rowIndex];
	pthread_mutex_unlock(&mutex);
	
	theValue = [[NSString alloc] initWithString:@""];
	
	if([[[aTableColumn headerCell] stringValue] isEqualToString:@"➜"]){
		if([[theControl midi] lastTimeChanged] - updateTimeInterval < 0.5){
			theValue = [theValue stringByAppendingString:@"➜"];
		}
	} 
	
	if([[[aTableColumn headerCell] stringValue] isEqualToString:@"Element"]){
		theValue = [theValue stringByAppendingString: NSStringFromClass([[theControl target] class])];
		theValue = [theValue stringByAppendingString:@"."];
		theValue = [theValue stringByAppendingString:NSStringFromSelector([theControl action])];
	} 

	else if([[[aTableColumn headerCell] stringValue] isEqualToString:@"Channel"]){
		theValue = [[theControl midi] channel];
	} 

	 else if([[[aTableColumn headerCell] stringValue] isEqualToString:@"Controller"]){
		theValue = [[theControl midi] controller];
	}
	
	else if([[[aTableColumn headerCell] stringValue] isEqualToString:@"Value"]){
		theValue = [[theControl midi] value];
	} 

	else if([[[aTableColumn headerCell] stringValue] isEqualToString:@"Actual"]){
		theValue =  [[NSNumber alloc] initWithFloat: [theControl floatValue]];
	}
	
	return theValue;
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [boundControls count];
}

-(void) bindPluginUIControl:(NSControl*)control {
	NSLog(@"[Midi bindPluginUIcontrol]");
	pthread_mutex_lock(&mutex);
	[boundControls removeObjectIdenticalTo:control];
	[boundControls addObject:[control retain]];
	pthread_mutex_unlock(&mutex);
	[midiMappingsList reloadData];
}

@end
