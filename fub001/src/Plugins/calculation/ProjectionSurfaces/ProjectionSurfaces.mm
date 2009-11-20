//
//  _ExampleOutput.mm
//  openFrameworks
//
//  Created by Jonas Jongejan on 15/11/09.

#import "ProjectionSurfaces.h"

@implementation ProjectionSurfaces
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
	NSLog(@"Set blaaa");
	haha = new string("blaa");
	
}

-(void) controlDraw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)timeStamp{
	ofBackground(0, 0, 0);
}

-(void) update:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)timeStamp{
	//for(int i=0;i<10;i++){
//		for(int u=0;u<100000;u++){
//			sqrt(cos(sin(i*i)));
//		}
//	}
}

-(void) draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)timeStamp{
	GLfloat rotate = timeInterval * 60.0+90; // 60 degrees per second!
	
	glRotatef(rotate, 0.0, 0.0, 1.0);
	
	
	ofSetColor(255, 0, 0);
	ofRect(0, 0, 1, 1);
	
	ofSetColor(255,255,255);
	img->draw(0, 0,0.5,0.5);
}
@end
