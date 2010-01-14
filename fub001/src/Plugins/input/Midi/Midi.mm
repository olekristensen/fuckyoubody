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
	
	updateView = false;
	
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
	
	pthread_mutex_lock(&mutex);
	
	for (theControl in boundControls){
		[[theControl midi] update:timeInterval displayTime:outputTime];
		/** test code 
		 if(timeInterval - [[theControl midi] lastTimeChanged] > ofRandom(0, 3)){
		 [[theControl midi] setSmoothingValue:[[NSNumber alloc] initWithInt:round(ofRandom(0, 1.0)*127)] withTimeInterval: timeInterval];
		 }
		 
		 // mark row for update
		 if([[theControl midi] hasChanged]){
		 updateRect = NSUnionRect(updateRect, [midiMappingsList rectOfRow:rowIndex]);
		 updateView = true;
		 }
		 **/
		rowIndex++;
	}
	
	pthread_mutex_unlock(&mutex);

	if(timeInterval - midiTimeInterval < 2) {
		[midiMappingsList reloadData];
	}
	
	if(timeInterval - midiTimeInterval > 0.15) {
		[[controller midiStatus] setState:NSOffState];
	}
}

BOOL isDataByte (Byte b)		{ return b < 0x80; }
BOOL isStatusByte (Byte b)		{ return b >= 0x80 && b < 0xF8; }
BOOL isRealtimeByte (Byte b)	{ return b >= 0xF8; }

- (void)processMIDIPacketList:(MIDIPacketList*)packetList sender:(id)sender {
	
	midiTimeInterval = updateTimeInterval;

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
							
				id theControl;
				
				pthread_mutex_lock(&mutex);
				
				int rowIndex = 0;
				
				for (theControl in boundControls){
					if ([[[theControl midi] channel] intValue] == channel) {
						if(controlChange){
							if ([[theControl midiController] intValue] == number) {
								[[theControl midi] setSmoothingValue:[NSNumber numberWithInt:value] withTimeInterval: updateTimeInterval];
							}
						}
					}
					rowIndex++;
				}
				pthread_mutex_unlock(&mutex);
			}
		}	
		packet = MIDIPacketNext (packet);
	}
	
	[[controller midiStatus] setState:NSOnState];
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
	[endpoint addReceiver:self];
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
		if(updateTimeInterval - [[theControl midi] lastTimeChanged] < 0.20){
			theValue = [theValue stringByAppendingString:@"➜"];
		}
	} 
	
	if([[[aTableColumn headerCell] stringValue] isEqualToString:@"Element"]){
		theValue = [[theControl midi] label];
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
		theValue = [[theControl midi] stringValue];
	}
	
	else if([[[aTableColumn headerCell] stringValue] isEqualToString:@"Visual"]){
		theValue = [[theControl midi] value];
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
