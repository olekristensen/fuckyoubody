//
//  FrostGuiObjects.m
//  openFrameworks
//
//  Created by frost on 06/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FrostGuiObjects.h"
/*
#pragma mark Colorwell
@implementation ofColorWell

- (void) receiveMidiOnChannel:(int)channel number:(int)number control:(bool)control noteOn:(bool)noteOn noteOff:(bool)noteOff value:(int)value{
	justReceivedMidi = false;	
	[self setNeedsDisplay:TRUE];
	if(midiChannel == channel && number >= midiNumber && number <= midiNumber+2){
		if(control && midiControlHookup){
			NSColor * c = [self color];
			CGFloat p[4];
			[c getHue:&p[0] saturation:&p[1] brightness:&p[2] alpha:&p[3]];
			NSColor * c2 = [NSColor colorWithCalibratedHue:p[0] saturation:p[1] brightness:p[2] alpha:1.0];
			[self setColor:c2];

			justReceivedMidi = true;
		} 
	}
}
- (void) setMidiChannel:(int)channel number:(int)number control:(bool)control note:(bool)note{
	midiChannel = channel;
	midiNumber = number;
	midiControlHookup = control;
	midiNoteHookup = note;
	justReceivedMidi = false;	
}
- (id) initWithFrame:(NSRect)frame;
- (void) awakeFromNib;
- (void) changeValueFromControl:(id)sender;
- (void) hookUpColor:(msaColor*)f;
- (msaColor) colorValue;

@end

*/

#pragma mark Checkbox

@implementation frostCheckbox

- (void) receiveMidiOnChannel:(int)channel number:(int)number control:(bool)control noteOn:(bool)noteOn noteOff:(bool)noteOff value:(int)value{	
	justReceivedMidi = false;	
	[self setNeedsDisplay:TRUE];
	if(midiChannel == channel && number == midiNumber){
		BOOL b = TRUE;
		if(value == 0){
			b = FALSE;
		}
		if(control && midiControlHookup){
			[self setBool:b];
			justReceivedMidi = true;
		} 
	} 
}
- (void) setMidiChannel:(int)channel number:(int)number control:(bool)control note:(bool)note{
	midiChannel = channel;
	midiNumber = number;
	midiControlHookup = control;
	midiNoteHookup = note;
	justReceivedMidi = false;
	
}

- (id)initWithFrame:(NSRect)frame {
	
	self = [super initWithFrame:frame];
	return self;
}

- (void) awakeFromNib{
	
	NSRect checkboxFrame = NSMakeRect(50,0, [self frame].size.width-50, [self frame].size.height); 
	
	NSButton* button = [[NSButton alloc] initWithFrame:checkboxFrame];
	
	//[button takeBoolValueFrom:self];
	[button setTarget:self];
	[button setAction: @selector(changeValueFromControl:)];
	//	if([self->isbutton intValue] > 0){
	if([self bezelStyle] == NSTexturedRoundedBezelStyle){
		[button setButtonType: NSMomentaryPushInButton ];
		[button setBezelStyle:NSTexturedRoundedBezelStyle];
		[button setImage:[self image]];
		[button setImagePosition:[self imagePosition]];
		isbutton = TRUE;
		
	} else {
		[button setButtonType: NSSwitchButton ];
		
	}
	[button setTitle:[self title]];
	//	[button setCell:[self cell]];
	
	[self addSubview:button];
	
	valButton = button;
	
	[button release];
}

- (void) changeValueFromControl:(id)sender{
	//printf("changeValueFromControl\n");
	[self setState:[sender state]];
	if(hookedUpToBool){
		if(!isbutton)
			*hookedUpBool = [self boolValue];		
		else{
			//printf("TRUE\n");
			*hookedUpBool = true;		
		}
	}
}

