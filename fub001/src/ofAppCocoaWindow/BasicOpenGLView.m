#import "GLee.h"
#import "BasicOpenGLView.h"

#include "ofAppCocoaWindow.h"
extern ofAppCocoaWindow * ofWindowPtr;

// ===================================

@implementation BasicOpenGLView

// pixel format definition - prob could be tweaked a lot
+ (NSOpenGLPixelFormat*) basicPixelFormat
{


	if( !ofWindowPtr->bFSAA ){
		NSOpenGLPixelFormatAttribute attributes [] = {
			NSOpenGLPFAWindow,
			NSOpenGLPFADoubleBuffer,	// double buffered
			NSOpenGLPFADepthSize, (NSOpenGLPixelFormatAttribute)16, // 16 bit depth buffer
			(NSOpenGLPixelFormatAttribute)nil
		};
		return [[[NSOpenGLPixelFormat alloc] initWithAttributes:attributes] autorelease];
	
	}else{

		//FSAA
		NSOpenGLPixelFormatAttribute attributes [] = { // 1
            NSOpenGLPFAWindow,
            NSOpenGLPFADoubleBuffer,
            NSOpenGLPFASampleBuffers, (NSOpenGLPixelFormatAttribute)4,
            NSOpenGLPFASamples, (NSOpenGLPixelFormatAttribute)8,
            NSOpenGLPFANoRecovery,
            (NSOpenGLPixelFormatAttribute)nil
        };
		return [[[NSOpenGLPixelFormat alloc] initWithAttributes:attributes] autorelease];
	
	}
	
}



#pragma mark ---- IB Actions ----

-(IBAction) animate: (id) sender
{
	fAnimate = 1 - fAnimate;
	if (fAnimate)
		[animateMenuItem setState: NSOnState];
	else 
		[animateMenuItem setState: NSOffState];
}

// ---------------------------------

-(IBAction) info: (id) sender
{
	fInfo = 1 - fInfo;
	if (fInfo)
		[infoMenuItem setState: NSOnState];
	else
		[infoMenuItem setState: NSOffState];
	[self setNeedsDisplay: YES];
}

#pragma mark ---- Method Overrides ----

-(void)keyDown:(NSEvent *)theEvent
{
    NSString *characters = [theEvent characters];
    if ([characters length]) {
        unichar character = [characters characterAtIndex:0];
		ofWindowPtr->keyPressed(character);
	}
}

// ---------------------------------

- (void)mouseDown:(NSEvent *)theEvent 
{
    if ([theEvent modifierFlags] & NSControlKeyMask) 
		[self rightMouseDown:theEvent];
	else if ([theEvent modifierFlags] & NSAlternateKeyMask) 
		[self otherMouseDown:theEvent];
	else {
		NSPoint location = [self convertPoint:[theEvent locationInWindow] fromView:nil];
		ofWindowPtr->mousePressed(location.x, location.y, 0);
	}
}

// ---------------------------------

- (void)rightMouseDown:(NSEvent *)theEvent
{
	NSPoint location = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	ofWindowPtr->mousePressed(location.x, location.y, 1);

}

// ---------------------------------

- (void)otherMouseDown:(NSEvent *)theEvent
{
	NSPoint location = [self convertPoint:[theEvent locationInWindow] fromView:nil];	
	ofWindowPtr->mousePressed(location.x, location.y, 2);
}

- (void)mouseMoved:(NSEvent *)theEvent{
	NSPoint location = [self convertPoint:[theEvent locationInWindow] fromView:nil];	
	ofWindowPtr->mouseMoved(location.x, location.y);
}


// ---------------------------------

- (void)mouseUp:(NSEvent *)theEvent
{
	ofWindowPtr->mouseReleased(0);
}

// ---------------------------------

- (void)rightMouseUp:(NSEvent *)theEvent
{
	ofWindowPtr->mouseReleased(1);
}

// ---------------------------------

- (void)otherMouseUp:(NSEvent *)theEvent
{
	ofWindowPtr->mouseReleased(2);
}

