//
//  _ExampleOutput.mm
//  openFrameworks
//
//  Created by Jonas Jongejan on 15/11/09.

#import "PluginIncludes.h"

@implementation _ExampleOutput
@synthesize s;

-(void) awakeFromNib{
	[super awakeFromNib];
}

-(void) initPlugin{
	NSLog(@"hmmmmmm");
	s = [NSString stringWithString:@"hmmm"];
	NSLog(s);
}

-(IBAction) pressButton:(id)sender{
	NSLog(@"Button pressed");
	[text setStringValue:s];
}

-(void) setup{
//	CGLSetCurrentContext(openglContext);

	

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
