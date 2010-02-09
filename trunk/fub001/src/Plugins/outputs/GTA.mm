#include "ProjectionSurfaces.h"
#include "GTA.h"

@implementation WallObject
@synthesize pos, offset, obstacle, texture, tower,visible;
-(ofxPoint3f*) position{
	return new ofxPoint3f(*pos+*offset);
}

- (NSComparisonResult)compare:(WallObject *)otherObject
{
	float diff = pos->z - [otherObject pos]->z;
	if (diff>0)
	{
		return NSOrderedDescending;
	}
	
	if (diff<0)
	{
		return NSOrderedAscending;
	}
	
	return NSOrderedSame;
}
- (NSComparisonResult)inversecompare:(WallObject *)otherObject
{
	float diff = pos->z - [otherObject pos]->z;
	if (diff>0)
	{
		return NSOrderedAscending;
	}
	
	if (diff<0)
	{
		return NSOrderedDescending;
	}
	
	return NSOrderedSame;
}
@end



@implementation GTA

-(void) initPlugin{
	wallObjects = [[NSMutableArray array] retain];
}

-(void) setup{
	aspect = 2*[GetPlugin(ProjectionSurfaces) getProjectionSurfaceByName:"Front" surface:"Backwall"]->aspect; 
	
	[self generateObjects];
	blur = new shaderBlur();
	blur->setup(800, 600);
	
}

-(void) update:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	camXPos += ([wallCamXControl floatValue]/100.0 - camXPos) * 0.1;
	zscale += ([wallZScaleControl floatValue]- zscale) * 0.1;
}

-(void) controlDraw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)timeStamp{
	
}

-(void) updateStep:(float)step{
	if([wallSpeedControl floatValue] != 0){
		WallObject * obj;
		for(obj in wallObjects){
			float a = 255.0-5.0*(float)[obj pos]->z* zscale/100.0;
			if([obj obstacle] == YES){
				if([wallBrakeControl state] == NSOnState){
					[obj pos]->z += ([wallSpeedControl floatValue]/50.0) * step * 60.0/ofGetFrameRate();
					if([obj pos]->z > 150){
						[obj pos]->z = 150;
					}
				} else {
					[obj pos]->z = -1000;	
				}
			} else {			
				//cout<<ofGetFrameRate()<<endl;
				[obj pos]->z += ([wallSpeedControl floatValue]/50.0) * step * 60.0/ofGetFrameRate();
				//float moveX = 0.003* [wallSpeedControl floatValue]/100.0 * 60.0/ofGetFrameRate();

				while([obj pos]->z + [obj offset]->z > 455){
					[obj pos]->z -= 1000;
					BOOL tower = NO;
					//					if([towerSlider floatValue] > 0){
					tower = (ofRandom(0, [towerSlider floatValue]) < 1);
					//					}
					BOOL visible = YES;
					visible = (ofRandom(0, [towerDistSlider floatValue]) < 1);
					
					[obj setTower:tower];
					[obj setVisible:visible];
					
					//[obj setOffset:new ofxPoint3f(0,0,0)];
				}
			}
			//}
		}	
	}	
	if([floorActiveControl state] == NSOnState){
		floorPos += [floorSpeedControl floatValue]/100.0;
		if(floorPos > 2)
			floorPos = -1;
	}
	if([floorToothControl state] == NSOnState){
		hajPos += [floorSpeedControl floatValue]/100.0;
	} else {
		hajPos = -1;
	}
}

