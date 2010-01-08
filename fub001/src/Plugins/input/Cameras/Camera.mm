//
//  Camera.mm
//  openFrameworks
//
//  Created by Jonas Jongejan on 02/12/09.
//  Copyright 2009 HalfdanJ. All rights reserved.
//

#import "Camera.h"
#import "Tracking.h"

@interface Camera (InternalMethods)

- (void)videoGrabberInit;
- (void)videoGrabberRespawn;

@end

static float aCameraWillRespawnAt = -1;
static BOOL camerasRespawning[3];

@implementation Camera
@synthesize settingsView, mytimeNow, mytimeThen, width, height, camInited, live, camNumber, camGUID, recordButton;

+ (float)aCameraWillRespawnAt { return aCameraWillRespawnAt; }
+ (BOOL)aCameraIsRespawning { return (camerasRespawning[0] || camerasRespawning[1] || camerasRespawning[2]); }
+ (BOOL)allCamerasAreRespawning { return (camerasRespawning[0] && camerasRespawning[1] && camerasRespawning[2]); }
+ (float)setCamera:(int)respawningCameraNumber willRespawningAt:(float)timeStamp  { aCameraWillRespawnAt = timeStamp; camerasRespawning[respawningCameraNumber] = YES; }
+ (float)setCamera:(int)respawningCameraNumber isRespawning:(BOOL)isRespawning  { camerasRespawning[respawningCameraNumber] = isRespawning; }



-(void) setup:(int)_camNumber withGUID:(uint64_t)_camGUID{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(aWillTerminate:)
												 name:NSApplicationWillTerminateNotification object:nil];
	userDefaults = [[NSUserDefaults standardUserDefaults] retain];
	
	//	width = 1280/2;
	//	height = 960/2;
	
	for (int i = 0; i < 3; i++) {
		camerasRespawning[i] = NO;
	}
	
	width = 640;
	height = 480;
	camNumber = _camNumber;
	camGUID = _camGUID;
	myframes = 0;
	live = YES;
	loadMoviePlease  = NO;
	camIsIniting = YES;
	isClosing = NO;
	
	videoPlayer = new videoplayerWrapper();
	videoPlayer->videoPlayer.setUseTexture(false);
	
	movies = [[NSMutableArray array] retain];
	[self updateMovieList];
	millisSinceLastMovieEvent = 0;
	
	tex = new ofTexture();
	tex->allocate(width,height,GL_LUMINANCE);
	pixels = new unsigned char[width * height];
	memset(pixels, 0, width*height);
	
	rgbTmpPixels = new unsigned char[width * height*3];
	memset(rgbTmpPixels, 0, width*height*3);
	
	tex->loadData(pixels, width, height, GL_LUMINANCE);	
	pthread_mutex_init(&mutex, NULL);
	
	if(![userDefaults boolForKey:[NSString stringWithFormat:@"camera.%i.live",[self camNumber]+1]]){
		live = NO;
		[movieSelector setEnabled:YES];
		[recordButton setEnabled:NO];
		[sourceSelector setSelectedSegment:1];

	}

	[self updateMovieList];	
	
	saver = new ofxQtVideoSaver();
	saver->setCodecQualityLevel(OF_QT_SAVER_CODEC_QUALITY_NORMAL);
	recording = NO;
	
	[self videoGrabberInit];
	
}

