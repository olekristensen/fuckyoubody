#include "Libdc1394Grabber.h"
#include "Libdc1394GrabberUtils.h"
#include "Libdc1394GrabberFramerateHelper.h"
#include "Libdc1394GrabberVideoFormatHelper.h"


dc1394_t* Libdc1394Grabber::d = NULL;

Libdc1394Grabber::Libdc1394Grabber()
{
	
	bChooseDevice = false;
	cameraIndex = -1;
	cameraGUID = -1;
	conversionNeeded = false;
	grabbedFirstImage = false;
	bHasNewFrame = false;
	
	YUV_BYTE_ORDER = DC1394_BYTE_ORDER_UYVY; //DC1394_BYTE_ORDER_UYVY, DC1394_BYTE_ORDER_YUYV
	ISO_SPEED = DC1394_ISO_SPEED_800; //DC1394_ISO_SPEED_400
	OPERATION_MODE = DC1394_OPERATION_MODE_1394B; // DC1394_OPERATION_MODE_LEGACY
	
	bayerMethod = DC1394_BAYER_METHOD_EDGESENSE;
	bayerPattern = DC1394_COLOR_FILTER_RGGB;
	
	availableFeatureAmount = 0;
	
	camera = NULL;
	pixels = NULL;
	
	/* Initialise libdc1394 */
    if(!d) {
        d = dc1394_new ();
    }
    if (!d) {
        ofLog(OF_LOG_FATAL_ERROR,"Failed to initialise libdc1394.");
        return;
    }
	
	err = dc1394_camera_enumerate(d, &list);
	
	if(err){ ofLog(OF_LOG_ERROR, "Failed to enumerate cameras"); }
	
    if( list->num == 0 ) {
		ofLog(OF_LOG_ERROR, "No cameras found");
    } else {
		dc1394_camera_free_list (list);
		err = dc1394_camera_enumerate(d, &list);
		if(err){ ofLog(OF_LOG_ERROR, "Failed to enumerate cameras"); }
	} 
	blinkCounter = 0;
}

Libdc1394Grabber::~Libdc1394Grabber()
{
	
	dc1394_camera_free_list (list);
	
	if (camera != NULL )
	{
		fprintf(stderr,"stop transmission\n");
		// Stop data transmission
		if (dc1394_video_set_transmission(camera,DC1394_OFF)!=DC1394_SUCCESS)
		{
			printf("couldn't stop the camera?\n");
		}
		// Close camera
		cleanupCamera();
	}
	
}


void Libdc1394Grabber::close()
{
	
	if (camera != NULL )
	{
		// Close camera
		cleanupCamera();
	}
}

void Libdc1394Grabber::setDeviceID(int _deviceID){
	cameraIndex	= _deviceID;
	ofLog(OF_LOG_NOTICE, "Trying to use Camera with Index %u",cameraIndex);
	bChooseDevice	= true;
}

void Libdc1394Grabber::setDeviceGUID(uint64_t _deviceGUID){
	cameraGUID = _deviceGUID;
	ofLog(OF_LOG_NOTICE, "Trying to use Camera with GUID %llx",cameraGUID);
	bChooseDevice = true;
}

uint64_t Libdc1394Grabber::getDeviceGUID(){
	if (camera != NULL) {
		return camera->guid;
	}
}

void Libdc1394Grabber::listDevices(){
    ofLog(OF_LOG_NOTICE, "-------------------------------------");
	
	ofLog(OF_LOG_NOTICE, "Listing available IIDC capture devices.\nUse GUID as unique ID for camera...");
	for (uint32_t index = 0; index < list->num; index++) {
		//printf("Using camera with GUID %"PRIx64"\n", camera->guid);
		ofLog(OF_LOG_NOTICE, "Device[%d].unit = %x, GUID = %llx", index, list->ids[index].unit, list->ids[index].guid);
	}
	
    ofLog(OF_LOG_NOTICE, "-------------------------------------");
}



bool Libdc1394Grabber::init( int _width, int _height, int _format, int _targetFormat, int _frameRate )
{
	
	targetFormat = _targetFormat;
	
	dc1394framerate_t  desiredFrameRate = Libdc1394GrabberFramerateHelper::numToDcLibFramerate( _frameRate );
	dc1394video_mode_t desiredVideoMode	= Libdc1394GrabberVideoFormatHelper::videoFormatFromParams( _width, _height, _format );
	desiredVideoMode = DC1394_VIDEO_MODE_FORMAT7_1;
	
	width = _width;
	height = _height;
	
	bool result = initCam( desiredVideoMode, desiredFrameRate, _width, _height );
	if(!result) return false;
	
    initInternalBuffers();
	startThread(true, false);   // blocking, verbose
	
	return true;
}