-(void) drawFBO:(float)alph{
	GLfloat density = 0.002; 
	GLfloat fogColor[4] = {0, 0, 0, 1.0}; 
	
	glEnable (GL_DEPTH_TEST); //enable the depth testing
	glEnable (GL_FOG); //enable the fog
	glFogi (GL_FOG_MODE, GL_LINEAR); //set the fog mode to GL_EXP2
	glFogf(GL_FOG_START, 300.0f);				// Fog Start Depth
	glFogf(GL_FOG_END, 800.0f);				// Fog End Depth
	
	
	glFogfv (GL_FOG_COLOR, fogColor); //set the fog color to 
	glFogf (GL_FOG_DENSITY, density); //set the density to the
	glHint (GL_FOG_HINT, GL_NICEST); // set the fog to look the 
	
	WallObject * obj;
	
	glPushMatrix();
	
	glScaled(800, 600, 1);
	glTranslated(camXPos, 0, 0);	
	float b = [wallNoiseControl floatValue]/100.0;
	glTranslated(ofRandom(-0.1*b, 0.1*b), ofRandom(-0.1*b, 0.1*b), ofRandom(-0.1*b, 0.1*b));	
	
	int i=0;
	NSArray * sortedArray = [wallObjects sortedArrayUsingSelector:@selector(compare:)];
	for(obj in sortedArray){
		glPushMatrix();
		//	blur->endRender();
		glScaled(1, 0.5, 1);
		
		float oh = 0.3;
		float ow = 0.2;
		glTranslated(ow, oh, 0);
		glRotated(360*3*[freakOutControl floatValue]/100.0, -0.003, 0.003, 1);
		glScaled(1+[freakOutControl floatValue]/100.0, 1, 1);
		glTranslated(-ow, -oh, 0);		
		
		/*		float a = 300.0-3.0*fabs((float)[obj pos]->z)* zscale/100.0;
		 if([obj pos]->z > 0){
		 a = 255;	
		 }
		 a = 255;	*/
		
		ofxPoint3f position = *[obj pos];
		
		position.x += [obj offset]->x * [wallStreetSizeControl floatValue]/100.0;
		position.y += [obj offset]->y * [wallStreetSizeControl floatValue]/100.0;
		
		if(i > numPerLayer*numLayers-numPerLayer){
			position.z += [obj offset]->z * zscale/100.0;
			position.z *= zscale/100.0;
		} else {
			position += *[obj offset];	
		}
		
		float zAlphaEffect = 1 + position.z/10.0 - 0.1;
		zAlphaEffect = [wallZAlphaControl floatValue]/100.0 * zAlphaEffect + (1-[wallZAlphaControl floatValue]/100.0);
		float a = 1.0;
		if(position.z > 200)
			a *= (450 - position.z)/250.0;
		
		a += 1-[wallZScaleControl floatValue]/100.0;
		a = ofClamp(a, 0, 1);
		
		a = 1;
		
		
		
		ofSetColor([wallAlphaControl floatValue]/100.0* alph*215*zAlphaEffect, [wallAlphaControl floatValue]/100.0*alph*221*zAlphaEffect, [wallAlphaControl floatValue]/100.0*alph*248*zAlphaEffect, 255*a);
		if([obj visible]){
			glBegin(GL_POLYGON);{
				glTranslated(0, 0, position.z);
				float s = [wallSizeControl floatValue]/100.0;
				if([obj obstacle]){
					s *= 1.8;
				}
				glVertex3f(position.x - s*0.5*1.0/aspect, position.y - s*0.5, position.z);
				glVertex3f(position.x + s*0.5*1.0/aspect, position.y - s*0.5, position.z);
				if(![obj tower]){
					glVertex3f(position.x + s*0.5*1.0/aspect, position.y + s*0.5, position.z);
					glVertex3f(position.x - s*0.5*1.0/aspect, position.y + s*0.5, position.z);
				} else {
					glVertex3f(position.x + s*0.5*1.0/aspect, 1, position.z);
					glVertex3f(position.x - s*0.5*1.0/aspect, 1, position.z);
					
				}
				//	blur->draw(position.x - s*0.5*1.4, position.y - s*0.5*1.4, s*1.4, s*1.4,true);
				//	[obj texture]->draw(position.x - s*0.5*1.4, position.y - s*0.5*1.4, s*1.4, s*1.4);
			} glEnd();
		}
		//	cout<<[obj pos]->x<<"  -  "<< [obj pos]->y<<endl;
		glPopMatrix();		
		i++;
	}
	glPopMatrix();		
	
	glDisable (GL_FOG); //enable the fog
	
}

