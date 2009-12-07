//
//  Tracking.mm
//  openFrameworks
//
//  Created by Jonas Jongejan on 07/12/09.
//  Copyright 2009 HalfdanJ. All rights reserved.
//

#include "PluginIncludes.h"

@implementation Tracking

-(void) initPlugin{
	for(int i=0;i<3;i++){
		tracker[i] = [[TrackerObject alloc] initWithId:i];	
		[tracker[i] setController:controller];
		[tracker[i] loadNibFile];
		
		NSView * dest;
		
		if(i == 0) dest = tracker0settings; 		
		if(i == 1) dest = tracker1settings; 
		if(i == 2) dest = tracker2settings; 
		
		[[tracker[i] settingsView] setFrame:[dest bounds]];
		[dest addSubview:[tracker[i] settingsView]];
		
	}
	
}

-(void) setup{
	for(int i=0;i<3;i++){
		[tracker[i] setup];
	}
}

-(void) update:(const CVTimeStamp *)outputTime{
	for(int i=0;i<3;i++){
		[tracker[i] update];
	}
}

-(void) controlDraw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)timeStamp{
	float h = ofGetHeight()/3.0;
	h = 200;
	float w = h * 640.0/480.0;
	//	float w = ofGetWidth()/4.0;
	
	glPushMatrix();
	for(int i=0;i<3;i++){
		glPushMatrix();{
			[tracker[i] controlDraw];
		}glPopMatrix();
		glTranslated(0, h, 0);
	}
	glPopMatrix();
}
@end
