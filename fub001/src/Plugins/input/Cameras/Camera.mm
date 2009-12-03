//
//  Camera.mm
//  openFrameworks
//
//  Created by Jonas Jongejan on 02/12/09.
//  Copyright 2009 HalfdanJ. All rights reserved.
//

#import "Camera.h"


@implementation Camera
@synthesize settingsView, mytimeNow, mytimeThen, width, height;


-(void) setup:(int)camNumber{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(aWillTerminate:)
												 name:NSApplicationWillTerminateNotification object:nil];
	
//	width = 1280/2;
//	height = 960/2;

	width = 640;
	height = 480;

	myframes = 0;
	ofSetLogLevel(OF_LOG_NOTICE);
	videoGrabber = new Libdc1394Grabber;
	videoGrabber->setFormat7(VID_FORMAT7_1);
	videoGrabber->listDevices();
	videoGrabber->setDiscardFrames(true);
	videoGrabber->set1394bMode(true);
	
	videoGrabber->setDeviceID(camNumber);	
	camInited = videoGrabber->init(width, height, VID_FORMAT_Y8, VID_FORMAT_GREYSCALE, 50, true);
		
	tex = new ofTexture();
	tex->allocate(width,height,GL_LUMINANCE);
	pixels = new unsigned char[width * height * 3];
	memset(pixels, 0, width*height*3);
	tex->loadData(pixels, width, height, GL_LUMINANCE);	
		
	if(camInited){		
		//Set all on manual
		videoGrabber->setFeatureMode(FEATURE_MODE_MANUAL, FEATURE_SHUTTER);
		videoGrabber->setFeatureMode(FEATURE_MODE_MANUAL, FEATURE_EXPOSURE);		
		videoGrabber->setFeatureMode(FEATURE_MODE_MANUAL, FEATURE_GAIN);		
		videoGrabber->setFeatureMode(FEATURE_MODE_MANUAL, FEATURE_GAMMA);				
		videoGrabber->setFeatureMode(FEATURE_MODE_MANUAL, FEATURE_BRIGHTNESS);		
		
		//Set sliders
		videoGrabber->getAllFeatureValues();
		[guidTextField setStringValue:[NSString stringWithFormat:@"%llx",videoGrabber->cameraGUID]];
		for(int i=0;i<videoGrabber->availableFeatureAmount;i++){
			if(videoGrabber->featureVals[i].feature == FEATURE_SHUTTER){
				[shutterSlider setFloatValue:videoGrabber->featureVals[i].currVal];			
			}
			if(videoGrabber->featureVals[i].feature == FEATURE_EXPOSURE){
				[exposureSlider setFloatValue:videoGrabber->featureVals[i].currVal];			
			}
			if(videoGrabber->featureVals[i].feature == FEATURE_GAIN){
				[gainSlider setFloatValue:videoGrabber->featureVals[i].currVal];			
			}
			if(videoGrabber->featureVals[i].feature == FEATURE_GAMMA){
				[gammaSlider setFloatValue:videoGrabber->featureVals[i].currVal];			
			}
			if(videoGrabber->featureVals[i].feature == FEATURE_BRIGHTNESS){
				[brightnessSlider setFloatValue:videoGrabber->featureVals[i].currVal];			
			}
			
		}
		
	}
}

-(void) update{
	if(camInited){
	bIsFrameNew = videoGrabber->grabFrame(&pixels);
	if(bIsFrameNew) {
		tex->loadData(pixels, width, height, GL_LUMINANCE);
		mytimeNow = ofGetElapsedTimef();
		if( (mytimeNow-mytimeThen) > 0.05f || myframes == 0 ) {
			myfps = myframes / (mytimeNow-mytimeThen);
			mytimeThen = mytimeNow;
			myframes = 0;
			frameRate = 0.5f * frameRate + 0.5f * myfps;
		}
		myframes++;
		
	}
	}
}

-(void) aWillTerminate:(NSNotification *)notification {
/*	videoGrabber->lock();	
	videoGrabber->stopThread();
	videoGrabber->unlock();
	ofSleepMillis(2000);	*/
	videoGrabber->close();
	camInited = false;
	delete videoGrabber;
}

-(ofTexture*) getTexture{
	return tex;
}

- (BOOL) loadNibFile {	
	if (![NSBundle loadNibNamed:@"Camera"  owner:self]){
		NSLog(@"Warning! Could not load the nib for camera ");
		return NO;
	}
	return YES;
}

-(IBAction) setShutter:(id)sender{
	videoGrabber->setFeatureValue([sender floatValue], FEATURE_SHUTTER);
}
-(IBAction) setExposure:(id)sender{
	videoGrabber->setFeatureValue([sender floatValue], FEATURE_EXPOSURE);	
}
-(IBAction) setGain:(id)sender{
	videoGrabber->setFeatureValue([sender floatValue], FEATURE_GAIN);
}
-(IBAction) setGamma:(id)sender{
	videoGrabber->setFeatureValue([sender floatValue], FEATURE_GAMMA);
}
-(IBAction) setBrightness:(id)sender{
	videoGrabber->setFeatureValue([sender floatValue], FEATURE_BRIGHTNESS);
}

-(float) framerate{
	return frameRate;	
}

@end
