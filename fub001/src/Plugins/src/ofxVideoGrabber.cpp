
#include "ofxVideoGrabber.h"
#include "ofUtils.h"

//--------------------------------------------------------------------
ofxVideoGrabber::ofxVideoGrabber()
{
    bGrabberInited = false;
	bUseTexture	= true;
	bIsFrameNew = false;
	pixels = NULL;
	
	
	float timeNow = 0;
	float timeThen = 0;
	float frameRate = 0;
	float fps = 0;
}

//--------------------------------------------------------------------
ofxVideoGrabber::~ofxVideoGrabber(){
	close();
	//delete videoGrabber;
}

//--------------------------------------------------------------------
bool ofxVideoGrabber::initGrabber( int _width, int _height, int _format, int _targetFormat, int _frameRate, bool _useTexture, ofxVideoGrabberSDK *sdk, ofxVideoGrabberSettings* _settings)
{
	videoGrabber = sdk;
	settings = _settings;
    bool initResult = videoGrabber->init( _width, _height, _format, _targetFormat, _frameRate);

	frameRate = _frameRate;
	
	width = videoGrabber->width;
    height = videoGrabber->height;
    bpp = videoGrabber->bpp;
    bUseTexture = _useTexture;

	if(initResult){
    if (bUseTexture){
        targetFormat = _targetFormat;

        /* create the texture, set the pixels to black and upload them to the texture (so at least we see nothing black the callback) */
        if(targetFormat == VID_FORMAT_GREYSCALE)
        {
            tex.allocate(videoGrabber->width,videoGrabber->height,GL_LUMINANCE);
            pixels = new unsigned char[width * height * bpp];
            memset(pixels, 0, width*height*bpp);
            tex.loadData(pixels, width, height, GL_LUMINANCE);
        }
        else if(targetFormat == VID_FORMAT_RGB)
        {
            tex.allocate(videoGrabber->width,videoGrabber->height,GL_RGB);
            pixels = new unsigned char[width * height * bpp];
            memset(pixels, 0, width*height*bpp);
            tex.loadData(pixels, width, height, GL_RGB);
        }
        else
        {
            ofLog(OF_LOG_FATAL_ERROR,"Texture allocation failed. Target format must be either VID_FORMAT_GREYSCALE or VID_FORMAT_RGB");
            initResult = false;
        }
    }
    else
    {
        if( targetFormat == VID_FORMAT_GREYSCALE || targetFormat == VID_FORMAT_RGB)
        {
            pixels = new unsigned char[width * height * bpp];
            memset(pixels, 0, width*height*bpp);
        }
        else
        {
            ofLog(OF_LOG_FATAL_ERROR,"Wrong target output format. Target format must be either VID_FORMAT_GREYSCALE or VID_FORMAT_RGB");
            initResult = false;
        }
     }

    settings->setupVideoSettings(videoGrabber);

    bGrabberInited = true;
	}
    return initResult;
}


//--------------------------------------------------------------------
void ofxVideoGrabber::setUseTexture(bool bUse)
{
	bUseTexture = bUse;
}

//--------------------------------------------------------------------
bool ofxVideoGrabber::isFrameNew()
{
	bool ret;
	if(((Libdc1394Grabber*)videoGrabber)->lock()){
		ret = bIsFrameNew;
		((Libdc1394Grabber*)videoGrabber)->unlock();
	}
    return ret;
}

//--------------------------------------------------------------------
unsigned char* ofxVideoGrabber::getPixels()
{
unsigned char* ret;
//	if(((Libdc1394Grabber*)videoGrabber)->lock()){
		ret = pixels;
//		((Libdc1394Grabber*)videoGrabber)->unlock();
//	}
    return ret;
}

//--------------------------------------------------------------------
void ofxVideoGrabber::update()
{
	if(bGrabberInited){
		grabFrame();
		settings->update();
		if(!((Libdc1394Grabber*) videoGrabber)->isThreadRunning()){
			cout<<"Thread not running!!!!!"<<endl;
			((Libdc1394Grabber*)videoGrabber)->startThread(true,false);
		}
	}
}

bool ofxVideoGrabber::grabberInited()
{
	if(this != NULL){
		return bGrabberInited;
	} else {
		return false;
	}
}	

bool ofxVideoGrabber::isReady()
{
	return grabberInited();
}	

//--------------------------------------------------------------------
void ofxVideoGrabber::grabFrame()
{

    if (bGrabberInited){
        bIsFrameNew = videoGrabber->grabFrame(&pixels);
        if(bIsFrameNew) {
			timeNow = ofGetElapsedTimef();
			if( ( timeNow - timeThen ) > 0 ) {
				fps = 1.0 / (timeNow-timeThen);
				frameRate *= 0.9f;
				frameRate += 0.1f*fps;
			}
			timeThen = timeNow;
            if (bUseTexture){
                if(targetFormat == VID_FORMAT_GREYSCALE)
                {
                    tex.loadData(pixels, width, height, GL_LUMINANCE);
                }
                else
                {
                    tex.loadData(pixels, width, height, GL_RGB);
                }
			}
        }
    }
}

//--------------------------------------------------------------------
void ofxVideoGrabber::draw(float _x, float _y, float _w, float _h)
{
	if(((Libdc1394Grabber*)videoGrabber)->lock()){
		if (bUseTexture){
			tex.draw(_x, _y, _w, _h);
		}
		if(bGrabberInited){
			settings->draw();
		}
		
		((Libdc1394Grabber*)videoGrabber)->unlock();
	}	
}

//--------------------------------------------------------------------
void ofxVideoGrabber::draw(float _x, float _y)
{
	draw(_x, _y, (float)width, (float)height);
}

//--------------------------------------------------------------------
void ofxVideoGrabber::close()
{
    if(bGrabberInited){
        bGrabberInited 		= false;
        bIsFrameNew 		= false;
        videoGrabber->close();
    }
}

//--------------------------------------------------------------------
float ofxVideoGrabber::getHeight(){
	return (float)height;
}

//--------------------------------------------------------------------
float ofxVideoGrabber::getWidth(){
	return (float)width;
}

//--------------------------------------------------------------------
ofTexture & ofxVideoGrabber::getTextureReference()
{
	if(!tex.bAllocated() ){
		ofLog(OF_LOG_WARNING, "ofxVideoGrabber - getTextureReference - texture is not allocated");
	}
	return tex;
}




