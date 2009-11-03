//
//  SharedContextGLView.h
//  openFrameworks
//
//  Created by Edvin Besic on 7/13/09.
//  Copyright 2009 Daddy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>
#import <QTKit/QTKit.h>
#import <QuartzCore/QuartzCore.h>

@interface SharedContextGLView : NSOpenGLView
{
	NSOpenGLContext*	mySharedOpenGLContext;
//	CVDisplayLinkRef displayLink; //display link for managing rendering thread
}

+(NSOpenGLPixelFormat*)basicPixelFormat;
-(void)awakeFromNib;

@end
