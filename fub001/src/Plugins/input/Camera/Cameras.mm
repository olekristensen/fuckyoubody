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
	
	userDefaults = [[NSUserDefaults standardUserDefaults] retain];
	
	if ([userDefaults stringForKey:@"camera.1.guid"] != nil) {
		sscanf([[userDefaults stringForKey:@"camera.1.guid"] cStringUsingEncoding:NSUTF8StringEncoding], "%llx", &cameraGUIDs[0]);
	}
	
	if ([userDefaults stringForKey:@"camera.2.guid"] != nil) {
		sscanf([[userDefaults stringForKey:@"camera.2.guid"] cStringUsingEncoding:NSUTF8StringEncoding], "%llx", &cameraGUIDs[1]);
	}
	
	if ([userDefaults stringForKey:@"camera.3.guid"] != nil) {
		sscanf([[userDefaults stringForKey:@"camera.3.guid"] cStringUsingEncoding:NSUTF8StringEncoding], "%llx", &cameraGUIDs[2]);
	}
	
	
	
	[self cameraUpdateGUIDs];
	
}


-(IBAction) pressButton:(id)sender{
	NSLog(@"Button pressed");
}

-(void) setup{
	
	
	lucidaGrande = new ofTrueTypeFont();
	lucidaGrande->loadFont("LucidaGrande.ttc",24, true, true, false);
	c->setup();
	c->setGUIDs(cameraGUIDs[0], cameraGUIDs[1], cameraGUIDs[2]);
	
	cameraThreadTimer = -500;
	camera_state = camera_state_running;
	numCameras = 3;
	cameraSetupCalled = true;

}

-(void) update{
	
	if(cameraSetupCalled){
		
		if(camera_state == camera_state_closing){
			
			if(cameraTimer == 0){
				cout<<endl<<"ERROR: DEAD CAMERA"<<endl;
				
				[cameraShutter1 setFloatValue:c->cameraShutter[0]]; 
				[cameraExposure1 setFloatValue:c->cameraExposure[0]]; 
				[cameraGain1 setFloatValue:c->cameraGain[0]]; 
				[cameraGamma1 setFloatValue:c->cameraGamma[0]];
				[cameraBrightness1 setFloatValue:c->cameraBrightness[0]];
				
				[cameraShutter2 setFloatValue:c->cameraShutter[1]]; 
				[cameraExposure2 setFloatValue:c->cameraExposure[1]]; 
				[cameraGain2 setFloatValue:c->cameraGain[1]]; 
				[cameraGamma2 setFloatValue:c->cameraGamma[1]];
				[cameraBrightness2 setFloatValue:c->cameraBrightness[1]];
				
				[cameraShutter3 setFloatValue:c->cameraShutter[2]]; 
				[cameraExposure3 setFloatValue:c->cameraExposure[2]]; 
				[cameraGain3 setFloatValue:c->cameraGain[2]]; 
				[cameraGamma3 setFloatValue:c->cameraGamma[2]];
				[cameraBrightness3 setFloatValue:c->cameraBrightness[2]];
				
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
				
				c->cameraShutter[0] = [cameraShutter1 floatValue]; 
				c->cameraExposure[0] = [cameraExposure1 floatValue]; 
				c->cameraGain[0] = [cameraGain1 floatValue]; 
				c->cameraGamma[0] = [cameraGamma1 floatValue]; 
				c->cameraBrightness[0] = [cameraBrightness1 floatValue]; 
				
				c->cameraShutter[1] = [cameraShutter2 floatValue]; 
				c->cameraExposure[1] = [cameraExposure2 floatValue]; 
				c->cameraGain[1] = [cameraGain2 floatValue]; 
				c->cameraGamma[1] = [cameraGamma2 floatValue]; 
				c->cameraBrightness[1] = [cameraBrightness2 floatValue]; 
				
				c->cameraShutter[2] = [cameraShutter3 floatValue]; 
				c->cameraExposure[2] = [cameraExposure3 floatValue]; 
				c->cameraGain[2] = [cameraGain3 floatValue]; 
				c->cameraGamma[2] = [cameraGamma3 floatValue]; 
				c->cameraBrightness[2] = [cameraBrightness3 floatValue]; 
				
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
						if(i==0)
							[[controller cameraFps1] setFloatValue:c->getVidGrabber(i)->fps];
						if(i==1)
							[[controller cameraFps2] setFloatValue:c->getVidGrabber(i)->fps];
						if(i==2)
							[[controller cameraFps3] setFloatValue:c->getVidGrabber(i)->fps];
						
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

 -(void) controlDraw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)timeStamp{

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

-(IBAction)		cameraBindGuid1:(id)sender{
	uint64_t guidVal;
	sscanf([[CameraGUID1 stringValue] cStringUsingEncoding:NSUTF8StringEncoding], "%llx", &guidVal);
	c->setGUID(0, (uint64_t)guidVal);
	cameraGUIDs[0] = (uint64_t)guidVal;
	[self cameraUpdateGUIDs];
}

-(IBAction)		cameraBindGuid2:(id)sender{
	uint64_t guidVal;
	sscanf([[CameraGUID2 stringValue] cStringUsingEncoding:NSUTF8StringEncoding], "%llx", &guidVal);
	c->setGUID(1, (uint64_t)guidVal);
	cameraGUIDs[1] = (uint64_t)guidVal;
	[self cameraUpdateGUIDs];
}

-(IBAction)	cameraBindGuid3:(id)sender{
	uint64_t guidVal;
	sscanf([[CameraGUID3 stringValue] cStringUsingEncoding:NSUTF8StringEncoding], "%llx", &guidVal);
	c->setGUID(2, (uint64_t)guidVal);
	cameraGUIDs[2] = (uint64_t)guidVal;
	[self cameraUpdateGUIDs];
}


-(void) cameraUpdateGUIDs{
	if(c->getGUID(0) != 0x0ll){
		[CameraGUID1 setStringValue:[NSString stringWithFormat:@"%llx",c->getGUID(0)]];
	}
	if(c->getGUID(1) != 0x0ll){
		[CameraGUID2 setStringValue:[NSString stringWithFormat:@"%llx",c->getGUID(1)]];
	}
	if(c->getGUID(2) != 0x0ll){
		[CameraGUID3 setStringValue:[NSString stringWithFormat:@"%llx",c->getGUID(2)]];
	}
}


@end