bool Libdc1394Grabber::initCam( dc1394video_mode_t _videoMode, dc1394framerate_t _frameRate, int _width, int _height )
{
	
	/***  
	 
	 TODO Select camera in a hierachy of GUID, then unit - cus UNIT != INDEX
	 
	 see below
	 
	 /**
	 * Create a new camera based on a GUID and a unit number (for multi-unit cameras)
	 
	 dc1394camera_t * dc1394_camera_new_unit(dc1394_t *dc1394, uint64_t guid, int unit);
	 
	 
	 ****/
	
	dc1394camera_t **cameras = NULL;
	uint32_t numCameras, i;
	
    /* Find cameras
	 err=dc1394_camera_enumerate (d, &list);
	 DC1394_ERR_RTN(err,"Failed to enumerate cameras");
	 */
	
	numCameras = list->num;
	
	ofLog(OF_LOG_NOTICE,"There were %d cameras found attached to your PC\n", numCameras );
	
	if( bChooseDevice ) {
		
		if(cameraGUID != -1){
			
			bool bFound = false;
			
			for (uint32_t index = 0; index < list->num; index++) {
				if (list->ids[index].guid == cameraGUID) {
					bFound = true;
					cameraIndex = list->ids[index].unit;
					ofLog(OF_LOG_NOTICE, "Found Camera with GUID %llx, it has Index %u",cameraGUID, cameraIndex);
				}
			}
			
			if (!bFound) {
				ofLog(OF_LOG_NOTICE,"initCam warning: Device Index for unit %llx not found, using first device\n", cameraGUID);
				if(list->num > 0){
					cameraGUID = list->ids[0].guid;
				}
			}
			
		} else if(cameraIndex != -1){
			
			bool bFound = false;
			
			for (uint32_t index = 0; index < list->num; index++) {
				if (list->ids[index].unit == cameraIndex) {
					bFound = true;
					cameraGUID = list->ids[index].guid;
					ofLog(OF_LOG_NOTICE, "Found Camera with Index %u, it has GUID %llx", cameraIndex, cameraGUID);
					
				}
			}
			
			if (!bFound) {
				ofLog(OF_LOG_NOTICE,"initCam warning: Device GUID for unit %u not found, using first device\n", cameraIndex);
				cameraIndex = list->ids[0].unit;
			}
			
		}
		
	} else if(list->num > 0) {
        cameraGUID = list->ids[0].guid;
    } else {
        ofLog(OF_LOG_ERROR, "in initCam, No cameras found");
    }
	
	/* Initialise camera */
	camera = dc1394_camera_new (d, cameraGUID);
	
    if (!camera) {
        dc1394_log_error("Failed to initialize camera with guid %llx", cameraGUID);
        return false;
    }
	
	
    // These methods would cleanup the mess left behind by other processes,
    // but as of (libdc1394 2.0.0 rc9) this is not supported for the Juju stack
#ifdef TARGET_OSX
	dc1394_iso_release_bandwidth(camera, INT_MAX);
	for (int channel = 0; channel < 64; ++channel) {
		dc1394_iso_release_channel(camera, channel);
	}
#endif
	
#ifdef TARGET_LINUX
	// This is rude, but for now needed (Juju)...
	dc1394_reset_bus(camera);
#endif
	
	free(cameras);
	
	ofLog(OF_LOG_NOTICE, "Using Camera with GUID %llx",camera->guid);
	
	dc1394_video_set_operation_mode(camera, OPERATION_MODE);
	dc1394_video_set_iso_speed(camera, ISO_SPEED);
	
	/**
	 
	 // Get video modes
	 if (dc1394_video_get_supported_modes(camera,&video_modes) != DC1394_SUCCESS)
	 {
	 ofLog(OF_LOG_FATAL_ERROR, "Can't get video modes");
	 cleanupCamera();
	 return false;
	 }
	 
	 ofLog(OF_LOG_NOTICE, "Listing Modes");
	 for(i = 0; i < video_modes.num; i++ )
	 {
	 dc1394video_mode_t mode = video_modes.modes[i];
	 //  Libdc1394GrabberUtils::print_mode_info( camera , mode );
	 }
	 
	 // Search the list for our preferred video mode
	 bool foundVideoMode = false;
	 for (i=video_modes.num-1;i>=0;i--)
	 {
	 if( video_modes.modes[i] == _videoMode )
	 {
	 foundVideoMode = true;
	 break;
	 }
	 }
	 
	 video_mode = _videoMode;
	 cout << "Video Mode = " << video_mode << endl;
	 
	 dc1394_get_color_coding_from_video_mode(camera, video_mode, &coding);
	 
	 **/
	video_mode = _videoMode;
	cout << "Video Mode = " << video_mode << endl;
	
	coding = DC1394_COLOR_CODING_MONO8;
	
	unsigned int source_bpp;
	dc1394_get_color_coding_bit_size(coding,&source_bpp);
	cout << "Source bpp = " << source_bpp  << endl;
	
	//if ((dc1394_is_video_mode_scalable(video_modes.modes[i]))|| (coding!=DC1394_COLOR_CODING_MONO8))
	//{ fprintf(stderr,"Could not get a valid MONO8 mode\n"); cleanupCamera(); }
	
	
	//	cout << endl << "**** Chosen Color coding ****" << endl;
	Libdc1394GrabberUtils::print_color_coding( coding );
	//	cout << endl << "*****************************" << endl << endl;
	
	sourceFormatLibDC = coding;
	sourceFormat = Libdc1394GrabberVideoFormatHelper::libcd1394ColorFormatToVidFormat(  coding );
	/**
	 cout << endl << "**** get color codings:" << endl;
	 dc1394color_codings_t color_modes;
	 err = dc1394_format7_get_color_codings(camera, video_mode, &color_modes);
	 
	 if(err == DC1394_SUCCESS) {
	 for (i=color_modes.num-1;i>=0;i--)
	 {
	 cout << i << " -> " << color_modes.codings[i] << endl;
	 }
	 } else {
	 cout << "could not get color codings..." << endl;
	 
	 }
	 
	 cout << "*******" << endl;
	 
	 // get framerates
	 if (dc1394_video_get_supported_framerates(camera,video_mode,&framerates)!=DC1394_SUCCESS)
	 {
	 fprintf(stderr,"Can't get framerates\n");
	 cleanupCamera();
	 }
	 
	 // search the list for our preferred framerate
	 bool foundFramerate = false;
	 for( i = 0; i < framerates.num; i++ )
	 {
	 if( framerates.framerates[i] == _frameRate )
	 {
	 framerate = framerates.framerates[i];
	 foundFramerate = true;
	 break;
	 }
	 }
	 
	 // if we didn't find it, select the highest one.
	 if( !foundFramerate ) framerate=framerates.framerates[framerates.num-1];
	 **/
	
	float bus_period = 0.0000625*3;  // for firewire 800
	int frame_rate = 25;
	int depth = 8;
	int num_packets = (int)(1.0/(bus_period*frame_rate) + 0.5);
	packet_size =  (_width*_height*depth + (num_packets*8) - 1)/(num_packets*8);
	//packet_size = DC1394_USE_MAX_AVAIL;
	
	//dc1394_format7_get_total_bytes(camera, video_mode, &packet_size);
	
	/*-----------------------------------------------------------------------
	 *  setup capture
	 *-----------------------------------------------------------------------*/
	fprintf(stderr,"Setting capture\n");
	
	
	if (dc1394_video_set_mode( camera, video_mode )!=DC1394_SUCCESS){
		ofLog(OF_LOG_ERROR, "failed to set format 7 video mode");
	}
	
	if (dc1394_format7_set_color_coding(camera, video_mode, coding)!=DC1394_SUCCESS){
		ofLog(OF_LOG_ERROR, "failed to set format 7 color coding");
	}
	
	if (dc1394_format7_set_packet_size(camera, video_mode, packet_size)!=DC1394_SUCCESS){
		ofLog(OF_LOG_ERROR, "failed to set format 7 packet_size");
	}
	
	if (dc1394_format7_set_roi(camera, video_mode, coding, packet_size, 0,0, _width, _height)!=DC1394_SUCCESS){
		ofLog(OF_LOG_ERROR, "failed to set format 7 roi");
	}
	
	//dc1394_video_set_framerate(camera, framerate);
	
	if (dc1394_capture_setup(camera,4,DC1394_CAPTURE_FLAGS_DEFAULT)!=DC1394_SUCCESS)
	{
		fprintf( stderr,"Unable to setup camera!\n - check that the video mode and framerate are supported by your camera\n");
		cleanupCamera();
		return false;
	}
	
	/*	cout << "chosen video format: "; Libdc1394GrabberUtils::print_format( video_mode ); cout << endl;
	 cout << "chosen frame rate: " << Libdc1394GrabberFramerateHelper::DcLibFramerateToString( framerate ) << endl;
	 */
	/*
	 // report camera's features ----------------------------------
	 if (dc1394_get_camera_feature_set(camera,&features) !=DC1394_SUCCESS)  { fprintf( stderr, "unable to get feature set\n"); }
	 else  { dc1394_print_feature_set(&features); }
	 */
	
	
	fprintf(stderr,"start transmission\n");
	/*-----------------------------------------------------------------------
	 *  have the camera start sending us data
	 *-----------------------------------------------------------------------*/
	if (dc1394_video_set_transmission(camera, DC1394_ON) !=DC1394_SUCCESS)
	{
		fprintf( stderr, "unable to start camera iso transmission\n");
		cleanupCamera();
	}
	
	fprintf(stderr,"wait transmission\n");
	/*-----------------------------------------------------------------------
	 *  Sleep until the camera has a transmission
	 *-----------------------------------------------------------------------*/
	dc1394switch_t status = DC1394_OFF;
	
	i = 0;
	while( status == DC1394_OFF && i++ < 5 )
	{
		usleep(50000);
		if (dc1394_video_get_transmission(camera, &status)!=DC1394_SUCCESS)
		{
			fprintf(stderr, "unable to get transmission status\n");
			cleanupCamera();
		}
	}
	
	if( i == 5 )
	{
		fprintf(stderr,"Camera doesn't seem to want to turn on!\n");
		cleanupCamera();
	}
	
	
    dc1394_get_image_size_from_video_mode(camera, video_mode, &width, &height);
    outputImageWidth = width;
    outputImageHeight = height;
	
	initFeatures();
	
	fprintf(stderr,"capture\n");
	
	blinkCounter = 0;
	
	return true;
}


