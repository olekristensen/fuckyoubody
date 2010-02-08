#pragma once

#import "GLee.h"

#import <Cocoa/Cocoa.h>
#include "Plugin.h"
#include "ofMain.h"
#define FLOORGRIDSIZE 8
#include "Filter.h"
#include "shaderBlur.h"
#define WallScaling 0.5




@interface Arkade : ofPlugin {
	@public
	IBOutlet NSButton * floorSquaresButton;
	IBOutlet NSButton * moveWithPerson;
	IBOutlet NSButton * lockToGrid;

	IBOutlet NSButton * leaveCookiesButton;
	IBOutlet NSButton * pacmanButton;
	IBOutlet NSSlider * pacmanSpeedSlider;
	
	IBOutlet NSButton * ballUpdateButton;
	IBOutlet NSButton * ballDrawButton;
	IBOutlet NSSlider * ballSpeedSlider;
	IBOutlet NSSlider * ballSizeSlider;
	
	IBOutlet NSSlider * terminatorLightFadeSlider;
	IBOutlet NSSlider * terminatorLightSpeedSlider;
	IBOutlet NSSlider * terminatorBlobLightSpeedSlider;	
	IBOutlet NSSlider * terminatorBlobLightFadeSlider;	
	IBOutlet NSSlider * terminatorBlobLightBlurSlider;	
	
	IBOutlet NSSlider * wallBuildSlider;	
	IBOutlet NSSlider * wallLockSlider;	
	
	IBOutlet NSSlider * gardenFadeSlider;	
	IBOutlet NSSlider * spaceFadeSlider;	
	IBOutlet NSSlider * spaceSpeedSlider;	
	IBOutlet NSSlider * spaceAutoLaunchSpeedSlider;	
	IBOutlet NSSlider * spaceAlienFadeSlider;	
	IBOutlet NSSlider * spaceAlienFadeOutSlider;	

	ofxPoint2f * personPosition;

	Filter * personFilterX, * personFilterY;
	
	shaderBlur * blur;
	
	bool doReset;
	
	//Floor squares
	float floorSquaresOpacity[ FLOORGRIDSIZE * FLOORGRIDSIZE ];
	vector<ofxPoint2f> cookies;
 	float cookiesRemoveFactor;
	ofxPoint2f * pongPos;
	float pongSquareSize;
	
	
	//Ball
	ofxPoint2f * ballPosition;
	ofxVec2f * ballDir;
	vector<ofxPoint2f> lastBallPositions;
	
	//Pacman
	ofxPoint2f * pacmanPosition;
	ofxVec2f * pacmanDir;
	float pacmanMouthValue;
	int pacmanMouthDir;
	bool pacmanEntering;
	ofSoundPlayer * pongWallSound;
	float pacmanDieFactor;
	
	//Choises
	ofxPoint2f * redChoisePosition;
	ofxPoint2f * blueChoisePosition;
	float choisesSize;
	bool makeChoises;
	
	//terminator
	bool terminatorMode;
	float blueScaleFactor;
	float lightRotation;
	float blobLightFactor;
	
	//Wall
	vector<ofxPoint2f> wallPoints;
	vector<ofxPoint2f> wallPointsTemp;

	vector<ofxPoint2f> outerWall;
	vector<
	ofxPoint2f> innerWall;
	float resolution;
	
	//Rockets
	NSMutableArray * aliens;
	NSMutableArray * rockets;
	ofxPoint2f * spaceInvadersPosition;
	int spaceInvadersDir;
	int spaceInvadersYDir;
	float timeSinceLastLaunch;

	ofImage * images[6];
	
}

-(IBAction) reset:(id)sender;
-(IBAction) makeChoises:(id)sender;
-(IBAction) activateTerminator:(id)sender;
-(IBAction) deactivateTerminator:(id)sender;
-(IBAction) generateWall:(id)sender;
-(IBAction) spawnRocket:(id)sender;
-(IBAction) resetSpaceinvaders:(id)sender;

-(void) findInnerPointsWithD:(ofxVec2f)d lastPoint:(ofxPoint2f)lastPoint lastPointDir:(ofxVec2f)lastPointDir;

-(BOOL) walkDirection:(ofxVec2f)dir fromPosition:(ofxPoint2f)pos;
-(void) calculateOuterWall;
-(BOOL) wallPointExist:(ofxPoint2f)p;
-(ofxPoint2f) wallPoint:(ofxPoint2f)p;
-(ofxPoint2f) pointFromDir:(ofxVec2f) dir position:(ofxPoint2f)pos;

-(int) getIatX:(float)x Y:(float)y;

-(void) draw:(int)side;

@end



//-------------------------------------------------------------------------------------------------------------------------------------------------



@interface Alien : NSObject
{
	@public
	ofxPoint2f * position;
	int type;
	
	ofImage ** images;
}

-(void)draw;


@end


//-------------------------------------------------------------------------------------------------------------------------------------------------



@interface Rocket : NSObject
{
	ofxVec2f * wallPosition;
	ofxVec2f * wallVel;
	
	ofxVec2f * floorPosition;
	ofxVec2f * floorVel;
	
	ofxVec2f * totalForce;
	BOOL onWall;
	
	Arkade * arkade;
	
	int age;
	int explodeAge;
	bool dead;
	
	ofxVec2f * wallRotation;
}

-(id) initAtPosition:(ofxVec2f)position arkade:(Arkade*)ark;
-(void) update:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime;
-(void) draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime;
-(void) drawRocket;
-(void) dealloc;

@end