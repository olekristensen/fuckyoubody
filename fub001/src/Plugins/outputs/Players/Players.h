#pragma once

#import "GLee.h"

#import <Cocoa/Cocoa.h>
#include "Plugin.h"
#include "ofMain.h"
#include "ofxVectorMath.h"


@interface Players : ofPlugin {
	IBOutlet NSColorWell * player1color;
	IBOutlet NSColorWell * player2color;
	IBOutlet NSColorWell * player3color;
	IBOutlet NSColorWell * player4color;
}
@property (assign,readonly) NSColorWell * player1color;
@property (assign,readonly) NSColorWell * player2color;
@property (assign,readonly) NSColorWell * player3color;
@property (assign,readonly) NSColorWell * player4color;

-(NSColor*) playerColor:(int)player;

@end
