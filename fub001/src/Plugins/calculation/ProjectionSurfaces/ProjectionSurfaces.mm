//
//  _ExampleOutput.mm
//  openFrameworks
//
//  Created by Jonas Jongejan on 15/11/09.

#import "ProjectionSurfaces.h"




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
		return self;
	}
}
@end



@implementation ProjectionSurfaces

-(void) awakeFromNib{
	[super awakeFromNib];
}

-(void) initPlugin{
	NSUserDefaults *userDefaults = [[NSUserDefaults standardUserDefaults] retain];
	[projectorsButton removeAllItems];
	[surfacesButton removeAllItems];
	
	projectors = [NSMutableArray array];
	[projectors retain];
	[projectors addObject:[[ProjectorObject alloc] initWithName:@"Front"]];	
	[projectors addObject:[[ProjectorObject alloc] initWithName:@"Back"]];	
	
	ProjectorObject * projector;
	
	for(projector in projectors){
		NSLog(@"Init projectionsurfaces");
		
		NSMutableArray * array = [NSMutableArray array];
		[array addObject:[[ProjectionSurfacesObject alloc] initWithName:@"Floor"]];
		[array addObject:[[ProjectionSurfacesObject alloc] initWithName:@"Backwall"]];
		
		[projector setSurfaces:array];
		[projectorsButton addItemWithTitle:[NSString stringWithCString:projector->name->c_str()]];
		
		ProjectionSurfacesObject * surface;
		for(surface in array){
			[surfacesButton addItemWithTitle:[NSString stringWithCString:surface->name->c_str()]];	
		}
	}
	
	position = new ofPoint(0,0);
	scale = 0.8;
}

-(IBAction) selectProjector:(id)sender{
	
}
-(IBAction) selectSurface:(id)sender{
	
}


-(void) setup{
	//	CGLSetCurrentContext(openglContext);
	
	/*	img = new ofImage;
	 img->loadImage("/Users/jonas/Documents/udvilking/of_preRelease_v0.06_xcode_FAT/apps/fub_/fub001_/bin/data/icon.png");
	 NSLog(@"Set blaaa");
	 haha = new string("blaa");
	 */	
}

-(void) controlDraw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)timeStamp{
	ofBackground(0, 0, 0);
	
	glPushMatrix();
	
	float projWidth = [self getCurrentProjector]->width;
	float projHeight = [self getCurrentProjector]->height;	
	float aspect =(float)  projHeight/projWidth;
	float viewAspect = (float)ofGetHeight() / ofGetWidth();
	
	glTranslated(ofGetWidth()/2.0, ofGetHeight()/2.0, 0);
	
	if(viewAspect > aspect){
		glScaled(ofGetWidth(), ofGetWidth(), 1.0);
	} else {
		glScaled(ofGetHeight()/aspect, ofGetHeight()/aspect, 1.0);	
	}
	
	
	//	glScaled(fit, fit, 1);
	glScaled(scale, scale, 1);
	//	glTranslated(-projWidth/2.0, -projHeight/2.0, 0);
	glTranslated(-0.5, -aspect/2.0, 0);	 
	ofEnableAlphaBlending();
	ofSetColor(255, 255, 255, 30);
	ofRect(0, 0, 1, aspect);
	ofSetColor(255, 255, 255, 70);
	ofNoFill();
	ofRect(0, 0, 1, aspect);
	ofFill();
	
	glPopMatrix();}

-(void) update:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)timeStamp{
	//for(int i=0;i<10;i++){
	//		for(int u=0;u<100000;u++){
	//			sqrt(cos(sin(i*i)));
	//		}
	//	}
}

-(void) draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)timeStamp{
	
}

-(void) controlMousePressed:(float)x y:(float)y button:(int)button{
	//	cout<<"x: "<<x<<" y: "<<y<<endl;
}
-(void) controlMouseScrolled:(NSEvent *)theEvent{
	scale += [theEvent deltaY]*0.01;
	if(scale > 3)
		scale = 3;
	if(scale < 0.1){
		scale = 0.1;
	}
};

-(ProjectorObject*) getCurrentProjector{
	return [projectors objectAtIndex:[projectorsButton indexOfSelectedItem]];
}
-(ProjectionSurfacesObject*) getCurrentSurface{
	return [[[self getCurrentProjector] surfaces] objectAtIndex:[surfacesButton indexOfSelectedItem]];	
}

@end
