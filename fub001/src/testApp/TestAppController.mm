//
//  TestAppController.m
//
//  Created by Jonas Jongejan on 03/11/09.
//

#import "TestAppController.h"
#include "PluginIncludes.h"
#include "testApp.h"
#include "ofAppCocoaWindow.h"

extern testApp * OFSAptr;
extern ofAppBaseWindow * window;

@implementation TestAppController

-(id) init{
	if([super init]){
		[self orderOut:nil];
		[self setAlphaValue:0.0];
		return self;
	}
}

-(void) awakeFromNib {

	NSLog(@"Awake from nib");

	[self orderOut:nil];
	[self setAlphaValue:0.0];
	
	[pluginManagerController setFrame:[mainView bounds]];
	[mainView addSubview:pluginManagerController];
	
	baseApp = OFSAptr;
	cocoaWindow = window;
	((ofAppCocoaWindow*)cocoaWindow)->windowController = self;
	((ofAppCocoaWindow*)cocoaWindow)->setup();
	
	ofSetBackgroundAuto(false);
	
}

-(void) setupPlugins{
	[pluginManagerController addHeader:@"Input"];
	[pluginManagerController addPlugin:[[Cameras alloc] init]];
	[pluginManagerController addPlugin:[[Lenses alloc] init]];
	
	[pluginManagerController addHeader:@"Calculation"];
	[pluginManagerController addPlugin:[[Tracking alloc] init]];
	[pluginManagerController addPlugin:[[ProjectionSurfaces alloc] init]];
	[pluginManagerController addPlugin:[[CameraCalibration alloc] init]];
	
	[pluginManagerController addHeader:@"Output"];
//	[pluginManagerController addPlugin:[[_ExampleOutput alloc] init]];
	[pluginManagerController addPlugin:[[Players alloc] init]];

	[pluginManagerController addPlugin:[[DanceSteps alloc] init]];
	//[pluginManagerController addPlugin:[[ParallelWorld alloc] init]];
	[pluginManagerController addPlugin:[[Lines alloc] init]];
	[pluginManagerController addPlugin:[[Stregkode alloc] init]];
	[pluginManagerController addPlugin:[[Lemmings alloc] init]];
	[pluginManagerController addPlugin:[[GTA alloc] init]];
	[pluginManagerController addPlugin:[[Strategi alloc] init]];
	[pluginManagerController addPlugin:[[Arkade alloc] init]];
	[pluginManagerController addPlugin:[[Ulykke alloc] init]];
	[pluginManagerController addPlugin:[[GrowingShadow alloc] init]];
	
	[pluginManagerController addPlugin:[[DMXOutput alloc] init]];
	
	//	[pluginManagerController addPlugin:[[_ExampleOutputAgain alloc] init]];
	
}

-(void) showMainWindow{

	[self setAlphaValue:0.0];
	[self orderFront:self];
	
	// firstView, secondView are outlets
	NSViewAnimation *theAnim;
	NSMutableDictionary* animWindowDict;
	
	// Create the attributes dictionary for the second view.
	animWindowDict = [NSMutableDictionary dictionaryWithCapacity:2];
	
	[animWindowDict setObject:self forKey:NSViewAnimationTargetKey];
	
	[animWindowDict setObject:NSViewAnimationFadeInEffect
					   forKey:NSViewAnimationEffectKey];
	
	// Create the view animation object.
	theAnim = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray
															   arrayWithObjects:animWindowDict, nil]];
	
	// Set some additional attributes for the animation.
	[theAnim setDuration:0.25];
	[theAnim setAnimationCurve:NSAnimationEaseInOut];
	
	[theAnim startAnimation];
	
	// The animation has finished, so go ahead and release it.
	[theAnim release];
	
	[self makeKeyAndOrderFront:nil];

}

@end
