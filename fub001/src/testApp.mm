
#import "GLee.h"
#import <Cocoa/Cocoa.h>

#include "testApp.h"
#include "CustomGLViewDelegate.h"



//#include "OFGuiController.h"


//--------------------------------------------------------------

testApp::testApp(): ofBaseApp() {
	setupCalled = false;
	
}

void testApp::setup(){	
	ofLog(OF_LOG_VERBOSE, "Testapp setup");

	ofSetDataPathRoot("data/");
	ofEnableAlphaBlending();
	ofBackground(0,0,0);	
	
	//	ofSetLogLevel(OF_LOG_VERBOSE);
	
	lucidaGrande.loadFont("LucidaGrande.ttc",22, false, true);
	
	
	//pluginByType <int> obj;
	//obj.get(pluginController);
	setupCalled = true;
	
	glEnable (GL_MULTISAMPLE_ARB);
    glHint (GL_MULTISAMPLE_FILTER_HINT_NV, GL_NICEST);
	
	
}
/*
void testApp::setReferenceToOtherWindow( CustomGLViewDelegate* delegate, int i )
{
		
}
*/

//--------------------------------------------------------------
void testApp::update()
{
	float mousex = (float)mouseX/ofGetWidth();
	float mousey = (float)mouseY/ofGetHeight();
	

}

//--------------------------------------------------------------
void testApp::draw(){
	//	ofDrawBitmapString(ofToString(ofGetFrameRate(), 0), 10, 20);
	
	fps = ofGetFrameRate();
}


//--------------------------------------------------------------
void testApp::keyPressed(int key){
	if(key == 'f'){
		ofToggleFullscreen();
	}
	if(key == 'c'){
		//getPlugin<Cameras*>(pluginController)->vidGrabber->videoSettings();
	}
}

//--------------------------------------------------------------
void testApp::keyReleased(int key){
	
}

//------------- -------------------------------------------------
void testApp::mouseMoved(int x, int y ){
	
}

//--------------------------------------------------------------
void testApp::mouseDragged(int x, int y, int button){
	
}

//--------------------------------------------------------------
void testApp::mousePressed(int x, int y, int button){
	
}

//--------------------------------------------------------------
void testApp::mouseReleased(int x, int y, int button){
	
}

