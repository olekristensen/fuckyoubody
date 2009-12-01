//
//  _ExampleOutput.mm
//  openFrameworks
//
//  Created by Jonas Jongejan on 15/11/09.

#import "ProjectionSurfaces.h"
#import "_ExampleOutput.h"



@implementation ProjectorObject
@synthesize surfaces;

-(id) initWithName:(NSString*)n{
	if([super init]){
		name =  new string([n cString]); 
		width = 1024;
		height = 768;
		return self;
	}
}
@end

@implementation ProjectionSurfacesObject
-(id) initWithName:(NSString*)n{
	if([super init]){
		name =  new string([n cString]); 
		corners[0] = new ofxPoint2f(0,0);
		corners[1] = new ofxPoint2f(1,0);
		corners[2] = new ofxPoint2f(1,1);
		corners[3] = new ofxPoint2f(0,1);
		aspect = 1;
		warp = new Warp();
		coordWarp = new  coordWarping;
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
	
	
	[projectorsButton removeAllItems];
	[surfacesButton removeAllItems];
	
	projectors = [NSMutableArray array];
	[projectors retain];
	[projectors addObject:[[ProjectorObject alloc] initWithName:@"Front"]];	
	[projectors addObject:[[ProjectorObject alloc] initWithName:@"Back"]];	
	
	ProjectorObject * projector;
	
	int projI = 0;
	// do thread work
	for(projector in projectors){
		NSLog(@"Init projectionsurfaces");
		
		NSMutableArray * array = [NSMutableArray array];
		[array addObject:[[ProjectionSurfacesObject alloc] initWithName:@"Floor"]];
		[array addObject:[[ProjectionSurfacesObject alloc] initWithName:@"Backwall"]];
		
		[projector setSurfaces:array];
		//projector->surfaces = array;
		[projectorsButton addItemWithTitle:[NSString stringWithCString:projector->name->c_str()]];
		
		ProjectionSurfacesObject * surface;
		int surfI = 0;
		for(surface in array){
			for(int i=0;i<4;i++){
				surface->corners[i]->x = [userDefaults doubleForKey:[NSString stringWithFormat:@"projector%d.surface%d.corner%d.x",projI, surfI, i]];
				surface->corners[i]->y = [userDefaults doubleForKey:[NSString stringWithFormat:@"projector%d.surface%d.corner%d.y",projI, surfI, i]];
			}
			surface->aspect =  [userDefaults doubleForKey:[NSString stringWithFormat:@"projector%d.surface%d.aspect",projI, surfI]];
			[surface recalculate];
			surface->undoManager = undoManager;
			
			[surfacesButton addItemWithTitle:[NSString stringWithCString:surface->name->c_str()]];	
			//			NSMenuItem * item = [surfacesButton lastItem];
			/*	if(surfI == 0 && projI == 0){
			 [item setKeyEquivalent:@"a"];
			 [item setKeyEquivalentModifierMask:NSCommandKeyMask];
			 [surfacesButton set
			 }*/
			surfI ++;
		}
		projI++;
	}

	position = new ofPoint(0,0);
	scale = 0.8;
	
	lastMousePos = new ofxVec2f;
	[aspectSlider setFloatValue:[self getCurrentSurface]->aspect];	
	
}

-(IBAction) selectProjector:(id)sender{
	[aspectSlider setFloatValue:[self getCurrentSurface]->aspect];
}
-(IBAction) selectSurface:(id)sender{
	[aspectSlider setFloatValue:[self getCurrentSurface]->aspect];	
}

-(IBAction) setAspect:(id)sender{
	[self getCurrentSurface]->aspect = [sender floatValue];
	int projector = [projectorsButton indexOfSelectedItem];
	int surface = [surfacesButton indexOfSelectedItem];
	[userDefaults setValue:[NSNumber numberWithFloat:[sender floatValue]] forKey:[NSString stringWithFormat:@"projector%d.surface%d.aspect",projector, surface]];
}

-(void) setup{
	font = new ofTrueTypeFont();
	font->loadFont("LucidaGrande.ttc",40, true, true, true);

}

-(void) controlDraw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)timeStamp{
	w = ofGetWidth();
	h = ofGetHeight();
	ofBackground(0, 0, 0);
	
	glPushMatrix();
	
	float projWidth = [self getCurrentProjector]->width;
	float projHeight = [self getCurrentProjector]->height;	
	float aspect =(float)  projHeight/projWidth;
	float viewAspect = (float)ofGetHeight() / ofGetWidth();
	
	glTranslated(ofGetWidth()/2.0, ofGetHeight()/2.0, 0);
	glTranslated(position->x, position->y, 0);
	if(viewAspect > aspect){
		glScaled(ofGetWidth(), ofGetWidth(), 1.0);
	} else {
		glScaled(ofGetHeight()/aspect, ofGetHeight()/aspect, 1.0);	
	}
	glScaled(scale, scale, 1);
	glTranslated(-0.5, -aspect/2.0, 0);	 
	ofEnableAlphaBlending();
	ofSetColor(255, 255, 255, 30);
	ofRect(0, 0, 1, aspect);
	ofSetColor(255, 255, 255, 70);
	ofNoFill();
	ofRect(0, 0, 1, aspect);
	ofFill();
	
	//Draw current projectorsurface
	for(int i=0;i<4;i++){
		ProjectionSurfacesObject* surface = [self getCurrentSurface];
		ofSetColor(255, 255, 255, 255);
		[self applyProjection:surface width:1.0 height:aspect];	
		[self drawGrid:*surface->name aspect:surface->aspect resolution:10 drawBorder:true alpha:1.0 fontSize:1.0];
		glPopMatrix();
		
		
		ofSetColor(255, 0, 0,255);
		ofNoFill();
		ofCircle(surface->corners[i]->x, surface->corners[i]->y*aspect, 0.015);
		ofSetColor(255, 0, 0,70);
		ofFill();
		ofCircle(surface->corners[i]->x, surface->corners[i]->y*aspect, 0.015);
	}
	
	glPopMatrix();}

