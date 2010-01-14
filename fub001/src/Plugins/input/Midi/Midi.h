/*
 *  Midi.h
 *  openFrameworks
 *
 *  Created by ole kristensen on 11/01/10.
 *  Copyright 2010 Recoil Performance Group. All rights reserved.
 *
 */

#pragma once

#import "GLee.h"

#import <Cocoa/Cocoa.h>

#include "Plugin.h"
#include "ofMain.h"

#include "PYMIDI.h"

@interface Midi : ofPlugin <NSTableViewDataSource> {
	
	pthread_mutex_t mutex;

	NSUserDefaults			* userDefaults;
	
	IBOutlet NSTableView	* midiMappingsList;
	IBOutlet NSPopUpButton	* midiInterface;
	
	CFTimeInterval			updateTimeInterval;
	
	PYMIDIManager			* manager;
	PYMIDIVirtualSource		* endpoint;
	
	NSMutableArray			* boundControls;
	
	bool					midiInterfaceSelectionFound;
	
}

-(IBAction) selectMidiInterface:(id)sender;

-(void) buildMidiInterfacePopUp;
-(void) midiSetupChanged;

-(void) redrawArrowColumn;
-(void) redrawValueColumn;
-(void) redrawScaledColumn;
-(void) midiStatusBlink;
-(void) midiStatusOn;
-(void) midiStatusOff;

-(void) bindPluginUIControl:(NSControl*)control;

-(id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;


@end