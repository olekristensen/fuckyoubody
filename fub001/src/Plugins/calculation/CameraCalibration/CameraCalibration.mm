
#include "CameraCalibration.h"
#include "Lenses.h"

@implementation CameraCalibration

-(void) initPlugin{
	cameraCalibrations = [[NSMutableArray array] retain];
	lastMousePos = new ofxVec2f();
}

-(void) setup{
	for(int i=0;i<3;i++){
		CameraCalibrationObject * obj = [[[CameraCalibrationObject alloc] init] retain];		
		[obj setName:[NSString stringWithFormat:@"CAMERA%d",i]];
		
		if(i==0){
			[obj setSurface:[GetPlugin(ProjectionSurfaces) getProjectionSurfaceByName:"Front" surface:"Floor"]];
			[obj calibPoints][0] = new ofxPoint2f(0.2,0.2);
			[obj calibPoints][1] = new ofxPoint2f(0.8,0.2);
			[obj calibPoints][2] = new ofxPoint2f(0.8,0.8);
			[obj calibPoints][3] = new ofxPoint2f(0.2,0.8);
			//			[obj calibPoints][0] = new ofxPoint2f([GetPlugin(ProjectionSurfaces) convertToProjection:ofxPoint2f(0,0) surface:surface]);
		}
		
		for(int u=0;u<4;u++){
			[obj calibHandles][u] = new ofxPoint2f();
			
		}
		
		[cameraCalibrations addObject:obj];
		
	}	
	
	font = new ofTrueTypeFont();
	font->loadFont("LucidaGrande.ttc",40, true, true, true);	
}


-(void) controlDraw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)timeStamp{
	int w = 640;
	int h = 480;
	//	[[GetPlugin(Cameras) getCameraWithId:[cameraSelector selectedSegment]] getTexture]->draw(0,0,ofGetWidth(),ofGetHeight());
	CameraCalibrationObject * obj = [cameraCalibrations objectAtIndex:[cameraSelector selectedSegment]];
	
	ofSetColor(255, 255, 255);
	[GetPlugin(Lenses) getUndistortedImageFromCameraId:[cameraSelector selectedSegment]]->draw(0,0,640,480);
	
	
	ofFill();
	for(int i=0;i<4;i++){
		ofNoFill();
		ofSetColor(0, 0,0);
		ofEllipse([obj calibHandles][i]->x*w, [obj calibHandles][i]->y*h, 21, 21);
		ofEllipse([obj calibHandles][i]->x*w, [obj calibHandles][i]->y*h, 19, 19);
		ofSetColor(255, 0,0);
		ofEllipse([obj calibHandles][i]->x*w, [obj calibHandles][i]->y*h, 20, 20);
	}
	
	
}

-(void) draw:(const CVTimeStamp *)outputTime{
	if([drawButton state] == NSOnState){
		ofSetColor(255, 255, 255);
		CameraCalibrationObject * obj = [cameraCalibrations objectAtIndex:[cameraSelector selectedSegment]];
		
		
		[obj applyWarp];
		[GetPlugin(Lenses) getUndistortedImageFromCameraId:[cameraSelector selectedSegment]]->draw(0,0,1,1);
		glPopMatrix();
		
		
		[GetPlugin(ProjectionSurfaces) apply:"Front" surface:"Floor"];
		ofFill();
		for(int i=0;i<4;i++){
			ofSetColor(0, 0,0);
			ofEllipse([obj calibPoints][i]->x*[obj surface]->aspect, [obj calibPoints][i]->y, 0.05, 0.05);
			
			ofSetColor(255, 255,255);
			ofEllipse([obj calibPoints][i]->x*[obj surface]->aspect, [obj calibPoints][i]->y, 0.03, 0.03);
		}
		glPopMatrix();
	}
}

