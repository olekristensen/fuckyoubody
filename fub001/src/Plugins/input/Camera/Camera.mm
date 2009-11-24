/*
 *  Camera.mm
 *  openFrameworks
 *
 *  Created by Fuck You Buddy on 23/11/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#import "PluginIncludes.h"

@implementation Camera

-(void) awakeFromNib{
	[super awakeFromNib];
}

-(void) initPlugin{
	
}


-(IBAction) pressButton:(id)sender{
	NSLog(@"Button pressed");
}

-(void) setup{
	
	img = new ofImage;
	img->loadImage("/Users/jonas/Documents/udvilking/of_preRelease_v0.06_xcode_FAT/apps/fub_/fub001_/bin/data/icon.png");
}

-(void) draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)timeStamp{
	GLfloat rotate = timeInterval * 60.0; // 60 degrees per second!
	glRotatef(rotate, 0.0, 0.0, 1.0);
	glBegin(GL_QUADS);
	glColor3f(1.0, 1.0, 1.0);
	glVertex2f(0, 0);
	glVertex2f(-1, 0);
	glVertex2f(-1, - 1);
	glVertex2f(0, -1);
	glEnd();
	
	ofSetColor(255, 0, 0);
	ofRect(0, 0, 1, 1);
	
	
	ofSetColor(255,255,255);
	//	((ProjectionSurfaces*)[controller getPlugin:[ProjectionSurfaces class]])->img->draw(0, 0,0.5,0.5);
	//	GetPlugin(ProjectionSurfaces)->img->draw(0, 0,0.5,0.5);
}
@end