- (bool) boolValue{
	//printf("boolValue\n");
	
	if([self state] == NSOnState){
		return true;
	} else {
		return false;
	}
}
- (void)drawRect:(NSRect)rect{
	//[valTextfield drawRect:rect];
	//[valSlider drawRect:rect];
	// nothing here - the slider itself should be hidden;
	NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	[paragraphStyle setAlignment:NSCenterTextAlignment];
	
	if(midiNoteHookup || midiControlHookup){
		NSDictionary *textAttribs;
		NSColor * c;
		if(justReceivedMidi)
			c = [NSColor redColor];
		else {
			c = [NSColor blackColor];
		}
		
		textAttribs = [NSDictionary dictionaryWithObjectsAndKeys: [NSFont fontWithName:@"Lucida Grande" size:7],
					   NSFontAttributeName, c,NSForegroundColorAttributeName,  paragraphStyle, NSParagraphStyleAttributeName, nil];
		
		NSRect frame = NSMakeRect(0, 0, 50, 30); 
		
		[[NSString stringWithFormat:@"%d C:%d\n%d  N:%d",midiChannel,midiControlHookup,midiNumber,midiNoteHookup] drawInRect:frame withAttributes:textAttribs];
		
	} else {
		NSDictionary *textAttribs;
		textAttribs = [NSDictionary dictionaryWithObjectsAndKeys: [NSFont fontWithName:@"Lucida Grande" size:12],
					   NSFontAttributeName, [NSColor blackColor],NSForegroundColorAttributeName,  paragraphStyle, NSParagraphStyleAttributeName, nil];
		
		NSRect frame = NSMakeRect(0, 0, 50, 30); 
		
		[@"-" drawInRect:frame withAttributes:textAttribs];
		
	}
	[paragraphStyle release];
	
}
- (void) hookUpBool:(bool*)f{
	hookedUpBool = f;
	hookedUpToBool = TRUE;
	*hookedUpBool = [self boolValue];
}
/*
 - (float) convertToMidiValue:(float)f {
 float a = [self maxValue] - [self minValue];
 f -= [self minValue];
 f /= a;
 f *= 127.0;
 return f;
 }
 - (float) convertFromMidiValue:(float)f{
 float a = [self maxValue] - [self minValue];
 f /= 127.0;
 f *= a;
 f += [self minValue];
 return f;
 }
 */

- (void) setState:(NSInteger)value {
	//printf("setState\n");
	[valButton setState:value];
	[super setState:value];
	[self sendAction:[self action] to:[self target]];
	if(!isbutton){		
		//printf("Set state %d\n", [self boolValue]);
		if(hookedUpToBool){
			*hookedUpBool = [self boolValue];		
		}
	}
}

- (void) setBool:(BOOL)value {
	//printf("setBool\n");
	NSInteger * i;
	if(value){
		i = NSOnState;
	} else {
		i = NSOffState;
	}
	
	[valButton setState:i];
	[super setState:i];
	[self sendAction:[self action] to:[self target]];
	if(hookedUpToBool){
		*hookedUpBool = [self boolValue];		
	}
}


@end



@implementation frostSlider


- (void) receiveMidiOnChannel:(int)channel number:(int)number control:(bool)control noteOn:(bool)noteOn noteOff:(bool)noteOff value:(int)value{	
	justReceivedMidi = false;	
	[self setNeedsDisplay:TRUE];
	if(midiChannel == channel && number == midiNumber){
		if((noteOn || noteOff) && midiNoteHookup){
			[self setFloatValue:(float)value*midiScaleFactor]		;	
			justReceivedMidi = true;
			
		}  
		if(control && midiControlHookup){
			[self setFloatValue:(float)value*midiScaleFactor];
			justReceivedMidi = true;
			
		} else {
		}
	}
}
- (void) setMidiChannel:(int)channel number:(int)number control:(bool)control note:(bool)note scale:(float)scale{
	midiChannel = channel;
	midiNumber = number;
	midiControlHookup = control;
	midiNoteHookup = note;
	midiScaleFactor = scale;
	justReceivedMidi = false;
}

- (id)initWithFrame:(NSRect)frame {
	self = [super initWithFrame:frame];
	return self;
}

- (void) awakeFromNib{
	
	NSRect sliderFrame = NSMakeRect(50,0, [self frame].size.width-110, [self frame].size.height); 
	
	NSSlider* slider = [[NSSlider alloc] initWithFrame:sliderFrame];
	
	[slider setMinValue:[self minValue]];
	[slider setMaxValue:[self maxValue]];
	[slider setTickMarkPosition:NSTickMarkBelow];
	[slider setNumberOfTickMarks:11];
	[slider setContinuous:true];
	[slider takeDoubleValueFrom:self];
	[slider setTarget:self];
	[slider setAction: @selector(changeValueFromControl:)];
	
	NSRect valFrame = NSMakeRect([self frame].size.width-50, 0, 50, 22); 
	
	NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
	
	[numberFormatter setAllowsFloats:YES];
	[numberFormatter setAlwaysShowsDecimalSeparator:YES];
	[numberFormatter setHasThousandSeparators:NO];
	[numberFormatter setNumberStyle:kCFNumberFormatterDecimalStyle];
	[numberFormatter setMinimumFractionDigits:1];
	
	NSNumber * maximum = [[NSNumber alloc] initWithDouble:[self maxValue]];
	NSNumber * minimum = [[NSNumber alloc] initWithDouble:[self minValue]];
	
	[numberFormatter setMaximum:maximum];
	[numberFormatter setMinimum:minimum];
	
	NSTextField * val = [[NSTextField alloc] initWithFrame:valFrame];
	
	[val setFormatter:numberFormatter];
	
	[val setTarget:self];
	[val setAction: @selector(changeValueFromControl:)];
	[val takeDoubleValueFrom:self];
	
	[self addSubview:slider];
	[self addSubview:val];
	
	valSlider = slider;
	valTextfield = val;
	
	[slider release];
	[val release];
	[numberFormatter release];
	[maximum release];
	[minimum release];
}