-(void) controlMousePressed:(float)x y:(float)y button:(int)button{
	ofxVec2f curMouse = [self convertMousePoint:ofxPoint2f(x,y)];
	CameraCalibrationObject * obj = [cameraCalibrations objectAtIndex:[cameraSelector selectedSegment]];
	selectedCorner = obj->warp->GetClosestCorner(curMouse.x, curMouse.y);

	if([obj calibHandles][selectedCorner]->distance(ofxPoint2f(curMouse.x, curMouse.y)) > 0.3){
		selectedCorner = -1;
	} else {
		//		[[self getCurrentSurface] setCorner:selectedCorner x:[self getCurrentSurface]->corners[selectedCorner]->x y:[self getCurrentSurface]->corners[selectedCorner]->y projector:[projectorsButton indexOfSelectedItem] surface:[surfacesButton indexOfSelectedItem] storeUndo:true];	
	}
		cout<<"Selected corner"<<selectedCorner<<endl;
	lastMousePos->x = curMouse.x;	
	lastMousePos->y = curMouse.y;	
}
-(void) controlMouseDragged:(float)x y:(float)y button:(int)button{
	CameraCalibrationObject * obj = [cameraCalibrations objectAtIndex:[cameraSelector selectedSegment]];
	
	ofxVec2f curMouse = [self convertMousePoint:ofxPoint2f(x,y)];
	ofxVec2f newPos =  obj->warp->corners[selectedCorner] + (curMouse-*lastMousePos);
	if(selectedCorner != -1){
		[obj calibHandles][selectedCorner] = new ofxPoint2f(newPos);
	} else {		
		//*position += (curMouse- ((ofxPoint2f)*lastMousePos));
	}
	cout<<newPos.x<<endl;
	lastMousePos->x = curMouse.x;	
	lastMousePos->y = curMouse.y;	
	
	[obj recalculate];
}

-(void) controlMouseReleased:(float)x y:(float)y{
	/*	if(selectedCorner != -1){
	 [[self getCurrentSurface] setCorner:selectedCorner x:[self getCurrentSurface]->corners[selectedCorner]->x y:[self getCurrentSurface]->corners[selectedCorner]->y projector:[projectorsButton indexOfSelectedItem] surface:[surfacesButton indexOfSelectedItem] storeUndo:true];		
	 }*/
}

-(ofxPoint2f) convertMousePoint:(ofxPoint2f)p{
	CameraCalibrationObject * obj = [cameraCalibrations objectAtIndex:[cameraSelector selectedSegment]];
	
	ofxPoint2f p2 = ofxPoint2f(p.x, p.y);
	float projWidth = 1024;
	float projHeight = 768;	
	float aspect =(float)  projHeight/projWidth;
	//float viewAspect = [obj surface]->aspect;
	
	//p2-= ofxPoint2f(w/2.0, h/2.0);	
	//p2 -= *position;
	/*if(viewAspect > aspect){
	 p2 /= ofxPoint2f(w,w);
	 } else {
	 p2 /= ofxPoint2f((float)h/aspect,(float)h/aspect);
	 }
	 */
	//p2 /= ofxPoint2f((float)scale,(float)scale);
/*	p2 -= ofxPoint2f(-0.5, -aspect/2.0);
	p2 /= ofxPoint2f((float)1.0,(float)aspect);*/
	p2.x /= 640.0;
	p2.y /= 480.0;
	return p2;
	//	glTranslated(-projWidth/2.0, -projHeight/2.0, 0);
 	
}

-(IBAction) reset:(id)sender{
	[[cameraCalibrations objectAtIndex:[cameraSelector selectedSegment]] reset];;
}


@end



@implementation CameraCalibrationObject
@synthesize name, surface;
-(id) init{
	if([super init]){
		warp = new Warp();
		coordWarp = new coordWarping;	
		coordWarpCalibration = new coordWarping;
	}
	return self;
}

-(ofxPoint2f **) calibHandles{
	return calibHandles;
}
-(ofxPoint2f **) calibPoints{
	return calibPoints;
}

