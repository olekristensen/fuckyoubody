/*
 *  shaderBlur.h
 *  openFrameworks
 *
 *  Created by theo on 17/10/2009.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */
#pragma once
#include "ofMain.h"
#include "ofxShader.h" 
#include "ofxFBOTexture.h"

class shaderBlur{

	public:
		void setup(int fboW, int fboH);
		
		void beginRender();
		void endRender();
		
		void setBlurParams(int numPasses, float blurDist);
		void blur(int numPasses, float blurDist);
		void draw(float x, float y, float w, float h, bool useShader);
	void setupRenderWindow();		
		ofxShader shaderH;
		ofxShader shaderV;

		ofxFBOTexture fbo1, fbo2;
		
		float blurDistance;
		int noPasses;
	
	int w,h;
};