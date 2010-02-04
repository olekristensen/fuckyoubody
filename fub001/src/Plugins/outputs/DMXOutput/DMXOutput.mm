//
//  DMXOutput.mm
//  openFrameworks
//
//  Created by Jonas Jongejan on 24/11/09.
//  Copyright 2009 HalfdanJ. All rights reserved.
//

#import "DMXOutput.h"
#include "HardwareBox.h"


@implementation DMXEffectColumn
@synthesize backgroundColorR, settingsView, number;

- (id) initWithNumber:(int)aNumber {
	self = [super init];
	if(self){
		[self setNumber:aNumber];
		
	}
	return self;
}

- (BOOL) loadNibFile {	
	if (![NSBundle loadNibNamed:@"DMXColumn"  owner:self]){
		NSLog(@"Warning! Could not load the nib for dmx ");
		return NO;
	}
	
	int i = 3;
	
	[backgroundColor setMidiControllersStartingWith:[[NSNumber alloc] initWithInt:i++ +(24*number)]];
	[backgroundColor setMidiLabelsPrefix:[NSString stringWithFormat:@"Box %i Background Color", number]];
	i+=3;
	[generalNumberColor setMidiControllersStartingWith:[[NSNumber alloc] initWithInt:i++ +(24*number)]];
	[generalNumberColor setMidiLabelsPrefix:[NSString stringWithFormat:@"Box %i General Number Color", number]];
	i+=3;
	[[generalNumberBlendmode midi] setController:[[NSNumber alloc] initWithInt:i++ +(24*number)]];
	[[generalNumberBlendmode midi] setLabel:[NSString stringWithFormat:@"Box %i General Number Blendmode", number]];
	
	[[generalNumberValue midi] setController:[[NSNumber alloc] initWithInt:i++ +(24*number)]];
	[[generalNumberValue midi] setLabel:[NSString stringWithFormat:@"Box %i General Number Value", number]];
	
	[noiseColor1 setMidiControllersStartingWith:[[NSNumber alloc] initWithInt:i++ +(24*number)]];
	[noiseColor1 setMidiLabelsPrefix:[NSString stringWithFormat:@"Box %i Noise Color From", number]];
	i+=3;
	
	[noiseColor2 setMidiControllersStartingWith:[[NSNumber alloc] initWithInt:i++ +(24*number)]];
	[noiseColor2 setMidiLabelsPrefix:[NSString stringWithFormat:@"Box %i Noise Color To", number]];
	i+=3;
	
	[[noiseBlendMode midi] setController:[[NSNumber alloc] initWithInt:i++ +(24*number)]];
	[[noiseBlendMode midi] setLabel:[NSString stringWithFormat:@"Box %i Noise Blendmode", number]];
	
	[[noiseThreshold midi] setController:[[NSNumber alloc] initWithInt:i++ +(24*number)]];
	[[noiseThreshold midi] setLabel:[NSString stringWithFormat:@"Box %i Noise Threshold", number]];
	
	[[noiseSpeed midi] setController:[[NSNumber alloc] initWithInt:i++ +(24*number)]];
	[[noiseSpeed midi] setLabel:[NSString stringWithFormat:@"Box %i Noise Speed", number]];
	
	for(int i=0;i<3;i++){
		for(int u=0;u<5;u++){
			noiseValues[i][u] = 0;
			noiseNextUpdate[i][u] = ofRandom(0, 10000);
		}
	}
	
	
	return YES;
}

