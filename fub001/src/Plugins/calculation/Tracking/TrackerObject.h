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
#import "CameraCalibration.h"
#include "ProjectionSurfaces.h"
#include "ofxCvOpticalFlowLK.h"

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
@property (assign) NSMutableArray * blobs;

-(ofxPoint2f) getLowestPoint;
-(void) dealloc;

@end

@interface Blob : NSObject
{
	int cameraId;
	ofxCvBlob * blob;
	ofxCvBlob * originalblob;
	ofxCvBlob * floorblob;
	ofxPoint2f * low;
	
@public
	CvSeq * cvSeq; 
}
@property (readwrite) int cameraId;
@property (readonly) ofxCvBlob * originalblob;
@property (readonly) ofxCvBlob * floorblob;

-(void) normalize:(int)w height:(int)h;
-(void) lensCorrect;
-(void) warp;
-(void) dealloc;

-(id)initWithBlob:(ofxCvBlob*)_blob;
-(id)initWithMouse:(ofPoint*)point;

-(vector <ofPoint>)pts;
-(int)nPts;
-(ofPoint)centroid;
-(float) area;
-(float)length;
-(ofRectangle) boundingRect;
-(BOOL) hole;

-(ofxPoint2f) getLowestPoint;



@end



@interface TrackerObject : NSObject {
	long unsigned int pidCounter;
	
	IBOutlet NSView * settingsView;
	int trackerNumber;
	PluginManagerController * controller;
	CameraCalibrationObject* calibrator;
	ProjectorObject * projector;
	
	int cw, ch;
	
	ofxCvGrayscaleImage *	grayImage;
	ofxCvGrayscaleImage *	flowImage;
	ofxCvGrayscaleImage *	flowLastImage;
	ofxCvGrayscaleImage *	grayImageBlured;	
	ofxCvGrayscaleImage *	grayBgMask;	
	ofxCvGrayscaleImage *	grayBg;
	ofxCvGrayscaleImage *	grayDiff;
	
	//Images used by thread
	ofxCvGrayscaleImage * threadGrayDiff;
	ofxCvGrayscaleImage * threadGrayImage;
	
	ofxCvGrayscaleImage * threadFlowLastImage;
	ofxCvGrayscaleImage * threadFlowImage;
	
	BOOL threadUpdateContour;
	BOOL threadUpdateOpticalFlow;
	
	ofxCvOpticalFlowLK	* opticalFlow;
	ofxCvContourFinder 	* contourFinder;
	
	BOOL loadBackgroundNow;
	
	NSMutableArray * persistentBlobs;
	NSMutableArray * blobs;
	
	IBOutlet NSSlider * blurSlider;
	IBOutlet NSSlider * thresholdSldier;
	IBOutlet NSSlider * postBlurSlider;
	IBOutlet NSSlider * postThresholdSlider;
	IBOutlet NSButton * activeButton;
	IBOutlet NSButton * opticalFlowActiveButton;
	IBOutlet NSButton * learnBackgroundButton;
	IBOutlet NSButton * learnBackgroundMaskButton;
	
	IBOutlet NSButton * drawDebugButton;
	IBOutlet NSSlider * persistentSlider;
	IBOutlet NSPopUpButton * presetMenu;
	IBOutlet NSButton * setMaskButton;
	IBOutlet NSTextField * maskText;
	
	IBOutlet NSTextField * blobCounter;
	IBOutlet NSTextField * blobCounter2;
	IBOutlet NSTextField * pblobCounter;
	IBOutlet NSTextField * currrentPblobCounter;
	IBOutlet NSTextField * newestId;
	
	IBOutlet NSSegmentedControl * presetPicker;
	IBOutlet NSSegmentedControl * presetMaskPicker;
	
	NSThread * thread;
	pthread_mutex_t mutex;
	pthread_mutex_t drawingMutex;
	
	NSUserDefaults * userDefaults;
	BOOL valuesLoaded;
	int preset;
	int setMaskCorner;
	
	//Mouse
	BOOL mouseEvent;
	ofPoint * mousePosition;
	
}
@property (assign, readonly) NSView * settingsView;
@property (assign, readwrite) PluginManagerController * controller;
@property (assign, readonly) NSMutableArray * blobs;
@property (assign, readonly) NSMutableArray * persistentBlobs;
@property (assign, readonly) ofxCvOpticalFlowLK	* opticalFlow;
@property (assign, readwrite) NSButton * learnBackgroundButton;
@property (assign, readonly) CameraCalibrationObject* calibrator;
@property (assign, readwrite) ProjectorObject * projector;
@property (readwrite) BOOL mouseEvent;
@property (readwrite) ofPoint * mousePosition;

-(IBAction) setBlurSliderValue:(id)sender;
-(IBAction) setThresholdSliderValue:(id)sender;
-(IBAction) setPostBlurSliderValue:(id)sender;
-(IBAction) setPostThresholdSliderValue:(id)sender;
-(IBAction) setActiveButtonValue:(id)sender;
-(IBAction) loadPresetControl:(id)sender;
-(IBAction) setPersistentSliderValue:(id)sender;
-(IBAction) setOpticalFlowActiveButtonValue:(id)sender;

-(void) loadPreset:(int)n;

-(BOOL) loadNibFile;

-(void) setup;
-(void) controlDraw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime;
-(void) update:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime;
-(void) draw;
-(id) initWithId:(int)num;
-(void) performBlobTracking:(id)param;

-(ofPoint) flowAtX:(float) pointX Y: (float) pointY;
-(ofPoint) flowInRegionX:(float) regionX Y: (float) regionY width: (float) regionWidth height: (float) regionHeight;

-(void) saveBackground;
-(void) loadBackground;

-(int) numBlobs;
-(Blob*) getBlob:(int)n;

-(int) numPersistentBlobs;
-(PersistentBlob*) getPersistentBlob:(int)n;

-(void) controlMousePressed:(float)x y:(float)y button:(int)button;

-(void) getMaskPoints:(ofPoint*)maskPoints;
@end
