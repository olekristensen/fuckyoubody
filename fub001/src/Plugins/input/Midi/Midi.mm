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
@synthesize boundControls;


-(void) initPlugin{
	
	pthread_mutex_init(&mutex, NULL);
	
	userDefaults = [[NSUserDefaults standardUserDefaults] retain];
	
	manager = [PYMIDIManager sharedInstance];
	endpoint = new PYMIDIRealEndpoint;
	[endpoint retain];
	
	sendEndpoint = new PYMIDIRealEndpoint;
	//	[sendEndpoint retain];
	
	updateView = false;
	
	boundControls = [[[NSMutableArray alloc] initWithCapacity:2] retain];
	
	//[self setBoundControls:[boundControlsController content]]; //
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(midiSetupChanged) name:@"PYMIDISetupChanged" object:nil];
	
	[self buildMidiInterfacePopUp];
	
}

-(void) setup{
	[midiMappingsList setDoubleAction:@selector(showSelectedControl:)];
}

- (IBAction)showSelectedControl:(id)sender {
	

	NSInteger theRow = [boundControlsController selectionIndex];
	
    if ( theRow != NSNotFound ) { 
		
        PluginUIMidiBinding* selectedBinding =
		(PluginUIMidiBinding*) [[boundControlsController arrangedObjects]
								  objectAtIndex: theRow];
		
        [selectedBinding bringIntoView];
		
    }
  
}

-(void) showConflictSheet{
	
	NSBeginCriticalAlertSheet(NSLocalizedString(@"MIDI Controller Conflict", @"Title of alert panel which comes up when user chooses Quit"),
					  NSLocalizedString(@"Continue", @"Choice (on a button) given to user which allows him/her to quit the application even though there are unsaved documents."),
					  NSLocalizedString(@"Quit", @"Choice (on a button) given to user which allows him/her to review all unsaved documents if he/she quits the application without saving them all first."),
					  NSLocalizedString(@"Show conflicts", @"Choice (on a button) given to user which allows him/her to review all unsaved documents if he/she quits the application without saving them all first."),
					  [NSApp mainWindow],
					  self,
					  @selector(willEndCloseConflictSheet:returnCode:contextInfo:),
					  @selector(didEndCloseConflictSheet:returnCode:contextInfo:),
					  nil,
					  NSLocalizedString(@"Some of the midi controllers are conflicting, they are highlighted in red in the list of midiControllers.", @"Warning in the alert panel which comes up when user chooses Quit and there are unsaved documents.")
					  );
}

- (void)willEndCloseConflictSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
	if (returnCode == NSAlertDefaultReturn) {       /* "Continue" */
		// do nothing
	} 
	if (returnCode == NSAlertAlternateReturn) {     /* "Quit" */
		[[[NSApplication sharedApplication] delegate] setNoQuestionsAsked:YES];
		[[NSApplication sharedApplication] terminate:self];
	}

	if (returnCode == NSAlertOtherReturn) {			/* "Show conflicts" */
		[globalController changeView:[[globalController viewItems] indexOfObject:self]];
	}       
}

- (void)didEndCloseConflictSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
	if (returnCode == NSAlertDefaultReturn) {       /* "Continue" */
		// do nothing
	} 
	if (returnCode == NSAlertAlternateReturn) {     /* "Quit" */
		[[[NSApplication sharedApplication] delegate] setNoQuestionsAsked:YES];
		[[NSApplication sharedApplication] terminate:self];
	}
	
	if (returnCode == NSAlertOtherReturn) {			/* "Show conflicts" */
		[globalController changeView:[[globalController viewItems] indexOfObject:self]];
	}       
}

-(void) update:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	
	updateTimeInterval = timeInterval;
	
	NSMutableIndexSet * rowIndexesChanged = [[NSMutableIndexSet alloc] init];
	
	id theBinding;
	int rowIndex = 0;
	
	pthread_mutex_lock(&mutex);
	
	for (theBinding in boundControls){
		[theBinding update:timeInterval displayTime:outputTime];
		if([theBinding hasChanged] || [theBinding activity]){
			NSInteger row = [boundControls indexOfObject:theBinding];
			if (row != NSNotFound) {
				[rowIndexesChanged addIndex:row];
			}			
		}
		rowIndex++;
	}
	
	[self performSelectorOnMainThread:@selector(_reloadRows:) withObject:rowIndexesChanged waitUntilDone:NO modes:[NSArray arrayWithObject:NSRunLoopCommonModes]];	
	
	pthread_mutex_unlock(&mutex);
	
	if(timeInterval - midiTimeInterval > 0.15) {
		[[controller midiStatus] setState:NSOffState];
	}
}

BOOL isDataByte (Byte b)		{ return b < 0x80; }
BOOL isStatusByte (Byte b)		{ return b >= 0x80 && b < 0xF8; }
BOOL isRealtimeByte (Byte b)	{ return b >= 0xF8; }

