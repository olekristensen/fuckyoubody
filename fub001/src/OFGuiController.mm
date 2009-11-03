#import "OFGuiController.h"
#include "testApp.h"


OFGuiController * gui = NULL;


@implementation ofPlugin

@synthesize name, enabled, header;

- (id)init {
	return [super init];
}

- (void) setEnabled:(NSNumber *) n {
	enabled = n;
}

@end


@implementation ListView

- (void)drawRect:(NSRect)rect{
	[super drawRect:rect];	
}

- (void)drawRow:(NSInteger)rowIndex clipRect:(NSRect)clipRect{
	ofPlugin * p = [[[self dataSource] viewItems] objectAtIndex:rowIndex];
	if([[p header] isEqualToNumber:[NSNumber numberWithBool:TRUE]]){
		NSRect bounds = [self rectOfRow:rowIndex];
		
		NSBezierPath*    clipShape = [NSBezierPath bezierPathWithRect:bounds];
		
		NSGradient* aGradient = [[[NSGradient alloc]
								  // initWithColorsAndLocations:[NSColor colorWithCalibratedRed:89 green:153 blue:229 alpha:1.0], (CGFloat)0.0,
								  initWithColorsAndLocations:[NSColor colorWithCalibratedHue:0.59 saturation:0.61 brightness:0.90 alpha:1.0], (CGFloat)0.0,
								  [NSColor colorWithCalibratedHue:0.608 saturation:0.85 brightness:0.81 alpha:1.0], (CGFloat)1.0,
								  nil] autorelease];
		
		[aGradient drawInBezierPath:clipShape angle:90.0];
		
		NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
		[paragraphStyle setAlignment:NSCenterTextAlignment];
		
		NSDictionary *textAttribs;
		textAttribs = [NSDictionary dictionaryWithObjectsAndKeys: [NSFont fontWithName:@"Lucida Grande" size:12],
					   NSFontAttributeName, [NSColor whiteColor],NSForegroundColorAttributeName,  paragraphStyle, NSParagraphStyleAttributeName, nil];
		
		[[p name] drawInRect:bounds withAttributes:textAttribs];
		
		[paragraphStyle release];
		
	} else {
		[super drawRow:rowIndex clipRect:clipRect];
	}
}

@end


@implementation contentView : NSView
- (void)drawRect:(NSRect)rect{
	[super drawRect:rect];	
}
@end



@implementation OFGuiController

@synthesize viewItems,views;

-(void) awakeFromNib {
	
	NSLog(@"--- wake from nib ---\n");
		
	}


- (id)init {
	NSLog(@"--- init ---\n");	
	
	if(self = [super init]) {
		
		userDefaults = [[NSUserDefaults standardUserDefaults] retain];
		
		ofApp = (testApp*)ofGetAppPtr();
	
		/**
		 (getPlugin<LiquidSpace*>(ofApp->pluginController))->fluidDrawer.getFluidSolver()->setFadeSpeed(0.00005 * [userDefaults doubleForKey:@"liquidSpace.fadeSpeed"]);
		 (getPlugin<LiquidSpace*>(ofApp->pluginController))->fluidDrawer.getFluidSolver()->setVisc(0.0000001 * [userDefaults doubleForKey:@"liquidSpace.viscosity"]);
		 (getPlugin<LiquidSpace*>(ofApp->pluginController))->fluidDrawer.getFluidSolver()->setColorDiffusion(0.0000001 * [userDefaults doubleForKey:@"liquidSpace.diffusion"]);
		 (getPlugin<LiquidSpace*>(ofApp->pluginController))->dropColor.set(1.0,1.0,1.0);
		 (getPlugin<LiquidSpace*>(ofApp->pluginController))->addingColor = [userDefaults boolForKey:@"liquidSpace.addingColor"];
		 (getPlugin<LiquidSpace*>(ofApp->pluginController))->colorMultiplier = 0.05 *  [userDefaults boolForKey:@"liquidSpace.colorMultiplier"];
		 (getPlugin<LiquidSpace*>(ofApp->pluginController))->addingForce = [userDefaults boolForKey:@"liquidSpace.addingForce"];
		 (getPlugin<LiquidSpace*>(ofApp->pluginController))->forceMultiplier = 0.05 * [userDefaults boolForKey:@"liquidSpace.forceMultiplier"];
		 **/
		
		gui = self;
		
		viewItems = [[NSMutableArray alloc] init];			
		
		
		uint64_t guidVal[3];
		
		for (int i=0; i<3; i++) {
			guidVal[i] = 0x0ll;
		}
		
		if ([userDefaults stringForKey:@"camera.1.guid"] != nil) {
			sscanf([[userDefaults stringForKey:@"camera.1.guid"] cStringUsingEncoding:NSUTF8StringEncoding], "%llx", &guidVal[0]);
		}
		
		if ([userDefaults stringForKey:@"camera.2.guid"] != nil) {
			sscanf([[userDefaults stringForKey:@"camera.2.guid"] cStringUsingEncoding:NSUTF8StringEncoding], "%llx", &guidVal[1]);
		}
		
		if ([userDefaults stringForKey:@"camera.3.guid"] != nil) {
			sscanf([[userDefaults stringForKey:@"camera.3.guid"] cStringUsingEncoding:NSUTF8StringEncoding], "%llx", &guidVal[2]);
		}
		
		

		

		
    }
	return self;
}


