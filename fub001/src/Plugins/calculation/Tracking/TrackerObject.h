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
	vector<ofxCvBlob> * blobs;
	
}

-(ofxPoint2f) getLowestPoint;

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
	
	IBOutlet NSSlider * blurSlider;
	IBOutlet NSSlider * thresholdSldier;
	IBOutlet NSSlider * postBlurSlider;
	IBOutlet NSSlider * postThresholdSlider;
	IBOutlet NSButton * activeButton;
	IBOutlet NSButton * learnBackgroundButton;
	
	NSThread * thread;
	pthread_mutex_t mutex;
	pthread_mutex_t drawingMutex;


}
@property (assign, readonly) NSView * settingsView;
@property (assign, readwrite) 	PluginManagerController * controller;
-(BOOL) loadNibFile;

-(void) setup;
-(void) controlDraw;
-(void) update;
-(id) initWithId:(int)num;
-(void) performBlobTracking:(id)param;

-(int) numBlobs;

@end