-(void)addColorForLamp:(ofPoint)lamp box:(DiodeBox*)box{
	//Background
	[box addColor:[backgroundColor color] onLamp:lamp withBlending:0];
	
	//Number	
	int tal = [generalNumberValue intValue];	
	bool flags[15];
	[self makeNumber:tal intoArray:flags];	
	NSColor * c;
	if(!flags[ (int)(lamp.x+lamp.y*3) ]){
		c = [NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0];
	} else {
		c = [generalNumberColor color];
	}
	[box addColor:c onLamp:lamp withBlending:[generalNumberBlendmode selectedSegment]];
	
	
	//Random noise
	
	noiseNextUpdate[(int)lamp.x][(int)lamp.y] -= [noiseSpeed floatValue] * 10.0/ofGetFrameRate();
	if(noiseNextUpdate[(int)lamp.x][(int)lamp.y] < 0 ){
		
		noiseNextUpdate[(int)lamp.x][(int)lamp.y] += 1000;
		
		
		float r = ofRandom(0, 1);
		if([noiseThreshold floatValue] > 0){
			if(r < [noiseThreshold floatValue]/100.0)
				r = 0;
			else 
				r = 1;
		}
		noiseValues[(int)lamp.x][(int)lamp.y] = r;
	}
	
	c = [[noiseColor1 color] blendedColorWithFraction:noiseValues[(int)lamp.x][(int)lamp.y] ofColor:[noiseColor2 color]];
	//c = [c colorWithAlphaComponent:[noiseAlpha floatValue]/[noiseAlpha maxValue]];
	[box addColor:c onLamp:lamp withBlending:[noiseBlendMode selectedSegment]];
	
	/*	if(lamp.x == 0 && lamp.y == 0){
	 if([patchButton state] == NSOnState){
	 [box addColor:[NSColor whiteColor] onLamp:lamp withBlending:0];	
	 }
	 }
	 */	
	
	
}

-(void) makeNumber:(int)n intoArray:(bool*) array{
	
	if(n == 0){
		int a[15] = { 
			1 , 1 , 1 ,
			1 , 0 , 1 ,
			1 , 0 , 1 ,
			1 , 0 , 1 ,
			1 , 1 , 1 };		
		
		for(int i=0;i<15;i++){
			array[i] = a[i];
		}		
	}
	if(n == 1){
		int a[15] = { 
			0 , 0 , 1 ,
			0 , 0 , 1 ,
			0 , 0 , 1 ,
			0 , 0 , 1 ,
			0 , 0 , 1 };		
		
		for(int i=0;i<15;i++){
			array[i] = a[i];
		}		
	}
	if(n == 2){
		int a[15] = { 
			1 , 1 , 1 ,
			0 , 0 , 1 ,
			1 , 1 , 1 ,
			1 , 0 , 0 ,
			1 , 1 , 1 };		
		
		for(int i=0;i<15;i++){
			array[i] = a[i];
		}		
	}
	if(n == 3){
		int a[15] = { 
			1 , 1 , 1 ,
			0 , 0 , 1 ,
			1 , 1 , 1 ,
			0 , 0 , 1 ,
			1 , 1 , 1 };		
		
		for(int i=0;i<15;i++){
			array[i] = a[i];
		}		
	}
	if(n == 4){
		int a[15] = { 
			1 , 0 , 1 ,
			1 , 0 , 1 ,
			1 , 1 , 1 ,
			0 , 0 , 1 ,
			0 , 0 , 1 };		
		
		for(int i=0;i<15;i++){
			array[i] = a[i];
		}		
	}
	if(n == 5){
		int a[15] = { 
			1 , 1 , 1 ,
			1 , 0 , 0 ,
			1 , 1 , 1 ,
			0 , 0 , 1 ,
			1 , 1 , 1 };		
		
		for(int i=0;i<15;i++){
			array[i] = a[i];
		}		
	}
	if(n == 6){
		int a[15] = { 
			1 , 0 , 0 ,
			1 , 0 , 0 ,
			1 , 1 , 1 ,
			1 , 0 , 1 ,
			1 , 1 , 1 };		
		
		for(int i=0;i<15;i++){
			array[i] = a[i];
		}		
	}
	if(n == 7){
		int a[15] = { 
			1 , 1 , 1 ,
			0 , 0 , 1 ,
			0 , 0 , 1 ,
			0 , 0 , 1 ,
			0 , 0 , 1 };		
		
		for(int i=0;i<15;i++){
			array[i] = a[i];
		}		
	}
	if(n == 8){
		int a[15] = { 
			1 , 1 , 1 ,
			1 , 0 , 1 ,
			1 , 1 , 1 ,
			1 , 0 , 1 ,
			1 , 1 , 1 };		
		
		for(int i=0;i<15;i++){
			array[i] = a[i];
		}		
	}
	if(n == 9){
		int a[15] = { 
			1 , 1 , 1 ,
			1 , 0 , 1 ,
			1 , 1 , 1 ,
			0 , 0 , 1 ,
			0 , 0 , 1 };		
		
		for(int i=0;i<15;i++){
			array[i] = a[i];
		}		
	}
	
	//	pthread_mutex_unlock(&mutex);
	
	
}



@end



@implementation DMXOutput


