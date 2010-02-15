
#include "CameraCalibration.h"
#include "Lenses.h"
#include "Cameras.h"

@implementation CameraCalibration
@synthesize cameraCalibrations;
-(void) initPlugin{
	cameraCalibrations = [[NSMutableArray array] retain];
	lastMousePos = new ofxVec2f();
	userDefaults = [[NSUserDefaults standardUserDefaults] retain];
	
	for(int i=0;i<3;i++){
		CameraCalibrationObject * obj = [[[CameraCalibrationObject alloc] init] retain];		
		[obj setName:[NSString stringWithFormat:@"CAMERA%d",i]];
		
		[cameraCalibrations addObject:obj];

	}	
}

-(void) setup{
	for(int i=0;i<3;i++){
		CameraCalibrationObject * obj = [cameraCalibrations objectAtIndex:i];
		if(i==0){
			[obj setSurface:[GetPlugin(ProjectionSurfaces) getProjectionSurfaceByName:"Front" surface:"Floor"]];
			[obj setProjector:[GetPlugin(ProjectionSurfaces) getProjectorByName:"Front"]];
			[obj calibPoints][0] = ofxPoint2f(0.2,0.2);
			[obj calibPoints][1] = ofxPoint2f(0.8,0.2);
			[obj calibPoints][2] = ofxPoint2f(0.8,0.8);
			[obj calibPoints][3] = ofxPoint2f(0.2,0.8);
		}
		
		if(i==1){
			[obj setSurface:[GetPlugin(ProjectionSurfaces) getProjectionSurfaceByName:"Back" surface:"Floor"]];
			[obj setProjector:[GetPlugin(ProjectionSurfaces) getProjectorByName:"Back"]];
			[obj calibPoints][0] = ofxPoint2f(0.2,0.2);
			[obj calibPoints][1] = ofxPoint2f(0.8,0.2);
			[obj calibPoints][2] = ofxPoint2f(0.8,0.8);
			[obj calibPoints][3] = ofxPoint2f(0.2,0.8);
		}
		
		if(i==2){
			[obj setSurface:[GetPlugin(ProjectionSurfaces) getProjectionSurfaceByName:"Front" surface:"Floor"]];
			[obj setProjector:[GetPlugin(ProjectionSurfaces) getProjectorByName:"Front"]];
			[obj calibPoints][0] = ofxPoint2f(0,0);
			[obj calibPoints][1] = ofxPoint2f(1,0);
			[obj calibPoints][2] = ofxPoint2f(1,1);
			[obj calibPoints][3] = ofxPoint2f(0,1);
		}
		
		for(int u=0;u<4;u++){
			[obj calibHandles][u].x = [userDefaults doubleForKey:[NSString stringWithFormat:@"camera%d.corner%d.x",i, u]];
			[obj calibHandles][u].y = [userDefaults doubleForKey:[NSString stringWithFormat:@"camera%d.corner%d.y",i, u]];			
		}
		
		[obj recalculate];
		
		
		
	}	
	
	font = new ofTrueTypeFont();
	font->loadFont("LucidaGrande.ttc",20, true, true, true);	
}