-(void) update{
}

-(void) draw{
	ProjectionSurfacesObject* surface = [self getCurrentSurface];
	[self applyProjection:surface];
	{
		//	[self apply:"Front" surface:"Floor"];
		ofSetColor(255, 255, 255);
		if([showGrid state] == NSOnState){
			[self drawGrid:*surface->name aspect:surface->aspect resolution:10 drawBorder:false alpha:1.0 fontSize:1.0];
		}
	} glPopMatrix();
}

-(void) drawGrid:(string)text aspect:(float)aspect resolution:(float)resolution drawBorder:(bool)drawBorder alpha:(float)a fontSize:(float)fontSize{
	ofEnableAlphaBlending();
	ofSetColor(255, 255, 255, 255*a);
	int xNumber = resolution+floor((aspect-1)*resolution);
	int yNumber = resolution;
	
	for(int i=0;i<=yNumber;i++){
		ofLine(0, i*1.0/resolution, aspect, i*1.0/resolution);
	}
	for(int i=0;i<=xNumber;i++){
		ofLine(i*1.0/resolution, 0, i*1.0/resolution, 1.0);
		
	}
	if(drawBorder){
		ofNoFill();
		ofSetLineWidth(5);
		
		ofSetColor(255, 0, 255255*a);
		ofRect(0, 0, 1*aspect, 1);
		
		ofFill();
		ofSetColor(255, 255, 255,255*a);
		ofSetLineWidth(1);
	} else {
		ofLine(aspect, 0, aspect, 1);
	}
	fontSize *= 0.003;
	glScaled(fontSize, fontSize, 1.0);
	//	glTranslated( aspect*0.5*1/0.003-verdana.stringWidth(text)/2.0,  0.5*1/0.003+verdana.stringHeight(text)/2.0, 0);
	
	if(aspect < 1.0){
		glTranslated( aspect*0.5*1.0/fontSize-font->stringHeight(text)/2.0,  10, 0);	
		
		glRotated(90, 0, 0, 1.0);
	} else {
		glTranslated( aspect*0.5*1.0/fontSize-font->stringWidth(text)/2.0,  0.5*1.0/fontSize+font->stringHeight(text)/2.0, 0);	
	}
	
	font->drawString(text,0,0);
}

