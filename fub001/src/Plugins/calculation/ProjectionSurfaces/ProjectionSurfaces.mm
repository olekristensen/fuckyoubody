//
//  _ExampleOutput.mm
//  openFrameworks
//
//  Created by Jonas Jongejan on 15/11/09.

#import "ProjectionSurfaces.h"
#import "Tracking.h"
#import <pthread.h>

@implementation ProjectorObject
@synthesize surfaces, name;

-(id) initWithName:(NSString*)n {
	if([super init]){
		name =  new string([n cString]); 
		width = 1024;
		height = 768;
		return self;
	}
}

@end

@implementation ProjectionSurfacesObject
-(id) initWithName:(NSString*)n projector:(id)proj{
	if([super init]){
		name =  new string([n cString]); 
		corners[0] = new ofxPoint2f(0,0);
		corners[1] = new ofxPoint2f(1,0);
		corners[2] = new ofxPoint2f(1,1);
		corners[3] = new ofxPoint2f(0,1);
		aspect = 1;
		warp = new Warp();
		coordWarp = new  coordWarping;
		projector = proj;
		
		for(int i=0;i<8;i++){
			trackingFilter[i] = new Filter();	
			trackingFilter[i]->setNl(9.413137469932821686e-04, 2.823941240979846506e-03, 2.823941240979846506e-03, 9.413137469932821686e-04);
			trackingFilter[i]->setDl(1, -2.5818614306773719263, 2.2466666427559748864, -.65727470210265670262);
		}
		
		
		
		[self recalculate];
		return self;
	}
}

-(void) recalculate{
	for(int i=0;i<4;i++){
		warp->SetCorner(i, (*corners[i]).x, (*corners[i]).y);
	}
	
	warp->MatrixCalculate();
	ofxPoint2f a[4];
	a[0] = ofxPoint2f(0,0);
	a[1] = ofxPoint2f(1,0);
	a[2] = ofxPoint2f(1,1);
	a[3] = ofxPoint2f(0,1);
	coordWarp->calculateMatrix(a, warp->corners);
	
}

-(void) setCorner:(int) n x:(float)x y:(float) y projector:(int)projector surface:(int)surface storeUndo:(BOOL)undo{
	NSUserDefaults *userDefaults = [[NSUserDefaults standardUserDefaults] retain];
	
	x = ofClamp(x, -1, 3);
	y = ofClamp(y, -1, 3);
	
	trackingDestinations[n] = new ofxPoint2f(x,y);
	for(int i=0;i<20;i++){
		trackingFilter[n*2]->filter(x);
		trackingFilter[n*2+1]->filter(y);
	}
	
	if(undo){
		NSArray * a = [NSArray arrayWithObjects:[NSNumber numberWithInt:n], [NSNumber numberWithFloat:x], [NSNumber numberWithFloat:y], nil];
		[self setCornerObject:a];
	} else {
		corners[n]->set(x,y);
	}
	
	[userDefaults setValue:[NSNumber numberWithDouble:corners[n]->x] forKey:[NSString stringWithFormat:@"projector%d.surface%d.corner%d.x",projector, surface, n]];
	[userDefaults setValue:[NSNumber numberWithDouble:corners[n]->y] forKey:[NSString stringWithFormat:@"projector%d.surface%d.corner%d.y",projector, surface, n]];
	[userDefaults release];	
}

-(void) setCornerObject:(NSArray*)obj{
	int corner = [[obj objectAtIndex:0] intValue];
	float x = [[obj objectAtIndex:1] floatValue]; 
	float y = [[obj objectAtIndex:2] floatValue];
	x = ofClamp(x, -1, 3);
	y = ofClamp(y, -1, 3);
	
	corners[corner]->set(x,y);
	[self recalculate];			
	lastUndoX = x;
	lastUndoY = y;
}

@end


@implementation ProjectionSurfaces

-(void) awakeFromNib{
	[super awakeFromNib];
}

