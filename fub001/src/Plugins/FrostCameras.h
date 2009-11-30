#pragma once
#include "ofMain.h"
#include "ofxVectorMath.h"
#include "Warp.h"

#include "ofxVideoGrabber.h"
#include "ofxVideoGrabberFeature.h"
#include "ofxVideoGrabberSettings.h"
#include "ofxVideoGrabberSDK.h"
#include "ofCvCameraCalibration.h"

/* SDKs */
#include "Libdc1394Grabber.h"

class FrostCameras{
public:
	FrostCameras();
	~FrostCameras();
	void setup();
	void update();

	void draw(int _grabberIndex, float _x, float _y, float _w, float _h);
	void draw(int _grabberIndex, float _x, float _y);
	void draw();
	
	void videoPlayerActivate(int _grabberIndex);
	void videoPlayerDeactivate(int _grabberIndex);
	
	bool videoPlayerActive(int _grabberIndex);
	void videoPlayerPlay(int _grabberIndex);
	void videoPlayerStop(int _grabberIndex);
	void videoPlayerSetLoopState(int _grabberIndex, int _state);
	bool videoPlayerLoadUrl(int _grabberIndex, string url);
		
	virtual unsigned char* getPixels(int _grabberIndex);

	bool calibAddSnapshot(uint64_t _cameraGUID);
	bool calibrate(uint64_t _cameraGUID);

	ofPoint undistortPoint(int _grabberIndex, float _PixelX, float _PixelY);
	ofPoint distortPoint(int _grabberIndex, float _PixelX, float _PixelY);
	
	void initGrabber(int _grabber, uint64_t _cameraGUID = 0x0ll);
	void initCameraCalibration(uint64_t _cameraGUID);

	void setGUIDs(uint64_t _cameraGUID1, uint64_t _cameraGUID2, uint64_t _cameraGUID3);
	bool cameraGUIDexists(uint64_t _cameraGUID);

	ofxVideoGrabber * getVidGrabber(int _cameraIndex);
	
	ofCvCameraCalibration calib[3];
	ofxCvGrayscaleImage calibImage[3];
	CvSize csize;
	
	void setCameraCalibration(uint64_t _cameraGUID, float _k1, float _k2, float _c1, float _c2, double fx, double cx, double fy, double cy);

	bool isFrameNew(int _cameraIndex);
	
	bool isRunning(int _cameraIndex);
	
	bool setGUID(int _grabber, uint64_t _cameraGUID);
	uint64_t getGUID(int _grabber);
	int getGrabberIndexFromGUID(uint64_t _cameraGUID);
	
	float cameraBrightness[3];
	float cameraExposure[3];
	float cameraShutter[3];
	float cameraGamma[3];
	float cameraGain[3];

	float cameraBrightnessBefore[3];
	float cameraExposureBefore[3];
	float cameraShutterBefore[3];
	float cameraGammaBefore[3];
	float cameraGainBefore[3];
	
	int camWidth;
	int camHeight;
	
	int getHeight(int _grabberIndex);
	int getWidth(int _grabberIndex);
	
	int getHeight();
	int getWidth();

	bool hasCameras;
	int numCameras;

private:
	
	u_int64_t cameraGUIDs[3];

	bool cameraInited[3];
	bool isReady(int _cameraIndex);

	int timeSinceLastCameraCheck;
	
	ofxVideoGrabber * vidGrabber[3];
	
	ofVideoPlayer videoPlayer[3];
	bool videoPlayerActivated[3];
	bool frameNew[3];

};