void Libdc1394Grabber::initInternalBuffers()
{
	
	if( targetFormat == VID_FORMAT_GREYSCALE || targetFormat == VID_FORMAT_Y8 ) { bpp = VID_BPP_GREY; }
	else if( targetFormat == VID_FORMAT_RGB || targetFormat == VID_FORMAT_BGR ) { bpp = VID_BPP_RGB; }
	else{ cout << "**** " << endl << "*** Libdc1394Grabber: Unsupported output format! *** " << endl << "***************************************** " << endl; }
	
	finalImageDataBufferLength = width*height*bpp;
	pixels = new unsigned char[finalImageDataBufferLength];
	for ( int i = 0; i < finalImageDataBufferLength; i++ ) { pixels[i] = 0; }
	
}

void Libdc1394Grabber::threadedFunction()
{
	while( 1 )
	{
		captureFrame();
		ofSleepMillis(2);
	}
	return;
}

unsigned char* Libdc1394Grabber::getPixels()
{
    return pixels;
}


bool Libdc1394Grabber::grabFrame(unsigned char ** _pixels)
{
    lock();
	if(bHasNewFrame)
    {
        bHasNewFrame = false;
		memcpy(*_pixels,pixels,width*height*bpp);
		unlock();
        return true;
    } else {
		unlock();
		return false;
	}
}