-(void) initPlugin{
	userDefaults = [[NSUserDefaults standardUserDefaults] retain];
	
	[trackerButton removeAllItems];
	
	projectors = [NSMutableArray array];
	[projectors retain];
	[projectors addObject:[[ProjectorObject alloc] initWithName:@"Front"]];	
	[projectors addObject:[[ProjectorObject alloc] initWithName:@"Back"]];	
	[projectors addObject:[[ProjectorObject alloc] initWithName:@"Extra"]];	
	
	[projectorsButton setSegmentCount:[projectors count]];
	
	
	ProjectorObject * projector;
	
	pthread_mutex_init(&mutex, NULL);
	
	int projI = 0;
	
	for(projector in projectors){
		NSLog(@"Init projectionsurfaces");
		
		NSMutableArray * array = [NSMutableArray array];
		[array addObject:[[ProjectionSurfacesObject alloc] initWithName:@"Floor" projector:projector]];
		[array addObject:[[ProjectionSurfacesObject alloc] initWithName:@"Backwall" projector:projector]];
		[array addObject:[[ProjectionSurfacesObject alloc] initWithName:@"Projector" projector:projector]];
		
		[surfacesButton setSegmentCount:[array count]];
		
		[projector setSurfaces:array];
		//projector->surfaces = array;
		[projectorsButton setLabel:[NSString stringWithCString:projector->name->c_str()] forSegment:projI];
		[projectorsButton setWidth:0 forSegment:projI];
		
		ProjectionSurfacesObject * surface;
		int surfI = 0;
		for(surface in array){
			for(int i=0;i<4;i++){
				surface->corners[i]->x = [userDefaults doubleForKey:[NSString stringWithFormat:@"projector%d.surface%d.corner%d.x",projI, surfI, i]];
				surface->corners[i]->y = [userDefaults doubleForKey:[NSString stringWithFormat:@"projector%d.surface%d.corner%d.y",projI, surfI, i]];
			}
			surface->aspect = [userDefaults doubleForKey:[NSString stringWithFormat:@"projector%d.surface%d.aspect",projI, surfI]];
			[surface recalculate];
			surface->undoManager = undoManager;
			
			surface->trackerNumber = [userDefaults doubleForKey:[NSString stringWithFormat:@"projector%d.surface%d.trackerNumber",projI, surfI]];
			
			[surfacesButton setLabel:[NSString stringWithCString:surface->name->c_str()] forSegment:surfI];
			[surfacesButton setWidth:0 forSegment:surfI];
			
			surfI ++;
		}
		projI++;
	}
	
	[projectorsButton setSelectedSegment:0];
	[surfacesButton setSelectedSegment:0];	
	
	
	position = new ofPoint(0,0);
	scale = 0.3;
	
	lastMousePos = new ofxVec2f();
	lastMousePosNotScaled = new ofxVec2f();
	[aspectSlider setFloatValue:[self getCurrentSurface]->aspect];	
	
	for (int i=1; i<4; i++) {
		[trackerButton addItemWithTitle:[NSString stringWithFormat:@"Tracker %i",i]];
	}
	
	[trackingButton setEnabled:NO];
	[calibrateButton setEnabled:NO];
	[self updateTrackerButton];	
}

-(IBAction) selectProjector:(id)sender{
	[aspectSlider setFloatValue:[self getCurrentSurface]->aspect];
	[self updateTrackerButton];
}

-(IBAction) selectSurface:(id)sender{
	[aspectSlider setFloatValue:[self getCurrentSurface]->aspect];
	[self updateTrackerButton];
}

-(IBAction) calibrate:(id)sender{
	[self getCurrentSurface]->calibrating = true;
}

-(IBAction) selectTracker:(id)sender{
	[self getCurrentSurface]->trackerNumber = [sender indexOfSelectedItem];	
	int projector = [projectorsButton selectedSegment];
	int surface = [surfacesButton selectedSegment];
	[userDefaults setValue:[NSNumber numberWithInt:[sender indexOfSelectedItem]] forKey:[NSString stringWithFormat:@"projector%d.surface%d.trackerNumber",projector, surface]];
}

-(void) updateTrackerButton {
	[trackerButton selectItemAtIndex:[self getCurrentSurface]->trackerNumber];
	if([self getCurrentSurface]->tracking){
		[trackingButton setState:NSOnState];
	} else {
		[trackingButton setState:NSOffState];
	}
}

