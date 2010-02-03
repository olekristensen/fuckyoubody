#ifndef _COORD_WARPING_H
#define _COORD_WARPING_H

#include "ofMain.h"
#include "ofxOpenCv.h"
#include "ofxVectorMath.h"
//we use openCV to calculate our transform matrix
#include "ofxCvConstants.h"
#include "ofxCvContourFinder.h"

class coordWarping{
	
	
public:
	
	//---------------------------
	coordWarping();
	~coordWarping();
	
	void calculateMatrix(ofxPoint2f src[4], ofxPoint2f dst[4]);
	
	ofxPoint2f transform(float xIn, float yIn);
	ofxPoint2f inversetransform(float xIn, float yIn);

	ofxPoint2f transform(ofxPoint2f p);
	ofxPoint2f inversetransform(ofxPoint2f p);
	
	CvMat *translate;
	CvMat *itranslate;
	
protected:
	
	CvPoint2D32f cvsrc[4];
	CvPoint2D32f cvdst[4];
	
};

#endif