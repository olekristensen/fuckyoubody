
#import "Jail.h"
#include "ProjectionSurfaces.h"

@implementation Jail

-(void) draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	ofFill();
	ofSetColor(255, 
			   255, 
			   255, 
			   255);
	
	
	
	[GetPlugin(ProjectionSurfaces) apply:"Back" surface:"Floor"];{
		glPushMatrix();{
			glRotated(-45.0 * [samlaWall floatValue]/100.0, 0, 0, 1);
			ofRect(0, 0, 0.01, 2*[leftWall floatValue]/100.0);
		}glPopMatrix();
		
		glPushMatrix();{
			glRotated(45.0 * [samlaWall floatValue]/100.0, 0, 0, 1);
			ofRect(0, 0.0, 2*[backWall floatValue]/100.0, 0.01);		
		}glPopMatrix();		
		
		
		if([rotation floatValue] > 0){
			glPushMatrix();{
				glRotated(-45.0, 0, 0, 1);
				glRotated((-[rotation floatValue]+45.0)*(1-[samlaWall floatValue]/100.0), 0, 0, 1);
				
				float rotated = 0;
				for(int i=0;i<18;i++){
					float angle = 45 - 35.0*([rotation floatValue]/360.0);

					glRotated(angle*(1-[samlaWall floatValue]/100.0), 0, 0, 1);
					rotated += angle;
					
					if(- [rotation floatValue] + rotated < 0 && - [rotation floatValue] + rotated	 > - 90){
						ofRect(0, 0, 0.01, 2);
					}
				}
			}glPopMatrix();
		}
		
		
		ofDisableAlphaBlending();
		ofSetColor(0, 0, 0,255);
		
		if([zipSlider floatValue] > 0){
			glPushMatrix();{
				
				glRotated(-45, 0, 0, 1);
				ofRect(-1, 0, 2, 2*[zipSlider floatValue]/100.0);
				ofRect(-1, sqrt(2), 2, -2*[zipSlider floatValue]/100.0);
			}glPopMatrix();
		}
		
	}glPopMatrix();		
	
	
	
	
	
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