-(IBAction) setAspect:(id)sender{
	[self getCurrentSurface]->aspect = [sender floatValue];
	int projector = [projectorsButton selectedSegment];
	int surface = [surfacesButton selectedSegment];
	[userDefaults setValue:[NSNumber numberWithFloat:[sender floatValue]] forKey:[NSString stringWithFormat:@"projector%d.surface%d.aspect",projector, surface]];
}

-(void) setup{
	font = new ofTrueTypeFont();
	font->loadFont("LucidaGrande.ttc",40, true, true, true);
	recoilLogo = new ofImage();
	NSBundle *bundle = [NSBundle mainBundle];
	recoilLogo->loadImage([[bundle pathForResource:@"recoilLogoForCalibration" ofType:@"png"] cString]);
	
}

-(void) controlDraw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)timeStamp{
	w = ofGetWidth();
	h = ofGetHeight();
	int numProjectors = [projectors count];
	int selectedProjector = [projectorsButton selectedSegment];
	
	float projWidth = [self getCurrentProjector]->width*numProjectors;
	float projHeight = [self getCurrentProjector]->height;	
	float aspect =(float)  projWidth/projHeight;
	float viewAspect = (float) w / h;
	
	float pw = aspect/numProjectors;
	
	
	ofBackground(0, 0, 0);
	ofFill();
	
	ofEnableAlphaBlending();
	glPushMatrix();{		
		glTranslated(w/2.0, h/2.0, 0);
		glTranslated(position->x, position->y, 0);
		
		float scaleC; 
		if(viewAspect > aspect){
			scaleC = w/aspect;
			glScaled(w/aspect, w/aspect, 1.0);
		} else {
			scaleC = h;
			glScaled(h, h, 1.0);	
		}
		
		glScaled(scale, scale, 1);
		
		
		float totalWidth = aspect;
		glPushMatrix();{
			glTranslated(-totalWidth/2.0, -0.5, 0);
			ProjectorObject * proj;
			int i=0;
			for(proj in projectors){
				if(i == selectedProjector)
					ofSetColor(255, 255, 255, 30);
				else
					ofSetColor(255, 255, 255, 10);					
				ofRect(0, 0, pw,1);				
				ofNoFill();
				ofSetColor(255, 255, 255, 70);
				ofRect(0, 0, pw, 1);
				ofFill();
				
				glTranslated(pw, 0, 0);
				i++;
			}
		}glPopMatrix();
		
		ProjectionSurfacesObject* surface = [self getCurrentSurface];
		ofSetColor(255, 255, 255, 255);
		
		glPushMatrix();{
			glTranslated(-totalWidth/2.0, -0.5, 0);
			glPushMatrix();{
				glScaled(numProjectors*pw, 1, 1);
				surface->warp->MatrixMultiply();
				glScaled(1.0/surface->aspect,  1, 1);
				[self drawGrid:*surface->name aspect:surface->aspect resolution:10 drawBorder:true alpha:1.0 fontSize:1.0 simple:NO];
			}glPopMatrix();
			
			
			
			//Draw current projectorsurface
			for(int i=0;i<4;i++){			
				ofFill();
				if(selectedCorner == i){
					ofSetColor(255, 255,0,70);
				} else {
					ofSetColor(64, 128,220,70);			
				}
				ofCircle(surface->corners[i]->x*aspect, surface->corners[i]->y, 0.045);
				ofNoFill();
				ofSetColor(0, 0,0,192);
				ofSetLineWidth(4);
				ofCircle(surface->corners[i]->x*aspect, surface->corners[i]->y, 0.045);

				if(selectedCorner == i){
					ofSetColor(255, 255,0,255);
				} else {
					ofSetColor(128, 255,255,255);
				}
				ofSetLineWidth(1.5);
				ofCircle(surface->corners[i]->x*aspect, surface->corners[i]->y, 0.045);
			}
			
		}glPopMatrix();
	} glPopMatrix();
}

-(void) update:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{	
	//scale = 0.3;
}

