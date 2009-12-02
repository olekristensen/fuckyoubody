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
	img->loadImage("danseDiagramOrden.png");;	
}

-(void) draw:(const CVTimeStamp *)outputTime{

	[GetPlugin(ProjectionSurfaces) apply:"Back" surface:"Floor"];
	ofSetColor(255, 255, 255);
	img->draw(0, 0,1,1);
	
	glPopMatrix();

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