-(void) controlDraw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)timeStamp{
	int w = 640;
	int h = 480;
	//	[[GetPlugin(Cameras) getCameraWithId:[cameraSelector selectedSegment]] getTexture]->draw(0,0,ofGetWidth(),ofGetHeight());
	CameraCalibrationObject * obj = [cameraCalibrations objectAtIndex:[cameraSelector selectedSegment]];
	
	ofSetColor(255, 255, 255);
	[GetPlugin(Lenses) getUndistortedImageFromCameraId:[cameraSelector selectedSegment]]->draw(0,0,640,480);
	ofEnableAlphaBlending();
	
	if(	![GetPlugin(Lenses) isCalibratedFromCameraId:[cameraSelector selectedSegment]]){
		ofNoFill();
		ofSetColor(0, 0,0,128);
		ofSetLineWidth(6);
		font->drawStringAsShapes("Uncalibrated Lens", (w - font->stringWidth("Uncalibrated Lens"))/2.0, (h - font->stringHeight("Uncalibrated Lens"))/2.0);
		ofSetColor(0, 0,0,208);
		ofSetLineWidth(3);
		font->drawStringAsShapes("Uncalibrated Lens", (w - font->stringWidth("Uncalibrated Lens"))/2.0, (h - font->stringHeight("Uncalibrated Lens"))/2.0);
		ofFill();
		ofSetColor(255, 255,255,64+(128*(1.0-fmodf(timeInterval/2.0,1.0))));
		font->drawStringAsShapes("Uncalibrated Lens", (w - font->stringWidth("Uncalibrated Lens"))/2.0, (h - font->stringHeight("Uncalibrated Lens"))/2.0);
	}
	
	for(int i=0;i<4;i++){
		ofNoFill();
		ofSetColor(0, 0,0,192);
		ofSetLineWidth(2);
		ofEllipse([obj calibHandles][i].x*w, [obj calibHandles][i].y*h, 18, 18);
		ofEllipse([obj calibHandles][i].x*w, [obj calibHandles][i].y*h, 22, 22);
		ofSetLineWidth(1.5);

		switch (i) {
			case 0:
				ofSetColor(255,0,0);
				break;
			case 1:
				ofSetColor(255, 0,255);
				break;
			case 2:
				ofSetColor(0, 255,0);
				break;
			case 3:
				ofSetColor(255, 255,0);
				break;
			default:
				break;
		}
		ofEllipse([obj calibHandles][i].x*w, [obj calibHandles][i].y*h, 20, 20);
	}
	
	
}

-(void) draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	if([drawButton state] == NSOnState){
		ofSetColor(255, 255, 255);
		CameraCalibrationObject * obj = [cameraCalibrations objectAtIndex:[cameraSelector selectedSegment]];
		
		[obj applyWarp];
				[GetPlugin(Lenses) getUndistortedImageFromCameraId:[cameraSelector selectedSegment]]->draw(0,0,1,1);
		//[[GetPlugin(Cameras) getCameraWithId:0] getTexture]->draw(0,0,1,1);
		glPopMatrix();
		
//		[GetPlugin(ProjectionSurfaces) apply:"Front" surface:"Floor"];
		[GetPlugin(ProjectionSurfaces) applyProjection:[obj surface]];
		ofFill();
		for(int i=0;i<4;i++){
			/*ofSetColor(0, 0,0);
			ofEllipse([obj calibPoints][i].x*[obj surface]->aspect, [obj calibPoints][i].y, 0.05, 0.05);
			
			ofSetColor(255, 255,255);
			ofEllipse([obj calibPoints][i].x*[obj surface]->aspect, [obj calibPoints][i].y, 0.04, 0.04);
			ofSetColor(255, 0,0);
			ofEllipse([obj calibPoints][i].x*[obj surface]->aspect, [obj calibPoints][i].y, 0.01, 0.01);*/
			
			ofNoFill();

			switch (i) {
				case 0:
					ofSetColor(255,0,0);
					break;
				case 1:
					ofSetColor(255, 0,255);
					break;
				case 2:
					ofSetColor(0, 255,0);
					break;
				case 3:
					ofSetColor(255, 255,0);
					break;
				default:
					break;
			}
			
			ofSetLineWidth(4);

			ofEllipse([obj calibPoints][i].x*[obj surface]->aspect, [obj calibPoints][i].y, 0.02, 0.02);
			ofSetLineWidth(2);
			ofSetColor(255, 255,255);
			ofEllipse([obj calibPoints][i].x*[obj surface]->aspect, [obj calibPoints][i].y, 0.035, 0.035);

			
			

		}
		glPopMatrix();
	}
}