-(void) draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	ofPushStyle();
	
	if([showGrid state] == NSOnState){
		
		ProjectorObject * proj;
		string s =  *[self getCurrentSurface]->name;
		int i=0;
		for(proj in projectors){
			ProjectionSurfacesObject * surf = [self getProjectionSurfaceByName:*proj->name surface:s];
			BOOL simple = YES;
			if([projectorsButton selectedSegment] == i){
				simple = NO;
			}
			ofSetColor(255, 255, 255);
			[self apply:*proj->name surface:s];
			[self drawGrid:s aspect:surf->aspect resolution:10 drawBorder:false alpha:1.0 fontSize:1.0 simple:simple];
			
			glPopMatrix();
			i++;
		}
	}
	
	
	if([[globalController testFloorButton] state] == NSOnState){
		ProjectionSurfacesObject * surf = [self getProjectionSurfaceByName:"Front" surface:"Floor"];
		
		ofSetColor(255, 255, 255);
		[self apply:"Front" surface:"Floor"];
		[self drawGrid:"Floor" aspect:[self getAspect] resolution:10 drawBorder:false alpha:1.0 fontSize:1.0 simple:NO];
		
		glPopMatrix();
		[self apply:"Back" surface:"Floor"];
		[self drawGrid:"Floor" aspect:[self getAspect] resolution:10 drawBorder:false alpha:1.0 fontSize:1.0 simple:NO];
		
		glPopMatrix();
	}
	if([[globalController testScreenButton] state] == NSOnState){
		ProjectionSurfacesObject * surf = [self getProjectionSurfaceByName:"Front" surface:"Floor"];
		
		ofSetColor(255, 255, 255);
		[self apply:"Front" surface:"Backwall"];
		[self drawGrid:"Screen" aspect:[self getAspect] resolution:10 drawBorder:false alpha:1.0 fontSize:1.0 simple:NO];
		
		glPopMatrix();
		[self apply:"Back" surface:"Backwall"];
		[self drawGrid:"Screen" aspect:[self getAspect] resolution:10 drawBorder:false alpha:1.0 fontSize:1.0 simple:NO];
		
		glPopMatrix();
	}
	
	ofSetColor(255, 255, 255, 255);
	ofRect(0, 0, 0.001, 0.001);
	ofRect(0.33, 0, 0.002, 0.001);
	ofRect(0.66, 0, -0.002, 0.001);
	ofRect(1, 0, -0.001, 0.001);
	
	ofRect(0, 1.0, 0.001, -0.001);
	ofRect(0.33, 1.0, 0.002, -0.001);
	ofRect(0.66, 1.0, 0.002, -0.001);
	ofRect(1, 1.0, -0.001, -0.001);
	
	ofPopStyle();
}

