#pragma once

#import "GLee.h"

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>


#include "Plugin.h"
#include "ofMain.h"
#include "ofxVectorMath.h"
#include "ofxXmlSettings.h"
#include "Warp.h"
#include "coordWarp.h"

@interface CameraCalibration : ofPlugin {
	
	NSMutableArray * CameraCalibrations;

}

@end


@interface CameraCalibrationObject : NSObject {
	
}

@end


/**


class CameraCalibrationObject {
public:
	Warp * warp;
	coordWarping * coordWarp;
	coordWarping * coordWarpCalibration;
	ofxPoint2f calibHandles[4];
	ofxPoint2f calibPoints[4];

	string name;
};

class CameraCalibration : public Data{
public:
	CameraCalibration();
	
	void draw();
	void drawOnFloor();

	void setup();
	void update();
	
	vector<CameraCalibrationObject *> cameras;
	
	bool drawDebug;
	ofTrueTypeFont	verdana;
	
	void drawSettings();
	
	ofxVec2f lastMousePos;
	int selectedCorner;
	int selectedKeystoner;
	
	void mousePressed(ofMouseEventArgs & args);
	void mouseDragged(ofMouseEventArgs & args);
	void keyPressed(ofKeyEventArgs & args);
	
	void saveXml();

	void guiWakeup();
	
	int w,h, offset;
	
	ofxXmlSettings * keystoneXml;
	
	void applyWarp(int cam, float _w=ofGetWidth(), float _h=ofGetHeight());
	ofxVec2f convertCoordinate(int cam, float x, float y);
	

	void reCalibrate();
};

**/