void Libdc1394Grabber::captureFrame()
{
    lock();
	if((!bHasNewFrame) && camera != NULL )
	{
		unlock();
		
		//  make sure DMA buffer is fresh, even if we're lagging behind the cam
		
		
		dc1394_video_set_transmission(camera, DC1394_OFF);
		
		bool bufferEmpty = false;
		
		while (!bufferEmpty){
			dc1394video_frame_t* frameToDiscard;
			if (camera != NULL) {
				if (dc1394_capture_dequeue(camera, DC1394_CAPTURE_POLICY_POLL, &frameToDiscard) == DC1394_SUCCESS){
					if(frameToDiscard != NULL){
						dc1394_capture_enqueue(camera, frameToDiscard);
						ofLog(OF_LOG_NOTICE, "discarded a frame");
					} else {
						bufferEmpty = true;
					}
				} else {
					bufferEmpty = true;
				}
			}
		}
		
		//		dc1394_video_set_transmission(camera, DC1394_ON);
		
		dc1394_video_set_one_shot(camera, DC1394_ON);
		
		// capture one frame
		if (dc1394_capture_dequeue(camera, DC1394_CAPTURE_POLICY_WAIT, &frame) != DC1394_SUCCESS)
		{
			fprintf(stderr, "unable to capture a frame\n");
			cleanupCamera();
		}
		
		
		if( !grabbedFirstImage )
		{
			setBayerPatternIfNeeded();
			grabbedFirstImage = true;
			
		}
		
		if(frame != NULL){
			lock();
			blinkCounter++;
			processCameraImageData( frame->image );
			bHasNewFrame = true;
			unlock();
			if(int err = dc1394_capture_enqueue(camera, frame) != DC1394_SUCCESS){
				fprintf(stderr, "unable to enqueue camera %d\n",err);
			}
		} else {
			ofLog(OF_LOG_ERROR, "there is a null frame");
		}
		
	} else {
		unlock();
	}
	
	
	
}


