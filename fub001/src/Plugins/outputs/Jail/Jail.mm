
#import "Jail.h"
#include "ProjectionSurfaces.h"

@implementation Jail

-(void) draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	ofFill();
	ofSetColor(255, 
			   255, 
			   255, 
			   255);
	
	if([rotation floatValue] > 0){
		
		[GetPlugin(ProjectionSurfaces) apply:"Back" surface:"Floor"];{
			glPushMatrix();
			glRotated(-45.0 * [samlaWall floatValue]/100.0, 0, 0, 1);
			ofRect(0, 0, 0.01, [leftWall floatValue]/100.0);
			glPopMatrix();
			
			glPushMatrix();
			glRotated(45.0 * [samlaWall floatValue]/100.0, 0, 0, 1);
			ofRect(0, 0.0, [backWall floatValue]/100.0, 0.01);		
			glPopMatrix();		
			
			glRotated([rotation floatValue], 0, 0, 1);
			for(int i=0;i<14;i++){
				if(i*20 + [rotation floatValue] < 90){
					ofRect(0, 0, 0.01, 2);
				}
				glRotated(20, 0, 0, 1);
			}
			
		}glPopMatrix();		
	}
	
	
	ofEnableAlphaBlending();
	
	[GetPlugin(ProjectionSurfaces) apply:"Back" surface:"Backwall"];{
		
		ofSetColor(255, 
				   255, 
				   255, 
				   255*[screenBarsAlpha floatValue]*(1.0-[screenBars1Balance floatValue])*[alpha floatValue]);
		
		for(float i=0;i<1.0;i+=[screenBarsWidth floatValue]+0.001){
			ofRect(([screenBarsOffset floatValue]*0.5*[screenBarsWidth floatValue])+i*[GetPlugin(ProjectionSurfaces) getAspectForProjection:"Back" surface:"Backwall"], 0, [screenBarsWidth floatValue]*[GetPlugin(ProjectionSurfaces) getAspectForProjection:"Back" surface:"Backwall"]*0.5, 1);
		}
		
		ofSetColor(255, 
				   255, 
				   255, 
				   255*[screenBarsAlpha floatValue]*(1.0-[screenBars2Balance floatValue])*[alpha floatValue]);
		
		for(float i=0;i<1.0;i+=[screenBarsWidth floatValue]+0.001){
			ofRect(([screenBarsOffset floatValue]*-0.5*[screenBarsWidth floatValue])+i*[GetPlugin(ProjectionSurfaces) getAspectForProjection:"Back" surface:"Backwall"], 0, [screenBarsWidth floatValue]*[GetPlugin(ProjectionSurfaces) getAspectForProjection:"Back" surface:"Backwall"]*0.5, 1);
		}
		
	}glPopMatrix();
	
	[GetPlugin(ProjectionSurfaces) apply:"Front" surface:"Backwall"];{
		
		ofSetColor(255, 
				   255, 
				   255, 
				   255*[screenBarsAlpha floatValue]*[screenBars1Balance floatValue]*[alpha floatValue]);
		
		for(float i=0;i<1.0;i+=[screenBarsWidth floatValue]+0.001){
			ofRect(([screenBarsOffset floatValue]*0.5*[screenBarsWidth floatValue])+i*[GetPlugin(ProjectionSurfaces) getAspectForProjection:"Back" surface:"Backwall"], 0, [screenBarsWidth floatValue]*[GetPlugin(ProjectionSurfaces) getAspectForProjection:"Front" surface:"Backwall"]*0.5, 1);
		}
		
		ofSetColor(255, 
				   255, 
				   255, 
				   255*[screenBarsAlpha floatValue]*[screenBars2Balance floatValue]*[alpha floatValue]);
		
		for(float i=0;i<1.0;i+=[screenBarsWidth floatValue]+0.001){
			ofRect(([screenBarsOffset floatValue]*-0.5*[screenBarsWidth floatValue])+i*[GetPlugin(ProjectionSurfaces) getAspectForProjection:"Back" surface:"Backwall"], 0, [screenBarsWidth floatValue]*[GetPlugin(ProjectionSurfaces) getAspectForProjection:"Front" surface:"Backwall"]*0.5, 1);
		}
		
	}glPopMatrix();
	
}

@end
