#pragma once 

#import "GLee.h"

#import <OpenGL/gl.h>
#import <OpenGL/glext.h>
#import <OpenGL/glu.h>

#include <AppKit/AppKit.h>
#include "SharedContextGLView.h"
#include "CustomGLViewDelegate.h"


/*
	More or less a copy of theo's BasicOpenGLView class, altered to
	pass events to our custom class instead of the OF main window.
*/


@interface CustomGLView : SharedContextGLView
{
	// string attributes
	NSMutableDictionary * stanStringAttrib;
	CFAbsoluteTime msgTime; // message posting time for expiration
	
	NSTimer* timer;
	
    bool fAnimate;
	IBOutlet NSMenuItem * animateMenuItem;
    bool fInfo;
	IBOutlet NSMenuItem * infoMenuItem;
	bool fDrawHelp;
	bool fDrawCaps;
	
	NSOpenGLPixelFormat * fullScreenGLPixelFormat;
	
	CFAbsoluteTime time;
	
	int window_id;
	
//	our custom delegate, handles events and whatnot...
	CustomGLViewDelegate* delegate;
	
	bool doDraw;
	

}

@property (assign, readonly) CustomGLViewDelegate* delegate;


- (void) setWindowId: (int) i;
- (void) setDoDraw: (bool) draw;

+ (NSOpenGLPixelFormat*) basicPixelFormat;

- (void)goFullscreen;
- (void)goWindow;
- (void)toggleFullscreen;

-(IBAction) animate: (id) sender;
-(IBAction) info: (id) sender;

- (void)keyDown:(NSEvent *)theEvent;
- (void) mouseDown:(NSEvent *)theEvent;
- (void) rightMouseDown:(NSEvent *)theEvent;
- (void) otherMouseDown:(NSEvent *)theEvent;
- (void) mouseUp:(NSEvent *)theEvent;
- (void) rightMouseUp:(NSEvent *)theEvent;
- (void) otherMouseUp:(NSEvent *)theEvent;
- (void) mouseDragged:(NSEvent *)theEvent;
- (void) scrollWheel:(NSEvent *)theEvent;
- (void) rightMouseDragged:(NSEvent *)theEvent;
- (void) otherMouseDragged:(NSEvent *)theEvent;

-(void)mouseMoved:(NSEvent *)theEvent;

- (void)animationTimer:(NSTimer *)timer;
- (void) drawRect:(NSRect)rect;

- (void) update;		// moved or resized

- (BOOL) acceptsFirstResponder;
- (BOOL) becomeFirstResponder;
- (BOOL) resignFirstResponder;

- (id) initWithFrame: (NSRect) frameRect;
- (void) awakeFromNib;

@end