void Libdc1394Grabber::processCameraImageData( unsigned char* _cameraImageData )
{
    static bool writeonce = true;
	
	if( sourceFormatLibDC == DC1394_COLOR_CODING_RAW8 || sourceFormatLibDC == DC1394_COLOR_CODING_MONO8 )
	{
		
		if( targetFormat == VID_FORMAT_GREYSCALE || targetFormat == VID_FORMAT_Y8 )
		{
			
			memcpy(pixels, _cameraImageData, width * height * bpp);
			
			//			if(writeonce) {
			//			    writeonce = false;
			//                cout << "processCameraImageData() targetFormat  = VID_FORMAT_GREYSCALE || targetFormat == VID_FORMAT_Y8" << endl;
			//			}
		}
		else if( targetFormat == VID_FORMAT_RGB )
		{
			dc1394_bayer_decoding_8bit( _cameraImageData, pixels, width, height,  bayerPattern, bayerMethod );
			if(writeonce) {
			    writeonce = false;
                cout << "processCameraImageData() targetFormat  = VID_FORMAT_RGB" << endl;
			}
		}
		else if ( targetFormat == VID_FORMAT_BGR )
		{
			dc1394_bayer_decoding_8bit( _cameraImageData, pixels, width, height,  bayerPattern, bayerMethod ); // we should really be converting this
		}
		else
		{
			cout << "************* Libdc1394Grabber::processCameraImageData Unsupported target format (" << videoFormatToString( targetFormat ) << ") from DC1394_COLOR_CODING_RAW8 or DC1394_COLOR_CODING_MONO8 *************" << endl;
		}
		
	}
	else if(  sourceFormatLibDC == DC1394_COLOR_CODING_MONO16 || sourceFormatLibDC == DC1394_COLOR_CODING_RAW16 )
	{
		if( targetFormat == VID_FORMAT_RGB )
		{
			//			dc1394_bayer_decoding_16bit( _cameraImageData, pixels, width, height,  bayerPattern, bayerMethod );
		}
		else if ( targetFormat == VID_FORMAT_BGR )
		{
			//			dc1394_bayer_decoding_16bit( _cameraImageData, pixels, width, height,  bayerPattern, bayerMethod ); // we should really be converting this
		}
		else
		{
			cout << "************* Libdc1394Grabber::processCameraImageData Unsupported target format (" << videoFormatToString( targetFormat ) << ") from DC1394_COLOR_CODING_MONO16 or DC1394_COLOR_CODING_RAW16 *************" << endl;
		}
	}
	else if(  sourceFormatLibDC == DC1394_COLOR_CODING_YUV411 || sourceFormatLibDC == DC1394_COLOR_CODING_YUV422 || sourceFormatLibDC == DC1394_COLOR_CODING_YUV444 )
	{
		if( targetFormat == VID_FORMAT_RGB )
		{
			dc1394_convert_to_RGB8( _cameraImageData, pixels, width, height, YUV_BYTE_ORDER, sourceFormatLibDC, 16);
		}
		else if ( targetFormat == VID_FORMAT_BGR )
		{
			dc1394_convert_to_RGB8( _cameraImageData, pixels, width, height, YUV_BYTE_ORDER, sourceFormatLibDC, 16); // we should really be converting this
		}
		else
		{
			cout << "************* Libdc1394Grabber::processCameraImageData Unsupported target format (" << videoFormatToString( targetFormat ) << ") from DC1394_COLOR_CODING_YUV411, DC1394_COLOR_CODING_YUV422 or DC1394_COLOR_CODING_YUV444 *************" << endl;
		}
		
	}
	else if(  sourceFormatLibDC == DC1394_COLOR_CODING_RGB8 )
	{
		if( targetFormat == VID_FORMAT_RGB )
		{
			memcpy(pixels, _cameraImageData, width * height * bpp);
		}
		else if ( targetFormat == VID_FORMAT_BGR )
		{
			memcpy(pixels, _cameraImageData, width * height * bpp);
			//memcpy ( pixels, _cameraImageData, finalImageDataBufferLength ); // we should really be converting this
		}
		else
		{
			cout << "************* Libdc1394Grabber::processCameraImageData Unsupported target format (" << videoFormatToString( targetFormat ) << ") from DC1394_COLOR_CODING_RGB8 *************" << endl;
		}
	}
	else
	{
		
		cout << "************* Libdc1394Grabber::processCameraImageData Unsupported source format! *************" << endl;
	}
	
}

void Libdc1394Grabber::setBayerPatternIfNeeded()
{
	if( sourceFormatLibDC == DC1394_COLOR_CODING_RAW8 || sourceFormatLibDC == DC1394_COLOR_CODING_MONO8 || sourceFormatLibDC == DC1394_COLOR_CODING_MONO16 || sourceFormatLibDC == DC1394_COLOR_CODING_RAW16 )
	{
		if( targetFormat == VID_FORMAT_RGB || targetFormat == VID_FORMAT_BGR || targetFormat == VID_FORMAT_GREYSCALE )
		{
			
			//		dc1394color_filter_t tmpBayerPattern;
			//		if( dc1394_format7_get_color_filter(camera, video_mode, &tmpBayerPattern) != DC1394_SUCCESS )
			//		{
			//			cout << "Libdc1394Grabber::setBayerPatternIfNeeded(), Failed to get the dc1394_format7_get_color_filter." << endl;
			//		}
			//		else
			//		{
			//			cout << "Libdc1394Grabber::setBayerPatternIfNeeded(), We got a pattern, it was: " << tmpBayerPattern << endl;
			//		}
			
			
			if ( Libdc1394GrabberUtils::getBayerTile( camera, &bayerPattern ) != DC1394_SUCCESS )
			{
				ofLog(OF_LOG_WARNING,"Could not get bayer tile pattern from camera" );
			} else {
			    ofLog(OF_LOG_WARNING,"Grabbed a bayer pattern from the camera");
            }
		}
		
	}
}


void Libdc1394Grabber::cleanupCamera()
{
	stopThread();
	while(isThreadRunning()) 1;
	//this sleep seems necessary, at least on OSX, to avoid an occasional hang on exit
	ofSleepMillis(300);
	
	dc1394switch_t is_iso_on = DC1394_OFF;
	if(camera) {
		if (dc1394_video_get_transmission(camera, &is_iso_on)!=DC1394_SUCCESS) {
			is_iso_on = DC1394_ON; // try to shut ISO anyway
		}
		if (is_iso_on > DC1394_OFF) {
			if (dc1394_video_set_transmission(camera, DC1394_OFF)!=DC1394_SUCCESS) {
				fprintf(stderr,"Could not stop ISO transmission\n");
			}
		}
		
		/* cleanup and exit */
		
		dc1394_capture_stop(camera);
		dc1394_reset_bus(camera);
		dc1394_camera_free (camera);
		camera = NULL;
		
		if(pixels) {
			delete [] pixels;
			pixels = NULL;
		}
		
	}
	
}




/*-----------------------------------------------------------------------
 *  Feature Methods
 *-----------------------------------------------------------------------*/
