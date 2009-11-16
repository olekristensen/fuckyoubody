//
//  PluginListView.m
//  openFrameworks
//
//  Created by Jonas Jongejan on 13/11/09.
//  Copyright 2009 HalfdanJ. All rights reserved.
//

#import "PluginListView.h"
#include "Plugin.h"

@implementation PluginListView

- (void)drawRect:(NSRect)rect{
	[super drawRect:rect];	
}

- (void)drawRow:(NSInteger)rowIndex clipRect:(NSRect)clipRect{
	ofPlugin * p = [[[self dataSource] viewItems] objectAtIndex:rowIndex];
	if([[p header] isEqualToNumber:[NSNumber numberWithBool:YES]]){
		NSRect bounds = [self rectOfRow:rowIndex];
		
		NSBezierPath*    clipShape = [NSBezierPath bezierPathWithRect:bounds];
		
		NSGradient* aGradient = [[[NSGradient alloc]
								  // initWithColorsAndLocations:[NSColor colorWithCalibratedRed:89 green:153 blue:229 alpha:1.0], (CGFloat)0.0,
								  initWithColorsAndLocations:[NSColor colorWithCalibratedHue:0.59 saturation:0.61 brightness:0.90 alpha:1.0], (CGFloat)0.0,
								  [NSColor colorWithCalibratedHue:0.608 saturation:0.85 brightness:0.81 alpha:1.0], (CGFloat)1.0,
								  nil] autorelease];
		
		[aGradient drawInBezierPath:clipShape angle:90.0];
		
		NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
		[paragraphStyle setAlignment:NSCenterTextAlignment];
		
		NSDictionary *textAttribs;
		textAttribs = [NSDictionary dictionaryWithObjectsAndKeys: [NSFont fontWithName:@"Lucida Grande" size:12],
					   NSFontAttributeName, [NSColor whiteColor],NSForegroundColorAttributeName,  paragraphStyle, NSParagraphStyleAttributeName, nil];
		
		[[p name] drawInRect:bounds withAttributes:textAttribs];
		
		[paragraphStyle release];
		
	} else {
		[super drawRow:rowIndex clipRect:clipRect];
	}	
}

@end