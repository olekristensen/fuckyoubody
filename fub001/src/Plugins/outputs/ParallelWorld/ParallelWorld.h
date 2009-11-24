#pragma once

#import "GLee.h"

#import <Cocoa/Cocoa.h>
#include "Plugin.h"
#include "ofMain.h"
#include "ofxVectorMath.h"

#define numFingers 3


@interface ParallelWorld : ofPlugin {
	@public
	bool fingerActive[numFingers];
	id identity[numFingers];
	ofxPoint2f fingerPositions[numFingers];
	
	vector<ofxPoint2f> lines1;
	vector<ofxPoint2f> lines2;
}

@end


@interface TouchField : BWGradientBox
{
	IBOutlet ParallelWorld * world;
}

@end