void Libdc1394Grabber::initFeatures()
{
	
	dc1394featureset_t tmpFeatureSet;
	
	// get camera features ----------------------------------
	if ( dc1394_feature_get_all(camera,&tmpFeatureSet) !=DC1394_SUCCESS)
	{
        fprintf( stderr, "unable to get feature set\n");
    }
	else
	{
		//dc1394_print_feature_set(&tmpFeatureSet);
		
		int tmpAvailableFeatures = 0;
		for( int i = 0; i < TOTAL_CAMERA_FEATURES; i++ )
		{
			if( tmpFeatureSet.feature[i].available ) { tmpAvailableFeatures++; }
		}
		
		availableFeatureAmount = tmpAvailableFeatures;
		
		featureVals = new ofxVideoGrabberFeature[availableFeatureAmount];
		
		tmpAvailableFeatures = 0;
		
		// cout << "Name\t" << "\tAbs." << "\tCurr." << "\tCurr2."  << "\tMin." << "\tMax." << endl;
		for( int i = 0; i < TOTAL_CAMERA_FEATURES; i++ )
		{
			if(tmpFeatureSet.feature[i].available)
			{
				featureVals[tmpAvailableFeatures].feature			= Libdc1394GrabberFeatureHelper::libdcFeatureToAVidFeature( tmpFeatureSet.feature[i].id );
				featureVals[tmpAvailableFeatures].name				= cameraFeatureToTitle( featureVals[tmpAvailableFeatures].feature );
				
				featureVals[tmpAvailableFeatures].isPresent			= tmpFeatureSet.feature[i].available;
				featureVals[tmpAvailableFeatures].isReadable		= tmpFeatureSet.feature[i].readout_capable;
				
				featureVals[tmpAvailableFeatures].hasAbsoluteMode	= tmpFeatureSet.feature[i].absolute_capable;
				featureVals[tmpAvailableFeatures].absoluteModeActive = tmpFeatureSet.feature[i].abs_control;
				
                for(unsigned int j = 0; j < tmpFeatureSet.feature[i].modes.num; j++)
                {
                    if(tmpFeatureSet.feature[i].modes.modes[j] == DC1394_FEATURE_MODE_MANUAL)
                    {
                        featureVals[tmpAvailableFeatures].hasManualMode	= true;
                    }
                    else if(tmpFeatureSet.feature[i].modes.modes[j] == DC1394_FEATURE_MODE_AUTO)
                    {
                        featureVals[tmpAvailableFeatures].hasAutoMode = true;
                    }
                    else if(tmpFeatureSet.feature[i].modes.modes[j] == DC1394_FEATURE_MODE_ONE_PUSH_AUTO)
                    {
                        featureVals[tmpAvailableFeatures].hasOnePush = true;
                    }
                }
				
				featureVals[tmpAvailableFeatures].isOnOffSwitchable	= tmpFeatureSet.feature[i].on_off_capable;
				featureVals[tmpAvailableFeatures].isOn				= tmpFeatureSet.feature[i].is_on;
				
                if(tmpFeatureSet.feature[i].current_mode == DC1394_FEATURE_MODE_MANUAL)
                {
                    featureVals[tmpAvailableFeatures].hasManualActive	= true;
                }
                else if(tmpFeatureSet.feature[i].current_mode == DC1394_FEATURE_MODE_AUTO)
                {
                    featureVals[tmpAvailableFeatures].hasAutoModeActive	= true;
                }
                else if(tmpFeatureSet.feature[i].current_mode == DC1394_FEATURE_MODE_ONE_PUSH_AUTO)
                {
                    featureVals[tmpAvailableFeatures].hasOnePushActive = true;
                }
				
				
				if( featureVals[tmpAvailableFeatures].hasAbsoluteMode )
				{
					dc1394_feature_set_absolute_control( camera, tmpFeatureSet.feature[i].id, DC1394_OFF );
					
					/* Not using Abs values (yet?) */
					//					featureVals[tmpAvailableFeatures].currVal = tmpFeatureSet.feature[i].abs_value;
					//
					//					featureVals[tmpAvailableFeatures].minVal  = tmpFeatureSet.feature[i].abs_min;
					//					featureVals[tmpAvailableFeatures].maxVal  = tmpFeatureSet.feature[i].abs_max;
					
				}
				else
				{
                    if(tmpFeatureSet.feature[i].id == DC1394_FEATURE_WHITE_BALANCE)
                    {
                        featureVals[tmpAvailableFeatures].currVal = (float)tmpFeatureSet.feature[i].BU_value;
                        featureVals[tmpAvailableFeatures].currVal2 = (float)tmpFeatureSet.feature[i].RV_value;
                        featureVals[tmpAvailableFeatures].minVal  = (float)tmpFeatureSet.feature[i].min;
                        featureVals[tmpAvailableFeatures].maxVal  = (float)tmpFeatureSet.feature[i].max;
                    }
                    else {
                        featureVals[tmpAvailableFeatures].currVal = (float)tmpFeatureSet.feature[i].value;
                        featureVals[tmpAvailableFeatures].minVal  = (float)tmpFeatureSet.feature[i].min;
                        featureVals[tmpAvailableFeatures].maxVal  = (float)tmpFeatureSet.feature[i].max;
                    }
				}
				
				//				cout << setw(13) << featureVals[tmpAvailableFeatures].name
				//				<< " :\t" << featureVals[tmpAvailableFeatures].hasAbsoluteMode
				//				<< "\t" << featureVals[tmpAvailableFeatures].currVal;
				
				if(tmpFeatureSet.feature[i].id == DC1394_FEATURE_WHITE_BALANCE)
				{
					//				    cout << "\t" << featureVals[tmpAvailableFeatures].currVal2;
                }
                else
                {
					//                  cout << "\t";
                }
				
				//				cout << "\t" << featureVals[tmpAvailableFeatures].minVal
				//				<< "\t" << featureVals[tmpAvailableFeatures].maxVal << endl;
				
				tmpAvailableFeatures++;
			}
		}
		
	}
	
}

