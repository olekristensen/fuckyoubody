#pragma once

#import "GLee.h"


#import <Cocoa/Cocoa.h>
#include "Plugin.h"
#include "ofMain.h"
#include "ofxVectorMath.h"
#include "ofxOpenCv.h"
#include "shaderBlur.h"

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
	
	IBOutlet PluginUIButton * colorBalanceSlider;
	IBOutlet PluginUIColorWell * blobcolor;
	IBOutlet PluginUIButton * blobBlurSlider;

	IBOutlet PluginUIButton * blobRedSlider;
	IBOutlet PluginUIButton * blobGreenSlider;
	IBOutlet PluginUIButton * blobBlueSlider;
	IBOutlet PluginUIButton * blobAlphaSlider;

	IBOutlet PluginUIButton * scoreSlider;
	IBOutlet NSSegmentedControl * trackingPosition;
	
	ofxVec2f * addRule;
	BOOL addNewBlob;
	
	NSUserDefaults *userDefaults;
	vector<int> pblobs;
	
	ofxCvColorImageAlpha * light; //The one we draw
	ofxCvColorImageAlpha * lightTemp; //For effects
	ofxCvColorImageAlpha * lightTemp2; //For effects

	CvPoint * pointArray ;
	shaderBlur * blur;

	
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

-(IBAction) setColorWell:(id)sender;

-(NSColor*) projectorColor;

-(id)initWithN:(int)n;
- (BOOL) loadNibFile;	
@end
