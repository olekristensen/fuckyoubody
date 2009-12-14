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
	aspect = 1.0;
	[self generateObjects];
	blur = new shaderBlur();
	blur->setup(ofGetWidth(), ofGetHeight());
	
}

-(void) update:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	if([wallSpeedControl floatValue] != 0){
		WallObject * obj;
		for(obj in wallObjects){
			float a = 255.0-5.0*(float)[obj pos]->z* [wallZScaleControl floatValue]/100.0;
			[obj pos]->z += [wallSpeedControl floatValue]/50.0 * 60.0/ofGetFrameRate();
			//float moveX = 0.003* [wallSpeedControl floatValue]/100.0 * 60.0/ofGetFrameRate();
			if([obj obstacle] == NO){
				/*	if([obj pos]->x < 0.5){
				 [obj offset]->x -= moveX;
				 } else {
				 [obj offset]->x += moveX;				
				 }*/	
			}
			while([obj pos]->z > 455){
				[obj pos]->z -= 1000;
				//				[obj setOffset:new ofxPoint3f(0,0,0)];
			}
			//}
		}	
	}
}

-(void) controlDraw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)timeStamp{
	
}

-(void) render{
	GLfloat density = 0.001; 
	GLfloat fogColor[4] = {0, 0, 0, 1.0}; 
	
	glEnable (GL_DEPTH_TEST); //enable the depth testing
	glEnable (GL_FOG); //enable the fog
	glFogi (GL_FOG_MODE, GL_EXP2); //set the fog mode to GL_EXP2
	
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
	ofSetupScreen();	
	glBlendFunc(GL_SRC_ALPHA, GL_ONE);
	glScaled(ofGetWidth(), ofGetHeight(), [wallZScaleControl floatValue]/20.0);
	
	int i=0;
	NSArray * sortedArray = [wallObjects sortedArrayUsingSelector:@selector(inversecompare:)];
	for(obj in sortedArray){
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
		
		camXPos += ([wallCamXControl floatValue]/100.0 - camXPos) * 0.1;
		glTranslated(camXPos, 0, 0);	
		
		
		glPushMatrix();
		
		//	blur->endRender();
		
		
		
		float a = 300.0-3.0*fabs((float)[obj pos]->z)* [wallZScaleControl floatValue]/100.0;
		if([obj pos]->z > 0){
			a = 255;	
		}
		a = 255;	
		ofxPoint3f position = *[obj pos] + *[obj offset]*[wallZScaleControl floatValue]/100.0;
		
		
		ofSetColor(255, 255, 255, a);
		glBegin(GL_POLYGON);{
			glTranslated(0, 0, position.z);
			float s = [wallSizeControl floatValue]/100.0;
			glVertex3f(position.x - s*0.5, position.y - s*0.5, position.z);
			glVertex3f(position.x + s*0.5, position.y - s*0.5, position.z);
			glVertex3f(position.x + s*0.5, position.y + s*0.5, position.z);
			glVertex3f(position.x - s*0.5, position.y + s*0.5, position.z);
			
			//	blur->draw(position.x - s*0.5*1.4, position.y - s*0.5*1.4, s*1.4, s*1.4,true);
			//	[obj texture]->draw(position.x - s*0.5*1.4, position.y - s*0.5*1.4, s*1.4, s*1.4);
		} glEnd();
		//	cout<<[obj pos]->x<<"  -  "<< [obj pos]->y<<endl;
		glPopMatrix();		
		i++;
		
	}
	
}

-(void) draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	glClear(GL_ACCUM_BUFFER_BIT);
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

				[self render];
	//glScaled(w, h, 1);
	/*int w, h;
	 
	 w = ofGetWidth();
	 h = ofGetHeight();
	 
	 glPushMatrix();
	 glViewport(0, -h+ h/10.0, w, h*2);
	 
	 float halfFov, theTan, screenFov, as;
	 screenFov 		= 30.0f;
	 
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
	 
	 //	glScaled(1.0/ofGetWidth(), 1.0/ofGetHeight(), 1);
	 
	 //	glScaled(blur->fbo1.getWidth(), blur->fbo1.getHeight(), 1);	
	 
	 
	 
	 */
	
	
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
			for(float x=0;x<=aspect;x+=[wallSizeControl floatValue]/100.0){
				WallObject * nObj = [[WallObject alloc] init];
				[nObj setPos:new ofxPoint3f(x,y,ofRandom(-100, 100)+z)];
				if([nObj pos]->x > aspect/2.0){
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
		[nObj setPos:new ofxPoint3f(0.5,0.95,-600)];
		[nObj setOffset:new ofxPoint3f()];
		[nObj setObstacle:YES];
		[nObj setTexture:(new ofTexture())];
		[nObj texture]->allocate(ofGetWidth(), ofGetHeight(), OF_IMAGE_COLOR_ALPHA);
		[wallObjects addObject:nObj];	
	}
}



@end