void Libdc1394Grabber::getAllFeatureValues()
{
	
	if( availableFeatureAmount == 0 ) return;
	
	for( int i = 0; i < availableFeatureAmount; i++ )
	{
		if(featureVals[i].isPresent)
		{
			getFeatureValues( &featureVals[i] );
		}
	}
	
}


void Libdc1394Grabber::getFeatureValues( ofxVideoGrabberFeature* _feature )
{
	
	dc1394feature_info_t tmpFeatureVals;
	tmpFeatureVals.id = Libdc1394GrabberFeatureHelper::AVidFeatureToLibdcFeature( _feature->feature );
	
	dc1394_feature_get( camera, &tmpFeatureVals);
	
	/* Not using Abs values (yet?) */
	//	if( _feature->hasAbsoluteMode )
	//	{
	//		_feature->currVal = tmpFeatureVals.abs_value;
	//		_feature->minVal = tmpFeatureVals.abs_min;
	//		_feature->maxVal = tmpFeatureVals.abs_max;
	//	}
	//	else
	{
        if(tmpFeatureVals.id == DC1394_FEATURE_WHITE_BALANCE)
        {
            _feature->currVal = (float)tmpFeatureVals.BU_value;
            _feature->currVal2 = (float)tmpFeatureVals.RV_value;
            _feature->minVal = (float)tmpFeatureVals.min;
            _feature->maxVal = (float)tmpFeatureVals.max;
        }
        else {
            _feature->currVal = (float)tmpFeatureVals.value;
            _feature->minVal = (float)tmpFeatureVals.min;
            _feature->maxVal = (float)tmpFeatureVals.max;
        }
	}
	
	if( _feature->isOnOffSwitchable )
	{
		_feature->isOn = tmpFeatureVals.is_on;
	}
	
	if( _feature->hasManualMode )
	{
        if(tmpFeatureVals.current_mode == DC1394_FEATURE_MODE_MANUAL)
        {
            _feature->hasManualActive = true;
        }
        else
        {
            _feature->hasManualActive = false;
        }
	}
	
	if( _feature->hasAutoMode )
	{
        if(tmpFeatureVals.current_mode == DC1394_FEATURE_MODE_AUTO)
        {
            _feature->hasAutoModeActive = true;
        }
        else
        {
            _feature->hasAutoModeActive = false;
        }
	}
	
    if( _feature->hasOnePush )
	{
        if(tmpFeatureVals.current_mode == DC1394_FEATURE_MODE_ONE_PUSH_AUTO)
        {
            _feature->hasOnePushActive = true;
        }
        else
        {
            _feature->hasOnePushActive = false;
        }
	}
	
}

void Libdc1394Grabber::setFeatureAbsoluteValue( float _val, int _feature )
{
	dc1394error_t err;
	
	//cout << " Libdc1394Grabber::setFeatureAbsoluteVal " << _val << ", " << _feature << endl;
	
	err = dc1394_feature_set_absolute_value( camera, Libdc1394GrabberFeatureHelper::AVidFeatureToLibdcFeature( _feature ), _val );
	if( err != DC1394_SUCCESS )
	{
		cout << "*******************" << endl;
		//cout << dc1394_error_strings[err] << endl;
		cout << "Libdc1394Grabber::setFeatureAbsoluteVal, failed to set feature: " << cameraFeatureToTitle( _feature ) << endl;
		cout << "*******************" << endl;
	}
}

void Libdc1394Grabber::setFeatureValue( float _val1, float _val2, int _feature)
{
	dc1394error_t err = DC1394_FAILURE;
	
    if(_feature == FEATURE_WHITE_BALANCE) {
        // _val = u_b, _val2 = v_r for whitebalance
        err = dc1394_feature_whitebalance_set_value( camera, (unsigned int) _val1, (unsigned int) _val2 );
    }
	if( err != DC1394_SUCCESS )
	{
		cout << "*******************" << endl;
		cout << "Libdc1394Grabber::setFeatureVal, failed to set feature: " << cameraFeatureToTitle( _feature ) << endl;
		cout << "*******************" << endl;
	}
}

void Libdc1394Grabber::setFeatureValue( float _val, int _feature )
{
	dc1394error_t err;
	
	//cout << " Libdc1  394Grabber::setFeatureVal " << _val << ", " << _feature << endl;
	
	err = dc1394_feature_set_value( camera, Libdc1394GrabberFeatureHelper::AVidFeatureToLibdcFeature( _feature ), (unsigned int)_val );
	
	
	if( err != DC1394_SUCCESS )
	{
		cout << "*******************" << endl;
		cout << "Libdc1394Grabber::setFeatureVal, failed to set feature: " << cameraFeatureToTitle( _feature ) << endl;
		cout << "*******************" << endl;
	}
	
}

