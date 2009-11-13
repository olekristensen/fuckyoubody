#pragma once

#import "GLee.h"


#import <Cocoa/Cocoa.h>
#include "ofMain.h"
//#include "CustomGLViewDelegate.h"

/*
class PluginController;
class ProjectionSurfaces;
class Tracker;
*/




@interface ofPlugin : NSObject
{
	NSString * name;
	NSNumber * enabled;
	NSNumber * header;	
}
@property (retain, readwrite) NSString *name;
@property (retain, readwrite) NSNumber *enabled;
@property (retain, readwrite) NSNumber *header;

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