- (void)processMIDIPacketList:(MIDIPacketList*)packetList sender:(id)sender {
	
	midiTimeInterval = updateTimeInterval;
	
	NSMutableIndexSet * rowIndexesChanged = [[NSMutableIndexSet alloc] init];
	
	MIDIPacket * packet = &packetList->packet[0];
	
	for (int i = 0; i < packetList->numPackets; i++) {
		
		for (int j = 0; j < packet->length; j+=3) {
			
			bool noteOn = false;
			bool noteOff = false;
			bool controlChange;
			int channel = -1;
			int number = -1;
			int value = -1;
			
			if(packet->data[0+j] >= 144 && packet->data[0+j] <= 159){
				noteOn = true;
				channel = packet->data[0+j] - 143;
				number = packet->data[1+j];
				value = packet->data[2+j];
			}
			if(packet->data[0+j] >= 128 && packet->data[0+j] <= 143){
				noteOff = true;
				channel = packet->data[0+j] - 127;
				number = packet->data[1+j];
				value = 0; //packet->data[2+j];
			}
			if(packet->data[0+j] >= 176 && packet->data[0+j] <= 191){
				controlChange = true;
				channel = packet->data[0+j] - 175;
				number = packet->data[1+j];
				value = packet->data[2+j];
			}
			
			if([self isEnabled]){
				
				id theBinding;
				
				pthread_mutex_lock(&mutex);
				
				NSMutableIndexSet * changedIndexes = [[NSMutableIndexSet alloc] init];
				int rowIndex = 0;
				
				for (theBinding in boundControls){
					if ([[theBinding channel] intValue] == channel) {
						if(controlChange){
							if ([[theBinding controller] intValue] == number) {
								[theBinding setSmoothingValue:[NSNumber numberWithInt:value] withTimeInterval: updateTimeInterval];
								NSInteger row = [boundControls indexOfObject:theBinding];
								if (row != NSNotFound) {								
									[rowIndexesChanged addIndex:row];
								}
							}
						}
					}
					rowIndex++;
				}
				
				[self performSelectorOnMainThread:@selector(_reloadRows:) withObject:rowIndexesChanged waitUntilDone:NO modes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
				
				pthread_mutex_unlock(&mutex);
			}
		}	
		packet = MIDIPacketNext (packet);
	}
	[[controller midiStatus] setState:NSOnState];
	[rowIndexesChanged release];
}

- (void)_reloadRows:(id)dirtyRows {
	pthread_mutex_lock(&mutex);
	[midiMappingsList reloadDataForRowIndexes:dirtyRows columnIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 7)]];
	pthread_mutex_unlock(&mutex);
}

-(void) controlDraw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)timeStamp{
	
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
				endpoint = endpointIterator;
				[endpoint addReceiver:self];
			}
		}
	}
	
	for (endpointIterator in [manager realDestinations]) {
		if ([userDefaults stringForKey:@"midi.interface"] != nil) {
			if([[endpointIterator displayName] isEqualToString:[userDefaults stringForKey:@"midi.interface"]]){
				sendEndpoint = endpointIterator;
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
	
	id endpointIterator;
	for (endpointIterator in [manager realDestinations]) {
		if ([userDefaults stringForKey:@"midi.interface"] != nil) {
			if([[endpointIterator displayName] isEqualToString:[endpoint displayName]]){
				sendEndpoint = endpointIterator;
			}
		}
	}
	
	[endpoint addReceiver:self];
	[userDefaults setValue:[sender titleOfSelectedItem] forKey:@"midi.interface"];
}


-(void)midiSetupChanged {
	[self buildMidiInterfacePopUp];
}

-(void)sendValue:(int)midiValue forNote:(int)midiNote onChannel:(int)midiChannel{
	
	Byte packetbuffer[128];
	MIDIPacketList packetlist;
	MIDIPacket     *packet     = MIDIPacketListInit(&packetlist);
	Byte mdata[3] = {(143+midiChannel), midiNote, midiValue};
	packet = MIDIPacketListAdd(&packetlist, sizeof(packetlist),
							   packet, 0, 3, mdata);
	
	if (endpoint) {
		[sendEndpoint addSender:self];
		[sendEndpoint processMIDIPacketList:&packetlist sender:self];
		[sendEndpoint removeSender:self];
	}
	
	
}

-(IBAction) sendGo:(id)sender{
	[self sendValue:1 forNote:1 onChannel:1];
}

-(IBAction) printMidiMappingsList:(id)sender{
	[midiMappingsListForPrint reloadData];
	
	[[NSPrintInfo sharedPrintInfo] setHorizontalPagination:NSFitPagination];
	[[NSPrintInfo sharedPrintInfo] setVerticalPagination:NSAutoPagination];
	
	
	NSPrintOperation *op = [NSPrintOperation
							printOperationWithView:midiMappingsListForPrint
							printInfo:[NSPrintInfo sharedPrintInfo]];
	[op runOperationModalForWindow:[[NSApplication sharedApplication] mainWindow]
						  delegate:self
					didRunSelector:nil
					   contextInfo:NULL];
	
	/**
	 
	 [[NSPrintOperation printOperationWithView:midiMappingsListForPrint printInfo:[NSPrintInfo sharedPrintInfo]] 
	 runOperation];
	 **/
}

-(void) bindPluginUIControl:(PluginUIMidiBinding*)binding {
	pthread_mutex_lock(&mutex);
	
	[boundControls removeObjectIdenticalTo:binding];
	
	id theBinding;
	for (theBinding in boundControls){
		if ([[theBinding channel] intValue] == [[binding channel] intValue]) {
			if ([[theBinding controller] intValue] == [[binding controller] intValue]) {
				[theBinding setConflict:YES];
				[binding setConflict:YES];
				NSLog(@"theere is a conflict bewteeen: %i %i   and    %i %i", [[theBinding channel] intValue], [[theBinding controller] intValue], [[binding channel] intValue], [[binding controller] intValue] );
				
				showMidiConflictAlert = YES;
				[NSObject cancelPreviousPerformRequestsWithTarget:self];
				[self performSelector:@selector(showConflictSheet) withObject:nil afterDelay:1.0];
			}
		}
	}
	
	[boundControlsController addObject:[binding retain]];
	
	pthread_mutex_unlock(&mutex);
}

@end
