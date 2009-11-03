//
//  FrostGuiObjects.h
//  openFrameworks
//
//  Created by frost on 06/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
#import "GLee.h"

#import <Cocoa/Cocoa.h>
/*
#import "msaColor.h"


@interface ofColorWell : NSColorWell
{
	NSColorWell * valColor;
	SEL myAction;
	NSObject * myTarget;
	
	int midiChannel;
	int midiNumber;
	bool midiControlHookup;
	bool midiNoteHookup;
	
	bool hookedUpToColor;
	msaColor * hookedUpColor;
	
	bool justReceivedMidi;
}

- (void) receiveMidiOnChannel:(int)channel number:(int)number control:(bool)control noteOn:(bool)noteOn noteOff:(bool)noteOff value:(int)value;
- (void) setMidiChannel:(int)channel number:(int)number control:(bool)control note:(bool)note;
- (id) initWithFrame:(NSRect)frame;
- (void) awakeFromNib;
- (void) changeValueFromControl:(id)sender;
- (void) hookUpColor:(msaColor*)f;
- (msaColor) colorValue;

@end
*/



@interface frostCheckbox : NSButton
{
	NSButton * valButton;
	SEL myAction;
	NSObject * myTarget;
	
	int midiChannel;
	int midiNumber;
	bool midiControlHookup;
	bool midiNoteHookup;
	
	bool hookedUpToBool;
	bool * hookedUpBool;
	
	IBOutlet NSNumber * isbutton;
	
	bool justReceivedMidi;
}

- (void) receiveMidiOnChannel:(int)channel number:(int)number control:(bool)control noteOn:(bool)noteOn noteOff:(bool)noteOff value:(int)value;
- (void) setMidiChannel:(int)channel number:(int)number control:(bool)control note:(bool)note;
- (id) initWithFrame:(NSRect)frame;
- (void) awakeFromNib;
- (void) changeValueFromControl:(id)sender;
- (void) hookUpBool:(bool*)f;
- (bool) boolValue;

@end



@interface frostSlider : NSSlider
{
	NSSlider * valSlider;
	NSTextField * valTextfield;
	SEL myAction;
	NSObject * myTarget;
	
	int midiChannel;
	int midiNumber;
	bool midiControlHookup;
	bool midiNoteHookup;
	float midiScaleFactor;
	
	bool hookedUpToFloat;
	float * hookedUpFloat;
		bool justReceivedMidi;
}

- (void) receiveMidiOnChannel:(int)channel number:(int)number control:(bool)control noteOn:(bool)noteOn noteOff:(bool)noteOff value:(int)value;

- (void) setMidiChannel:(int)channel number:(int)number control:(bool)control note:(bool)note scale:(float)scale;
- (id) initWithFrame:(NSRect)frame;
- (void) awakeFromNib;
- (void) changeValueFromControl:(id)sender;
- (void) changeValueFromControlMidi:(id)sender;
- (void) hookUpFloat:(float*)f;
- (float) convertToMidiValue:(float)f;
- (float) convertFromMidiValue:(float)f;

@end
