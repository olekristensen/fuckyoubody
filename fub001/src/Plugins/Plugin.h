#pragma once

#import "GLee.h"

#import <Cocoa/Cocoa.h>
#include "PluginManagerController.h"

#include "ofMain.h"

//#include "CustomGLViewDelegate.h"

/*
class PluginController;
class ProjectionSurfaces;
class Tracker;
*/

@class PluginManagerController;

@interface ofPlugin : NSObject
{
	NSString * name;
	NSNumber * enabled;
	NSNumber * header;	
	PluginManagerController * controller;
	
	IBOutlet NSView * view;
	IBOutlet ofPlugin * plugin;
}
@property (retain, readwrite) NSString *name;
@property (assign, readwrite) NSNumber *enabled;
@property (assign, readwrite) NSNumber *header;
@property (assign, readwrite) PluginManagerController *controller;
@property (assign, readwrite) NSView * view;

- (BOOL) initWithController:(PluginManagerController*) c;
- (void) initPlugin; //The function wich the different plugin can put their init code in
- (BOOL) loadPluginNibFile;
- (void) setup;
- (void) draw;
- (void) update;

/*- (void)drawRect:(NSRect)rect;
 - (void)drawRow:(NSInteger)rowIndex clipRect:(NSRect)clipRect;*/


@end



class ofPluginold {
public:
	enum Type {
		INPUT,
		DATA,
		OUTPUT
	};
	
	int type;
	bool enabled;
	
	virtual void guiWakeup(){};
//	CustomGLViewDelegate * glDelegate;
	float dt;
	
//	PluginController * controller;
	
	
	ofPluginold();
	virtual ~ofPluginold(){};

	virtual void setup(){};
	virtual void draw(){};
	virtual void update(){};
	
	virtual void drawOnFloor(){};
	virtual void drawOnWall(){};
	
	virtual void drawMasking(){};
	
	/*void applyFloorProjection();
	void applyWallProjection();

	ProjectionSurfaces* projection();
	Tracker* blob(int n);
*/
	float mouseX, mouseY;
};