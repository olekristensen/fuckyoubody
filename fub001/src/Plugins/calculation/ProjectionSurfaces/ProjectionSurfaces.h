//
//  _ExampleOutput.h
//  openFrameworks
//
//  Created by Jonas Jongejan on 15/11/09.
//

#pragma once

#import "GLee.h"

#import <Cocoa/Cocoa.h>
#include "Plugin.h"
#include "ofMain.h"


@interface ProjectionSurfaces : ofPlugin {
	IBOutlet NSTextField * text;
	NSString * s;
@public
	ofImage * img;
	string * haha;
}
@property (retain, readwrite) NSString *s;

-(IBAction) pressButton:(id)sender;
@end
