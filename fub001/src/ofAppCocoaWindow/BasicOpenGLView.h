#pragma once 

#import "GLee.h"

#import <OpenGL/gl.h>
#import <OpenGL/glext.h>
#import <OpenGL/glu.h>
#include <AppKit/AppKit.h>
#include "SharedContextGLView.h"
#import <QTKit/QTKit.h>
#import <QuartzCore/QuartzCore.h>



@interface BasicOpenGLView : SharedContextGLView
{
	// string attributes
	NSMutableDictionary * stanStringAttrib;
	CFAbsoluteTime msgTime; // message posting time for expiration
	NSTimer* timer;
 	NSTimer* hudtimer;

    bool fAnimate;
	IBOutlet NSMenuItem * animateMenuItem;
    bool fInfo;
	IBOutlet NSMenuItem * infoMenuItem;
	bool fDrawHelp;
	bool fDrawCaps;
	
	NSOpenGLPixelFormat * fullScreenGLPixelFormat;
		
	CFAbsoluteTime time;
	CVDisplayLinkRef displayLink; //display link for managing rendering thread
	
	IBOutlet NSTextField * fpsText;

	int fps;
}

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

- (void)animationTimer:(NSTimer*)timer;
- (void)updateHud:(NSTimer*)timer;

- (void) drawRect:(NSRect)rect;

- (void) update;		// moved or resized

- (BOOL) acceptsFirstResponder;
- (BOOL) becomeFirstResponder;
- (BOOL) resignFirstResponder;

- (id) initWithFrame: (NSRect) frameRect;
- (void) awakeFromNib;

@end


