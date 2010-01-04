#import "PluginIncludes.h"



@implementation DanceSteps

-(void) initPlugin{
	for(int i=0;i<numFingers;i++){
		fingerActive[i] = false;	
		fingerPositions[i] = new ofxPoint2f();
		identity[i] = nil;
		img = new ofImage();
	}
	min = 0.05;
	max = 0.09;
	cout<<"LOAD"<<endl;
	

	[self remake:self];
	
}
-(IBAction) remake:(id)sender{
	lines = new vector<float>;
	float x = 0;
	while(x < 1.3){
		lines->push_back(x);
		x += ofRandom(min,max);
	}
}
-(IBAction) setMinSize:(id)sender{
	min = [sender floatValue];
}
-(IBAction) setMaxSize:(id)sender{
	max = [sender floatValue];	
}

-(void) setup{
	img->loadImage("filmskilt.png");;	
	font = new ofTrueTypeFont();
	font->loadFont("LucidaGrande.ttc",40, true, true, true);
}

-(void) draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{

/*	[GetPlugin(ProjectionSurfaces) apply:"Back" surface:"Floor"];
	ofSetColor(255, 255, 255);
	img->draw(0, 0,1,1);
	
	for
	
	glPopMatrix();*/
	
		/**
	Blob * blob;
	//cout<<"Num blobs: "<<[tracker(2) numBlobs]<<endl;
	for(blob in [tracker(2) blobs]){
		ofSetColor(255, 255, 255);
//		glScaled(0.1, 0.1, 0.1);
		glBegin(GL_LINE_STRIP);
	//	cout<<"Num points: "<<[blob nPts]<<endl;
		for(int i=0;i<[blob nPts];i++){
		//	cout<<[blob pts][i].x<<"  "<<[blob pts][i].y<<endl;
			glVertex3f([blob pts][i].x, [blob pts][i].y, 0);
		}
		glEnd();
	}
		 **/
	
	ofFill();
	ofEnableAlphaBlending();
	
	[GetPlugin(ProjectionSurfaces) apply:"Front" surface:"Floor"];
	
	ofSetColor(255, 255, 255,255);
	
//	img->draw(0, 0,1,1);
	
	glPopMatrix();
	
	/**
	[GetPlugin(ProjectionSurfaces) apply:"Back" surface:"Floor"];
		
	ofSetColor(255, 255, 255,255);
	
//	img->draw(0, 0,1,1);
	
	glPopMatrix();
	
	
	[GetPlugin(ProjectionSurfaces) apply:"Front" surface:"Backwall"];
	
	ofSetColor(255, 0,127,255);

	ofRect(0, 0, [GetPlugin(ProjectionSurfaces) getAspect]/2, 1);

	ofSetColor(255, 127, 0,255);
	
	ofRect([GetPlugin(ProjectionSurfaces) getAspect]/2, 0, [GetPlugin(ProjectionSurfaces) getAspect]/2, 1);
	
	ofSetColor(127, 127, 127,sinf(timeInterval/2.0)*255);
	
	ofRect(0, 0, [GetPlugin(ProjectionSurfaces) getAspect], 1);
	
	
//	img->draw(0, 0,1,1);
	
	glPopMatrix();
	
	
	[GetPlugin(ProjectionSurfaces) apply:"Back" surface:"Backwall"];
	
	
	
	ofSetColor(0,255,127,255);
	
	ofRect(0, 0, [GetPlugin(ProjectionSurfaces) getAspect]/2, 1);
	
	ofSetColor(0, 127, 255,255);
	
	ofRect([GetPlugin(ProjectionSurfaces) getAspect]/2, 0, [GetPlugin(ProjectionSurfaces) getAspect]/2, 1);

	ofSetColor(127, 127, 127,sinf(timeInterval/2.0)*255);
	
	ofRect(0, 0, [GetPlugin(ProjectionSurfaces) getAspect], 1);
	
//	img->draw(0, 0,1,1);
	
	glPopMatrix();

	 **/
	/**

	[GetPlugin(ProjectionSurfaces) apply:"Back" surface:"Backwall"];
	
	ofSetColor(255, 255, 255,255);
	
	ofRect(0, 0, [GetPlugin(ProjectionSurfaces) getAspect], 1);
	
	ofSetColor(0,0,0,255);
	
	ofCircle([GetPlugin(ProjectionSurfaces) getAspect]/2, 0.5, 0.2);
		
	glPopMatrix();

	[GetPlugin(ProjectionSurfaces) apply:"Front" surface:"Backwall"];

	ofSetColor(0,0,0,255);
	
	ofRect(0, 0, [GetPlugin(ProjectionSurfaces) getAspect], 1);
	
	ofSetColor(170, 170, 170,255);
	
	ofCircle([GetPlugin(ProjectionSurfaces) getAspect]/2, 0.5, 0.2);

	glPopMatrix();

	 **/

	
	[GetPlugin(ProjectionSurfaces) apply:"Back" surface:"Backwall"];
	
	ofFill();
	ofSetColor(255, 255, 255,255);

	ofRect(0, 0, [GetPlugin(ProjectionSurfaces) getAspect], 1);
	
	img->draw(0,0.2,1,1);
	
	glPopMatrix();
	
	[GetPlugin(ProjectionSurfaces) apply:"Front" surface:"Backwall"];
	
	ofSetColor(255,255,255,255);
	ofNoFill();
	ofSetLineWidth(0.05);
	
	ofRect(0, 0, [GetPlugin(ProjectionSurfaces) getAspect], 1);
		
	glPopMatrix();

	
	
	/** floor grid from back
	
	int n= 20;

	[GetPlugin(ProjectionSurfaces) apply:"Back" surface:"Floor"];
	
	ofSetColor(255, 255, 255);
	for(int i=0;i<n;i++){
		ofRect( (float)i/n * [GetPlugin(ProjectionSurfaces) getAspect], 0, 0.01, 1);

	}

	 glPopMatrix();

	 **/
	 
	//ofRect(0, 0.2, 1, 0.01);


	
/*	[GetPlugin(ProjectionSurfaces) apply:"Front" surface:"Floor"];
	
	ofSetColor(255, 255, 255);
	ofRect(1, 1, 0.01, -1);
	ofRect(1, 0.8, -1, 0.01);
	
	
	glPopMatrix();
	
 */
	/**
	[GetPlugin(ProjectionSurfaces) apply:"Front" surface:"Backwall"];
	glTranslated([GetPlugin(ProjectionSurfaces) getAspect]*0.5*1.0/n, 0, 0);
	for (int i=0;i<n;i++) {
		ofSetColor(255, 255, 255);
	
		ofRect( (float)i/n * [GetPlugin(ProjectionSurfaces) getAspect], 0, [GetPlugin(ProjectionSurfaces) getAspect]*0.5*1.0/n, 1);
	}
	
	glPopMatrix();
	**/
	 
}

-(void) controlDraw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)timeStamp{
	//cout << [controlOuptutView openGLContext] << endl;
	ofBackground(0, 0, 0);
	ofSetColor(255, 255, 255);
	for(int i=0;i<numFingers;i++){
		if(fingerActive[i]){
			ofCircle(fingerPositions[i]->x*ofGetWidth(), fingerPositions[i]->y*ofGetHeight(), 20);
		}
	}
}
@end


