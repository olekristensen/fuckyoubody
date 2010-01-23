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
	IBOutlet NSTableView	* midiMappingsListForPrint;
	IBOutlet NSView			* printHeaderView;
	IBOutlet NSPopUpButton	* midiInterface;
	
	CFTimeInterval			updateTimeInterval;
	CFTimeInterval			midiTimeInterval;
	
	PYMIDIManager			* manager;
	PYMIDIVirtualSource		* endpoint;
	PYMIDIVirtualDestination* sendEndpoint;
	
	IBOutlet NSArrayController		* boundControlsController;
	NSMutableArray			* boundControls;
	
	bool					midiInterfaceSelectionFound;
	bool					updateView;
	
}

@property (assign) NSMutableArray * boundControls;

-(IBAction) selectMidiInterface:(id)sender;
-(IBAction) printMidiMappingsList:(id)sender;
-(IBAction) sendGo:(id)sender;

-(void)sendValue:(int)midiValue forNote:(int)midiNote onChannel:(int)midiChannel;


-(void) buildMidiInterfacePopUp;
-(void) midiSetupChanged;
-(void) bindPluginUIControl:(PluginUIMidiBinding*)binding;

-(id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;


@end