/*-(LedLamp*) getLamp:(int)x y:(int)y{
 LedLamp * lamp;
 for(lamp in lamps){
 if(lamp->pos->x == x && lamp->pos->y == y){
 return lamp;
 }
 }
 }*/


-(void) initPlugin{
	thread = [[NSThread alloc] initWithTarget:self
									 selector:@selector(updateDmx:)
									   object:nil];
	serial = new ofSerial();
	
	
	
	master = 255;
	diodeboxes = [[NSMutableArray array] retain];
	int address = 1;
	for(int i=0;i<4;i++){
		DiodeBox * box = [[DiodeBox alloc] initWithStartaddress:address];
		[box setNumber:i];
		[diodeboxes addObject:box];
		address +=60;
	}
	
	
	DiodeBox * box;
	int n= 0;
	for(box in diodeboxes){
		[box reset];
		
		for(int y=0;y<5;y++){
			for(int x=0;x<3;x++){
				LedLamp * lamp = [box getLampAtPoint:ofPoint(x,y)];
				cout<<"Lamp startup : "<<lamp->g<<endl;			
			}
		}
	}
	
	
	
	for(int i=0;i<5;i++){
		columns[i] = [[DMXEffectColumn alloc] initWithNumber:i];
		[columns[i] loadNibFile];
		NSView * dest;
		
		if(i == 0) dest = column0; 		
		if(i == 1) dest = column1; 
		if(i == 2) dest = column2; 
		if(i == 3) dest = column3; 		
		if(i == 4) dest = column4; 
		
		
		[[columns[i] settingsView] setFrame:[dest bounds]];
		[dest addSubview:[columns[i] settingsView]];
		
	}
	
	
	for(int i=0;i<5;i++){
		gtaPositions.push_back(ofxPoint3f(((i<2)?0:1), round(ofRandom(0, 5)), ofRandom(-10, 0)));
	}
	
	for (int i=0; i<4; i++) {
		ulykkePos[i] = ofRandom(0, 5);
	}
	
	
}

-(void) controlDraw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)timeStamp{
	ofEnableAlphaBlending();
	glPushMatrix();{
		glTranslated(50, 1, 0);
		ofFill();
		
		DiodeBox * box;
		for(box in diodeboxes){
			ofNoFill();
			ofSetColor(0, 0, 0,200);
			ofRect(0, 0, 150, 248);
			
			ofFill();
			ofSetColor(0, 0, 0,100);
			ofRect(0, 0, 150, 250);
			
			glPushMatrix();{
				glTranslated(25, 25, 0);
				LedLamp * lamp;
				for(lamp in [box lamps]){
					if(lamp->pos != nil){
						ofFill();
						ofSetColor(lamp->r, lamp->g, lamp->b, lamp->a);
						ofCircle(lamp->pos->x*50.0, lamp->pos->y*50.0, 20);
						
						ofNoFill();
						ofSetColor(0, 0, 0, 200);
						ofCircle(lamp->pos->x*50.0, lamp->pos->y*50.0, 20);
						
					}
				}
			}glPopMatrix();
			
			glTranslated(250, 0, 0);
			
		}
	}glPopMatrix();
}