-(void) drawGrid:(string)text aspect:(float)aspect resolution:(float)resolution drawBorder:(bool)drawBorder alpha:(float)a fontSize:(float)fontSize simple:(BOOL)simple{
	if (pthread_mutex_lock(&mutex) == 0) {
		ofSetLineWidth(1);
		ofSetColor(255, 255, 255, 255*a);
		int xNumber = resolution+floor((aspect-1)*resolution);
		int yNumber = resolution;
		fontSize *= 0.0025;
		
		for(int i=0;i<=yNumber;i++){
			ofLine(0, i*1.0/resolution, aspect, i*1.0/resolution);
		}
		
		int xNumberCentered = xNumber;
		
		if (xNumber%2 == 1) {
			xNumberCentered--;
		}
		for(int i=0;i<=xNumberCentered;i++){
			ofLine(((i*1.0/resolution)-((xNumberCentered/resolution)*0.5))+(0.5*aspect), 0, ((i*1.0/resolution)-((xNumberCentered/resolution)*0.5))+(0.5*aspect), 1.0);
			
		}
		if(drawBorder){
			ofNoFill();
			ofSetLineWidth(6);
			
			ofSetColor(64, 128, 220,255*a);
			ofRect(0, 0, 1*aspect, 1);
			
			ofFill();
			ofSetColor(255, 255, 255,255*a);
			ofSetLineWidth(1);
		} else {
			
			//white sides
			ofLine(aspect, 0, aspect, 1);
			ofLine(0, 0, 0, 1);
			
			//yellow corners
			ofSetLineWidth(3);
			ofSetColor(255, 255,0,255*a);
			
			ofLine(0, 0, 0.05, 0.0);
			ofLine(0, 0, 0.0, 0.05);
			
			ofLine(0, 1, 0.05, 1);
			ofLine(0, 1, 0.0, 0.95);
			
			ofLine(aspect, 0, aspect-0.05, 0.0);
			ofLine(aspect, 0, aspect, 0.05);
			
			ofLine(aspect, 1, aspect-0.05, 1.0);
			ofLine(aspect, 1, aspect, 0.95);
			
		}
		
		
		ofSetLineWidth(6);
		ofSetColor(255, 255,0,255*a);
		
		ofFill();
		if(!simple){
			
			//up arrow
			glBegin(GL_POLYGON);{
				
				glVertex2f((aspect*0.5), 0);
				glVertex2f((aspect*0.5)-(0.05), 1.0/resolution);
				glVertex2f((aspect*0.5)+(0.05), 1.0/resolution);
				glVertex2f((aspect*0.5), 0);		
			} glEnd();
			
			ofSetColor(0,0,0,255*a);
			
			glPushMatrix();{
				
				float fontSizeForN = fontSize * 0.40;
				
				glScaled(fontSizeForN, fontSizeForN, 1.0);
				
				glTranslated( aspect*0.5*1.0/fontSizeForN-font->stringWidth("N")/1.5,  0.1*1.0/fontSizeForN-(font->stringHeight("N")*0.3), 0);	
				
				font->drawString("N",0, 0);
				
			} glPopMatrix();
			
			ofSetColor(255, 255,0,255*a);
			
			ofNoFill();
			
			glBegin(GL_POLYGON);{
				
				glVertex2f((aspect*0.5)-(0.05), 1.0);
				glVertex2f((aspect*0.5), 1.0-(1.0/resolution));
				glVertex2f((aspect*0.5)+(0.05), 1.0);
				
			} glEnd();
			
			
			// center cross
			ofLine((aspect*0.5)-0.05, 0.5, (aspect*0.5)+0.05, 0.5);
			ofLine((aspect*0.5), 1.0/resolution, (aspect*0.5), 1.0-(0.5/resolution));
			
			glPushMatrix();{
				
				glScaled(fontSize, fontSize, 1.0);
				if(aspect < 1.0){
					glTranslated( aspect*0.5*1.0/fontSize-(recoilLogo->getHeight()*0.4*aspect),  0.5*1.0/fontSize-(recoilLogo->getWidth()*aspect)/2.0, 0);	
					glRotated(90, 0, 0, 1.0);
					glScaled(aspect, aspect, 1.0);
				} else {
					glTranslated( aspect*0.5*1.0/fontSize-recoilLogo->getWidth()/2.0,  0.5*1.0/fontSize+(recoilLogo->getHeight()*0.4), 0);	
				}
				ofFill();
				ofSetColor(255,255,255,255);
				recoilLogo->draw(recoilLogo->getWidth()*0.20, recoilLogo->getHeight()*0.2075, recoilLogo->getWidth()*0.6,recoilLogo->getHeight()*0.6);
			} glPopMatrix();
			// center elipse
			ofNoFill();
			ofSetCircleResolution(100);
			if(aspect < 1.0){
				ofSetLineWidth(5);
				ofSetColor(64, 128, 220,255*a);
				for (float i = 1.35; i < 1.37; i+=0.01) {
					ofEllipse(aspect/2, 0.5, aspect*i*((aspect/2)/aspect), aspect*i*0.5);
				}
			} else {
				ofSetLineWidth(5);
				ofSetColor(64, 128, 220,255*a);
				for (float i = 1.35; i < 1.37; i+=0.01) {
					ofEllipse(aspect/2, 0.5,i*((aspect/2)/aspect), i*0.5);
				}
			}
			
			// text label
			ofSetLineWidth(1);
			
			//	glTranslated( aspect*0.5*1/0.003-verdana.stringWidth(text)/2.0,  0.5*1/0.003+verdana.stringHeight(text)/2.0, 0);
			
			glPushMatrix();{
				glScaled(fontSize, fontSize, 1.0);
				if(aspect < 1.0){
					glTranslated( aspect*0.5*1.0/fontSize+(font->stringHeight(text)*0.3*aspect),  0.5*1.0/fontSize-(font->stringWidth(text)*aspect)/2.0, 0);	
					glRotated(90, 0, 0, 1.0);
					glScaled(aspect, aspect, 1.0);
				} else {
					glTranslated( aspect*0.5*1.0/fontSize-font->stringWidth(text)/2.0,  0.5*1.0/fontSize-(font->stringHeight(text)*0.3), 0);	
				}
				ofSetColor(0, 0, 0,200);
				ofNoFill();
				ofSetLineWidth(6);
				font->drawStringAsShapes(text,0,0);
				ofFill();
				ofSetColor(255, 255, 255,255);
				font->drawStringAsShapes(text,0,0);
				ofSetLineWidth(1);
			} glPopMatrix();
		}
		pthread_mutex_unlock(&mutex);
	}
	
}

