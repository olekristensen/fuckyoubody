
#include "CameraCalibration.h"
#include "Lenses.h"
#include "Cameras.h"

@implementation CameraCalibration
@synthesize cameraCalibrations;
-(void) initPlugin{
	cameraCalibrations = [[NSMutableArray array] retain];
	lastMousePos = new ofxVec2f();
	userDefaults = [[NSUserDefaults standardUserDefaults] retain];
}

-(void) setup{
	for(int i=0;i<3;i++){
		CameraCalibrationObject * obj = [[[CameraCalibrationObject alloc] init] retain];		
		[obj setName:[NSString stringWithFormat:@"CAMERA%d",i]];
		
		if(i==0){
			[obj setSurface:[GetPlugin(ProjectionSurfaces) getProjectionSurfaceByName:"Front" surface:"Floor"]];
			[obj calibPoints][0] = ofxPoint2f(0.2,0.2);
			[obj calibPoints][1] = ofxPoint2f(0.8,0.2);
			[obj calibPoints][2] = ofxPoint2f(0.8,0.8);
			[obj calibPoints][3] = ofxPoint2f(0.2,0.8);
		}
		
		if(i==1){
			[obj setSurface:[GetPlugin(ProjectionSurfaces) getProjectionSurfaceByName:"Front" surface:"Floor"]];
			[obj calibPoints][0] = ofxPoint2f(0.2,0.2);
			[obj calibPoints][1] = ofxPoint2f(0.8,0.2);
			[obj calibPoints][2] = ofxPoint2f(0.8,0.8);
			[obj calibPoints][3] = ofxPoint2f(0.2,0.8);
		}
		
		if(i==2){
			[obj setSurface:[GetPlugin(ProjectionSurfaces) getProjectionSurfaceByName:"Front" surface:"Floor"]];
			[obj calibPoints][0] = ofxPoint2f(0,0);
			[obj calibPoints][1] = ofxPoint2f(1,0);
			[obj calibPoints][2] = ofxPoint2f(1,1);
			[obj calibPoints][3] = ofxPoint2f(0,1);
		}
		
		for(int u=0;u<4;u++){
			[obj calibHandles][u].x = [userDefaults doubleForKey:[NSString stringWithFormat:@"camera%d.corner%d.x",i, u]];
			[obj calibHandles][u].y = [userDefaults doubleForKey:[NSString stringWithFormat:@"camera%d.corner%d.y",i, u]];			
		}
		
		[obj recalculate];

		
		[cameraCalibrations addObject:obj];
		
	}	
	
	font = new ofTrueTypeFont();
	font->loadFont("LucidaGrande.ttc",20, true, true, true);	
}


-(void) controlDraw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)timeStamp{
	int w = 640;
	int h = 480;
	//	[[GetPlugin(Cameras) getCameraWithId:[cameraSelector selectedSegment]] getTexture]->draw(0,0,ofGetWidth(),ofGetHeight());
	CameraCalibrationObject * obj = [cameraCalibrations objectAtIndex:[cameraSelector selectedSegment]];
	
	ofSetColor(255, 255, 255);
	[GetPlugin(Lenses) getUndistortedImageFromCameraId:[cameraSelector selectedSegment]]->draw(0,0,640,480);
	ofEnableAlphaBlending();
	
	if(	![GetPlugin(Lenses) isCalibratedFromCameraId:[cameraSelector selectedSegment]]){
		ofNoFill();
		ofSetColor(0, 0,0,128);
		ofSetLineWidth(6);
		font->drawStringAsShapes("Uncalibrated Lens", (w - font->stringWidth("Uncalibrated Lens"))/2.0, (h - font->stringHeight("Uncalibrated Lens"))/2.0);
		ofSetColor(0, 0,0,208);
		ofSetLineWidth(3);
		font->drawStringAsShapes("Uncalibrated Lens", (w - font->stringWidth("Uncalibrated Lens"))/2.0, (h - font->stringHeight("Uncalibrated Lens"))/2.0);
		ofFill();
		ofSetColor(255, 255,255,64+(128*(1.0-fmodf(timeInterval/2.0,1.0))));
		font->drawStringAsShapes("Uncalibrated Lens", (w - font->stringWidth("Uncalibrated Lens"))/2.0, (h - font->stringHeight("Uncalibrated Lens"))/2.0);
	}
	
	for(int i=0;i<4;i++){
		ofNoFill();
		ofSetColor(0, 0,0,192);
		ofSetLineWidth(2);
		ofEllipse([obj calibHandles][i].x*w, [obj calibHandles][i].y*h, 18, 18);
		ofEllipse([obj calibHandles][i].x*w, [obj calibHandles][i].y*h, 22, 22);
		ofSetLineWidth(1.5);

		switch (i) {
			case 0:
				ofSetColor(255,0,0);
				break;
			case 1:
				ofSetColor(255, 0,255);
				break;
			case 2:
				ofSetColor(0, 255,0);
				break;
			case 3:
				ofSetColor(255, 255,0);
				break;
			default:
				break;
		}
		ofEllipse([obj calibHandles][i].x*w, [obj calibHandles][i].y*h, 20, 20);
	}
	
	
}