-(void) update:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	if(ofGetFrameRate() > 2){
		for(int i=0;i<gtaPositions.size();i++){
			gtaPositions[i].z += 0.1 * 60.0/ofGetFrameRate();
			if(gtaPositions[i].z > 9){
				gtaPositions[i].z -= 10+ofRandom(-2, 2);
				gtaPositions[i].y = roundf(ofRandom(0, 4));
				//	gtaPositions[i].x = roundf(ofRandom(0, 1));
			}
			
			//	cout<<gtaPositions[i].z<<endl;
		}
		for(int i=0;i<4;i++){
			ulykkePos[i] += 0.1 * 60.0/ofGetFrameRate();
			if (ulykkePos[i] > 4) {
				ulykkePos[i]-= 6;
			}
		}
		
		
		DiodeBox * box;
		int n= 0;
		for(box in diodeboxes){
			[box reset];
			/*//Background
			 for(int x=0;x<3;x++){
			 for(int y=0;y<5;y++){
			 [box addColor:[backgroundColor color] onLamp:ofPoint(x,y) withBlending:0];
			 }
			 }*/
			int num = 0;
			for(int y=0;y<5;y++){
				for(int x=0;x<3;x++){
					NSColor * c;
					[columns[n] addColorForLamp:ofPoint(x,y) box:box];
					num++;
				}
			}
			
			num = 0;
			for(int y=0;y<5;y++){
				for(int x=0;x<3;x++){
					NSColor * c;
					[columns[4] addColorForLamp:ofPoint(x,y) box:box];
					num++;
				}
			}
			
			
			
			//GTA road effect
			for(int y=0;y<5;y++){
				for(int x=0;x<3;x++){
					for(int i=0;i<gtaPositions.size();i++){
						ofxPoint3f p = gtaPositions[i];
						p.z = roundf(p.z);
						
						NSColor * c = [NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:1.0];
						
						
						if([[diodeboxes objectAtIndex:n] isLamp:ofPoint(x,y) atCoordinate:p]){
							c = [c colorWithAlphaComponent:1.0*[GTAEffect floatValue]/100.0];
							[box addColor:c onLamp:ofPoint(x,y) withBlending:BLENDING_ADD];
						} else if([[diodeboxes objectAtIndex:n] isLamp:ofPoint(x,y) atCoordinate:p-ofxPoint3f(0,0,1)]){
							c = [c colorWithAlphaComponent:0.6*[GTAEffect floatValue]/100.0];
							[box addColor:c onLamp:ofPoint(x,y) withBlending:BLENDING_ADD];
						} else if([[diodeboxes objectAtIndex:n] isLamp:ofPoint(x,y) atCoordinate:p-ofxPoint3f(0,0,2)]){
							c = [c colorWithAlphaComponent:0.2*[GTAEffect floatValue]/100.0];
							[box addColor:c onLamp:ofPoint(x,y) withBlending:BLENDING_ADD];
						}
						
					}
					
				}
			}
			
			
			//GTA Ulykke
			num = 0;
			for(int x=0;x<3;x++){
				int xPos = x;
				if(n > 1)
					xPos = 2-x;
					
				float d = fabs(xPos - ulykkePos[n])*0.5;
				if(d > 1)
					d = 1;
				
				NSColor * c = [NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:(1.0-d)*[GTAUlykke floatValue]/100.0];			

				for(int y=0;y<5;y++){
					[box addColor:c onLamp:ofPoint(x,y) withBlending:BLENDING_ADD];
					num++;
				}
			}
			
			
			
			
			for(int y=0;y<5;y++){
				for(int x=0;x<3;x++){
					LedLamp * lamp = [box getLampAtPoint:ofPoint(x,y)];
					//				cout<<"Lamp : "<<lamp->g<<" channel : "<<lamp->channel+1<<endl;			
					[GetPlugin(HardwareBox) setDmxValue:lamp->r onChannel:lamp->channel];
					[GetPlugin(HardwareBox) setDmxValue:lamp->g onChannel:lamp->channel+1];
					[GetPlugin(HardwareBox) setDmxValue:lamp->b onChannel:lamp->channel+2];
					[GetPlugin(HardwareBox) setDmxValue:master onChannel:lamp->channel+3];
					
				}
			}
			
			//[GetPlugin(HardwareBox) setDmxValue:255 onChannel:1];
			
			
			n++;
			
		}
	}
	
}

-(void) updateDmx:(id)param{
}


-(IBAction) setBackgroundRed:(id)sender{
	NSColor * c = [NSColor colorWithCalibratedRed:[sender floatValue]/512.0 green:[[backgroundColor color] greenComponent] blue:[[backgroundColor color] blueComponent] alpha:1.0];
	[backgroundColor setColor:c];
}	
-(IBAction) setBackgroundGreen:(id)sender{
	NSColor * c = [NSColor colorWithCalibratedRed:[[backgroundColor color] redComponent] green:[sender floatValue]/512.0 blue:[[backgroundColor color] blueComponent] alpha:1.0];
	[backgroundColor setColor:c];
}
-(IBAction) setBackgroundBlue:(id)sender{
	NSColor * c = [NSColor colorWithCalibratedRed:[[backgroundColor color] redComponent] green:[[backgroundColor color] greenComponent] blue:[sender floatValue]/512.0 alpha:1.0];
	[backgroundColor setColor:c];
}
-(IBAction) setBackground:(id)sender{
	[backgroundRedColor setFloatValue:[[sender color] redComponent]*512];
	[backgroundGreenColor setFloatValue:[[sender color] greenComponent]*512];
	[backgroundBlueColor setFloatValue:[[sender color] blueComponent]*512];
}

@end
