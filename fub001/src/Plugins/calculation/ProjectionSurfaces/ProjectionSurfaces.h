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
#include "Filter.h"

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
	
	Filter * trackingFilter[8];
	ofxPoint2f * trackingOffsets[4];
	ofxPoint2f * trackingDestinations[4];
	
	int trackerNumber;
	
	bool tracking;
	bool calibrating;
	
	id projector;
}
-(void) recalculate;
-(void) setCornerObject:(NSArray*)obj;
-(void) setCorner:(int) n x:(float)x y:(float) y projector:(int)projector surface:(int)surface storeUndo:(BOOL)undo;
-(id) initWithName:(NSString*)n projector:(id)proj;


@end

@interface ProjectorObject : NSObject {
@public
	NSMutableArray * surfaces;
	string * name;
	float width;
	float height;
}
@property (retain, readwrite) 	NSMutableArray * surfaces;
@property (readwrite) string * name;

-(id) initWithName:(NSString*)n;
@end


@interface ProjectionSurfaces : ofPlugin {
	IBOutlet NSSegmentedControl * projectorsButton;
	IBOutlet NSSegmentedControl * surfacesButton;	
	IBOutlet NSPopUpButton * trackerButton;	
	
	IBOutlet NSButton * showGrid;

	IBOutlet NSButton * trackingButton;
	IBOutlet NSButton * calibrateButton;
	
	IBOutlet PluginUISlider * aspectSlider;
	ofTrueTypeFont	* font;
	ofImage * recoilLogo;
	ofxVec2f * lastMousePos;
	ofxVec2f * lastMousePosNotScaled;

	int selectedCorner;
	int selectedSurface;
	pthread_mutex_t mutex;

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
-(IBAction) selectTracker:(id)sender;
-(IBAction) calibrate:(id)sender;
-(IBAction) setAspect:(id)sender;

-(ProjectorObject*) getCurrentProjector;
-(ProjectionSurfacesObject*) getCurrentSurface;
-(void) drawGrid:(string)text aspect:(float)aspect resolution:(float)resolution drawBorder:(bool)drawBorder alpha:(float)a fontSize:(float)fontSize simple:(BOOL)simple;
-(void) applyProjection:(ProjectionSurfacesObject*) obj width:(float) _w height:(float) _h;
-(void) applyProjection:(ProjectionSurfacesObject*) obj;
-(void) apply:(string)projection surface:(string)surface;
-(void) apply:(string)projection surface:(string)surface width:(float) _w height:(float) _h;
-(ProjectionSurfacesObject*) getProjectionSurfaceByName:(string)projection surface:(string)surface;
-(ProjectorObject*) getProjectorByName:(string)projection;
-(ofxPoint2f) convertToProjection:(ofxPoint2f)p;
-(ofxPoint2f) convertFromProjection:(ofxPoint2f)p;
-(ofxPoint2f) convertToProjection:(ofxPoint2f)p surface:(ProjectionSurfacesObject*)surface;
-(ofxPoint2f) convertFromProjection:(ofxPoint2f)p surface:(ProjectionSurfacesObject*)surface;

//New ones
-(ofxPoint2f) convertPoint:(ofxPoint2f)p toProjection:(string)projection fromSurface:(string)surface;
-(ofxPoint2f) convertPoint:(ofxPoint2f)p fromProjection:(string)projection toSurface:(string)surface;
-(float) getAspectForProjection:(string)projection surface:(string)surface;

-(ofxPoint2f) getFloorCoordinateOfProjector:(int)proj;
-(ofxVec2f) getFloorVectorBetweenProjectors;

-(float) getAspect;
-(float) getAspectForProjection:(string) projection surface:(string) surface;
-(ofxPoint2f) convertMousePoint:(ofxPoint2f)p;
@end