-(ofxPoint2f) convertPoint:(ofxPoint2f)p{
	ofxPoint2f p2 = ofxPoint2f(p.x, p.y);
	float projWidth = [self getCurrentProjector]->width;
	float projHeight = [self getCurrentProjector]->height;	
	float aspect =(float)  projHeight/projWidth;
	float viewAspect = (float)w / h;
	
	p2-= ofxPoint2f(w/2.0, h/2.0);	
	p2 -= *position;
	if(viewAspect > aspect){
		p2 /= ofxPoint2f(w,w);
	} else {
		p2 /= ofxPoint2f((float)h/aspect,(float)h/aspect);
	}
	
	p2 /= ofxPoint2f((float)scale,(float)scale);
	p2 -= ofxPoint2f(-0.5, -aspect/2.0);
	p2 /= ofxPoint2f((float)1.0,(float)aspect);
	return p2;
	//	glTranslated(-projWidth/2.0, -projHeight/2.0, 0);
 	
}

-(void) applyProjection:(ProjectionSurfacesObject*) obj width:(float) _w height:(float) _h{
	//	cout<<_w<<"  "<<_h<<endl;
	glPushMatrix();
	float setW = 1.0/ (obj->aspect);
	float setH = 1.0;
	
	glScaled(_w, _h, 1.0);
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
	ProjectorObject * proj;
	
	
	
	for(proj in projectors){
		if(strcmp(proj->name->c_str(), projection.c_str()) == 0){
			ProjectionSurfacesObject * surf;
			NSArray * a = proj->surfaces;
			for(surf in a){
				if(strcmp(surf->name->c_str(), surface.c_str()) == 0){
					//	cout<<"found"<<endl;
					[self applyProjection:surf width:_w height:_h];
				}
				
			}
		}
	}
	
}

-(float) getAspect{
	if(lastAppliedSurface != nil){
		return lastAppliedSurface->aspect; 
	}
}

-(void) controlMousePressed:(float)x y:(float)y button:(int)button{
	ofxVec2f curMouse = [self convertPoint:ofxPoint2f(x,y)];
	
	selectedCorner = [self getCurrentSurface]->warp->GetClosestCorner(curMouse.x, curMouse.y);
	if([self getCurrentSurface]->corners[selectedCorner]->distance(ofxPoint2f(curMouse.x, curMouse.y)) > 0.1){
		selectedCorner = -1;
	} else {
		//		[[self getCurrentSurface] setCorner:selectedCorner x:[self getCurrentSurface]->corners[selectedCorner]->x y:[self getCurrentSurface]->corners[selectedCorner]->y projector:[projectorsButton indexOfSelectedItem] surface:[surfacesButton indexOfSelectedItem] storeUndo:true];	
	}
	lastMousePos->x = curMouse.x;	
	lastMousePos->y = curMouse.y;	
}
-(void) controlMouseDragged:(float)x y:(float)y button:(int)button{
	ofxVec2f curMouse = [self convertPoint:ofxPoint2f(x,y)];
	ofxVec2f newPos =  [self getCurrentSurface]->warp->corners[selectedCorner] + (curMouse-*lastMousePos);
	if(selectedCorner != -1){
		[[self getCurrentSurface] setCorner:selectedCorner x:newPos.x y:newPos.y projector:[projectorsButton indexOfSelectedItem] surface:[surfacesButton indexOfSelectedItem] storeUndo:NO];
	} else {		
		*position += (curMouse- ((ofxPoint2f)*lastMousePos))*500.0*scale;
	}
	lastMousePos->x = curMouse.x;	
	lastMousePos->y = curMouse.y;	
	
	[[self getCurrentSurface] recalculate];
}

-(void) controlMouseReleased:(float)x y:(float)y{
	if(selectedCorner != -1){
		[[self getCurrentSurface] setCorner:selectedCorner x:[self getCurrentSurface]->corners[selectedCorner]->x y:[self getCurrentSurface]->corners[selectedCorner]->y projector:[projectorsButton indexOfSelectedItem] surface:[surfacesButton indexOfSelectedItem] storeUndo:true];		
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
	cout<<key<<endl;	
}

-(ProjectorObject*) getCurrentProjector{
	return [projectors objectAtIndex:[projectorsButton indexOfSelectedItem]];
}
-(ProjectionSurfacesObject*) getCurrentSurface{
	return [[self getCurrentProjector]->surfaces objectAtIndex:[surfacesButton indexOfSelectedItem]];	
}

@end