-(void) draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	
	int n=1;
	for(int i=0;i<n;i++){
		[self updateStep:1.0/n];
		
		
		blur->beginRender();
		//glPushMatrix();
		int w, h;
		
		w = 800;
		h = 600;	
		
		glViewport(0, -h, w, h*2);
		
		float halfFov, theTan, screenFov, as;
		screenFov 		= 120.0f;
		
		float eyeX 		= (float)w / 2.0;
		float eyeY 		= (float)h / 2.0;
		halfFov 		= PI * screenFov / 360.0;
		theTan 			= tanf(halfFov);
		float dist 		= eyeY / theTan;
		float nearDist 	= dist / 10.0;	// near / far clip plane
		float farDist 	= dist * 10.0;
		as 			= (float)w/(float)h;
		
		glMatrixMode(GL_PROJECTION);
		glLoadIdentity();
		gluPerspective(screenFov, as, nearDist, farDist);
		
		glMatrixMode(GL_MODELVIEW);
		glLoadIdentity();
		gluLookAt(eyeX, eyeY, dist, eyeX, h/2.0, 0.0, 0.0, 1.0, 0.0);
		
//		glTranslatef(+w/2.0, 0, 0);
//			glScalef(1.0/[GetPlugin(ProjectionSurfaces) getAspectForProjection:"Front" surface:"Backwall"], -1, 1);           // invert Y axis so increasing Y goes down.		
					glScalef(1, -1, 1);           // invert Y axis so increasing Y goes down.		
//		glTranslatef(- (1.0/[GetPlugin(ProjectionSurfaces) getAspectForProjection:"Front" surface:"Backwall"]) * w/2.0, 0, 0);
		
		glTranslatef(0, -h, 0);       // shift origin up to upper-left corner.
		
		//	glTranslatef(0, +h*0.5, 0);       // shift origin up to upper-left corner.
		
		//	ofSetupScreen();
		ofBackground(0, 0, 0);
		ofSetColor(200, 200, 0);
		//ofRect(10,10, 780, 580);
		//glPopMatrix();
		ofDisableAlphaBlending();
		
		[self drawFBO:1.0/n];
		//ofSetColor(200, 200, 255);
		//ofRect(0, 0, 100, 100);
		
		blur->endRender();
		if([wallBlurControl floatValue] > 0){
			blur->blur(2, [wallBlurControl floatValue]/100.0);
		}
		
		glViewport(0,0,ofGetWidth(),ofGetHeight());
		
		ofSetupScreen();
		glScaled(ofGetWidth(), ofGetHeight(), 1);
		[GetPlugin(ProjectionSurfaces) apply:"Front" surface:"Backwall"];
		ofEnableAlphaBlending();
		glBlendFunc(GL_SRC_ALPHA, GL_ONE);
		
		blur->draw(0, 0, [GetPlugin(ProjectionSurfaces) getAspect]*2, 1, true);
		glPopMatrix();
	}
	
	if([floorActiveControl state] == NSOnState){\
		ofSetColor(215, 221, 248);

		[GetPlugin(ProjectionSurfaces) apply:"Front" surface:"Floor"];{
			ofFill();
			glRotated(-45, 0, 0, 1);
			glPushMatrix();
			glTranslatef([floorXControl floatValue]/100.0, 1-floorPos, 0);
			ofRect(0, 0, 0.06, 0.4);
			glPopMatrix();
			
			glPushMatrix();
			glTranslatef([floorXControl floatValue]/100.0, 1-hajPos, 0);
			for(float i=-1;i<1;i+= 0.2){
				ofTriangle(i, 0, i+1/8.0, 0, i+1/16.0, -0.07);
			}
			glPopMatrix();
			
		}glPopMatrix();
		
		
		[GetPlugin(ProjectionSurfaces) apply:"Back" surface:"Floor"];{
			ofFill();
			glRotated(-45, 0, 0, 1);
			glPushMatrix();
			glTranslatef([floorXControl floatValue]/100.0, 1-floorPos, 0);
			ofRect(0, 0, 0.06, 0.4);
			glPopMatrix();
			
			glPushMatrix();
			glTranslatef([floorXControl floatValue]/100.0, 1-hajPos, 0);
			for(float i=-1;i<1;i+= 0.2){
				ofTriangle(i, 0, i+1/8.0, 0, i+1/16.0, -0.07);
			}
			glPopMatrix();
			
		}glPopMatrix();
	}	
	
	
	
	//ofSetColor(255, 255, 255);
	
	
	/*
	 
	 blur->beginRender();
	 ofSetupScreen();	
	 ofSetColor(255, 255, 255);
	 ofBackground(0, 0, 0);
	 
	 ofRect(0.2*blur->fbo1.getWidth(), 0.2*blur->fbo1.getHeight(), 0.6*blur->fbo1.getWidth(), 0.6*blur->fbo1.getHeight());
	 blur->endRender();
	 
	 
	 ofEnableAlphaBlending();
	 
	 
	 
	 */
	
	
	/*	ofSetupScreen();
	 ofSetColor(255, 255, 255,255);
	 blur->draw(0, 0, ofGetWidth(), ofGetHeight(), true);
	 */	
	//	ofRect(0, 0, 1, 1);*/
	
}

-(void) generateObjects{
	[wallObjects removeAllObjects];
	floorPos = -1;
	numLayers = 0;
	for(float z=-1000;z<=0;z+=200){
		int i=0;
		for(float y=0;y<=1;y+=[wallSizeControl floatValue]/100.0){
			for(float x=0;x<=1;x+=(1.0/aspect)*[wallSizeControl floatValue]/100.0){
				WallObject * nObj = [[WallObject alloc] init];
				[nObj setPos:new ofxPoint3f(x,y,z)];
				if([nObj pos]->x > 1/2.0){
					[nObj setOffset:new ofxPoint3f(0.2,0,ofRandom(-100, 100))];					
				} else {
					[nObj setOffset:new ofxPoint3f(-0.2,0,ofRandom(-100, 100))];						
				}			
				
				[nObj setTower:NO];
				[nObj setVisible:YES];

				[nObj setObstacle:NO];
				[wallObjects addObject:nObj];
				i++;
			}
		}
		numPerLayer = i;
		numLayers ++;
	}
	
	for(int i=0;i<1;i++){
		WallObject * nObj = [[WallObject alloc] init];
		[nObj setPos:new ofxPoint3f(0.5,0.95,-1000)];
		[nObj setOffset:new ofxPoint3f()];
		[nObj setObstacle:YES];
		[nObj setTexture:(new ofTexture())];
		[nObj setTower:NO];
		[nObj setVisible:YES];
		[nObj texture]->allocate(ofGetWidth(), ofGetHeight(), OF_IMAGE_COLOR_ALPHA);
		[wallObjects addObject:nObj];	
	}
}

-(IBAction) reset:(id)sender{
	[self generateObjects];
	
	
}

@end
