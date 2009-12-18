//
//  Cameras.m
//  openFrameworks
//
//  Created by Jonas Jongejan on 02/12/09.
//  Copyright 2009 HalfdanJ. All rights reserved.
//

#import "Cameras.h"

#define NUM_CAMERAS 3

@implementation Cameras
@synthesize width, height;

-(void) initPlugin{
	
	width = 0;
	height = 0;
	
	for(int i=0;i<NUM_CAMERAS;i++){
		cam[i] = [[Camera alloc] init];	
		[cam[i] loadNibFile];
		
		NSView * dest;
		
		if(i == 0) dest = cam0settings; 		
		if(i == 1) dest = cam1settings; 
		if(i == 2) dest = cam2settings; 
		
		[[cam[i] settingsView] setFrame:[dest bounds]];
		[dest addSubview:[cam[i] settingsView]];
		
	}
	
}


-(void) setup{
	
	NSUserDefaults *userDefaults = [[NSUserDefaults standardUserDefaults] retain];
	
	uint64_t guidVal[NUM_CAMERAS];
	
	for (int i=0; i<NUM_CAMERAS; i++) {
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
	

	// first setup the cams with a guid
	for(int i=0;i<NUM_CAMERAS;i++){
		if (guidVal[i] != 0x0ll) {
			[cam[i] setup:i withGUID:guidVal[i]];
		}
	}

	// then setup the cams without a guid
	for(int i=0;i<NUM_CAMERAS;i++){
		if (guidVal[i] == 0x0ll) {
			[cam[i] setup:i withGUID:guidVal[i]];
		}
	}
	
	width = [cam[1] width];
	height = [cam[1] height];
	
	[userDefaults release];

}

-(void) update:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	for(int i=0;i<3;i++){
		[cam[i] update:timeInterval displayTime:outputTime];
		if(i==0){
			[[controller cameraFps1] setFloatValue:[cam[i] framerate]];
			[[controller cameraStatus1] setState:((ofGetElapsedTimef() - [cam[i] mytimeNow] < 0.05) && ([cam[i] framerate] > 5.0) ? NSOnState : NSOffState)];
		}
		if(i==1){
			[[controller cameraFps2] setFloatValue:[cam[i] framerate]];
			[[controller cameraStatus2] setState:((ofGetElapsedTimef() - [cam[i] mytimeNow] < 0.05) && ([cam[i] framerate] > 5.0) ? NSOnState : NSOffState)];
		}
		if(i==2){
			[[controller cameraFps3] setFloatValue:[cam[i] framerate]];
			[[controller cameraStatus3] setState:((ofGetElapsedTimef() - [cam[i] mytimeNow] < 0.05) && ([cam[i] framerate] > 5.0) ? NSOnState : NSOffState)];
		}
	}
	if([Camera allCamerasAreRespawning]){
		[[controller statusTextField] setStringValue:@"Initialising cameras"];
		[[controller statusBusy] startAnimation:nil];
	} else if (![Camera aCameraIsRespawning]){
		[[controller statusTextField] setStringValue:@""];
		[[controller statusBusy] stopAnimation:nil];
	} 
}

-(void) controlDraw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)timeStamp{
	ofSetColor(255, 255, 255, 255);
	
	float w = ofGetWidth() / 3.0;
	float h = w * (480.0/640.0);
	float windowHeight = ofGetHeight();
	h = fminf(h,windowHeight);
	
	for(int i=0;i<NUM_CAMERAS;i++){
		[cam[i] getTexture]->draw(i*w, 0,w,h);
	}
}

- (Camera*)getCameraWithId:(int)cameraId{
	if (0 <= cameraId && cameraId < NUM_CAMERAS) {
		return cam[cameraId];
	}
}

- (ofTexture*)getTexture:(int)cameraId{
	return [[self getCameraWithId:cameraId] getTexture];
}
- (unsigned char*)getPixels:(int)cameraId{
	return [[self getCameraWithId:cameraId] getPixels];	
}
- (BOOL) isFrameNew:(int)cameraId{
	return [[self getCameraWithId:cameraId] isFrameNew];		
}

-(IBAction) recordAll:(id)sender{
	for(int i=0;i<NUM_CAMERAS;i++){
		[[cam[i] recordButton] setState:[sender state]];
	}
}

@end
