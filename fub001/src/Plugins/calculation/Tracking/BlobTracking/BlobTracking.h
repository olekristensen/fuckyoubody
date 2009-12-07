#pragma once
#include "ofMain.h"
#include "Plugin.h"

#include "ofxOpenCv.h"
#include "contourSimplify.h"
#include "ofxXmlSettings.h"
#include "ofxCvOpticalFlowLK.h"
//#include "LensDistortion.h"
#include "ofxThread.h"
#include "ofCvCameraCalibration.h"


class TrackerThread : public ofxThread{
public:
	TrackerThread();
	void start();
	void stop();
	void threadedFunction();

	bool updateContour;
	ofxCvContourFinder 	contourFinder;
	ofxCvOpticalFlowLK	opticalFlow;

	ofxCvGrayscaleImage		grayDiff;
	ofxCvGrayscaleImage 	grayImage;
	ofxCvGrayscaleImage 	grayLastImage;

	float w,h;
};


class PersistentBlob {
public:
	PersistentBlob();
	static unsigned long int idCounter;
	
	long unsigned int id;
	ofxPoint2f centroid;
	ofxPoint2f lastcentroid;
	ofxVec2f centroidV;
	
	ofxPoint2f getLowestPoint();
	
	int timeoutCounter;
	vector<ofxCvBlob> blobs;
};

class Tracker {
public:
	Tracker();
	void setup();
	void update();
	void findContours();
	
	TrackerThread thread;
	int cameraId;
	
	ofxPoint2f blackCorners[4]; 
	ofxXmlSettings * xml;
	
	
	ofxCvGrayscaleImage 	grayImage;
	ofxCvGrayscaleImage 	grayLastImage;
	ofxCvGrayscaleImage 	grayImageBlured;
	
	ofxCvGrayscaleImage 	grayBgMask;
	
	ofxCvGrayscaleImage 	grayBg;
	ofxCvGrayscaleImage 	grayDiff;
	
	//	ofxExtendedBlobTracking 	simplifiedContourFinder;

	PluginManagerController * controller;
	
	float 				threshold;
	float				blur;
	bool				active;
	
	bool				bLearnBakground;
	bool				bUseBgMask;
	bool				bVideoPlayerWasActive;

	bool mouseBlob;
	ofxCvBlob mouseGeneratedBlob;
	void updateMouseBlob(float x, float y, int button);
	
	void setBgMaskFromPixels(unsigned char* _pixels, int width, int height);
	
	contourSimplify contourSimp;
	
	//Getters
	int numBlobs();
	ofxCvBlob getConvertedBlob(ofxCvBlob * blob, ofCvCameraCalibration * calibrator);
	ofxCvBlob getBlob(int n);
	ofxCvBlob getLargestBlob();
	
	vector<ofxCvBlob> getBlobById(unsigned long int _id);
	int numPersistentBlobs();
	bool persistentBlobExist(unsigned long int _id);
	unsigned long int getPersistentBlobId(int n);
	void deletePersistentBlobById(unsigned long int id);
	
	int getWidth();
	int getHeight();
	
	void saveBackground(int num = 0);
	bool loadBackground(int num = 0);

	/*
	 void smoothBlobs(float smooth);
	 void extrudeBlobs(float value);	
	 */
	ofxCvBlob smoothBlob(ofxCvBlob blob, float smooth);
	void extrudeBlob(ofxCvBlob * blob, float value);	
	
	float postBlur, postThreshold;
	
	vector<PersistentBlob> persistentBlobs;
	
private:
	int cw, ch;
		
};
/**
class BlobTracking : public Input{
public:
	BlobTracking();
	
	void draw();
	void setup();
	void update();
	
	vector<Tracker*> trackers;
	
	float threshold;
	
	void drawSettings();
	
	void setThreshold(int n, float v);
	void setBlur(int n, int v);
	void grab(int n);
	void setActive(int n, bool b);
	
	float initThreshold[3];
	float initBlur[3];
	bool initActive[3];
	bool bUseBgMask[3];

	
	bool drawDebug;
	
	//Getters
	//Tracker* tracker(int n);
	
	
	
};
**/