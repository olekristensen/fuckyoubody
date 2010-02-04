#import "GrowingShadow.h"
#import "Tracking.h"
#import "Cameras.h"


@implementation GrowingShadow

@synthesize coordinateX, coordinateY;

-(void) initPlugin{
	
}

-(void) setup{
	shadow = new ofxCvColorImageAlpha();
	shadow->allocate(ShadowSizeX,ShadowSizeY);
	shadow->set(0,0,0,0);
	shadowTemp = new ofxCvColorImageAlpha();
	shadowTemp->allocate(ShadowSizeX,ShadowSizeY);
	shadowTemp->set(0,0,0,0);
	
	newestShadowTemp = new ofxCvColorImageAlpha();
	newestShadowTemp->allocate(ShadowSizeX,ShadowSizeY);
	newestShadowTemp->set(0,0,0,0);	
	
	for(int i=0;i<BufferLength;i++){
		ofxCvColorImageAlpha  img;
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
		
		newestShadowTemp->set(0,0,0,0);
		
		Blob * b;
		for(b in [tracker(1) blobs]){
			CvPoint * pointArray = new CvPoint[ [b nPts] ];
			
			for( int u = 0; u < [b nPts]; u++){
				float pointPercent = (float)u/[b nPts];
				ofxPoint2f p = [GetPlugin(ProjectionSurfaces) convertPoint:[b pts][u] fromProjection:"Back" toSurface:"Floor"];

				ofxVec2f blobP;
				blobP.x = int(p.x*ShadowSizeX);
				blobP.y = int(p.y*ShadowSizeY);				
				
				float c = -pointPercent*TWO_PI+PI;
				ofxVec2f lemmingP = ofxVec2f((cos(c)*0.02+[coordinateX floatValue])*ShadowSizeX,(sin(c)*0.02+[coordinateY floatValue])*ShadowSizeY);
				float percent = [morphSlider floatValue]/100.0;
				
				ofxVec2f point = (1.0-percent)*blobP + percent*lemmingP;
				pointArray[u].x  = point.x;
				pointArray[u].y  = point.y;
				//				cout<<pointArray[u].x<<"  "<<pointArray[u].y<<endl;
			}
			int nPts = [b nPts];
			cvFillPoly(newestShadowTemp->getCvImage(),&pointArray , &nPts, 1, cvScalar(255, 255, 255, 255.0));			
			newestShadowTemp->flagImageChanged();
		}
		
		history[histPos] = *newestShadowTemp;	

	}

	
	int pos = histPos - [delaySlider  intValue];
	while(pos < 0){
		pos += BufferLength;
	}
	
//	cvAddWeighted(shadow->getCvImage() ,[fadeSlider floatValue]/100.0, history[pos].getCvImage(),1, -0.35, shadowTemp->getCvImage());¨
	//*shadow = *shadowTemp;
	*shadow =  history[pos];
	
	if([blurSlider intValue] > 0){
		shadow->blur([blurSlider intValue]);
	}
	
	if([thresholdSlider intValue] > 0){
		cvThreshold( shadow->getCvImage(), shadowTemp->getCvImage(), [thresholdSlider intValue], 255, CV_THRESH_BINARY );		
		*shadow = *shadowTemp;
		
	//	shadow->threshold([thresholdSlider intValue]);
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
	ofFill();
	float a = (*scalePoint-[GetPlugin(ProjectionSurfaces) getFloorCoordinateOfProjector:1]).angle(ofxVec2f(1,0));
	//ofxVec2f v = (*scalePoint-[GetPlugin(ProjectionSurfaces) getFloorCoordinateOfProjector:1]);
	
	[GetPlugin(ProjectionSurfaces) apply:"Front" surface:"Floor"];
	float v = [invertSlider floatValue]*2.5;
	ofSetColor(v, v, v);
	ofRect(0, 0, 1, 1);
	
	glTranslated(scalePoint->x, scalePoint->y, 0);	
	glRotatef(90-a,0,0,1);
	
	glScaled(1, [scaleSlider floatValue]/10.0, 0);

	glRotatef(-(90-a),0,0,1);
	glTranslated(-scalePoint->x, -scalePoint->y, 0);
	
	ofEnableAlphaBlending();
	float r = [distanceBlurAngleSlider floatValue];
	glRotatef(-r, 0, 0, 1);
	int n = [distanceBlurPassesSlider intValue];
//	ofSetColor(255.0/n, 255.0/n, 255.0/n,255.0);
//	ofSetColor(255, 255, 255, 255.0/n);
	v = 255-v;
	ofSetColor(v, v, v,2*255.0/n);

	for(int i=0;i<n;i++){
		glRotatef((2.0*r)/n, 0, 0, 1);
		shadow->draw(0,0,1,1);
	}
	ofSetColor(255, 255, 255);
	ofLine(scalePoint->x, scalePoint->y, [GetPlugin(ProjectionSurfaces) getFloorCoordinateOfProjector:1].x, [GetPlugin(ProjectionSurfaces) getFloorCoordinateOfProjector:1].y);
	
	glPopMatrix();
}

@end
