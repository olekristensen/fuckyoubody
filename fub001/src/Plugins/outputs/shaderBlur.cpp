/*
 *  shaderBlur.cpp
 *  openFrameworks
 *
 *  Created by theo on 17/10/2009.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include "shaderBlur.h"

//--------------------------------------------------------------
void shaderBlur::setup(int fboW, int fboH){	
	
	ofBackground(255,255,255);	
	//ofSetVerticalSync(true);
	w = fboW;
	h = fboH;
	
	fbo1.allocate(fboW, fboH, true);
	fbo2.allocate(fboW, fboH, true);
	
	shaderH.loadShader("shaders/simpleBlurHorizontal");
	shaderV.loadShader("shaders/simpleBlurVertical");

	noPasses = 1;
	blurDistance = 2.0;
}

void shaderBlur::setupRenderWindow(){

	glViewport(0,0 , w, h);
	
	float halfFov, theTan, screenFov, as;
	screenFov 		= 120.0f;
	
	float eyeX 		= (float)w / 2.0;
	float eyeY 		= (float)h / 2.0;
	halfFov 		= PI * screenFov / 360.0;
	theTan 			= tanf(halfFov);
	float dist 		= eyeY / theTan;
	float nearDist 	= dist / 10.0;	// near / far clip plane
	float farDist 	= dist * 10.0;
	as 			= (float)w/(float)h;
	
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	gluPerspective(screenFov, as, nearDist, farDist);
	
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	gluLookAt(eyeX, eyeY, dist, eyeX, eyeY, 0.0, 0.0, 1.0, 0.0);
	
	glScalef(1, -1, 1);           // invert Y axis so increasing Y goes down.
	glTranslatef(0, -h, 0);       // shift origin up to upper-left corner.
	
	ofBackground(0, 0, 0);
	
	glScalef(w, h, 1);
	
}

//--------------------------------------------------------------
void shaderBlur::beginRender(){
	fbo1.swapIn();
//	fbo1.setupScreenForMe();

	
}

//--------------------------------------------------------------
void shaderBlur::endRender(){
	fbo1.swapOut();
	//ofSetupScreen();
}

//--------------------------------------------------------------
void shaderBlur::setBlurParams(int numPasses, float blurDist){
	noPasses		= ofClamp(numPasses, 1, 100000);
	blurDistance	= blurDist;
}

//--------------------------------------------------------------

void shaderBlur::blur(int numPasses, float blurDist){
	noPasses		= ofClamp(numPasses, 1, 100000);
	blurDistance	= blurDist;
	
	
	ofxFBOTexture * src, * dst;
	src = &fbo1;
	dst = &fbo2;
	
	if( 1 ){
		
		for(int i = 0; i < noPasses; i++){
			float blurPer =  blurDistance * ofMap(i, 0, noPasses, 1.0/noPasses, 1.0);
			
			//first the horizontal shader 
			shaderH.setShaderActive(true);
			shaderH.setUniformVariable1f("blurAmnt", blurDistance);
			
			dst->swapIn();
			//	dst->setupScreenForMe();
			
	
			glViewport(0, 0, w, h);
			
			float halfFov, theTan, screenFov, as;
			screenFov 		= 120.0f;
			
			float eyeX 		= (float)w / 2.0;
			float eyeY 		= (float)h / 2.0;
			halfFov 		= PI * screenFov / 360.0;
			theTan 			= tanf(halfFov);
			float dist 		= eyeY / theTan;
			float nearDist 	= dist / 10.0;	// near / far clip plane
			float farDist 	= dist * 10.0;
			as 			= (float)w/(float)h;
			
			glMatrixMode(GL_PROJECTION);
			glLoadIdentity();
			gluPerspective(screenFov, as, nearDist, farDist);
			
			glMatrixMode(GL_MODELVIEW);
			glLoadIdentity();
			gluLookAt(eyeX, eyeY, dist, eyeX, eyeY, 0.0, 0.0, 1.0, 0.0);
			
			glScalef(1, -1, 1);           // invert Y axis so increasing Y goes down.
			glTranslatef(0, -h, 0);       // shift origin up to upper-left corner.
			
			
			
			src->draw(0, 0);
			dst->swapOut();
			//	ofSetupScreen();
			
			shaderH.setShaderActive(false);
			
			//now the vertical shader
			shaderV.setShaderActive(true);	
			shaderV.setUniformVariable1f("blurAmnt", blurDistance);
			
			src->swapIn();
			

			glViewport(0, 0, w, h);		
			glMatrixMode(GL_PROJECTION);
			glLoadIdentity();
			gluPerspective(screenFov, as, nearDist, farDist);
			
			glMatrixMode(GL_MODELVIEW);
			glLoadIdentity();
			gluLookAt(eyeX, eyeY, dist, eyeX, eyeY, 0.0, 0.0, 1.0, 0.0);
			
			glScalef(1, -1, 1);           // invert Y axis so increasing Y goes down.
			glTranslatef(0, -h, 0);       // shift origin up to upper-left corner.
			
			
			dst->draw(0,0);
			src->swapOut();
			
			shaderV.setShaderActive(false);
			
			//			ofxFBOTexture  * tmp = src;
			//			src = dst;
			//			dst = tmp;
		}		
		
	}
}

//--------------------------------------------------------------
void shaderBlur::draw(float x, float y, float w, float h, bool useShader){
	//ofEnableAlphaBlending();	
	ofSetColor(255, 255, 255, 255);
	fbo1.draw(x, y, w, h);	

}