-(ofxPoint2f) convertMousePoint:(ofxPoint2f)p{
	int numProjectors = [projectors count];
	int selectedProjector = [projectorsButton selectedSegment];
	
	ofxPoint2f p2 = ofxPoint2f(p.x, p.y);
	float projWidth = [self getCurrentProjector]->width*numProjectors;
	float projHeight = [self getCurrentProjector]->height;	
	float aspect =(float)  projWidth/projHeight;
	float viewAspect = (float) w / h;

	
	p2-= ofxPoint2f(w/2.0, h/2.0);	
	 
	
	
	p2 -= *position;
	if(viewAspect > aspect){
		p2 /= ofxPoint2f(w,w)/aspect;
	} else {
		p2 /= ofxPoint2f((float)h,(float)h);
	}
	
	

	p2 /= scale;
	

	p2 += ofxPoint2f(aspect*0.5, 0.5);
	
	
	p2 /= ofxPoint2f((float)aspect,(float)1);
	
	cout<<p2.x<<"  "<<p2.y<<endl;

	return p2;
	//	glTranslated(-projWidth/2.0, -projHeight/2.0, 0);
	
}

-(void) applyProjection:(ProjectionSurfacesObject*) obj width:(float) _w height:(float) _h{
	//	cout<<_w<<"  "<<_h<<endl;
	
	glPushMatrix();
	if(strcmp([((ProjectorObject*)obj->projector) name]->c_str(), "Front") == 0){
		glViewport(0, 0, ofGetWidth()/3.0, ofGetHeight());
	} else if(strcmp([((ProjectorObject*)obj->projector) name]->c_str(), "Extra") == 0){
		glViewport(2*ofGetWidth()/3.0, 0, ofGetWidth()/3.0, ofGetHeight());
	} else {
		glViewport(ofGetWidth()/3.0, 0, ofGetWidth()/3.0, ofGetHeight());
	}
	
	
	float setW = 1.0/ (obj->aspect);
	float setH = 1.0;
	if(strcmp([((ProjectorObject*)obj->projector) name]->c_str(), "Back") == 0){
		glTranslated(-_w, 0, 0);
	}
	if(strcmp([((ProjectorObject*)obj->projector) name]->c_str(), "Extra") == 0){
		glTranslated(-2*_w, 0, 0);
	}
	glScaled(_w*3, _h, 1.0);
	obj->warp->MatrixMultiply();
	glScaled(setW, setH, 1.0);
	
	lastAppliedSurface = obj;
	
}
-(void) applyProjection:(ProjectionSurfacesObject*) obj{
	[self applyProjection:obj width:1 height:1];
}

-(void) apply:(string)projection surface:(string)surface{
	[self apply:projection surface:surface width:1 height:1];
}

-(void) apply:(string)projection surface:(string)surface width:(float) _w height:(float) _h{
	[self applyProjection:[self getProjectionSurfaceByName:projection surface:surface] width:_w height:_h];
}

-(ProjectionSurfacesObject*) getProjectionSurfaceByName:(string)projection surface:(string)surface{
	ProjectorObject * proj;
	for(proj in projectors){
		if(strcmp(proj->name->c_str(), projection.c_str()) == 0){
			ProjectionSurfacesObject * surf;
			NSArray * a = proj->surfaces;
			for(surf in a){
				if(strcmp(surf->name->c_str(), surface.c_str()) == 0){
					return surf;
				}
				
			}
		}
	}	
	cout<<"No surface found"<<endl;
}