-(void) recalculate{
	ofxPoint2f a[4];
	a[0] = ofxPoint2f(0,0);
	a[1] = ofxPoint2f(1,0);
	a[2] = ofxPoint2f(1,1);
	a[3] = ofxPoint2f(0,1);
	
	coordWarpCalibration->calculateMatrix(*calibHandles, *calibPoints);	
	
	ofxPoint2f corners[4];
	for(int u=0;u<4;u++){
		corners[u] = coordWarpCalibration->transform(a[u].x, a[u].y);
		warp->SetCorner(u,corners[u].x,corners[u].y);
	}
	
	warp->MatrixCalculate();
	coordWarp->calculateMatrix(a, warp->corners);		
	
}

-(void) applyWarp{
	glPushMatrix();
	warp->MatrixMultiply();	
}


-(void) reset{
	int choice = NSAlertDefaultReturn;
	NSString *title = [NSString stringWithFormat:NSLocalizedString(@"Do you want to reset the Calibration?", @"Title of alert panel which comes up when user chooses Quit")];
	choice = NSRunAlertPanel(title, 
							 NSLocalizedString(@"Resetting is not undoable\n\nIf you reset the calibration you will have to put four suitable calibration objects on the stage floor again.", @"Warning in the alert panel which comes up when user chooses Quit and there are unsaved documents."), 
							 NSLocalizedString(@"Reset", @"Choice (on a button) given to user which allows him/her to quit the application even though there are unsaved documents."),
							 NSLocalizedString(@"Cancel", @"Choice (on a button) given to user which allows him/her to review all unsaved documents if he/she quits the application without saving them all first."),     // ellipses
							 nil);
	
	if (choice == NSAlertDefaultReturn){           /* Cancel */
		calibHandles[0] = new ofxPoint2f(0.0,0.0);
		calibHandles[1] = new ofxPoint2f(1,0);
		calibHandles[2] = new ofxPoint2f(1,1);
		calibHandles[3] = new ofxPoint2f(0,1);
		[self recalculate];
	}
}

@end



