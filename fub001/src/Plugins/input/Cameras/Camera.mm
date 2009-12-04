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
	live = YES;
	loadMoviePlease  = NO;
	
	videoGrabber->setDeviceID(camNumber);	

	camInited = videoGrabber->init(width, height, VID_FORMAT_Y8, VID_FORMAT_GREYSCALE, 50, true);
	videoPlayer = new videoplayerWrapper();

	movies = [[NSMutableArray array] retain];
	[self updateMovieList];
	millisSinceLastMovieEvent = 0;
	
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
		
	} else {
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
	if(!live){
		if(loadMoviePlease){
			[self loadMovie:loadMovieString];
			loadMoviePlease = NO;
		}
			videoPlayer->videoPlayer.idleMovie();
/*		if(millisSinceLastMovieEvent > 1.0/30.0){
			//
			videoPlayer->videoPlayer.nextFrame();
		//	videoPlayer->videoPlayer.idleMovie();
			millisSinceLastMovieEvent = 0;
		}
		millisSinceLastMovieEvent += 1.0/ofGetFrameRate();
 */
		cout<<videoPlayer->videoPlayer.getPosition()<<endl;		
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
	if(live){
		return tex;		
	} else {

		return &videoPlayer->videoPlayer.getTextureReference();
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
		
		if ([isFile boolValue]) {
			NSString *fileName = nil;
			[item getResourceValue:&fileName forKey:NSURLNameKey error:NULL];
			
			NSLog(fileName);
			[movieSelector addItemWithTitle:fileName];
			[movies addObject:item];
			if(loadMoviePlease == NO && live == NO){
				cout<<"LoadMoviePlease"<<endl;
				loadMovieString = [NSString stringWithString:fileName];
				NSLog(loadMovieString);
				loadMoviePlease = YES;
			}
		} else {
			
		}
	}
}

-(void) loadMovie:(NSString*) name{
	//videoPlayer = new videoplayerWrapper();
	NSString * file = [NSString stringWithFormat:@"recordedMovies/%@", name];

	cout<<"Load: "<<	[file cString]<<endl;
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
}
-(IBAction) setMovieFile:(id)sender{
	
}
-(IBAction) toggleRecord:(id)sender{
	
}

-(float) framerate{
	return frameRate;	
}

@end
