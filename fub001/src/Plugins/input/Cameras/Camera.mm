//
//  Camera.mm
//  openFrameworks
//
//  Created by Jonas Jongejan on 02/12/09.
//  Copyright 2009 HalfdanJ. All rights reserved.
//

#import "Camera.h"


@implementation Camera
@synthesize settingsView, mytimeNow, mytimeThen, width, height, camInited, live, camNumber ;


-(void) setup:(int)_camNumber{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(aWillTerminate:)
												 name:NSApplicationWillTerminateNotification object:nil];
	userDefaults = [[NSUserDefaults standardUserDefaults] retain];
	
	//	width = 1280/2;
	//	height = 960/2;
	
	width = 640;
	height = 480;
	camNumber = _camNumber;
	myframes = 0;
	ofSetLogLevel(OF_LOG_NOTICE);
	videoGrabber = new Libdc1394Grabber;
	videoGrabber->setFormat7(VID_FORMAT7_1);
	videoGrabber->listDevices();
	videoGrabber->setDiscardFrames(true);
	videoGrabber->set1394bMode(true);
	live = YES;
	loadMoviePlease  = NO;
	
	videoGrabber->setDeviceID(camNumber);	
	
	camInited = videoGrabber->init(width, height, VID_FORMAT_Y8, VID_FORMAT_GREYSCALE, 50, true);
	videoPlayer = new videoplayerWrapper();
	videoPlayer->videoPlayer.setUseTexture(false);
	
	movies = [[NSMutableArray array] retain];
	[self updateMovieList];
	millisSinceLastMovieEvent = 0;
	
	tex = new ofTexture();
	tex->allocate(width,height,GL_LUMINANCE);
	pixels = new unsigned char[width * height];
	memset(pixels, 0, width*height);
	tex->loadData(pixels, width, height, GL_LUMINANCE);	
	pthread_mutex_init(&mutex, NULL);
	
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
	
	
	if(![userDefaults boolForKey:[NSString stringWithFormat:@"camera%d.live",[self camNumber]]]){
		live = NO;
		[movieSelector setEnabled:YES];
		[recordButton setEnabled:NO];
		[sourceSelector setSelectedSegment:1];
		[self updateMovieList];
	}
	
	
}

-(void) update{
	if(live){
		if(camInited){
			pthread_mutex_lock(&mutex);
			bIsFrameNew = videoGrabber->grabFrame(&pixels);
			pthread_mutex_unlock(&mutex);
			if(bIsFrameNew) {
				pthread_mutex_lock(&mutex);
				tex->loadData(pixels, width, height, GL_LUMINANCE);
				pthread_mutex_unlock(&mutex);
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
	else {
		if(loadMoviePlease){
			[self loadMovie:loadMovieString];
			loadMoviePlease = NO;
		}
		videoPlayer->videoPlayer.idleMovie();
		if(videoPlayer->videoPlayer.isFrameNew()){
			for(int i=videoPlayer->videoPlayer.width * videoPlayer->videoPlayer.height -1; i >= 0  ; i--){
				pixels[i] = videoPlayer->videoPlayer.pixels[i*3];
			}			
			tex->loadData(pixels, videoPlayer->videoPlayer.width, videoPlayer->videoPlayer.height, GL_LUMINANCE);
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

-(unsigned char*) getPixels{
	return pixels;
}

- (BOOL) loadNibFile {	
	if (![NSBundle loadNibNamed:@"Camera"  owner:self]){
		NSLog(@"Warning! Could not load the nib for camera ");
		return NO;
	}
	return YES;
}

-(void) updateMovieList{
	[movieSelector removeAllItems];
	[movies removeAllObjects];
	NSFileManager * filesystem = [NSFileManager defaultManager];
	NSLog([NSString stringWithCString:ofToDataPath("recordedMovies/", true).c_str()]);
	NSError *error = nil;
	NSURL *url = [NSURL URLWithString:[NSString stringWithCString:ofToDataPath("recordedMovies/", true).c_str()]];
	NSArray * content = [filesystem contentsOfDirectoryAtURL:url includingPropertiesForKeys:[NSArray array] options:0 error:&error];
	NSLog(@"Found %d files",[content count]);
	NSURL * item;
	int i=0;
	for(item in content){
		i++;
		NSNumber *isFile = nil;
		[item getResourceValue:&isFile forKey:NSURLIsRegularFileKey error:NULL];
		
		NSNumber * isHidden = nil;
		[item getResourceValue:&isHidden forKey:NSURLIsHiddenKey error:NULL];
		
		if ([isFile boolValue] && ![isHidden boolValue]) {
			NSString *fileName = nil;
			[item getResourceValue:&fileName forKey:NSURLNameKey error:NULL];
			
			NSLog(fileName);
			[movieSelector addItemWithTitle:fileName];
			[movies addObject:item];
			if(loadMoviePlease == NO && live == NO){
				loadMovieString = [NSString stringWithString:fileName];
				loadMoviePlease = YES;
			}
		} else {
			
		}
	}
}

-(void) loadMovie:(NSString*) name{
	//videoPlayer = new videoplayerWrapper();
	NSString * file = [NSString stringWithFormat:@"recordedMovies/%@", name];
	if(videoPlayer->videoPlayer.loadMovie([file cString] )){
		//	videoPlayer->setLoopState(OF_LOOP_NORMAL);
		cout<<"Loaded: "<<	[file cString]<<endl;
		
		videoPlayer->videoPlayer.play();
	} else {
		cout<<"Could not load: "<<	[file cString]<<endl;
	}
	
}



-(IBAction) setShutter:(id)sender{
	if(camInited)
		videoGrabber->setFeatureValue([sender floatValue], FEATURE_SHUTTER);
}
-(IBAction) setExposure:(id)sender{
	if(camInited)
		videoGrabber->setFeatureValue([sender floatValue], FEATURE_EXPOSURE);	
}
-(IBAction) setGain:(id)sender{
	if(camInited)
		videoGrabber->setFeatureValue([sender floatValue], FEATURE_GAIN);
}
-(IBAction) setGamma:(id)sender{
	if(camInited)
		videoGrabber->setFeatureValue([sender floatValue], FEATURE_GAMMA);
}
-(IBAction) setBrightness:(id)sender{
	if(camInited)
		videoGrabber->setFeatureValue([sender floatValue], FEATURE_BRIGHTNESS);
}

-(IBAction) setSource:(id)sender{
	switch ([sender selectedSegment]) {
		case 0:
			//Live
			[movieSelector setEnabled:NO];
			[recordButton setEnabled:YES];
			live = YES;
			break;
		case 1:
			//Movie
			[movieSelector setEnabled:YES];
			[recordButton setEnabled:NO];
			live = NO;
			[self updateMovieList];
			
			break;			
			
		default:
			break;
	}
	[userDefaults setValue:[NSNumber numberWithBool:live] forKey:[NSString stringWithFormat:@"camera%d.live",camNumber]];
}
-(IBAction) setMovieFile:(id)sender{
	loadMovieString = [NSString stringWithString:[sender titleOfSelectedItem]];
	loadMoviePlease = YES;
	
}
-(IBAction) toggleRecord:(id)sender{
	
}

-(float) framerate{
	return frameRate;	
}

@end