-(ProjectorObject*) getProjectorByName:(string)projection{
	ProjectorObject * proj;
	for(proj in projectors){
		if(strcmp(proj->name->c_str(), projection.c_str()) == 0){
			return proj;		
		}
	}	
	cout<<"No projector found"<<endl;
	
}

-(ofxPoint2f) convertToProjection:(ofxPoint2f)p{
	if(lastAppliedSurface != nil){
		return [self convertToProjection:p surface:lastAppliedSurface]; 
	}
}
-(ofxPoint2f) convertFromProjection:(ofxPoint2f)p{
	if(lastAppliedSurface != nil){
		return [self convertFromProjection:p surface:lastAppliedSurface]; 
	}	
}
-(ofxPoint2f) convertToProjection:(ofxPoint2f)p surface:(ProjectionSurfacesObject*)surface{
	p.x /= surface->aspect;
	ofxPoint2f r = (ofxPoint2f) surface->coordWarp->transform(p.x, p.y);
	return r;
}
-(ofxPoint2f) convertFromProjection:(ofxPoint2f)p surface:(ProjectionSurfacesObject*)surface{
	ofxPoint2f r = surface->coordWarp->inversetransform(p.x, p.y);
	r.x *= surface->aspect;
	//r.y = p.y;
	return r;
}

-(ofxPoint2f) convertPoint:(ofxPoint2f)p toProjection:(string)projection fromSurface:(string) surface{
	return [self convertToProjection:p surface:[self getProjectionSurfaceByName:projection surface:surface]];	
}
-(ofxPoint2f) convertPoint:(ofxPoint2f)p fromProjection:(string)projection toSurface:(string)surface{
	return [self convertFromProjection:p surface:[self getProjectionSurfaceByName:projection surface:surface]];
}

-(float) getAspect{
	if(lastAppliedSurface != nil){
		return lastAppliedSurface->aspect; 
	}
}

-(float) getAspectForProjection:(string) projection surface:(string) surface{
	return [self getProjectionSurfaceByName:projection surface:surface]->aspect;
}

-(void) controlMousePressed:(float)x y:(float)y button:(int)button{
	ofxVec2f curMouse = [self convertMousePoint:ofxPoint2f(x,y)];
	
	selectedCorner = [self getCurrentSurface]->warp->GetClosestCorner(curMouse.x, curMouse.y);
	if([self getCurrentSurface]->corners[selectedCorner]->distance(ofxPoint2f(curMouse.x, curMouse.y)) > 0.1){
		selectedCorner = -1;
	} else {
		//		[[self getCurrentSurface] setCorner:selectedCorner x:[self getCurrentSurface]->corners[selectedCorner]->x y:[self getCurrentSurface]->corners[selectedCorner]->y projector:[projectorsButton indexOfSelectedItem] surface:[surfacesButton indexOfSelectedItem] storeUndo:true];	
	}
	lastMousePos->x = curMouse.x;	
	lastMousePos->y = curMouse.y;	
	lastMousePosNotScaled->x = x;
	lastMousePosNotScaled->y = y;
}
-(void) controlMouseDragged:(float)x y:(float)y button:(int)button{
	ofxVec2f curMouse = [self convertMousePoint:ofxPoint2f(x,y)];
	ofxVec2f newPos =  [self getCurrentSurface]->warp->corners[selectedCorner] + (curMouse-*lastMousePos);
	if(selectedCorner != -1){
		[[self getCurrentSurface] setCorner:selectedCorner x:newPos.x y:newPos.y projector:[projectorsButton selectedSegment] surface:[surfacesButton selectedSegment] storeUndo:NO];
	} else {		
		*position += (ofPoint(x,y) - ((ofxPoint2f)*lastMousePosNotScaled))*scale*2.0;
	}
	lastMousePos->x = curMouse.x;	
	lastMousePos->y = curMouse.y;	
	lastMousePosNotScaled->x = x;
	lastMousePosNotScaled->y = y;	
	[[self getCurrentSurface] recalculate];
}

-(void) controlMouseReleased:(float)x y:(float)y{
	if(selectedCorner != -1){
		[[self getCurrentSurface] setCorner:selectedCorner x:[self getCurrentSurface]->corners[selectedCorner]->x y:[self getCurrentSurface]->corners[selectedCorner]->y projector:[projectorsButton selectedSegment] surface:[surfacesButton selectedSegment ] storeUndo:true];		
	}
}