// ---------------------------------

- (void)mouseDragged:(NSEvent *)theEvent
{
	NSPoint location = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	ofWindowPtr->mouseDragged(location.x, location.y, 0);
}

// ---------------------------------

- (void)scrollWheel:(NSEvent *)theEvent
{
//	float wheelDelta = [theEvent deltaX] +[theEvent deltaY] + [theEvent deltaZ];
//	if (wheelDelta)
//	{
//		GLfloat deltaAperture = wheelDelta * -camera.aperture / 200.0f;
//
//	}
}

// ---------------------------------

- (void)rightMouseDragged:(NSEvent *)theEvent
{
	NSPoint location = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	ofWindowPtr->mouseDragged(location.x, location.y, 1);
}

// ---------------------------------

- (void)otherMouseDragged:(NSEvent *)theEvent
{
	NSPoint location = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	ofWindowPtr->mouseDragged(location.x, location.y, 2);

}

// ---------------------------------
// THEO - this our update function!
// per-window timer function, basic time based animation preformed here
- (void)animationTimer:(NSTimer*)timer
{
	/*if( ofWindowPtr->bNewWindowString ){
		NSString *stringFromUTFString = [[NSString alloc] initWithUTF8String:ofWindowPtr->windowString.c_str() ];
		[ [self window] setTitle: stringFromUTFString];
		ofWindowPtr->bNewWindowString = false;
	}

	if( ofWindowPtr->bNewScreenSize ){
		NSRect newFrame  = [[self window] frame];
		NSRect currFrame = [self frame];

		newFrame.size = NSMakeSize(ofWindowPtr->requestedWidth, ofWindowPtr->requestedHeight);
		newFrame.origin.y += currFrame.size.height - ofWindowPtr->requestedHeight + 40; //the 40 takes into account the top and bottom bars
		
		[[self window] setFrame:newFrame display:NO];
		ofWindowPtr->bNewScreenSize = false;
	}

	if( ofWindowPtr->bNewScreenPosition ){
		NSRect screenRect = [[NSScreen mainScreen] frame];

		NSPoint point;
		point.x = ofWindowPtr->requestedX;
		point.y = screenRect.size.height - (ofWindowPtr->requestedY+20); //takes into account the 20 pixels of the menubar
						
		[[self window] setFrameTopLeftPoint:point];
		
		ofWindowPtr->bNewScreenPosition = false;
	}
	*/
	

//	

	
	if( ofWindowPtr->bNewScreenMode && ofWindowPtr->windowMode == 1 ){
		[self goFullscreen];
		ofWindowPtr->bNewScreenMode = false;
	}	
	
	else if( ofWindowPtr->bNewScreenMode && ofWindowPtr->windowMode == 0 ){
		[self goWindow];
		ofWindowPtr->bNewScreenMode = false;
	}		
	
	ofWindowPtr->update();


	[self drawRect:[self bounds]]; // redraw now instead dirty to enable updates during live resize
}

// ---------------------------------

- (void) drawRect:(NSRect)rect
{		

	
    [[self openGLContext] makeCurrentContext];
	NSRect rectView = [self frame];
	fps = ofWindowPtr->getFrameRate();
		ofWindowPtr->render(rectView.size.width, rectView.size.height);
	
	[[self openGLContext] flushBuffer];

}

// ---------------------------------

//THEO - not a real update - animationTimer is our update

// this can be a troublesome call to do anything heavyweight, as it is called on window moves, resizes, and display config changes.  So be
// careful of doing too much here.
- (void) update // window resizes, moves and display changes (resize, depth and display config change)
{
	[super update];
		
	if (![self inLiveResize])  {// if not doing live resize

	}
}

// ---------------------------------

-(id) initWithFrame: (NSRect) frameRect
{
	//creation of the GL  context
	NSOpenGLPixelFormat * pf = [BasicOpenGLView basicPixelFormat];
	self = [super initWithFrame: frameRect pixelFormat: pf];
			
    return self;
}

// ---------------------------------

