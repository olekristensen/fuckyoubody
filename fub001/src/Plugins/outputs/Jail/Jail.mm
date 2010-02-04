
#import "Jail.h"
#include "ProjectionSurfaces.h"

@implementation Jail

-(void) draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	ofFill();
	[GetPlugin(ProjectionSurfaces) apply:"Back" surface:"Floor"];{
		ofRect(0, 0, 0.01, [leftWall floatValue]/100.0);
		ofRect(0, 0.05, [backWall floatValue]/100.0, 0.01);		
		
		
		glRotated([rotation floatValue], 0, 0, 1);
		for(int i=0;i<3;i++){
			ofRect(0, 0, 0.01, 2);
			glRotated(20, 0, 0, 1);
		}
		
	}glPopMatrix();
}

@end
