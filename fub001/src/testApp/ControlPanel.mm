//
//  ControlPanel.mm
//  openFrameworks
//
//  Created by Fuck You Buddy on 16/02/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ControlPanel.h"


@implementation ControlPanel
@synthesize fpsTextField, cameraFps1,   cameraStatus1,   midiStatus, statusTextField, statusBusy,  hardwareStatus, xbeeStatus, xbeeStrength, testDmxButton, testFloorButton, testScreenButton, laserButton, ledButton;
-(void) awakeFromNib{
	[statusBusy setUsesThreadedAnimation:YES];
	
}
@end
