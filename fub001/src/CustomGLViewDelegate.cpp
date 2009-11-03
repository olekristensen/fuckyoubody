#include "CustomGLViewDelegate.h"
#include "ofBaseApp.h"
#include "testApp.h"
#include "ofGraphics.h"

/*
 Reference to our of-application
 */
extern testApp * OFSAptr;


/*
 Setup OpenGL in the same manner as openframeworks.
 */
int CustomGLViewDelegate::window_id_counter = 0;
CustomGLViewDelegate::CustomGLViewDelegate(int i){
	m_Width = 800;	// default window params
	m_Height =600;
	m_PositionX	= 100 ;
	m_PositionY	= 100 ;
	m_FullScreen = false ;
	m_Title =  "Second OpenGL Window" ;
	m_NewSize =  true ;
    m_NewPosition =  true ;
	m_NewMode =  false ;
	m_NewTitle	=  true ;
	m_MouseX = 0 ;
	m_MouseY = 0 ; 
	setupCalled = false;	
//	window_id = CustomGLViewDelegate::window_id_counter;
//	CustomGLViewDelegate::window_id_counter++;
	window_id = i;
	
	
}
void CustomGLViewDelegate::setupOpenGLForOF( int w, int h )
{
	float halfFov, theTan, screenFov, aspect;
	screenFov 		= 60.0f;
	
	float eyeX 		= (float)w / 2.0;
	float eyeY 		= (float)h / 2.0;
	halfFov 		= PI * screenFov / 360.0;
	theTan 			= tanf(halfFov);
	float dist 		= eyeY / theTan;
	float nearDist 	= dist / 10.0;	// near / far clip plane
	float farDist 	= dist * 10.0;
	aspect 			= (float)w/(float)h;
	
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	gluPerspective(screenFov, aspect, nearDist, farDist);
	
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	gluLookAt(eyeX, eyeY, dist, eyeX, eyeY, 0.0, 0.0, 1.0, 0.0);
	
	glScalef(1, -1, 1);           // invert Y axis so increasing Y goes down.
  	glTranslatef(0, -h, 0);       // shift origin up to upper-left corner.
}

/*
 Getters
 */
int CustomGLViewDelegate::getWidth( )			{ return m_Width; }
int CustomGLViewDelegate::getHeight( )			{ return m_Height; }
int CustomGLViewDelegate::getPositionX( )		{ return m_PositionX; }
int CustomGLViewDelegate::getPositionY( )		{ return m_PositionY; }
bool CustomGLViewDelegate::isFullScreen( )		{ return m_FullScreen; }
std::string CustomGLViewDelegate::getTitle( )	{ return m_Title; }


/*
 Setters
 */
void CustomGLViewDelegate::setSize( int w, int h )
{
	/*if( w != m_Width || h != m_Height )
	 {
	 m_Width	 = w;
	 m_Height = h;
	 m_NewSize= true;
	 }*/
}

void CustomGLViewDelegate::setPosition( int x, int y )
{
	if( x != m_PositionX || y != m_PositionY )
	{
		m_PositionX		= x;
		m_PositionY		= y;
		m_NewPosition	= true;
	}
}

void CustomGLViewDelegate::setFullScreen( bool f )
{
	if( m_FullScreen != f )
	{
		m_FullScreen	= f;
		m_NewMode		= true;
	}
}

void CustomGLViewDelegate::setTitle( std::string title )
{
	if( m_Title != title )
	{
		m_Title		= title;
		m_NewTitle	= true;
	}
}

/*
 Event handlers
 */
void CustomGLViewDelegate::handleMouseMove( int x, int y )
{
	m_MouseX = mouseX = x; m_MouseY = mouseY = m_Height -  y;
//	printf( "CustomGLViewDelegate::handleMouseMove @ %i, %i\n", x, y );
	
	static ofMouseEventArgs mouseEventArgs;
	mouseEventArgs.x = mouseX;
	mouseEventArgs.y = mouseY;
	
	ofNotifyEvent( mouseMoved, mouseEventArgs );
}

void CustomGLViewDelegate::handleMouseDown( int x, int y, int b )
{	
	m_MouseX = mouseX= x; m_MouseY = mouseY = m_Height - y;	

	static ofMouseEventArgs mouseEventArgs;
	mouseEventArgs.x = mouseX;
	mouseEventArgs.y = mouseY;
	mouseEventArgs.button = b;
	
	ofNotifyEvent( mousePressed, mouseEventArgs );
}

void CustomGLViewDelegate::handleMouseUp( int b ) 
{
//	printf( "CustomGLViewDelegate::handleMouseUp @ %i, %i - button %i\n", m_MouseX, m_MouseY, b );'
	static ofMouseEventArgs mouseEventArgs;

	ofNotifyEvent( mouseReleased, mouseEventArgs );
}

void CustomGLViewDelegate::handleKeyDown( int key )
{
	printf( "CustomGLViewDelegate::handleKeyDown: %i\n", key );
	static ofKeyEventArgs keyEventArgs;
	
	keyEventArgs.key = key;
	ofNotifyEvent( keyPressed, keyEventArgs );
	
}

void CustomGLViewDelegate::handleMouseDragged( int x, int y, int b )
{
	m_MouseX = mouseX = x; m_MouseY = mouseY = m_Height -y;
//	printf( "CustomGLViewDelegate::handleMouseDragged @ %i, %i - button %i\n", x, y, b );
	
	static ofMouseEventArgs mouseEventArgs;
	mouseEventArgs.x = mouseX;
	mouseEventArgs.y = mouseY;
	mouseEventArgs.button = b;
	
	ofNotifyEvent( mouseDragged, mouseEventArgs );
	
}

void CustomGLViewDelegate::handleKeyUp( int key )
{
	printf( "CustomGLViewDelegate::handleKeyUp: %i\n", key );
	static ofKeyEventArgs keyEventArgs;
	
	keyEventArgs.key = key;
	ofNotifyEvent( keyReleased, keyEventArgs );
}

/*
 Give the main application a reference to ourselves
 */
void CustomGLViewDelegate::registerWithMainApplication( )
{
	if( OFSAptr != NULL ){
	//	((testApp*)OFSAptr)->setReferenceToOtherWindow( this, window_id );
	}
}

/*
 Setup, this is a tricky one, if we run setup right here we might be doing it without
 having created all of our shared openglcontexts, so any texture loading will fail. Here,
 we will just register ourselves with the main application and have it call this method
 instead.
 */
void CustomGLViewDelegate::setup(void(testApp:: * method)())
{
	setupCalled = true;
	drawMethod = method;
	printf( "CustomGLViewDelegate::setup\n" );
}

/*
 Update loop
 */
void CustomGLViewDelegate::update( )
{
}

/*
 Render loop
 */
void CustomGLViewDelegate::render( int w, int h )
{
	if(setupCalled ){
		glClearColor( 0.0f, 0.0f, 0.0f, 1.0f );
		glClear		( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
		
		// we need to call this so we can use normal of drawing routines
		setupOpenGLForOF( w, h );
		
		// do whatever you want here...

		(OFSAptr->*drawMethod)();
	}
	
	//	OFSAptr->draw();
}