- (BOOL)acceptsFirstResponder
{
  return YES;
}

// ---------------------------------

- (BOOL)becomeFirstResponder
{
  return  YES;
}

// ---------------------------------

- (BOOL)resignFirstResponder
{
  return YES;
}

// ---------------------------------
- (void) goFullscreen{
	if([self respondsToSelector:@selector(isInFullScreenMode)])
	{
		if(![self isInFullScreenMode])
		{
		   [self enterFullScreenMode:[[NSScreen screens]lastObject]
				 withOptions:[NSDictionary dictionaryWithObject: [NSNumber numberWithBool: NO] forKey: NSFullScreenModeAllScreens] ];
		}
	}
}

// ---------------------------------
- (void) goWindow{
	if([self respondsToSelector:@selector(isInFullScreenMode)]){
		if([self isInFullScreenMode]){
		   [self exitFullScreenModeWithOptions:nil];
		}
	}
}

// ---------------------------------
- (void) toggleFullscreen{
	if([self respondsToSelector:@selector(isInFullScreenMode)])
   {
	   if([self isInFullScreenMode])
	   {
		   [self exitFullScreenModeWithOptions:nil];
	   }
	   else
	   {
		   [self enterFullScreenMode:[NSScreen mainScreen] withOptions:nil];
	   }
   }
}

// ---------------------------------

- (void) awakeFromNib
{
	[super awakeFromNib];
	printf("awakeFromNib\n");

	fInfo = 1;
	fAnimate = 1;
	time = CFAbsoluteTimeGetCurrent();  // set animation time start time
	fDrawHelp = 1;
		
	//lets set the window size to the requested size - this is duplicated in update - so maybe making some nice functions could be a good idea
	/*NSRect currFrame = [self frame];
	NSRect newFrame = [[self windaow] frame];
	newFrame.size = NSMakeSize(ofWindowPtr->requestedWidth, ofWindowPtr->requestedHeight);
	newFrame.origin.y += currFrame.size.height - ofWindowPtr->requestedHeight + 40; //the 40 takes into account the top and bottom bars*/
	/*[[self window] setFrame:newFrame display:NO];	*/
	
	//need this to get mouse moved events
	[[self window] setAcceptsMouseMovedEvents:YES]; 
		
//	if([self respondsToSelector:@selector(isInFullScreenMode)])
//   {
//	   if([self isInFullScreenMode])
//	   {
//		   [self exitFullScreenModeWithOptions:nil];
//	   }
//	   else
//	   {
//		   [self enterFullScreenMode:[NSScreen mainScreen] withOptions:nil];
//	   }
//   }

	//some cool stuff:
	
	 //SetSystemUIMode(kUIModeAllHidden,NULL);					//hides ui elements
	//[[self window] setLevel:NSScreenSaverWindowLevel]; //sets what level to draw at
	//[[self window] setAlphaValue:0.5];						
	//[[self window] setOpaque:true];							//supposidely speeds up drawing

	// start animation timer -  theo: we need to find a way to change this interval?
	timer = [NSTimer timerWithTimeInterval:(1.0f/ofWindowPtr->frameRateGoal) target:self selector:@selector(animationTimer:) userInfo:nil repeats:YES];
	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSEventTrackingRunLoopMode]; // ensure timer fires during resize

	hudtimer = [NSTimer timerWithTimeInterval:(1.0f/10.0) target:self selector:@selector(updateHud:) userInfo:nil repeats:YES];
	[[NSRunLoop currentRunLoop] addTimer:hudtimer forMode:NSDefaultRunLoopMode];
	// call setup here instead
	ofWindowPtr->setup();
	
	if([[NSScreen screens] count] > 1){
		[self goFullscreen];
	}
}

/*- (CVReturn)renderTime:(const CVTimeStamp*)outputTime
{
    // Add your drawing codes here

	[self animationTimer];
    return kCVReturnSuccess;
}*/


- (void)updateHud:(NSTimer*)timer
{
	[fpsText setStringValue:[[NSNumber numberWithInt:fps]stringValue]];
}

@end
