//
//  Combat.mm
//  openFrameworks
//
//  Created by Fuck You Buddy on 04/02/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Combat.h"
#include "ProjectionSurfaces.h"
#include "Players.h"

@implementation Combat


-(void) draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	ofFill();
	
	[GetPlugin(ProjectionSurfaces) apply:"Back" surface:"Floor"];
	glPushMatrix();
	glTranslated(0.5, 0.5, 0);
	glRotated([rotation floatValue], 0, 0, 1);
	for(int i=0;i<4;i++){
		glRotated(90, 0, 0, 1);
		NSColor * c = [GetPlugin(Players) playerColor:i+1];
		ofSetColor([c redComponent]*255, [c greenComponent]*255, [c blueComponent]*255);
		
		ofTriangle(0, 0, 0.5, -0.5, 0.5, 0.5);
	}
	glPopMatrix();
	glPopMatrix();
}
@end
