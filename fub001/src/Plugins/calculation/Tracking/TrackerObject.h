//
//  TrackerObject.h
//  openFrameworks
//
//  Created by Jonas Jongejan on 07/12/09.
//  Copyright 2009 HalfdanJ. All rights reserved.
//

#pragma once

#import "GLee.h"

#import <Cocoa/Cocoa.h>

#include "Plugin.h"
#include "ofMain.h"
#include "ofxOpenCv.h"
#include "ofxVectorMath.h"

@interface PersistentBlob : NSObject
{
	@public
	long unsigned int pid;
	ofxPoint2f * centroid;
	ofxPoint2f * lastcentroid;
	ofxVec2f   * centroidV;
	

	int timeoutCounter;
	NSMutableArray * blobs;
	
}

-(ofxPoint2f) getLowestPoint;

@end

@interface Blob : NSObject
{
	
	ofxCvBlob * blob;
}

-(void) normalize:(int)w height:(int)h;
-(void) lensCorrect;

-(id)initWithBlob:(ofxCvBlob*)_blob;
-(vector <ofPoint>)pts;
-(int)nPts;
-(ofPoint)centroid;
-(float) area;
-(float)length;
-(ofRectangle) boundingRect;
-(BOOL) hole;


@end

 

@interface TrackerObject : NSObject {
	IBOutlet NSView * settingsView;
	int trackerNumber;
	PluginManagerController * controller;
	
	int cw, ch;
	
	ofxCvGrayscaleImage *	grayImage;
	ofxCvGrayscaleImage *	grayLastImage;
	ofxCvGrayscaleImage *	grayImageBlured;	
	ofxCvGrayscaleImage *	grayBgMask;	
	ofxCvGrayscaleImage *	grayBg;
	ofxCvGrayscaleImage *	grayDiff;

	//Images used by thread
	ofxCvGrayscaleImage * threadGrayDiff;
	ofxCvGrayscaleImage * threadGrayImage;
	ofxCvGrayscaleImage * threadGrayLastImage;
	BOOL threadUpdateContour;

	
	ofxCvContourFinder 	* contourFinder;
	
	NSMutableArray * persistentBlobs;
	NSMutableArray * blobs;

	IBOutlet NSSlider * blurSlider;
	IBOutlet NSSlider * thresholdSldier;
	IBOutlet NSSlider * postBlurSlider;
	IBOutlet NSSlider * postThresholdSlider;
	IBOutlet NSButton * activeButton;
	IBOutlet NSButton * learnBackgroundButton;
	
	NSThread * thread;
	pthread_mutex_t mutex;
	pthread_mutex_t drawingMutex;
	
	NSUserDefaults * userDefaults;
	BOOL valuesLoaded;


}
@property (assign, readonly) NSView * settingsView;
@property (assign, readwrite) PluginManagerController * controller;
@property (assign, readonly) NSMutableArray * blobs;
@property (assign, readonly) NSMutableArray * persistentBlobs;

-(IBAction) setBlurSliderValue:(id)sender;
-(IBAction) setThresholdSliderValue:(id)sender;
-(IBAction) setPostBlurSliderValue:(id)sender;
-(IBAction) setPostThresholdSliderValue:(id)sender;
-(IBAction) setActiveButtonValue:(id)sender;

-(BOOL) loadNibFile;

-(void) setup;
-(void) controlDraw;
-(void) update;
-(id) initWithId:(int)num;
-(void) performBlobTracking:(id)param;

-(void) saveBackground;
-(void) loadBackground;

-(int) numBlobs;
-(Blob*) getBlob:(int)n;

@end