/**
 CameraCalibration::CameraCalibration(){
 type = DATA;
 
 for(int i=0;i<3;i++){
 cameras.push_back(new CameraCalibrationObject);
 cameras[i]->warp = new Warp();
 cameras[i]->coordWarp = new coordWarping;
 cameras[i]->coordWarpCalibration = new coordWarping;
 cameras[i]->name = "CAMERA "+ofToString(i, 0);
 }
 
 drawDebug = false;
 selectedCorner = 0;
 selectedKeystoner = 0;
 offset = 0;
 
 
 
 }
 
 void CameraCalibration::guiWakeup(){
 ofAddListener(glDelegate->mousePressed,this, &CameraCalibration::mousePressed);
 ofAddListener(glDelegate->mouseDragged,this, &CameraCalibration::mouseDragged);
 ofAddListener(glDelegate->keyPressed,this, &CameraCalibration::keyPressed);
 
 w = 640;
 h = 480;
 }
 
 
 void CameraCalibration::setup(){
 verdana.loadFont("verdana.ttf",40);
 
 keystoneXml = new ofxXmlSettings;
 keystoneXml->loadFile("keystoneSettings.xml");
 int numFloor = keystoneXml->getNumTags("cameras");
 if(numFloor != 1){
 cout<<"====== ERROR: No cameras in keystone xml ======"<<endl;
 } else {
 
 keystoneXml->pushTag("cameras", 0);
 for(int u=0;u<3;u++){
 keystoneXml->pushTag("camera", u);
 int numCorners = keystoneXml->getNumTags("corner");
 if(numCorners != 4){
 } else {
 for(int i=0;i<4;i++){
 //cameras[u]->warp->SetCorner( keystoneXml->getAttribute("corner", "number", 0, i) ,  keystoneXml->getAttribute("corner", "x", 0.0, i),  keystoneXml->getAttribute("corner", "y", 0.0, i));
 cameras[u]->calibHandles[i] = ofxPoint2f(keystoneXml->getAttribute("corner", "x", 0.0, i),  keystoneXml->getAttribute("corner", "y", 0.0, i));
 }
 }
 keystoneXml->popTag();			
 }
 keystoneXml->popTag();
 
 }
 
 cameras[0]->calibPoints[0] = projection()->getFloor()->coordWarp->transform(0.2,0.2);
 cameras[0]->calibPoints[1] = projection()->getFloor()->coordWarp->transform(0.8,0.2);
 cameras[0]->calibPoints[2] = projection()->getFloor()->coordWarp->transform(0.8,0.8);
 cameras[0]->calibPoints[3] = projection()->getFloor()->coordWarp->transform(0.2,0.8);
 
 
 cameras[1]->calibPoints[0] = projection()->getFloor()->coordWarp->transform(0.35,0.4);
 cameras[1]->calibPoints[1] = projection()->getFloor()->coordWarp->transform(0.7,0.4);
 cameras[1]->calibPoints[2] = projection()->getFloor()->coordWarp->transform(0.7,0.7);
 cameras[1]->calibPoints[3] = projection()->getFloor()->coordWarp->transform(0.35,0.7);
 
 cameras[2]->calibPoints[0] = projection()->getWall()->coordWarp->transform(0.0,0.0);
 cameras[2]->calibPoints[1] = projection()->getWall()->coordWarp->transform(1,0);
 cameras[2]->calibPoints[2] = projection()->getWall()->coordWarp->transform(1,1);
 cameras[2]->calibPoints[3] = projection()->getWall()->coordWarp->transform(0,1);
 
 reCalibrate();
 
 }
 
 void CameraCalibration::reCalibrate(){
 for(int i=0;i<3;i++){
 ofxPoint2f a[4];
 a[0] = ofxPoint2f(0,0);
 a[1] = ofxPoint2f(1,0);
 a[2] = ofxPoint2f(1,1);
 a[3] = ofxPoint2f(0,1);
 
 cameras[i]->coordWarpCalibration->calculateMatrix(cameras[i]->calibHandles, cameras[i]->calibPoints);	
 
 ofxPoint2f corners[4];
 for(int u=0;u<4;u++){
 corners[u] = cameras[i]->coordWarpCalibration->transform(a[u].x, a[u].y);
 cameras[i]->warp->SetCorner(u,corners[u].x,corners[u].y);
 }
 
 cameras[i]->warp->MatrixCalculate();
 cameras[i]->coordWarp->calculateMatrix(a, cameras[i]->warp->corners);		
 }
 
 }
 void CameraCalibration::update(){
 
 }
 
 void CameraCalibration::drawOnFloor(){
 }
 void CameraCalibration::draw(){
 ofDisableAlphaBlending();
 if(drawDebug){
 ofSetColor(255, 255, 255, 255);
 glPushMatrix();
 applyWarp(selectedKeystoner);
 getPlugin<Cameras*>(controller)->draw(selectedKeystoner,0,0,1,1);
 glPopMatrix();
 
 ofFill();
 ofSetColor(255, 0, 0);
 
 for(int i=0;i<4;i++){
 ofEllipse(ofGetWidth()*cameras[selectedKeystoner]->calibPoints[i].x, ofGetHeight()*cameras[selectedKeystoner]->calibPoints[i].y, 5, 5);			
 }
 
 }
 
 
 
 }
 
 void CameraCalibration::drawSettings(){
 ofPushStyle();
 
 ofFill();
 
 glPushMatrix();
 //	glTranslated(offset, offset, 0);
 glPushMatrix();
 
 ofSetColor(255, 255, 255, 255);
 glPushMatrix();
 //applyWarp(selectedKeystoner,w,h);
 getPlugin<Cameras*>(controller)->draw(selectedKeystoner,0,0,w,h);
 glPopMatrix();
 glPopMatrix();
 
 for(int i=0;i<4;i++){
 ofSetColor(255,0, 0,255);
 if(selectedCorner == i){
 ofSetColor(255,255, 0,255);
 }
 //	ofxVec2f v = cameras[selectedKeystoner]->warp->corners[i];
 //
 ofxPoint2f p = cameras[selectedKeystoner]->calibHandles[i];
 
 //ofEllipse(p.x*w, p.y*h, 10, 10);
 }		
 
 
 ofNoFill();
 ofSetLineWidth(2);
 for(int i=0;i<4;i++){
 ofSetColor(255, 0, 0, 225);
 ofEllipse(cameras[selectedKeystoner]->calibHandles[i].x*w, cameras[selectedKeystoner]->calibHandles[i].y*h, 15, 15);
 }
 ofFill();
 
 
 ofPopStyle();
 
 }
 
 void CameraCalibration::mousePressed(ofMouseEventArgs & args){
 ofxVec2f curMouse = ofxVec2f((float)(glDelegate->mouseX-offset)/w, (float)(glDelegate->mouseY-offset)/h);
 ofxPoint2f m = ofxPoint2f(curMouse.x, curMouse.y);
 //selectedCorner = cameras[selectedKeystoner]->warp->GetClosestCorner(curMouse.x, curMouse.y);'
 float closestDist = -1;
 for(int i=0;i<4;i++){
 if(cameras[selectedKeystoner]->calibHandles[i].distance(m) < closestDist || closestDist == -1){
 closestDist = cameras[selectedKeystoner]->calibHandles[i].distance(m);
 selectedCorner = i;
 }
 }
 lastMousePos = curMouse;
 }
 
 void CameraCalibration::mouseDragged(ofMouseEventArgs & args){
 ofxVec2f curMouse = ofxVec2f((float)(glDelegate->mouseX-offset)/w, (float)(glDelegate->mouseY-offset)/h);
 ofxVec2f newPos =  cameras[selectedKeystoner]->calibHandles[selectedCorner] + (curMouse-lastMousePos);
 cameras[selectedKeystoner]->calibHandles[selectedCorner] = newPos;
 lastMousePos = curMouse;
 reCalibrate();
 saveXml();
 }
 
 void CameraCalibration::keyPressed(ofKeyEventArgs & args){
 ofxVec2f newPos =  cameras[selectedKeystoner]->warp->corners[selectedCorner] ;
 
 if(args.key == 63233){
 newPos -= ofxVec2f(0,-0.001);
 }
 if(args.key == 63232){
 newPos += ofxVec2f(0,-0.001);
 }
 if(args.key == 63234){
 newPos += ofxVec2f(-0.001,0);
 }
 if(args.key == 63235){
 newPos -= ofxVec2f(-0.001,0);
 }
 
 reCalibrate();
 
 saveXml();
 }
 
 void CameraCalibration::saveXml(){
 
 keystoneXml->pushTag("cameras", 0);
 for(int u=0;u<3;u++){
 keystoneXml->pushTag("camera", u);
 
 int numCorners = keystoneXml->getNumTags("corner");
 if(numCorners != 4){
 cout<<"====== ERROR: Wrong number of corners ======"<<endl; 
 } else {
 for(int i=0;i<4;i++){
 keystoneXml->setAttribute("corner", "number", i, i);
 keystoneXml->setAttribute("corner", "x", cameras[u]->calibHandles[i].x, i);
 keystoneXml->setAttribute("corner", "y", cameras[u]->calibHandles[i].y, i);
 
 }
 }
 keystoneXml->popTag();
 
 }
 keystoneXml->popTag();
 
 keystoneXml->saveFile("keystoneSettings.xml");
 
 
 }
 
 void CameraCalibration::applyWarp(int cam, float _w, float _h){
 glPushMatrix();
 float setW = 1.0;
 float setH = 1.0;
 
 glScaled(_w, _h, 1.0);
 cameras[cam]->warp->MatrixMultiply();
 glScaled(setW, setH, 1.0);
 }
 
 ofxVec2f CameraCalibration::convertCoordinate(int cam, float x, float y){
 ofxVec2f v;
 ofxPoint2f p = cameras[cam]->coordWarp->transform(x,y);
 v.x = p.x;
 v.y = p.y;
 return v;
 }
 
 */