-(void) controlMouseScrolled:(NSEvent *)theEvent{
	scale += [theEvent deltaY]*0.01;
	if(scale > 3)
		scale = 3;
	if(scale < 0.1){
		scale = 0.1;
	}
}

- (void) controlKeyPressed:(int)key{
	if(key >= 123 && key <= 126){
		if(selectedCorner != -1){
			ofxVec2f newPos =  [self getCurrentSurface]->warp->corners[selectedCorner];
			float n = 0.0003;
			if(key == 123){
				newPos += ofxVec2f(-n,0);
			}
			if(key == 124){
				newPos += ofxVec2f(n,0);
			}
			if(key == 125){
				newPos += ofxVec2f(0,n);
			}
			if(key == 126){
				newPos += ofxVec2f(0,-n);
			}
			
			[[self getCurrentSurface] setCorner:selectedCorner x:newPos.x y:newPos.y projector:[projectorsButton selectedSegment] surface:[surfacesButton selectedSegment] storeUndo:NO];
		}
		[[self getCurrentSurface] recalculate];
	}
	
}

-(ProjectorObject*) getCurrentProjector{
	return [projectors objectAtIndex:[projectorsButton selectedSegment]];
}
-(ProjectionSurfacesObject*) getCurrentSurface{
	return [[self getCurrentProjector]->surfaces objectAtIndex:[surfacesButton selectedSegment]];	
}

-(ofxPoint2f) getFloorCoordinateOfProjector:(int)proj{
	ofxVec2f pf11 = [self convertPoint:ofxPoint2f(0.15,1) fromProjection:"Front" toSurface:"Floor"];
	ofxVec2f pf12 = [self convertPoint:ofxPoint2f(0.15,0) fromProjection:"Front" toSurface:"Floor"];
	ofxVec2f pf21 = [self convertPoint:ofxPoint2f(0.45,1) fromProjection:"Front" toSurface:"Floor"];
	ofxVec2f pf22 = [self convertPoint:ofxPoint2f(0.45,0) fromProjection:"Front" toSurface:"Floor"];
	
	
	ofxVec2f pb11 = [self convertPoint:ofxPoint2f(0.55,1) fromProjection:"Back" toSurface:"Floor"];
	ofxVec2f pb21 = [self convertPoint:ofxPoint2f(0.95,1) fromProjection:"Back" toSurface:"Floor"];
	ofxVec2f pb12 = [self convertPoint:ofxPoint2f(0.55,0) fromProjection:"Back" toSurface:"Floor"];
	ofxVec2f pb22 = [self convertPoint:ofxPoint2f(0.95,0) fromProjection:"Back" toSurface:"Floor"];
	
	//B i y = a+bx
	float bf1 =((float)pf12.y-pf11.y)/(pf12.x-pf11.x);
	float bf2 =((float)pf22.y-pf21.y)/(pf22.x-pf21.x);
	
	float bb1 =((float)pb12.y-pb11.y)/(pb12.x-pb11.x);
	float bb2 =((float)pb22.y-pb21.y)/(pb22.x-pb21.x);
	
	//A i y = a+bx <=> a = y - bx
	float af1 = pf11.y - bf1*pf11.x;
	float af2 = pf21.y - bf2*pf21.x;
	
	float ab1 = pb11.y - bb1*pb11.x;
	float ab2 = pb21.y - bb2*pb21.x;
	
	//intersection xi = - (a1 - a2) / (b1 - b2) yi = a1 + b1xi
	ofxPoint2f iFront = ofxPoint2f(-(af1 - af2)/(bf1-bf2) , af1 + bf1*(-(af1 - af2)/(bf1-bf2)));
	ofxPoint2f iBack = ofxPoint2f(-(ab1 - ab2)/(bb1-bb2) , ab1 + bb1*(-(ab1 - ab2)/(bb1-bb2)));
	
	if(proj == 0){
		return iFront;
	} else if (proj == 1){
		return iBack;
	}
	
}
-(ofxVec2f) getFloorVectorBetweenProjectors{
	return [self getFloorCoordinateOfProjector:0] - [self getFloorCoordinateOfProjector:1];
}

@end
