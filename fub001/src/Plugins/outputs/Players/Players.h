#pragma once

#import "GLee.h"

#import <Cocoa/Cocoa.h>
#include "Plugin.h"
#include "ofMain.h"
#include "ofxVectorMath.h"
#include "Player.h"

@interface Players : ofPlugin {
	Player * players[4];
		
	IBOutlet NSView * player1View;
		IBOutlet NSView * player2View;
		IBOutlet NSView * player3View;
		IBOutlet NSView * player4View;
}

-(NSColor*) playerColorLed:(int)player;
-(NSColor*) playerColor:(int)player;
@end
