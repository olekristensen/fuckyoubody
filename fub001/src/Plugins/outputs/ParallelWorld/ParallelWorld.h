#pragma once

#import "GLee.h"

#import <Cocoa/Cocoa.h>
#include "Plugin.h"
#include "ofMain.h"
#include "ofxVectorMath.h"
#include "PluginOpenGLControl.h"

#define numFingers 3


@interface ParallelWorld : ofPlugin {
	@public
	bool fingerActive[numFingers];
	id identity[numFingers];
	ofxPoint2f * fingerPositions[numFingers];
	float min;
	float max;
	vector<float> *lines;
	
	IBOutlet NSButton * rotating;
}
-(IBAction) setMinSize:(id)sender;
-(IBAction) setMaxSize:(id)sender;
-(IBAction) remake:(id)sender;
@end


@interface TouchField : PluginOpenGLControlView
{
	IBOutlet ParallelWorld * world;
}

@end

