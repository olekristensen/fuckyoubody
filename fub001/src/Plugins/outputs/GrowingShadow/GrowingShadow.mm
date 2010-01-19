#import "GrowingShadow.h"
#import "Tracking.h"
#import "Cameras.h"


@implementation GrowingShadow

-(void) initPlugin{
	
}

-(void) setup{
	shadow = new ofxCvGrayscaleImage();
	shadow->allocate(ShadowSizeX,ShadowSizeY);
	shadow->set(255);
	shadowTemp = new ofxCvGrayscaleImage();
	shadowTemp->allocate(ShadowSizeX,ShadowSizeY);
	shadowTemp->set(255);
	
	newestShadowTemp = new ofxCvGrayscaleImage();
	newestShadowTemp->allocate(ShadowSizeX,ShadowSizeY);
	newestShadowTemp->set(255);	
	
	for(int i=0;i<BufferLength;i++){
		ofxCvGrayscaleImage  img;
		img.allocate(ShadowSizeX,ShadowSizeY);
		img.set(0);
		history.push_back(img);
	}
	
	histPos = 0;
	
	scalePoint = new ofxVec2f;


}


-(void) update:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	
	if ([[GetPlugin(Cameras) getCameraWithId:1] isFrameNew]) {
		histPos++;
		if(histPos >= history.size())
			histPos = 0;
		
		newestShadowTemp->set(255);
		
		Blob * b;
		for(b in [tracker(1) blobs]){
			CvPoint * pointArray = new CvPoint[ [b nPts] ];
			
			for( int u = 0; u < [b nPts]; u++){
				ofxPoint2f p = [GetPlugin(ProjectionSurfaces) convertPoint:[b pts][u] fromProjection:"Back" toSurface:"Floor"];
				pointArray[u].x = int(p.x*ShadowSizeX);
				pointArray[u].y = int(p.y*ShadowSizeY);
				//				cout<<pointArray[u].x<<"  "<<pointArray[u].y<<endl;
			}
			int nPts = [b nPts];
			cvFillPoly(newestShadowTemp->getCvImage(),&pointArray , &nPts, 1, cvScalar(0, 0, 0, 255.0));			
			newestShadowTemp->flagImageChanged();
		}
		
		history[histPos] = *newestShadowTemp;	

	}

	
	int pos = histPos - [delaySlider  intValue];
	while(pos < 0){
		pos += BufferLength;
	}
	
	cvAddWeighted(shadow->getCvImage() ,[fadeSlider floatValue]/100.0, history[pos].getCvImage(),1, -0.45, shadowTemp->getCvImage());
	*shadow = *shadowTemp;
	
	if([blurSlider intValue] > 0){
		shadow->blur([blurSlider intValue]);
	}
	
	if([thresholdSlider intValue] > 0){
		shadow->threshold([thresholdSlider intValue]);
	}
	
	shadow->flagImageChanged();
	
}
-(IBAction) startGrow:(id)sender{
	ofPoint highestPoint = ofPoint(-1,-1);
	Blob * b;
	for(b in [tracker(1) blobs]){
		for( int u = 0; u < [b nPts]; u++){
			if(highestPoint.x == -1 || [b pts][u].y > highestPoint.y){
				highestPoint = [b pts][u];
			}
		}
	}
	if(highestPoint.y != -1){
		*scalePoint = [GetPlugin(ProjectionSurfaces) convertPoint:(ofxPoint2f)highestPoint fromProjection:"Back" toSurface:"Floor"];
	}
	
	cout<<"Scale point set: x="<<scalePoint->x<<"  y="<<scalePoint->y<<endl;
}

-(void) draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	float a = (*scalePoint-[GetPlugin(ProjectionSurfaces) getFloorCoordinateOfProjector:1]).angle(ofxVec2f(1,0));
	cout<<a<<endl;
	//ofxVec2f v = (*scalePoint-[GetPlugin(ProjectionSurfaces) getFloorCoordinateOfProjector:1]);
	
	[GetPlugin(ProjectionSurfaces) apply:"Front" surface:"Floor"];
	
	glTranslated(scalePoint->x, scalePoint->y, 0);	
	glRotatef(90-a,0,0,1);
	
	glScaled(1, [scaleSlider floatValue]/10.0, 0);

	glRotatef(-(90-a),0,0,1);
	glTranslated(-scalePoint->x, -scalePoint->y, 0);
	
	glEnable(GL_BLEND);
	glBlendFunc(GL_ONE, GL_ONE);

	float r = [distanceBlurAngleSlider floatValue];
	glRotatef(-r, 0, 0, 1);
	int n = [distanceBlurPassesSlider intValue];
	ofSetColor(255.0/n, 255.0/n, 255.0/n,255.0);
//	ofSetColor(255, 255, 255);
	for(int i=0;i<n;i++){
		glRotatef((2.0*r)/n, 0, 0, 1);
		shadow->draw(0,0,1,1);
	}
	ofSetColor(255, 255, 255);
	ofLine(scalePoint->x, scalePoint->y, [GetPlugin(ProjectionSurfaces) getFloorCoordinateOfProjector:1].x, [GetPlugin(ProjectionSurfaces) getFloorCoordinateOfProjector:1].y);
	
	glPopMatrix();
}

@end
