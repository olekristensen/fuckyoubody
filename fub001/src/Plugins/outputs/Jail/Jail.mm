
#import "Jail.h"
#include "ProjectionSurfaces.h"
#include "Midi.h"

@implementation Jail

-(void) draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	
	ofFill();
	
	ofSetColor(255, 
			   255, 
			   255, 
			   255);
	float rot = 157*[GetPlugin(Midi) getPitchBend:0]/16256.0 ;
	//rot = [rotation floatValue];
	float samle = 100.0*[GetPlugin(Midi) getPitchBend:1]/16256.0;
	//samle = [samlaWall floatValue];
	float zip = 100.0*[GetPlugin(Midi) getPitchBend:2]/16256.0;

	float s = (0.8*[widthSlider floatValue]/100.0)*((100-samle)/100.0);

	[GetPlugin(ProjectionSurfaces) apply:"Back" surface:"Floor"];{
		glPushMatrix();{
			glRotated(-45.0 * samle/100.0, 0, 0, 1);
			/*
			glBegin(GL_POLYGON);
			glVertex2f(0, 0);
			glVertex2f(0.01, 0);
			glVertex2f(0.01+s, 2*[leftWall floatValue]/100.0);
			glVertex2f(0, 2*[leftWall floatValue]/100.0);
			glEnd();
			*/
			ofRect(0, 0, 0.01, 2*[leftWall floatValue]/100.0);
		}glPopMatrix();
		
		glPushMatrix();{
			glRotated(45.0 * samle/100.0, 0, 0, 1);
			/*glBegin(GL_POLYGON);
			glVertex2f(0, 0);
			glVertex2f(0,0.01);
			glVertex2f(2*[backWall floatValue]/100.0, 0.01+s);
			glVertex2f(2*[backWall floatValue]/100.0, 0);
			glEnd();*/
			
			ofRect(0, 0.0, 2*[backWall floatValue]/100.0, 0.01);		
		}glPopMatrix();		
		
		
		//	if(rot > 0)
		//		cout<<rot<<endl;
		
		if(rot > 0){
			glPushMatrix();{
				glRotated(-45.0, 0, 0, 1);
				glRotated((-rot+45.0)*(1-samle/100.0), 0, 0, 1);
				
				float rotated = 0;
				for(int i=0;i<18;i++){
					//					float angle = 23;
					float angle = 45 - 35.0*(rot/360.0);
					
					glRotated(angle*(1-samle/100.0), 0, 0, 1);
					rotated += angle;
					
					if(- rot + rotated < 0 && - rot + rotated	 > - 90){
						glBegin(GL_POLYGON);
						glVertex2f(0, 0);
						glVertex2f(0.01, 0);
						glVertex2f(0.01+s, 2);
						glVertex2f(0-s, 2);
						glEnd();
					}
				}
			}glPopMatrix();
		}
		
		ofSetColor(0, 0, 0, 255);
		
		// left mask
		ofRect(0, -1, -2, 2);
		
		// top mask
		ofRect(-1, 0, 3, -2);
		
	
		// right mask
		ofRect(1+1*(1-[mask floatValue]), -1, 3, 3);
		
		// bottom mask
		ofRect(-1, 1+1*(1-[mask floatValue]), 3, 3);
				
		
		
		ofDisableAlphaBlending();
		ofSetColor(0, 0, 0,255);
		
		if(zip > 0){
			glPushMatrix();{
				
				glTranslated(0.5, 0.5, 0);
				glRotated(-45, 0, 0, 1);
				ofRect(-1, -2, 2, 2*zip/100.0);
				ofRect(-1, 2, 2, -2*zip/100.0);
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
