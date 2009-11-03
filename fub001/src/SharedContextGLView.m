//
//  SharedContextGLView.m
//  openFrameworks
//
//  Created by Edvin Besic on 7/13/09.
//  Copyright 2009 Daddy. All rights reserved.
//

#import "SharedContextGLView.h"
/*
@interface SharedContextGLView (private)

- (CVReturn)renderTime:(const CVTimeStamp *)timeStamp;
//- (GLenum)readbackFrameIntoBuffer:(void*)buffer alignment:(int)alignment width:(int)width height:(int)height offsetX:(int)offsetX offsetY:(int)offsetY;

@end
*/
/*
#pragma mark--callbacks--

static CVReturn renderCallback(CVDisplayLinkRef displayLink, 
							   const CVTimeStamp *inNow, 
							   const CVTimeStamp *inOutputTime, 
							   CVOptionFlags flagsIn, 
							   CVOptionFlags *flagsOut, 
							   void *displayLinkContext)
{
    return [(SharedContextGLView*)displayLinkContext renderTime:inOutputTime];
}*/

// reference to the first context created, used by all others
// as a shareContext reference
NSOpenGLContext* __sharedOpenGLContext;

@implementation SharedContextGLView


+(NSOpenGLPixelFormat*)basicPixelFormat
{
	
	
	NSOpenGLPixelFormatAttribute attrs[] =
    {
		NSOpenGLPFAWindow, //Added
        NSOpenGLPFAPixelBuffer,
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFAAccelerated,
        NSOpenGLPFAMultisample,
        NSOpenGLPFASampleBuffers, (NSOpenGLPixelFormatAttribute)1,
        NSOpenGLPFASamples, (NSOpenGLPixelFormatAttribute)4,
        (NSOpenGLPixelFormatAttribute)nil
    };
/*	
	NSOpenGLPixelFormatAttribute attributes [] = {
        NSOpenGLPFAWindow,
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFASampleBuffers, 1, 
        NSOpenGLPFASamples, 2,
        NSOpenGLPFANoRecovery,
        (NSOpenGLPixelFormatAttribute)nil
    };
	*/
	return [[[NSOpenGLPixelFormat alloc] initWithAttributes:attrs] autorelease];
}






/*- (void)prepareOpenGL
{
	printf("---- Prepare OpenGL ----");
	
	// Synchronize buffer swaps with vertical refresh rate
    GLint swapInt = 1;
    [[self openGLContext] setValues:&swapInt forParameter:NSOpenGLCPSwapInterval]; 
	
   /* // Create a display link capable of being used with all active displays
    CVDisplayLinkCreateWithActiveCGDisplays(&displayLink);
	
    // Set the renderer output callback function
    CVDisplayLinkSetOutputCallback(displayLink, &renderCallback, self);
	
    // Set the display link for the current renderer
    CGLContextObj cglContext = [[self openGLContext] CGLContextObj];
    CGLPixelFormatObj cglPixelFormat = [[self pixelFormat] CGLPixelFormatObj];
    CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(displayLink, cglContext, cglPixelFormat);
	
    // Activate the display link
    CVDisplayLinkStart(displayLink);
}
*/


-(void)awakeFromNib
{
	printf( "SharedOpenGLContext::awakeFromNib\n" );

/// first time
	if( __sharedOpenGLContext == nil )
	{
		__sharedOpenGLContext = mySharedOpenGLContext = [[NSOpenGLContext alloc] initWithFormat:[SharedContextGLView basicPixelFormat] shareContext:nil];
		printf( "SharedOpenGLContext: Created main context\n" );
	}
	else
	{
		mySharedOpenGLContext = [[NSOpenGLContext alloc] initWithFormat:[SharedContextGLView basicPixelFormat] shareContext:__sharedOpenGLContext];
		printf( "SharedOpenGLContext: Created secondary context\n" );
	}

/// set and make current
	[self setOpenGLContext:mySharedOpenGLContext];
	[mySharedOpenGLContext makeCurrentContext];
}

- (void)dealloc
{
    // Release the display link
  //  CVDisplayLinkRelease(displayLink);
	
    [super dealloc];
}

@end