- (void) changeValueFromControl:(id)sender{
	[self setFloatValue:[sender floatValue]];
	if(hookedUpToFloat){
		*hookedUpFloat = [self floatValue];
		
	}
}


- (void)drawRect:(NSRect)rect{
	//[valTextfield drawRect:rect];
	//[valSlider drawRect:rect];
	// nothing here - the slider itself should be hidden;
	NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	[paragraphStyle setAlignment:NSCenterTextAlignment];
	
	if(midiNoteHookup || midiControlHookup){
		NSDictionary *textAttribs;
		NSColor * c;
		
		if(justReceivedMidi)
			c = [NSColor redColor];
		else {
			c = [NSColor blackColor];
		}
		
		textAttribs = [NSDictionary dictionaryWithObjectsAndKeys: [NSFont fontWithName:@"Lucida Grande" size:7],
					   NSFontAttributeName, c,NSForegroundColorAttributeName,  paragraphStyle, NSParagraphStyleAttributeName, nil];
		
		NSRect frame = NSMakeRect(0, 0, 50, 30); 
		
		[[NSString stringWithFormat:@"%d C:%d %i\n%d  N:%d",midiChannel,midiControlHookup,(int)(floor([self convertToMidiValue:[self floatValue]])),midiNumber,midiNoteHookup] drawInRect:frame withAttributes:textAttribs];
		
	} else {
		NSDictionary *textAttribs;
		textAttribs = [NSDictionary dictionaryWithObjectsAndKeys: [NSFont fontWithName:@"Lucida Grande" size:12],
					   NSFontAttributeName, [NSColor blackColor],NSForegroundColorAttributeName,  paragraphStyle, NSParagraphStyleAttributeName, nil];
		
		NSRect frame = NSMakeRect(0, 0, 50, 30); 
		
		[@"-" drawInRect:frame withAttributes:textAttribs];
		
	}
	[paragraphStyle release];
}


- (void) hookUpFloat:(float*)f{
	hookedUpFloat = f;
	hookedUpToFloat = true;
	*hookedUpFloat = [self floatValue];
	//printf("   %f",*hookedUpFloat);
}

- (float) convertToMidiValue:(float)f {
	float a = [self maxValue] - [self minValue];
	f -= [self minValue];
	f /= a;
	f *= 127.0;
	return f;
}
- (float) convertFromMidiValue:(float)f{
	float a = [self maxValue] - [self minValue];
	f /= 127.0;
	f *= a;
	f += [self minValue];
	return f;
}

- (void) setFloatValue:(float)aFloat {
	[valSlider setFloatValue:aFloat];
	[valTextfield setFloatValue:aFloat];
	[super setFloatValue:aFloat];
	[self sendAction:[self action] to:[self target]];
	if(hookedUpToFloat){
		//printf("   %f",*hookedUpFloat);
		*hookedUpFloat = [self floatValue];
	}
}

- (void) setDoubleValue:(double)aDouble {
	//	[self changeValueFromControl:[NSNumber numberWithDouble:aDouble]];
	[valSlider setDoubleValue:aDouble];
	[valTextfield setDoubleValue:aDouble];
	[super setDoubleValue:aDouble];
	[self sendAction:[self action] to:[self target]];
	if(hookedUpToFloat){
		*hookedUpFloat = [self floatValue];
		//printf("   %f",*hookedUpFloat);
		
	}
}

- (void) setEnabledWithButton:(id)sender{
	if([sender state] == NSOnState){
		[super setEnabled:FALSE];
		[valSlider setEnabled:FALSE];
		[valTextfield setEnabled:FALSE];
	} else {
		[super setEnabled:TRUE];
		[valSlider setEnabled:TRUE];
		[valTextfield setEnabled:TRUE];
	}
}


@end