-(void) controlMousePressed:(float)x y:(float)y button:(int)button{
	ofxVec2f curMouse = [self convertMousePoint:ofxPoint2f(x,y)];
	CameraCalibrationObject * obj = [cameraCalibrations objectAtIndex:[cameraSelector selectedSegment]];
	
	float shortestDist = nil;
	for(int i=0;i<4;i++){
		if(shortestDist == nil || [obj calibHandles][i].distance(curMouse) < shortestDist){
			shortestDist = [obj calibHandles][i].distance(curMouse);
			selectedCorner = i;
		}
	}
	
	
	if([obj calibHandles][selectedCorner].distance(ofxPoint2f(curMouse.x, curMouse.y)) > 0.3){
		selectedCorner = -1;
	} 
	cout<<"Selected corner"<<selectedCorner<<endl;
	lastMousePos->x = curMouse.x;	
	lastMousePos->y = curMouse.y;	
}
-(void) controlMouseDragged:(float)x y:(float)y button:(int)button{
	CameraCalibrationObject * obj = [cameraCalibrations objectAtIndex:[cameraSelector selectedSegment]];
	
	ofxVec2f curMouse = [self convertMousePoint:ofxPoint2f(x,y)];
	ofxVec2f newPos =  [obj calibHandles][selectedCorner] + (curMouse-*lastMousePos);
	if(selectedCorner != -1){
		[obj calibHandles][selectedCorner] = ofxPoint2f(newPos);
		[userDefaults setDouble:newPos.x forKey:[NSString stringWithFormat:@"camera%d.corner%d.x",[cameraSelector selectedSegment], selectedCorner]];
		[userDefaults setDouble:newPos.y forKey:[NSString stringWithFormat:@"camera%d.corner%d.y",[cameraSelector selectedSegment], selectedCorner]];
	} else {		
		//*position += (curMouse- ((ofxPoint2f)*lastMousePos));
	}
	lastMousePos->x = curMouse.x;	
	lastMousePos->y = curMouse.y;	
	
	[obj recalculate];
}

-(void) controlMouseReleased:(float)x y:(float)y{
	/*	if(selectedCorner != -1){
	 [[self getCurrentSurface] setCorner:selectedCorner x:[self getCurrentSurface]->corners[selectedCorner]->x y:[self getCurrentSurface]->corners[selectedCorner]->y projector:[projectorsButton indexOfSelectedItem] surface:[surfacesButton indexOfSelectedItem] storeUndo:true];		
	 }*/
}

-(ofxPoint2f) convertMousePoint:(ofxPoint2f)p{
	CameraCalibrationObject * obj = [cameraCalibrations objectAtIndex:[cameraSelector selectedSegment]];
	
	ofxPoint2f p2 = ofxPoint2f(p);
	p2.x /= 640.0;
	p2.y /= 480.0;
	return p2; 	
}

-(IBAction) reset:(id)sender{
	CameraCalibrationObject * obj = [cameraCalibrations objectAtIndex:[cameraSelector selectedSegment]];
	[obj reset];
	
	for(int i=0;i<4;i++){
		[userDefaults setDouble:obj->calibHandles[i].x forKey:[NSString stringWithFormat:@"camera%d.corner%d.x",[cameraSelector selectedSegment], i]];
		[userDefaults setDouble:obj->calibHandles[i].y forKey:[NSString stringWithFormat:@"camera%d.corner%d.y",[cameraSelector selectedSegment], i]];
	}

}


-(ofxPoint2f) convertPoint:(ofxPoint2f)p fromCamera:(int)cam{
//	p.x /= [[cameraCalibrations objectAtIndex:cam] surface]->aspect;
	ofxPoint2f r = (ofxPoint2f) ((CameraCalibrationObject*)[cameraCalibrations objectAtIndex:cam])->coordWarp->transform(p.x, p.y);
	return r;
}
-(ofxPoint2f) convertPoint:(ofxPoint2f)p toCamera:(int)cam{
	
	ofxPoint2f r = ((CameraCalibrationObject*)[cameraCalibrations objectAtIndex:cam])->coordWarp->inversetransform(p.x, p.y);
//	r.x *= [[cameraCalibrations objectAtIndex:cam] surface]->aspect;
	//r.y = p.y;
	return r;
}

