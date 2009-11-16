//
//  PluginListView.h
//  openFrameworks
//
//  Created by Jonas Jongejan on 13/11/09.
//  Copyright 2009 HalfdanJ. All rights reserved.
//
#pragma once

#import "GLee.h"

#import <Cocoa/Cocoa.h>


@interface PluginListView : NSTableView
{
}
- (void)drawRect:(NSRect)rect;
- (void)drawRow:(NSInteger)rowIndex clipRect:(NSRect)clipRect;
@end