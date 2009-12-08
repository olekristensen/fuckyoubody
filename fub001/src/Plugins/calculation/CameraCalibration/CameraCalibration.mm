#include "CameraCalibration.h"


@implementation CameraCalibration


@end



@implementation CameraCalibrationObject


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