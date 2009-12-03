/*
 *  LensDistortion.cpp
 *  openFrameworks
 *
 *  Created by Fuck You Buddy on 03/12/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include "LensDistortion.h"

@implementation LensDistortion

-(void) initPlugin{
	for(int i=0;i<3;i++){
		cameraCalibrator[i] = new ofCvCameraCalibration();
		
		
	}
	
}


-(void) setup{
	for(int i=0;i<3;i++){

	}
	
}

-(void) update:(const CVTimeStamp *)outputTime{

}

-(void) controlDraw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)timeStamp{

}

@end
