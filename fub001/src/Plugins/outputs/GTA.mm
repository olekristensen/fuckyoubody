#import "PluginIncludes.h"


@implementation WallObject
@synthesize pos, offset, obstacle, texture;
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
	aspect = [GetPlugin(ProjectionSurfaces) getProjectionSurfaceByName:"Front" surface:"Backwall"]->aspect; 
	
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
				
				while([obj pos]->z > 455){
					[obj pos]->z -= 1000;
					//				[obj setOffset:new ofxPoint3f(0,0,0)];
				}
			}
			//}
		}	
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
	/*	NSArray * inverseSortedArray = [wallObjects sortedArrayUsingSelector:@selector(inversecompare:)];
	 float lastZ = 0;
	 for(obj in inverseSortedArray){
	 //	blur->blur(10, 0.5);
	 
	 shaders.push_back(blur->fbo1);
	 }*/	
	//	ofSetupScreen();	
	//glBlendFunc(GL_SRC_ALPHA, GL_ONE);
	//	glScaled(ofGetWidth(), ofGetHeight(), [wallZScaleControl floatValue]/20.0);
	
	glPushMatrix();
	/*		if([obj pos]->z < 0 || 1){
	 ofSetupScreen();	
	 blur->blur(1, 1);
	 ofSetupScreen();	
	 ofEnableAlphaBlending();
	 glBlendFunc(GL_SRC_ALPHA, GL_ONE);
	 glScaled(ofGetWidth(), ofGetHeight(), [wallZScaleControl floatValue]/20.0);
	 
	 }
	 */
	//	glTranslatef(0, +0.1, 0);
	glScaled(800, 600, 1);
	glTranslated(camXPos, 0, 0);	
	
	int i=0;
	NSArray * sortedArray = [wallObjects sortedArrayUsingSelector:@selector(compare:)];
	for(obj in sortedArray){
		glPushMatrix();
		//	blur->endRender();
		glScaled(1, 0.5, 1);
		
		float a = 300.0-3.0*fabs((float)[obj pos]->z)* zscale/100.0;
		if([obj pos]->z > 0){
			a = 255;	
		}
		a = 255;	
		ofxPoint3f position = *[obj pos] + *[obj offset]*zscale/100.0;
		
		glScaled(1, 1, zscale/100.0);
		ofSetColor(alph*255, alph*255, alph*255, 255);

		glBegin(GL_POLYGON);{
			glTranslated(0, 0, position.z);
			float s = [wallSizeControl floatValue]/100.0;
			glVertex3f(position.x - s*0.5*1.0/aspect, position.y - s*0.5, position.z);
			glVertex3f(position.x + s*0.5*1.0/aspect, position.y - s*0.5, position.z);
			glVertex3f(position.x + s*0.5*1.0/aspect, position.y + s*0.5, position.z);
			glVertex3f(position.x - s*0.5*1.0/aspect, position.y + s*0.5, position.z);
			
			//	blur->draw(position.x - s*0.5*1.4, position.y - s*0.5*1.4, s*1.4, s*1.4,true);
			//	[obj texture]->draw(position.x - s*0.5*1.4, position.y - s*0.5*1.4, s*1.4, s*1.4);
		} glEnd();
		//	cout<<[obj pos]->x<<"  -  "<< [obj pos]->y<<endl;
		glPopMatrix();		
		i++;
	}
	glPopMatrix();		
	
	glDisable (GL_FOG); //enable the fog
	
}

