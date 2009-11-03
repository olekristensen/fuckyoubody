#import "GLee.h"
#import <Cocoa/Cocoa.h>

#include "ofAppCocoaWindow.h"

#include "ofMain.h"
#include "testApp.h"
#include "ofAppGlutWindow.h"


int main(int argc, char *argv[])
{
	ofAppCocoaWindow window;
	window.setUseFSAA(true);
    ofSetupOpenGL(&window, 320, 240, OF_WINDOW);
	
	ofRunApp( new testApp() );
	
}