-(void) update:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
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
				
				if([recordButton state] == NSOnState){
					for(int i=0;i<width*height*3;i+=3){
						rgbTmpPixels[i] = pixels[i/3];
						rgbTmpPixels[i+1] = pixels[i/3];
						rgbTmpPixels[i+2] = pixels[i/3];
					}
					saver->addFrame(rgbTmpPixels, 1.0f / MIN(frameRate, ofGetFrameRate())); 	
					if(!recording){
						saver->setup(640,480,[[NSString stringWithFormat:@"recordedMovies/camera%i_recording%i.mov",[self camNumber]+1, numFiles] cString]);	
					}
					recording = YES;
				} else if(recording){
					recording = NO;
					saver->finishMovie();	
					numFiles ++;
				}				
			} else if ((ofGetElapsedTimef()-mytimeThen) > 1.0f) {
				NSLog(@"Camera %i was TOO LATE",camNumber);
				frameRate = 0;
				[self videoGrabberRespawn];
			} 
			if (camerasRespawning[camNumber]) {
				NSLog(@"Camera %i schedules respawn for itself",camNumber);
				frameRate = 0;
				mytimeThen = ofGetElapsedTimef() + 5.0f;
				[self videoGrabberRespawn];
			}
			if([Camera allCamerasAreRespawning]){
				NSLog(@"Camera %i schedules respawn for all",camNumber);
				frameRate = 0;
				aCameraWillRespawnAt = ofGetElapsedTimef() + 5.0f;
			}
		} else if (camWasInited && ofGetElapsedTimef()-mytimeThen > 0.1f) {
			NSLog(@"Camera %i was alive, but not anymore",camNumber);
			frameRate = 0;
			mytimeThen=ofGetElapsedTimef();
			[self videoGrabberRespawn];
		}
	} else {
		if(loadMoviePlease){
			[self loadMovie:loadMovieString];
			loadMoviePlease = NO;
		}
		videoPlayer->videoPlayer.idleMovie();
		if(videoPlayer->videoPlayer.isFrameNew()){
			
			mytimeNow = ofGetElapsedTimef();
			if( (mytimeNow-mytimeThen) > 0.05f || myframes == 0 ) {
				myfps = myframes / (mytimeNow-mytimeThen);
				mytimeThen = mytimeNow;
				myframes = 0;
				frameRate = 0.5f * frameRate + 0.5f * myfps;
			}
			myframes++;
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

-(BOOL) isFrameNew{
	if(live){
		return bIsFrameNew;
	} else {
		return videoPlayer->videoPlayer.isFrameNew(); 
	}
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
	NSString * fileNameFromDefaults = [userDefaults stringForKey:[NSString stringWithFormat:@"camera.%i.movie.fileName",camNumber+1]];
	BOOL foundFileNameFromDefaults = NO;
	NSFileManager * filesystem = [NSFileManager defaultManager];
	NSLog([NSString stringWithCString:ofToDataPath("recordedMovies/", true).c_str()]);
	NSError *error = nil;
	NSURL *url = [NSURL URLWithString:[NSString stringWithCString:ofToDataPath("recordedMovies/", true).c_str()]];
	NSArray * content = [filesystem contentsOfDirectoryAtURL:url includingPropertiesForKeys:[NSArray array] options:0 error:&error];
	NSLog(@"Found %d files",[content count]);
	numFiles = [content count];
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
			NSLog(fileNameFromDefaults);
			if ([fileNameFromDefaults compare:loadMovieString]) {
				NSLog(@"found");
				foundFileNameFromDefaults = YES;
			}
		}
	}
	if (foundFileNameFromDefaults){
		loadMovieString = fileNameFromDefaults;
		[movieSelector selectItemWithTitle:loadMovieString];
	}	
}

-(void) loadMovie:(NSString*) name{
	//videoPlayer = new videoplayerWrapper();
	NSString * file = [NSString stringWithFormat:@"recordedMovies/%@", name];
	if(videoPlayer->videoPlayer.loadMovie([file cString] )){
		//	videoPlayer->setLoopState(OF_LOOP_NORMAL);
		cout<<"Loaded: "<<	[file cString]<<endl;
		videoPlayer->videoPlayer.play();
		[[[GetPlugin(Tracking) trackerNumber:camNumber] learnBackgroundButton] setState:NSOnState];
	} else {
		cout<<"Could not load: "<<	[file cString]<<endl;
	}
}



