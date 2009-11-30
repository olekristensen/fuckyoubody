/*
 *  Camera.mm
 *  openFrameworks
 *
 *  Created by Fuck You Buddy on 23/11/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#import "PluginIncludes.h"

@implementation Cameras
@synthesize c;

-(void) awakeFromNib{
	[super awakeFromNib];
}

-(void) initPlugin{
	
	c = new FrostCameras();
	cameraSetupCalled = false;

}


-(IBAction) pressButton:(id)sender{
	NSLog(@"Button pressed");
}

-(void) setup{
	

	cameraThreadTimer = -500;
	camera_state = camera_state_running;
	numCameras = 3;
	c->setup();
	
	cameraSetupCalled = true;
	
}

-(void) update:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)timeStamp{
	
	if(cameraSetupCalled){
		if(camera_state == camera_state_closing){
			
			if(cameraTimer == 0){
				cout<<endl<<"ERROR: DEAD CAMERA"<<endl;
				
				for(int i=0;i<3;i++){
					cameraBrightness[i] = c->cameraBrightness[i];
					cameraExposure[i] = c->cameraExposure[i];
					cameraShutter[i] = c->cameraShutter[i];
					cameraGamma[i] = c->cameraGamma[i];
					cameraGain[i] = c->cameraGain[i];
				}
				
				delete c;
				
				cameraTimer = ofGetElapsedTimeMillis();
			}
			
			if (ofGetElapsedTimeMillis() - cameraTimer > 500) {
				camera_state = camera_state_starting;
				cameraTimer = 0;
			}
		}
		if (camera_state == camera_state_starting) {
			if(cameraTimer == 0){
				c = new FrostCameras();
				c->setGUIDs(cameraGUIDs[0], cameraGUIDs[1], cameraGUIDs[2]);
				
				for(int i=0;i<3;i++){
					c->cameraBrightness[i] = cameraBrightness[i];
					c->cameraExposure[i] = cameraExposure[i];
					c->cameraShutter[i] = cameraShutter[i];
					c->cameraGamma[i] = cameraGamma[i];
					c->cameraGain[i] = cameraGain[i];
				}
				
				c->setup();
				//	cout<<"GUIDS: "<<cameraGUIDs[0]<<"  "<<cameraGUIDs[1]<<"  "<<cameraGUIDs[2]<<endl;
				cameraTimer = ofGetElapsedTimeMillis();
			}			
			if (ofGetElapsedTimeMillis() - cameraTimer > 3000) {
				c->update();
				cameraThreadTimer = 0;
				camera_state = camera_state_running;
				cameraTimer = 0;
			}
		}
		
		if (camera_state == camera_state_running) {
			for(int i=0;i<3;i++){
				if(c->isRunning(i)){
					ofLog(OF_LOG_NOTICE, "Camera " + ofToString(i, 0) + " is running");
					if(((Libdc1394Grabber*) c->getVidGrabber(i)->videoGrabber)->lock()){
						ofLog(OF_LOG_NOTICE, "Got lock on Camera " + ofToString(i, 0));
						if(((Libdc1394Grabber*) c->getVidGrabber(i)->videoGrabber)->blinkCounter != cameraLastBlinkCount[i]){
							cameraThreadTimer = 0;
						} else {
							cameraThreadTimer ++;
						}
						cameraLastBlinkCount[i] = ((Libdc1394Grabber*) c->getVidGrabber(i)->videoGrabber)->blinkCounter;
						((Libdc1394Grabber*) c->getVidGrabber(i)->videoGrabber)->unlock();
					}
				} else {
					//	ofLog(OF_LOG_WARNING, "Camera " + ofToString(i, 0) + " is NOT running");
					if(c->hasCameras){
						cameraThreadTimer ++;
					}
				}
			}
			if(cameraThreadTimer > 150){
				camera_state = camera_state_closing;
				cameraTimer = 0;
			}
			ofLog(OF_LOG_NOTICE, "Camera Thread Timer " + ofToString(cameraThreadTimer, 0) );
		}
	}
}

-(void) controlSetup{
	
	lucidaGrande = new ofTrueTypeFont();

}


-(void) controlDraw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)timeStamp{
	
	lucidaGrande->loadFont("LucidaGrande.ttc",20, true, true, false);

	float viewWidth = [controlGlView convertSizeToBase: [controlGlView bounds].size].width;
	float viewHeight = [controlGlView convertSizeToBase: [controlGlView bounds].size].height;
	
	ofFill();
	ofSetColor(164,164, 164);
	ofRect(0, 0, viewWidth , viewHeight);
	ofSetColor(196, 196, 100);
	for (float i = 0.0; i < viewWidth+viewHeight; i+=20.0) {
		ofBeginShape();
		ofVertex(i,0);
		ofVertex(i+10, 0);
		ofVertex((i-viewHeight)+11.0, viewHeight);
		ofVertex(i-viewHeight+1, viewHeight);
		ofEndShape(true);
	}
	
	if (c != NULL) {
		
		for (int i=0; i<3; i++) {
			if(c->isRunning(i)){
				ofSetColor(255,255, 255);
				c->getVidGrabber(i)->draw((viewWidth/3.0)*i,0,viewWidth/3.0,viewHeight);
				if(((Libdc1394Grabber*) c->getVidGrabber(i)->videoGrabber)->lock()){
					if(((Libdc1394Grabber*) c->getVidGrabber(i)->videoGrabber)->blinkCounter % 50 < 25){
						ofSetColor(255, 0, 0);
						ofEllipse((viewWidth/3.0)*i+10, 10, 10, 10);
					}
					((Libdc1394Grabber*) c->getVidGrabber(i)->videoGrabber)->unlock();
				}
			} else {
				ofEnableAlphaBlending();
				ofSetColor(255,255,255,(((sinf(ofGetElapsedTimef()*5.0)/2.0)+0.5)*255));
				lucidaGrande->drawString("camera offline",(45+((viewWidth/3.0)*i)),(viewHeight/2)+10);
			}
		}
		
	}
	
	
	
}

-(void) draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)timeStamp{
	
}
@end
