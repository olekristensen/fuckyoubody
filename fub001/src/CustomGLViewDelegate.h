#ifndef CUSTOMGLVIEWDELEGATE_H
#define CUSTOMGLVIEWDELEGATE_H

#include "ofEvents.h"
#include "ofxVectorMath.h"
/*
 
 You can either use this class as a bridge between the cocoa window and your
 custom c++ class or you can do whatever you want right here.
 
 */

#include <string>

class testApp;

class CustomGLViewDelegate
{
	
private:
	int			m_PositionX;	// position of window
	int			m_PositionY;
	bool		m_FullScreen;	// window mode
	std::string	m_Title;
	
	
	int			m_MouseX;		// save mouse position since mouse-up
	int			m_MouseY;		// doesn't supply any
	
	// slightly modified of function to intialize projection
	// with supplied width/height
	void setupOpenGLForOF( int w, int h );
	
	
public:
	int mouseX, mouseY;
	
	int window_id;
	static int window_id_counter;
	
	int			m_Width;		// dimentions of window
	int			m_Height;
	
	bool		m_NewSize;		// property flags
	bool		m_NewPosition;
	bool		m_NewMode;
	bool		m_NewTitle;
	
	void (testApp::*drawMethod)();
	bool setupCalled;
	
	ofEvent<ofKeyEventArgs> 	keyPressed;
	ofEvent<ofKeyEventArgs> 	keyReleased;
	
	ofEvent<ofMouseEventArgs> 	mouseMoved;
	ofEvent<ofMouseEventArgs> 	mouseDragged;
	ofEvent<ofMouseEventArgs> 	mousePressed;
	ofEvent<ofMouseEventArgs> 	mouseReleased;	
	
	//----------------------------------------------------
	
	CustomGLViewDelegate(int i) ;
	
	~CustomGLViewDelegate( ){};
	
	//----------------------------------------------------
	// getters / setters
	
	int getWidth( );
	int getHeight( );
	int getPositionX( );
	int getPositionY( );
	bool isFullScreen( );
	std::string getTitle( );
	
	void setSize( int w, int h );
	void setPosition( int x, int y );
	void setFullScreen( bool f );
	void setTitle( std::string title );
	
	
	
	//----------------------------------------------------
	// event handlers
	
	void handleMouseMove	( int x, int y );
	void handleMouseDown	( int x, int y, int b );
	void handleMouseUp		( int b );
	void handleMouseDragged ( int x, int y, int b );
	
	void handleKeyDown		( int key );
	void handleKeyUp		( int key );
	
	void registerWithMainApplication( );
	void setup(void(testApp:: * method)());
	void update( );
	void render( int w, int h );
	
	
};





#endif