-(IBAction) setShutter:(id)sender{
	[userDefaults setFloat:[sender floatValue] forKey:[NSString stringWithFormat:@"camera.%i.shutter",camNumber+1]];
	if(camInited)
		videoGrabber->setFeatureValue([sender floatValue], FEATURE_SHUTTER);
}
-(IBAction) setExposure:(id)sender{
	[userDefaults setFloat:[sender floatValue] forKey:[NSString stringWithFormat:@"camera.%i.exposure",camNumber+1]];
	if(camInited)
		videoGrabber->setFeatureValue([sender floatValue], FEATURE_EXPOSURE);	
}
-(IBAction) setGain:(id)sender{
	[userDefaults setFloat:[sender floatValue] forKey:[NSString stringWithFormat:@"camera.%i.gain",camNumber+1]];
	if(camInited)
		videoGrabber->setFeatureValue([sender floatValue], FEATURE_GAIN);
}
-(IBAction) setGamma:(id)sender{
	[userDefaults setFloat:[sender floatValue] forKey:[NSString stringWithFormat:@"camera.%i.gamma",camNumber+1]];
	if(camInited)
		videoGrabber->setFeatureValue([sender floatValue], FEATURE_GAMMA);
}
-(IBAction) setBrightness:(id)sender{
	[userDefaults setFloat:[sender floatValue] forKey:[NSString stringWithFormat:@"camera.%i.brightness",camNumber+1]];
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
	[userDefaults setValue:[NSNumber numberWithBool:live] forKey:[NSString stringWithFormat:@"camera.%i.live",camNumber+1]];
}
-(IBAction) setMovieFile:(id)sender{
	
	loadMovieString = [NSString stringWithString:[sender titleOfSelectedItem]];
	[userDefaults setValue:loadMovieString forKey:[NSString stringWithFormat:@"camera.%i.movie.fileName",camNumber+1]];
	loadMoviePlease = YES;
	
}
-(IBAction) toggleRecord:(id)sender{
	
}

-(float) framerate{
	return frameRate;	
}