-(void) changeView:(int)n{
	ofPlugin * p = [viewItems objectAtIndex:n];
	int row = n;
	NSEnumerator *enumerator = [[contentArea subviews] objectEnumerator];
	id anObject;
	
	while (anObject = [enumerator nextObject]) {
		[anObject retain];
		[anObject removeFromSuperview];
	}
	
	id view = nil;
	
	if(view != nil){
		[contentArea addSubview:view];
		NSRect currFrame = [contentArea frame];
		CGFloat h = currFrame.size.height;
		
		NSRect currFrame2 = [view frame];
		CGFloat h2 = currFrame2.size.height;
		
		[view setFrameOrigin:NSMakePoint(0,h-h2)]; 
	}
}

-(IBAction) setListViewRow:(id)sender {
	[self changeView:[sender selectedRow]];
}

-(IBAction)		toggleFullscreen:(id)sender{
	ofToggleFullscreen();
}

- (id)tableView:(NSTableView *)aTableView
objectValueForTableColumn:(NSTableColumn *)aTableColumn
			row:(int)rowIndex
{
	NSMutableArray * array;
	int i;
	if(rowIndex < [viewItems count]){
		array = viewItems;
		i = rowIndex;
	}
	
	ofPlugin * p = [array objectAtIndex:i];
	if(![(NSString*)[aTableColumn identifier] compare:@"name"]){
		return [p name];		
	} else if(![(NSString*)[aTableColumn identifier] compare:@"enable"]){
		return [p enabled];
	} else {
		return @"hmm?";
	}
	
}


- (void)tableView:(NSTableView *)aTableView
   setObjectValue:anObject
   forTableColumn:(NSTableColumn *)aTableColumn
			  row:(int)rowIndex
{
	NSMutableArray * array;
	int i;
	if(rowIndex < [viewItems count]){
		array = viewItems;
		i = rowIndex;
	}
	
	ofPlugin * p = [array objectAtIndex:i];
	
	if(![(NSString*)[aTableColumn identifier] compare:@"name"]){
	} else if(![(NSString*)[aTableColumn identifier] compare:@"enable"]){
		[p setEnabled:anObject];	
		[userDefaults setValue:[p enabled] forKey:[NSString stringWithFormat:@"plugins.enable%d",i]];
		
		
	}  
	return;
}

-(void) changePluginEnabled:(int)n enable:(bool)enable{
	NSMutableArray * array;
	int i;
	if(n < [viewItems count]){
		array = viewItems;
		i = n;
	}
	i ++;
	if(i >= 3){
		i++;	
	}	
	if(i >= 6){
		i++;	
	}
	
	
	ofPlugin * p = [array objectAtIndex:i];
	[p setEnabled:[NSNumber numberWithBool:enable]];	
	[userDefaults setValue:[p enabled] forKey:[NSString stringWithFormat:@"plugins.enable%d",i]];
	[listView setNeedsDisplay:TRUE];

	//[self changeView:i];
	
}


- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [viewItems count];
}

@end




