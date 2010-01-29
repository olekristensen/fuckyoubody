#pragma once

#import "GLee.h"


#import <Cocoa/Cocoa.h>
#include "Plugin.h"
#include "ofMain.h"
#include "ofxVectorMath.h"


@interface Player : NSObject {
	int playerNumber;
	
	IBOutlet NSView * settingsView;
	
	IBOutlet NSTextField * title;
	IBOutlet NSTextField * name;
	IBOutlet PluginUIColorWell * color;
	
	IBOutlet NSTextField * numberPBlobs;
	IBOutlet PluginUIButton * addTopButton;
	IBOutlet PluginUIButton * addRightButton;
	IBOutlet PluginUIButton * addBottomButton;
	IBOutlet PluginUIButton * addLeftButton;
	IBOutlet PluginUIButton * resetBlobButton;
	
	
	ofxVec2f * addRule;
	BOOL addNewBlob;
	
	NSUserDefaults *userDefaults;
	
	vector<int> pblobs;
	
}
@property (assign, readwrite) NSView * settingsView;

-(void) setup;
-(void) draw;
-(void) update;

-(IBAction) addTopButton:(id)sender;
-(IBAction) addRightButton:(id)sender;
-(IBAction) addBottomButton:(id)sender;
-(IBAction) addLeftButton:(id)sender;
-(IBAction) resetBlobButton:(id)sender;

-(id)initWithN:(int)n;
- (BOOL) loadNibFile;	
@end
