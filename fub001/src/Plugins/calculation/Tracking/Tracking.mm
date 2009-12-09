//
//  Tracking.mm
//  openFrameworks
//
//  Created by Jonas Jongejan on 07/12/09.
//  Copyright 2009 HalfdanJ. All rights reserved.
//

#include "PluginIncludes.h"

@implementation Tracking

-(TrackerObject*) trackerNumber:(int)n{
	return trackerObj[n];	
}

-(void) initPlugin{
	for(int i=0;i<3;i++){
		trackerObj[i] = [[TrackerObject alloc] initWithId:i];	
		[trackerObj[i] setController:controller];
		[trackerObj[i] loadNibFile];
		
		NSView * dest;
		
		if(i == 0) dest = tracker0settings; 		
		if(i == 1) dest = tracker1settings; 
		if(i == 2) dest = tracker2settings; 
		
		[[trackerObj[i] settingsView] setFrame:[dest bounds]];
		[dest addSubview:[trackerObj[i] settingsView]];
		
	}
}

-(void) setup{
	for(int i=0;i<3;i++){
		[trackerObj[i] setup];
	}
}

-(void) update:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	for(int i=0;i<3;i++){
		[trackerObj[i] update:timeInterval displayTime:outputTime];
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
			[trackerObj[i] controlDraw:timeInterval displayTime:timeStamp];
		}glPopMatrix();
		glTranslated(0, h+10, 0);
	}
	glPopMatrix();
}
@end