-(void) draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	/*glClear(GL_ACCUM_BUFFER_BIT);
	 int i, j;
	 int min, max;
	 int count;
	 GLfloat scale, dx, dy;
	 GLdouble FRUSTDIM = 100.f;
	 GLdouble FRUSTNEAR = 320.f;
	 GLdouble FRUSTFAR = 660.f;
	 scale = 0.01;
	 float focus = 1000;
	 
	 min = -2;
	 max = -min + 1;
	 count = -2 * min + 1;
	 count *= count;
	 
	 scale = 2.f;
	 
	 
	 for(j = min; j < max; j++) {
	 for(i = min; i < max; i++) {
	 dx = scale * i * FRUSTNEAR/focus;
	 dy = scale * j * FRUSTNEAR/focus;
	 glMatrixMode(GL_PROJECTION);
	 glLoadIdentity();
	 glFrustum(-FRUSTDIM + dx, 
	 FRUSTDIM + dx, 
	 -FRUSTDIM + dy, 
	 FRUSTDIM + dy, 
	 FRUSTNEAR,
	 FRUSTFAR); 
	 glMatrixMode(GL_MODELVIEW);
	 glLoadIdentity();
	 glTranslatef(scale * i, scale * j, 0.f);
	 
	 glAccum(GL_ACCUM, 1.f/count);
	 }
	 } 
	 glAccum(GL_RETURN, 1.f);*/
	
	//glScaled(w, h, 1);
	/*int w, h;
	 
	 w = 800;
	 h = 600;
	 
	 glPushMatrix();
	 glViewport(0, -h+ h/10.0, w, h*2);
	 
	 float halfFov, theTan, screenFov, as;
	 screenFov 		= 120.0f;
	 
	 float eyeX 		= (float)w / 2.0;
	 float eyeY 		= (float)h / 2.0 ;
	 halfFov 		= PI * screenFov / 360.0;
	 theTan 			= tanf(halfFov);
	 float dist 		= (h / 2.0) / theTan;
	 float nearDist 	= dist / 100000.0;	// near / far clip plane
	 float farDist 	= dist * 50000.0;
	 as 			= (float)w/(float)h;
	 
	 glMatrixMode(GL_PROJECTION);
	 glLoadIdentity();
	 gluPerspective(screenFov, as, nearDist, farDist);
	 
	 glMatrixMode(GL_MODELVIEW);
	 glLoadIdentity();
	 gluLookAt(eyeX, eyeY, dist, eyeX, h/2.0, 0.0, 0.0, 1.0, 0.0);
	 
	 glScalef(1, -1, 1);           // invert Y axis so increasing Y goes down.
	 glTranslatef(0, -h, 0);       // shift origin up to upper-left corner.
	 
	 glScaled(1, 0.5, 1);
	 */
	
	
	//	glScaled(1.0/ofGetWidth(), 1.0/ofGetHeight(), 1);
	
	//	glScaled(blur->fbo1.getWidth(), blur->fbo1.getHeight(), 1);	
	
	//
	int n=1;
	for(int i=0;i<n;i++){
		[self updateStep:1.0/n];
		
		
		blur->beginRender();
		//glPushMatrix();
		int w, h;
		
		w = 800;
		h = 600;	
		
		glViewport(0, -h+ h/10.0, w, h*2);
		
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
		
		glScalef(1, -1, 1);           // invert Y axis so increasing Y goes down.
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
			blur->blur(10, [wallBlurControl floatValue]/100.0);
		}
		
		glViewport(0,0,ofGetWidth(),ofGetHeight());
		
		ofSetupScreen();
		glScaled(ofGetWidth(), ofGetHeight(), 1);
		[GetPlugin(ProjectionSurfaces) apply:"Front" surface:"Backwall"];
		ofEnableAlphaBlending();
		glBlendFunc(GL_SRC_ALPHA, GL_ONE);

		blur->draw(0, 0, 1, 1, true);
		glPopMatrix();
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
	int i=0;
	for(float z=-1000;z<=0;z+=200){
		for(float y=0;y<=1;y+=[wallSizeControl floatValue]/100.0){
			for(float x=0;x<=1;x+=(1.0/aspect)*[wallSizeControl floatValue]/100.0){
				WallObject * nObj = [[WallObject alloc] init];
				[nObj setPos:new ofxPoint3f(x,y,ofRandom(-100, 100)+z)];
				if([nObj pos]->x > 1/2.0){
					[nObj setOffset:new ofxPoint3f(0.2,0,0)];					
				} else {
					[nObj setOffset:new ofxPoint3f(-0.2,0,0)];						
				}			
				
				[nObj setObstacle:NO];
				[wallObjects addObject:nObj];
			}
		}
	}
	
	for(int i=0;i<1;i++){
		WallObject * nObj = [[WallObject alloc] init];
		[nObj setPos:new ofxPoint3f(0.5,0.95,-1000)];
		[nObj setOffset:new ofxPoint3f()];
		[nObj setObstacle:YES];
		[nObj setTexture:(new ofTexture())];
		[nObj texture]->allocate(ofGetWidth(), ofGetHeight(), OF_IMAGE_COLOR_ALPHA);
		[wallObjects addObject:nObj];	
	}
}



@end
