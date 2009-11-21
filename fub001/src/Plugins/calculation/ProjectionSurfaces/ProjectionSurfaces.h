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

#include "ofxVectorMath.h"
#include "ofxXmlSettings.h"

#include "Warp.h"
#include "coordWarp.h"

@interface ProjectionSurfacesObject : NSObject {
@public
	float aspect;
	Warp * warp;
	coordWarping * coordWarp;
	string * name;
	
	ofxPoint2f * corners[4];
}
-(void) recalculate;
-(void) setCorner:(int) n x:(float)x y:(float) y;
-(id) initWithName:(NSString*)n;

@end

@interface ProjectorObject : NSObject {
@public
	NSMutableArray * surfaces;
	string * name;
	float width;
	float height;
}
@property (retain, readwrite) 	NSMutableArray * surfaces;

-(id) initWithName:(NSString*)n;
@end


@interface ProjectionSurfaces : ofPlugin {
	IBOutlet NSPopUpButton * projectorsButton;
	IBOutlet NSPopUpButton * surfacesButton;	
	
	ofTrueTypeFont	* verdana;
	ofxVec2f * lastMousePos;
	int selectedCorner;
	int selectedSurface;
	
	ofPoint * position;
	float scale;
	
	NSMutableArray * projectors;
	
@public
}
-(IBAction) selectProjector:(id)sender;
-(IBAction) selectSurface:(id)sender;
-(ProjectorObject*) getCurrentProjector;
-(ProjectionSurfacesObject*) getCurrentSurface;
@end
