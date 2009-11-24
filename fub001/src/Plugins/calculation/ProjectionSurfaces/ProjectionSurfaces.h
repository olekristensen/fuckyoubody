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
	
	NSUndoManager * undoManager;
	
	float lastUndoX, lastUndoY;
	
	ofxPoint2f * corners[4];
}
-(void) recalculate;
-(void) setCornerObject:(NSArray*)obj;
-(void) setCorner:(int) n x:(float)x y:(float) y projector:(int)projector surface:(int)surface storeUndo:(BOOL)undo;
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
	IBOutlet NSButton * showGrid;
	IBOutlet NSSlider * aspectSlider;
	ofTrueTypeFont	* verdana;
	ofxVec2f * lastMousePos;
	int selectedCorner;
	int selectedSurface;
	
	ofPoint * position;
	float scale;
	
	float w, h;
	
	NSMutableArray * projectors;
	
	ProjectionSurfacesObject* lastAppliedSurface;
	NSUserDefaults *userDefaults;
	
@public
}
-(IBAction) selectProjector:(id)sender;
-(IBAction) selectSurface:(id)sender;
-(IBAction) setAspect:(id)sender;

-(ProjectorObject*) getCurrentProjector;
-(ProjectionSurfacesObject*) getCurrentSurface;
-(void) drawGrid:(string)text aspect:(float)aspect resolution:(float)resolution drawBorder:(bool)drawBorder alpha:(float)a fontSize:(float)fontSize;
-(void) applyProjection:(ProjectionSurfacesObject*) obj width:(float) _w height:(float) _h;
-(void) applyProjection:(ProjectionSurfacesObject*) obj;
-(void) apply:(string)projection surface:(string)surface;
-(void) apply:(string)projection surface:(string)surface width:(float) _w height:(float) _h;;
-(float) getAspect;
-(ofxPoint2f) convertPoint:(ofxPoint2f)p;
@end