-(void) draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	if([drawButton state] == NSOnState){
		ofSetColor(255, 255, 255);
		CameraCalibrationObject * obj = [cameraCalibrations objectAtIndex:[cameraSelector selectedSegment]];
		
		[obj applyWarp];
				[GetPlugin(Lenses) getUndistortedImageFromCameraId:[cameraSelector selectedSegment]]->draw(0,0,1,1);
		//[[GetPlugin(Cameras) getCameraWithId:0] getTexture]->draw(0,0,1,1);
		glPopMatrix();
		
		[GetPlugin(ProjectionSurfaces) apply:"Front" surface:"Floor"];
		ofFill();
		for(int i=0;i<4;i++){
			/*ofSetColor(0, 0,0);
			ofEllipse([obj calibPoints][i].x*[obj surface]->aspect, [obj calibPoints][i].y, 0.05, 0.05);
			
			ofSetColor(255, 255,255);
			ofEllipse([obj calibPoints][i].x*[obj surface]->aspect, [obj calibPoints][i].y, 0.04, 0.04);
			ofSetColor(255, 0,0);
			ofEllipse([obj calibPoints][i].x*[obj surface]->aspect, [obj calibPoints][i].y, 0.01, 0.01);*/
			
			ofNoFill();

			switch (i) {
				case 0:
					ofSetColor(255,0,0);
					break;
				case 1:
					ofSetColor(255, 0,255);
					break;
				case 2:
					ofSetColor(0, 255,0);
					break;
				case 3:
					ofSetColor(255, 255,0);
					break;
				default:
					break;
			}
			
			ofSetLineWidth(4);

			ofEllipse([obj calibPoints][i].x*[obj surface]->aspect, [obj calibPoints][i].y, 0.02, 0.02);
			ofSetLineWidth(2);
			ofSetColor(255, 255,255);
			ofEllipse([obj calibPoints][i].x*[obj surface]->aspect, [obj calibPoints][i].y, 0.035, 0.035);

			
			

		}
		glPopMatrix();
	}
}

-(void) controlMousePressed:(float)x y:(float)y button:(int)button{
	ofxVec2f curMouse = [self convertMousePoint:ofxPoint2f(x,y)];
	CameraCalibrationObject * obj = [cameraCalibrations objectAtIndex:[cameraSelector selectedSegment]];
	
	float shortestDist = nil;
	for(int i=0;i<4;i++){
		if(shortestDist == nil || [obj calibHandles][i].distance(curMouse) < shortestDist){
			shortestDist = [obj calibHandles][i].distance(curMouse);
			selectedCorner = i;
		}
	}
	
	
	if([obj calibHandles][selectedCorner].distance(ofxPoint2f(curMouse.x, curMouse.y)) > 0.3){
		selectedCorner = -1;
	} 
	cout<<"Selected corner"<<selectedCorner<<endl;
	lastMousePos->x = curMouse.x;	
	lastMousePos->y = curMouse.y;	
}
-(void) controlMouseDragged:(float)x y:(float)y button:(int)button{
	CameraCalibrationObject * obj = [cameraCalibrations objectAtIndex:[cameraSelector selectedSegment]];
	
	ofxVec2f curMouse = [self convertMousePoint:ofxPoint2f(x,y)];
	ofxVec2f newPos =  [obj calibHandles][selectedCorner] + (curMouse-*lastMousePos);
	if(selectedCorner != -1){
		[obj calibHandles][selectedCorner] = ofxPoint2f(newPos);
		[userDefaults setDouble:newPos.x forKey:[NSString stringWithFormat:@"camera%d.corner%d.x",[cameraSelector selectedSegment], selectedCorner]];
		[userDefaults setDouble:newPos.y forKey:[NSString stringWithFormat:@"camera%d.corner%d.y",[cameraSelector selectedSegment], selectedCorner]];
	} else {		
		//*position += (curMouse- ((ofxPoint2f)*lastMousePos));
	}
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
	
	ofxPoint2f p2 = ofxPoint2f(p);
	p2.x /= 640.0;
	p2.y /= 480.0;
	return p2; 	
}

-(IBAction) reset:(id)sender{
	CameraCalibrationObject * obj = [cameraCalibrations objectAtIndex:[cameraSelector selectedSegment]];
	[obj reset];
	
	for(int i=0;i<4;i++){
		[userDefaults setDouble:obj->calibHandles[i].x forKey:[NSString stringWithFormat:@"camera%d.corner%d.x",[cameraSelector selectedSegment], i]];
		[userDefaults setDouble:obj->calibHandles[i].y forKey:[NSString stringWithFormat:@"camera%d.corner%d.y",[cameraSelector selectedSegment], i]];
	}

}


@end



@implementation CameraCalibrationObject
@synthesize name, surface;
-(id) init{
	if([super init]){
		warp = new Warp();
		coordWarp = new coordWarping;	
		coordWarpCalibration = new coordWarping;
		for(int i=0;i<4;i++){
			calibPoints[i] = ofxPoint2f();
			calibHandles[i] = ofxPoint2f();
		}
	}
	return self;
}

-(ofxPoint2f *) calibHandles{
	return calibHandles;
}
-(ofxPoint2f *) calibPoints{
	return calibPoints;
}

-(void) recalculate{
	ofxPoint2f a[4];
	a[0] = ofxPoint2f(0,0);
	a[1] = ofxPoint2f(1,0);
	a[2] = ofxPoint2f(1,1);
	a[3] = ofxPoint2f(0,1);
	
	ofxPoint2f pts[4];
	ofxPoint2f hndls[4];
	for(int i=0;i<4;i++){
		pts[i] = [GetPlugin(ProjectionSurfaces) convertToProjection:calibPoints[i] surface:surface];
		hndls[i] = calibHandles[i];
		hndls[i].x /= surface->aspect;
	}
	
	coordWarpCalibration->calculateMatrix(hndls, pts);	
	
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
		calibHandles[0] = ofxPoint2f(0.0,0.0);
		calibHandles[1] = ofxPoint2f(1,0);
		calibHandles[2] = ofxPoint2f(1,1);
		calibHandles[3] = ofxPoint2f(0,1);
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