-(void) videoGrabberInit{
	
	camIsIniting = YES;
	isClosing = NO;
	
	ofSetLogLevel(OF_LOG_NOTICE);
	videoGrabber = new Libdc1394Grabber;
	videoGrabber->setFormat7(VID_FORMAT7_1);
	videoGrabber->listDevices();
	videoGrabber->setDiscardFrames(true);
	videoGrabber->set1394bMode(true);
	
	if (camGUID != 0x0ll) {
		videoGrabber->setDeviceID([[NSString stringWithFormat:@"%llx",camGUID] cString]);	
	}
	
	camInited = videoGrabber->init(width, height, VID_FORMAT_Y8, VID_FORMAT_GREYSCALE, 50, true);
	
	if(camInited)
		camWasInited = camInited;
	
	if(camInited){		
		
		[guidTextField setStringValue:[NSString stringWithFormat:@"%llx",videoGrabber->cameraGUID]];
		
		[guidTextField bind:@"value"
				   toObject:[NSUserDefaultsController sharedUserDefaultsController]
				withKeyPath:[NSString stringWithFormat:@"values.camera.%i.guid", camNumber+1]
					options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
														forKey:@"NSContinuouslyUpdatesValue"]];
		
		
		//Set all on manual
		videoGrabber->setFeatureMode(FEATURE_MODE_MANUAL, FEATURE_SHUTTER);
		videoGrabber->setFeatureMode(FEATURE_MODE_MANUAL, FEATURE_EXPOSURE);		
		videoGrabber->setFeatureMode(FEATURE_MODE_MANUAL, FEATURE_GAIN);		
		videoGrabber->setFeatureMode(FEATURE_MODE_MANUAL, FEATURE_GAMMA);				
		videoGrabber->setFeatureMode(FEATURE_MODE_MANUAL, FEATURE_BRIGHTNESS);		
		
		//Set sliders
		videoGrabber->getAllFeatureValues();
		
		for(int i=0;i<videoGrabber->availableFeatureAmount;i++){
			if(videoGrabber->featureVals[i].feature == FEATURE_SHUTTER){
				if ([userDefaults floatForKey:[NSString stringWithFormat:@"camera.%i.shutter",camNumber+1]] != nil) {
					videoGrabber->setFeatureValue(
												  [userDefaults floatForKey:[NSString stringWithFormat:@"camera.%i.shutter",camNumber+1]],
												  FEATURE_SHUTTER);
				}
				[shutterSlider setFloatValue:videoGrabber->featureVals[i].currVal];
			}
			if(videoGrabber->featureVals[i].feature == FEATURE_EXPOSURE){
				if ([userDefaults floatForKey:[NSString stringWithFormat:@"camera.%i.exposure",camNumber+1]] != nil) {
					videoGrabber->setFeatureValue(
												  [userDefaults floatForKey:[NSString stringWithFormat:@"camera.%i.exposure",camNumber+1]],
												  FEATURE_EXPOSURE);
				}
				[exposureSlider setFloatValue:videoGrabber->featureVals[i].currVal];
			}
			if(videoGrabber->featureVals[i].feature == FEATURE_GAIN){
				if ([userDefaults floatForKey:[NSString stringWithFormat:@"camera.%i.gain",camNumber+1]] != nil) {
					videoGrabber->setFeatureValue(
												  [userDefaults floatForKey:[NSString stringWithFormat:@"camera.%i.gain",camNumber+1]],
												  FEATURE_GAIN);
				}
				[gainSlider setFloatValue:videoGrabber->featureVals[i].currVal];	
			}
			if(videoGrabber->featureVals[i].feature == FEATURE_GAMMA){
				if ([userDefaults floatForKey:[NSString stringWithFormat:@"camera.%i.gamma",camNumber+1]] != nil) {
					videoGrabber->setFeatureValue(
												  [userDefaults floatForKey:[NSString stringWithFormat:@"camera.%i.gamma",camNumber+1]],
												  FEATURE_GAMMA);
				}
				[gammaSlider setFloatValue:videoGrabber->featureVals[i].currVal];			
			}
			if(videoGrabber->featureVals[i].feature == FEATURE_BRIGHTNESS){
				if ([userDefaults floatForKey:[NSString stringWithFormat:@"camera.%i.shutter",camNumber+1]] != nil) {
					videoGrabber->setFeatureValue(
												  [userDefaults floatForKey:[NSString stringWithFormat:@"camera.%i.brightness",camNumber+1]],
												  FEATURE_BRIGHTNESS);
				} 
				[brightnessSlider setFloatValue:videoGrabber->featureVals[i].currVal];			
			}
		}
	}
	
	camIsIniting = NO;
	
}

-(void) videoGrabberRespawn{
	if(![Camera aCameraIsRespawning]){
		[Camera setCamera:camNumber willRespawningAt:ofGetElapsedTimef()+0.5f];
		NSLog(@"0: CAMERA %i triggered respawn", camNumber);
	}
	
	[Camera setCamera:camNumber isRespawning:YES];
	
	NSLog(@"1: CAMERA %i respawn called", camNumber);
	
	camInited = NO;
	
	if(ofGetElapsedTimef() - [Camera aCameraWillRespawnAt] > 0 && [Camera aCameraIsRespawning]){
		NSLog(@"2: CAMERA %i time for respawn", camNumber);
		if(!camIsIniting){
			
			pthread_mutex_lock(&mutex);
			
			NSLog(@"3: CAMERA %i got lock", camNumber);
			
			if (!isClosing && !camIsIniting && videoGrabber != NULL) {
				isClosing = YES;
				NSLog(@"3: CAMERA %i deletes", camNumber);
				delete videoGrabber;
				videoGrabber = NULL;
			} else {
				camIsIniting = YES;
				NSLog(@"3: CAMERA %i initialises", camNumber);
				[Camera setCamera:camNumber isRespawning:NO];
				[self videoGrabberInit];
			}
			pthread_mutex_unlock(&mutex);
		}
	}
}



@end
