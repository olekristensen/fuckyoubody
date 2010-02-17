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

	NSUserDefaults				* userDefaults;
	
	IBOutlet NSTableView		* midiMappingsList;
	IBOutlet NSTableView		* midiMappingsListForPrint;
	IBOutlet NSView				* printHeaderView;
	IBOutlet NSPopUpButton		* midiInterface;
	IBOutlet NSTextField		* mscDeviceID;
	IBOutlet NSTextField		* appleScriptMachine;
	IBOutlet NSTextField		* appleScriptUsername;
	IBOutlet NSSecureTextField	* appleScriptPassword;
	
	CFTimeInterval			updateTimeInterval;
	CFTimeInterval			midiTimeInterval;
	
	PYMIDIManager				* manager;
	PYMIDIVirtualSource			* endpoint;
	PYMIDIVirtualDestination	* sendEndpoint;
	
	IBOutlet NSArrayController	* boundControlsController;
	NSMutableArray				* boundControls;
	
	bool					midiInterfaceSelectionFound;
	bool					updateView;
	bool					showMidiConflictAlert;
	bool					didShowMidiConflictAlert;
	
	float pitchBends[16];
	
}

@property (assign) NSMutableArray * boundControls;

-(IBAction) selectMidiInterface:(id)sender;
-(IBAction) printMidiMappingsList:(id)sender;
-(IBAction) sendGo:(id)sender;
-(IBAction) sendResetAll:(id)sender;
-(IBAction) testNoteOn:(id)sender;

-(void)sendValue:(int)midiValue forNote:(int)midiNote onChannel:(int)midiChannel;

-(void) buildMidiInterfacePopUp;
-(void) midiSetupChanged;
-(void) bindPluginUIControl:(PluginUIMidiBinding*)binding;
-(void) unbindPluginUIControl:(PluginUIMidiBinding*)binding;

-(void) showConflictSheet;
- (IBAction)showSelectedControl:(id)sender;
- (void)willEndCloseConflictSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;
- (void)didEndCloseConflictSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;

-(NSString*) getAppleScriptConnectionString;

-(id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;
-(float) getPitchBend:(int)channel;
@end