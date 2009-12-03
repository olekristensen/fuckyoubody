//
//  Cameras.m
//  openFrameworks
//
//  Created by Jonas Jongejan on 02/12/09.
//  Copyright 2009 HalfdanJ. All rights reserved.
//

#import "Cameras.h"


@implementation Cameras

-(void) initPlugin{
	for(int i=0;i<3;i++){
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
	for(int i=0;i<3;i++){
		[cam[i] setup:i];
	}
	
}

-(void) update:(const CVTimeStamp *)outputTime{
	for(int i=0;i<3;i++){
		[cam[i] update];
		if(i==0){
			[[controller cameraFps1] setFloatValue:[cam[i] framerate]];
			[[controller cameraStatus1] setState:((ofGetElapsedTimef() - [cam[i] mytimeThen] > 0.0) && ([cam[i] framerate] > 5.0) ? NSOnState : NSOffState)];
		}
		if(i==1){
			[[controller cameraFps2] setFloatValue:[cam[i] framerate]];
			[[controller cameraStatus2] setState:((ofGetElapsedTimef() - [cam[i] mytimeThen] > 0.0) && ([cam[i] framerate] > 5.0) ? NSOnState : NSOffState)];
		}
		if(i==2){
			[[controller cameraFps3] setFloatValue:[cam[i] framerate]];
			[[controller cameraStatus3] setState:((ofGetElapsedTimef() - [cam[i] mytimeThen] > 0.0) && ([cam[i] framerate] > 5.0) ? NSOnState : NSOffState)];
		}	
	}
}

-(void) controlDraw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)timeStamp{
	ofSetColor(255, 255, 255, 255);
	
	float w = ofGetWidth() / 3.0;
	float h = w * (480.0/640.0);
	for(int i=0;i<3;i++){
		[cam[i] getTexture]->draw(i*w, 0,w,h);
	}
}
@end