//void Libdc1394Grabber::getFeatureModes()
//{
//    dc1394error_t err;
//    err = dc1394_feature_has_auto_mode(camera, DC1394_FEATURE_MODE_MANUAL, &value);
//    if( (err == DC1394_SUCCESS) && value )
//    {
//
//    }
//}

void Libdc1394Grabber::setFeatureMode(int _featureMode, int _feature )
{
    dc1394error_t err = DC1394_FAILURE;
    dc1394feature_t tmpFeature = Libdc1394GrabberFeatureHelper::AVidFeatureToLibdcFeature( _feature );
    int index = -1;
	
	for( int i = 0; i < availableFeatureAmount; i++ )
	{
		if(featureVals[i].feature == _feature)
		{
			index = i;
		}
	}
	
	if (_featureMode == FEATURE_MODE_MANUAL)
	{
	    if(featureVals[index].isOnOffSwitchable) {
            setFeatureOnOff(true,_feature);
	    }
	    err = dc1394_feature_set_mode( camera, tmpFeature, DC1394_FEATURE_MODE_MANUAL );
		//	    if(err == DC1394_SUCCESS) {
		//            err = dc1394_feature_set_absolute_control( camera, tmpFeature, DC1394_OFF );
		//	    }
	}
	else if(_featureMode == FEATURE_MODE_AUTO)
	{
	    if(featureVals[index].isOnOffSwitchable) {
            setFeatureOnOff(true,_feature);
	    }
	    err = dc1394_feature_set_mode( camera, tmpFeature, DC1394_FEATURE_MODE_AUTO );
		//	    if(err == DC1394_SUCCESS) {
		//            err = dc1394_feature_set_absolute_control( camera, tmpFeature, DC1394_OFF );
		//	    }
	}
	else if(_featureMode == FEATURE_MODE_ONE_PUSH_AUTO)
	{
	    if(featureVals[index].isOnOffSwitchable) {
            setFeatureOnOff(true,_feature);
	    }
	    err = dc1394_feature_set_mode( camera, tmpFeature, DC1394_FEATURE_MODE_ONE_PUSH_AUTO );
		//	    if(err == DC1394_SUCCESS) {
		//            err = dc1394_feature_set_absolute_control( camera, tmpFeature, DC1394_OFF );
		//	    }
	}
	
    if( err != DC1394_SUCCESS )
	{
		cout << "*******************" << endl;
		cout << "Libdc1394Grabber::setFeatureMode, failed to set mode for feature: " << cameraFeatureToTitle( _feature ) << endl;
		cout << "*******************" << endl;
	}
}

bool Libdc1394Grabber::setFeatureOnOff( bool _val, int _feature )
{
	dc1394error_t err = DC1394_FAILURE;
	dc1394feature_t tmpFeature = Libdc1394GrabberFeatureHelper::AVidFeatureToLibdcFeature( _feature );
	
    if( _val ) {
        err = dc1394_feature_set_power( camera, tmpFeature, DC1394_ON );
    }
    else {
        err = dc1394_feature_set_power( camera, tmpFeature, DC1394_OFF );
    }
    return true;
	
	if( err != DC1394_SUCCESS )
	{
		cout << "*******************" << endl;
		cout << "Libdc1394Grabber::setFeatureStateOnOff, failed to set feature: " << cameraFeatureToTitle( _feature ) << endl;
		cout << "*******************" << endl;
	}
	return false;
}



void Libdc1394Grabber::setFeaturesOnePushMode()
{
	setFeatureMode( FEATURE_SHUTTER, FEATURE_MODE_MANUAL );
	dc1394_feature_set_mode( camera, DC1394_FEATURE_SHUTTER,	DC1394_FEATURE_MODE_ONE_PUSH_AUTO );
	
	//dc1394_feature_set_mode( camera, DC1394_FEATURE_WHITE_BALANCE, DC1394_FEATURE_MODE_ONE_PUSH_AUTO );
	
	setFeatureMode( FEATURE_GAIN, FEATURE_MODE_MANUAL );
	dc1394_feature_set_mode( camera, DC1394_FEATURE_GAIN,		DC1394_FEATURE_MODE_ONE_PUSH_AUTO );
	
	//dc1394_feature_set_mode( camera, DC1394_FEATURE_IRIS,		DC1394_FEATURE_MODE_ONE_PUSH_AUTO );
	
	setFeatureMode( FEATURE_EXPOSURE, FEATURE_MODE_MANUAL );
	dc1394_feature_set_mode( camera, DC1394_FEATURE_EXPOSURE,	DC1394_FEATURE_MODE_ONE_PUSH_AUTO );
	
	//dc1394_feature_set_mode( camera, DC1394_FEATURE_BRIGHTNESS, DC1394_FEATURE_MODE_ONE_PUSH_AUTO );
}

int Libdc1394Grabber::stringToFeature( string _featureName )
{
	return -1;
}
