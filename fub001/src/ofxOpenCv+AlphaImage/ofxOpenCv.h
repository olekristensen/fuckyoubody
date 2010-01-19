#ifndef OFX_CV_H
#define OFX_CV_H


//--------------------------
// constants
#include "ofxCvConstants.h"

//--------------------------
// images
#include "ofxCvImage.h"
#include "ofxCvGrayscaleImage.h"
#include "ofxCvColorImage.h"
#include "ofxCvColorImageAlpha.h" /////////////////
#include "ofxCvFloatImage.h"
#include "ofxCvShortImage.h"

//--------------------------
// contours and blobs
#include "ofxCvContourFinder.h"

//edited by JGL to use Takashkis google code
//--------------------------
// optical flow
#include "ofxCvOpticalFlowLK.h"
#include "ofxCvOpticalFlowBM.h"

// face tracking
#include "ofxCvHaarFinder.h"

#endif
