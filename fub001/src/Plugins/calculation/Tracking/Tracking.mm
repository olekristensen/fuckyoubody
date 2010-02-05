//
//  Tracking.mm
//  openFrameworks
//
//  Created by Jonas Jongejan on 07/12/09.
//  Copyright 2009 HalfdanJ. All rights reserved.
//

#include "ProjectionSurfaces.h"
#include "Tracking.h"

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
	
	if([wallTracking state] == NSOnState){
		if([[self trackerNumber:0] numBlobs] == 4){
			
			Blob * b;
			ofxPoint2f center;
			int n= 0;
			for(b in [[self trackerNumber:0] blobs]){
				center += [b centroid];
				n++;
			}
			center /= n;
			
			ofPoint topLeft = center, topRight= center, bottomLeft= center, bottomRight= center;
			for(b in [[self trackerNumber:0] blobs]){
				if(([b centroid].x < topLeft.x && [b centroid].y < topLeft.y)){
					topLeft = [b centroid];
				}
				if(([b centroid].x > topRight.x && [b centroid].y < topRight.y)){
					topRight = [b centroid];
				}
				if(([b centroid].x < bottomLeft.x && [b centroid].y > bottomLeft.y)){
					bottomLeft = [b centroid];
				}
				if(([b centroid].x > bottomRight.x && [b centroid].y > bottomRight.y)){
					bottomRight = [b centroid];
				}
			}
			
			ProjectionSurfacesObject * surf = [GetPlugin(ProjectionSurfaces) getProjectionSurfaceByName:"Front" surface:"Backwall"];
			surf->corners[0] = new ofxPoint2f( topLeft );
			surf->corners[1] = new ofxPoint2f( topRight );
			surf->corners[2] = new ofxPoint2f( bottomRight );
			surf->corners[3] = new ofxPoint2f( bottomLeft );
			[surf recalculate];
		}
	}
	
	
}

-(void) draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	for(int i=0;i<3;i++){
		[trackerObj[i] draw];
	}
}

-(void) controlDraw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)timeStamp{
	float h = ofGetHeight()/3.0;
	h = 226;
	float w = h * 640.0/480.0;
	//	float w = ofGetWidth()/4.0;
	
	glPushMatrix();
	glTranslated(0, 26, 0);
	for(int i=0;i<3;i++){
		glPushMatrix();{
			[trackerObj[i] controlDraw:timeInterval displayTime:timeStamp];
		}glPopMatrix();
		glTranslated(0, h, 0);
	}
	glPopMatrix();
}

-(void) controlMousePressed:(float)x y:(float)y button:(int)button {
	int h = 226;
	
	if(y<26){
		
	} else if(y < 	26+h-26){
		[trackerObj[0] controlMousePressed:x y:y-26 button:button];
	} else if(y < 26+h){
		
	} else if(y < 26+h+h-26){
		[trackerObj[1] controlMousePressed:x y:y-(26+h) button:button];	
	} else if(y < 26+h+h){
		
	} else if(y < 26+h+h+h-26){
		[trackerObj[2] controlMousePressed:x y:y-(26+h+h) button:button];	
	}
}

-(void) mouseUpPoint:(NSPoint)theEvent{
	for(int i=0;i<3;i++){
		[trackerObj[i] setMouseEvent:NO];
	}			
}

-(void) mouseDownPoint:(NSPoint)theEvent{
	for(int i=0;i<3;i++){
		[trackerObj[i] setMouseEvent:YES];
		[trackerObj[i] setMousePosition:new ofPoint(theEvent.x, theEvent.y)];
	}			
	
}

-(void) mouseDraggedPoint:(NSPoint)theEvent{
	for(int i=0;i<3;i++){
		[trackerObj[i] setMouseEvent:YES];
		[trackerObj[i] setMousePosition:new ofPoint(theEvent.x, theEvent.y)];
	}			
	
}

@end