-(void) applyWarpOnCam:(int)cam{
	
	
	[((CameraCalibrationObject*)[cameraCalibrations objectAtIndex:cam]) applyWarp];
}
@end



@implementation CameraCalibrationObject
@synthesize name, surface,projector;
-(id) init{
	if([super init]){
		warp = new Warp();
		coordWarp = new coordWarping;	
		coordWarpCalibration = new coordWarping;
		for(int i=0;i<4;i++){
			calibPoints[i] = ofxPoint2f();
			calibHandles[i] = ofxPoint2f();
		}
	}
	return self;
}

-(ofxPoint2f *) calibHandles{
	return calibHandles;
}
-(ofxPoint2f *) calibPoints{
	return calibPoints;
}

-(void) recalculate{
	ofxPoint2f a[4];
	a[0] = ofxPoint2f(0,0);
	a[1] = ofxPoint2f(1,0);
	a[2] = ofxPoint2f(1,1);
	a[3] = ofxPoint2f(0,1);
	
	ofxPoint2f pts[4];
	ofxPoint2f hndls[4];
	for(int i=0;i<4;i++){
		pts[i] = [GetPlugin(ProjectionSurfaces) convertToProjection:calibPoints[i] surface:surface];
		hndls[i] = calibHandles[i];
		hndls[i].x /= surface->aspect;
	}
	
	coordWarpCalibration->calculateMatrix(hndls, pts);	
	
	ofxPoint2f corners[4];
	for(int u=0;u<4;u++){
		corners[u] = coordWarpCalibration->transform(a[u].x, a[u].y);
		warp->SetCorner(u,corners[u].x,corners[u].y);
	}
	
	warp->MatrixCalculate();
	coordWarp->calculateMatrix(a, warp->corners);		
	
	
}

-(void) applyWarp{
	glPushMatrix();
	if(strcmp([(projector) name]->c_str(), "Front") == 0){
		glViewport(0, 0, ofGetWidth()/3.0, ofGetHeight());
	} else {
		glViewport(ofGetWidth()/3.0, 0, ofGetWidth()/3.0, ofGetHeight());
	}
	
	float setW = 1.0;
	float setH = 1.0;
	if(strcmp([(projector) name]->c_str(), "Front") != 0){
		glTranslated(-1, 0, 0);
	}
	glScaled(3, 1, 1.0);
	warp->MatrixMultiply();	
	glScaled(setW, setH, 1.0);
}


-(void) reset{
	int choice = NSAlertDefaultReturn;
	NSString *title = [NSString stringWithFormat:NSLocalizedString(@"Do you want to reset the Calibration?", @"Title of alert panel which comes up when user chooses Quit")];
	choice = NSRunAlertPanel(title, 
							 NSLocalizedString(@"Resetting is not undoable\n\nIf you reset the calibration you will have to put four suitable calibration objects on the stage floor again.", @"Warning in the alert panel which comes up when user chooses Quit and there are unsaved documents."), 
							 NSLocalizedString(@"Reset", @"Choice (on a button) given to user which allows him/her to quit the application even though there are unsaved documents."),
							 NSLocalizedString(@"Cancel", @"Choice (on a button) given to user which allows him/her to review all unsaved documents if he/she quits the application without saving them all first."),     // ellipses
							 nil);
	
	if (choice == NSAlertDefaultReturn){           /* Cancel */
		calibHandles[0] = ofxPoint2f(0.0,0.0);
		calibHandles[1] = ofxPoint2f(1,0);
		calibHandles[2] = ofxPoint2f(1,1);
		calibHandles[3] = ofxPoint2f(0,1);
		[self recalculate];
	}
}




@end

