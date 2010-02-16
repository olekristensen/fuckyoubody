//
//  DMXOutput.mm
//  openFrameworks
//
//  Created by Jonas Jongejan on 24/11/09.
//  Copyright 2009 HalfdanJ. All rights reserved.
//

#import "DMXOutput.h"
#include "HardwareBox.h"
#include "Players.h"
#include "GTA.h"

@implementation DMXEffectColumn
@synthesize backgroundColorR, settingsView, number, generalNumberColor;

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
	
	[[backgroundTakeColor midi] setController:[[NSNumber alloc] initWithInt:i++ +(24*number)]];
	[[backgroundTakeColor midi] setLabel:[NSString stringWithFormat:@"Box %i Take player color background", number]];
	
	[[generalNumberTakeColor midi] setController:[[NSNumber alloc] initWithInt:i++ +(24*number)]];
	[[generalNumberTakeColor midi] setLabel:[NSString stringWithFormat:@"Box %i Take player color numbers", number]];
	
	i = 10;
	[[topCrop midi] setController:[[NSNumber alloc] initWithInt:i++ +(10*number)]];
	[[topCrop midi] setChannel:[NSNumber numberWithInt:16]];
	[[topCrop midi] setLabel:[NSString stringWithFormat:@"Box %i Background top crop ", number]];
	
	
	for(int i=0;i<3;i++){
		for(int u=0;u<5;u++){
			noiseValues[i][u] = 0;
			noiseNextUpdate[i][u] = ofRandom(0, 10000);
		}
	}
	
	
	return YES;
}

-(void)addColorForLamp:(ofPoint)lamp box:(DiodeBox*)box{
	if([[globalController testDmxButton] state] == NSOnState){
		if(number < 4){
			NSColor * c;
			switch (number) {
				case 0:
					c = [NSColor redColor];
					break;
				case 1:
					c = [NSColor blueColor];
					break;
				case 2:
					c = [NSColor greenColor];
					break;
				case 3:
					c = [NSColor yellowColor];
					break;
					
				default:
					break;
			}
			
			[box addColor:c onLamp:lamp withBlending:0];
			
			
			switch (number) {
				case 0:
					c = [NSColor blueColor];
					break;
				case 1:
					c = [NSColor greenColor];
					break;
				case 2:
					c = [NSColor magentaColor];
					break;
				case 3:
					c = [NSColor redColor];
					break;
					
				default:
					break;
			}
			
			
			int tal =number + 1;	
			bool flags[15];
			[self makeNumber:tal intoArray:flags];	
			if(!flags[ (int)(lamp.x+lamp.y*3) ]){
				c = [NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0];
			} else {
				c = c;
			}
			[box addColor:c onLamp:lamp withBlending:0];
			
		}
		
	} else {
		//Background
		if(lamp.y >= 5*[topCrop floatValue]/100.0){
			[box addColor:[backgroundColor color] onLamp:lamp withBlending:0];
		}
		
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
	rainbowadd =0;
	
	
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
		gtaTower.push_back(NO);
	}
	
	for (int i=0; i<4; i++) {
		ulykkePos[i] = ofRandom(0, 5);
	}
	
	for(int i=0;i<6;i++){
		bokseringTime.push_back(0);	
	}
	
}

-(void) setup{
	music = new ofSoundPlayer();
	music->loadSound("beat.aif");
	music->play();
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
		rainbowadd += 0.1 * 1.0/ofGetFrameRate();
		if(rainbowadd > 1)
			rainbowadd = 0;
		
		
		
		for(int i=0;i<gtaPositions.size();i++){
			gtaPositions[i].z += ([[GetPlugin(GTA) wallSpeedControl] floatValue]/500.0 + 0.2 ) * 0.2 * 60.0/ofGetFrameRate();
			if(gtaPositions[i].z > 9){
				gtaPositions[i].z -= 10+ofRandom(-2, 2);
				gtaPositions[i].y = roundf(ofRandom(0, 4));
				gtaTower[i] = YES;
				gtaTower[i] = (ofRandom(0, [GTATower floatValue]) < 1);
				cout<<gtaTower[i]<<endl;
				
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
		
		for(box in diodeboxes){		
			for(int y=0;y<5;y++){
				for(int x=0;x<3;x++){
					LedLamp * lamp = [box getLampAtPoint:ofPoint(x,y)];
					[GetPlugin(HardwareBox) setDmxValue:lamp->r onChannel:lamp->channel];
					[GetPlugin(HardwareBox) setDmxValue:lamp->g onChannel:lamp->channel+1];
					[GetPlugin(HardwareBox) setDmxValue:lamp->b onChannel:lamp->channel+2];
					[GetPlugin(HardwareBox) setDmxValue:master onChannel:lamp->channel+3];					
				}
			}
			[box reset];
		}
		
		
		int n= 0;
		for(box in diodeboxes){
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
						
						int start = y;
						int stop  = y;
						if(gtaTower[i])
							stop = 4;
						
						for(int u=start;u<=stop;u++){
							if([[diodeboxes objectAtIndex:n] isLamp:ofPoint(x,y) atCoordinate:p] > 0.6){
								c = [c colorWithAlphaComponent:1.0*[GTAEffect floatValue]/100.0];
								[box addColor:c onLamp:ofPoint(x,u) withBlending:BLENDING_ADD];
							} else if([[diodeboxes objectAtIndex:n] isLamp:ofPoint(x,y) atCoordinate:p-ofxPoint3f(0,0,1)] > 0.6){
								c = [c colorWithAlphaComponent:0.6*[GTAEffect floatValue]/100.0];
								[box addColor:c onLamp:ofPoint(x,u) withBlending:BLENDING_ADD];
							} else if([[diodeboxes objectAtIndex:n] isLamp:ofPoint(x,y) atCoordinate:p-ofxPoint3f(0,0,2)] > 0.6){
								c = [c colorWithAlphaComponent:0.2*[GTAEffect floatValue]/100.0];
								[box addColor:c onLamp:ofPoint(x,u) withBlending:BLENDING_ADD];
							}
						}
						
					}
					
				}
			}
			
			//RAINBOW			
			float hue=rainbowadd, sat=1, bright=1, alph=1;
			
			for(int y=0;y<5;y++){
				for(int x=0;x<3;x++){
					//NSColor * c = [color copy];
					float h = hue+0.1*x + y*0.1;
					if(h > 1)
						h -= 1;
					NSColor * c = [NSColor colorWithCalibratedHue:h saturation:sat brightness:bright alpha:alph];
					c = [c colorWithAlphaComponent:[rainbowAlpha floatValue]/100.0];
					[box addColor:c onLamp:ofPoint(x,y) withBlending:BLENDING_ADD];
					
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
				NSColor * c ;
				if(n == 0 || n == 2){
					c = [NSColor colorWithCalibratedRed:0.0 green:0.0 blue:1.0 alpha:(1.0-d)*[GTAUlykke floatValue]/100.0];			
				} else {
					c = [NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:(1.0-d)*[GTAUlykke floatValue]/100.0];								
				}
				
				for(int y=0;y<5;y++){
					[box addColor:c onLamp:ofPoint(x,y) withBlending:BLENDING_ADD];
					num++;
				}
			}
			
			//Boksering pæle
			int off = 0;
			switch (n) {
				case 0:
					off = 6;
					break;
				case 1:
					off = 9;
					break;
				case 3:
					off = 3;
					break;					
				default:
					break;
			}
			
			
			//Cross
			/*NSColor * c = [NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:1.0];
			 for(int y=0;y<5;y++){
			 int x = 1;
			 [box addColor:c onLamp:ofPoint(x,y) withBlending:BLENDING_ADD];
			 }
			 for(int x=0;x<3;x++){
			 int y = 2;
			 [box addColor:c onLamp:ofPoint(x,y) withBlending:BLENDING_ADD];
			 
			 }*/
			
			//Arrow
			if([ArrowAlpha floatValue]/100.0 > 0){
				NSColor * c = [NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:[ArrowAlpha floatValue]/100.0];
				switch (int(round(4*[ArrowAnimation floatValue] / 100.0))) {
					case 0:
						[box addColor:c onLamp:ofPoint(0,0) withBlending:BLENDING_ADD];
						[box addColor:c onLamp:ofPoint(1,1) withBlending:BLENDING_ADD];			
						[box addColor:c onLamp:ofPoint(2,2) withBlending:BLENDING_ADD];
						[box addColor:c onLamp:ofPoint(1,3) withBlending:BLENDING_ADD];
						[box addColor:c onLamp:ofPoint(0,4) withBlending:BLENDING_ADD];
						break;
					case 1:
						[box addColor:c onLamp:ofPoint(1,0) withBlending:BLENDING_ADD];
						[box addColor:c onLamp:ofPoint(2,1) withBlending:BLENDING_ADD];			
//						[box addColor:c onLamp:ofPoint(0,2) withBlending:BLENDING_ADD];
						[box addColor:c onLamp:ofPoint(2,3) withBlending:BLENDING_ADD];
						[box addColor:c onLamp:ofPoint(1,4) withBlending:BLENDING_ADD];
						break;
					case 2:
						[box addColor:c onLamp:ofPoint(2,0) withBlending:BLENDING_ADD];
//						[box addColor:c onLamp:ofPoint(0,1) withBlending:BLENDING_ADD];			
						[box addColor:c onLamp:ofPoint(0,2) withBlending:BLENDING_ADD];
//						[box addColor:c onLamp:ofPoint(0,3) withBlending:BLENDING_ADD];
						[box addColor:c onLamp:ofPoint(2,4) withBlending:BLENDING_ADD];
						break;
					case 3:
						//[box addColor:c onLamp:ofPoint(2,0) withBlending:BLENDING_ADD];
						[box addColor:c onLamp:ofPoint(0,1) withBlending:BLENDING_ADD];			
						[box addColor:c onLamp:ofPoint(1,2) withBlending:BLENDING_ADD];
						[box addColor:c onLamp:ofPoint(0,3) withBlending:BLENDING_ADD];
						//[box addColor:c onLamp:ofPoint(2,4) withBlending:BLENDING_ADD];
						break;
					case 4:
						[box addColor:c onLamp:ofPoint(0,0) withBlending:BLENDING_ADD];
						[box addColor:c onLamp:ofPoint(1,1) withBlending:BLENDING_ADD];			
						[box addColor:c onLamp:ofPoint(2,2) withBlending:BLENDING_ADD];
						[box addColor:c onLamp:ofPoint(1,3) withBlending:BLENDING_ADD];
						[box addColor:c onLamp:ofPoint(0,4) withBlending:BLENDING_ADD];
						break;
						
					default:
						break;
				}
				
			}
			/*	if([bokseringPale floatValue] > 0){
			 int bluePos = 12*[bokseringPale floatValue]/100.1;
			 int greenPos = 6+ 12*[bokseringPale floatValue]/100.1;			
			 
			 
			 
			 if(greenPos >= 12)
			 greenPos -= 12;
			 
			 for(int i=0;i<3;i++){
			 if(bluePos == i+off){
			 for(int y=0;y<5;y++){
			 int x = i;
			 //if(n > 1)
			 x = 2-x;
			 
			 NSColor * c = [GetPlugin(Players) playerColorLed:2];
			 c = [c colorWithAlphaComponent:1];
			 [box addColor:c onLamp:ofPoint(x,y) withBlending:BLENDING_ADD];
			 }
			 }	
			 if(greenPos == i+off){
			 for(int y=0;y<5;y++){
			 int x = i;
			 //if(n > 1)
			 x = 2-x;
			 
			 NSColor * c = [GetPlugin(Players) playerColorLed:4];
			 c = [c colorWithAlphaComponent:1];
			 [box addColor:c onLamp:ofPoint(x,y) withBlending:BLENDING_ADD];
			 }
			 }	
			 }
			 }
			 
			 
			 //Green wall
			 bool taken[] = {false, false, false};*/
			/*	if([bokseringGreen floatValue] > 0){
			 int greenPos = 6+ 12*[bokseringGreen floatValue]/99.0;	
			 
			 for(int i=0;i<3;i++){
			 if((greenPos > i+off && off >= 6)  || (greenPos > 12 && greenPos - 12 > i+off) ){
			 taken[i] = true;
			 for(int y=0;y<5;y++){							
			 int x = 2-i;							
			 NSColor * c = [GetPlugin(Players) playerColorLed:4];
			 c = [c colorWithAlphaComponent:1];
			 [box addColor:c onLamp:ofPoint(x,y) withBlending:BLENDING_ADD];
			 }
			 }
			 
			 
			 }
			 }	
			 
			 //Blue wall
			 float offSet = 12.0*[bokseringOffset floatValue]/100.0;
			 if([bokseringBlue floatValue] > 0){
			 int bluePos = 12*[bokseringBlue floatValue]/99.0;	
			 
			 for(int i=0;i<3;i++){
			 if((bluePos > i+off-offSet && bluePos < 12-offSet ) && (!taken[i] || n < 2)  ){
			 for(int y=0;y<5;y++){							
			 int x = 2-i;							
			 NSColor * c = [GetPlugin(Players) playerColorLed:2];
			 c = [c colorWithAlphaComponent:1];
			 [box addColor:c onLamp:ofPoint(x,y) withBlending:BLENDING_OVER];
			 }
			 }
			 
			 
			 }
			 }	*/
			
			
			
			
			
			
			
			
			//[GetPlugin(HardwareBox) setDmxValue:255 onChannel:1];
			
			
			n++;
		}
		
		
		
		int bokseringCols[12];
		for(int i=0;i<12;i++){
			bokseringCols[i] = 0;
		}
		
		if([bokseringPale floatValue] > 0){
			int greenPos = 6+ 12*[bokseringPale floatValue]/100.1;				
			int bluePos = 12*[bokseringPale floatValue]/100.1;
			
			
			bokseringCols[greenPos] = 1;
			bokseringCols[bluePos] = 2;
		}
		
		int offSet = 12.0*[bokseringOffset floatValue]/100.0;
		if([bokseringGreen floatValue] > 0){
			int greenPos = 6+ 12*[bokseringGreen floatValue]/99.0;	
			int start = 6 + offSet;
			if(start >= 12)
				start -= 12;			
			int stop = start + 12*[bokseringGreen floatValue]/100.0;
			for(int i=start;i<stop;i++){
				bokseringCols[i] = 1;	
			}		
			for(int i=12;i<stop;i++){
				bokseringCols[i-12] = 1;	
			}	
		}
		
		if([bokseringBlue floatValue] > 0){
			int bluePos = 12*[bokseringBlue floatValue]/99.0;	
			int start = offSet;
			if(start >= 12)
				start -= 12;			
			int stop = start + 12*[bokseringBlue floatValue]/100.0;
			
			for(int i=start;i<stop;i++){
				bokseringCols[i] = 2;	
			}				
			for(int i=12;i<stop;i++){
				bokseringCols[i-12] = 2;	
			}	
		}		
		
		for(int i=0;i<4;i++){
			int n = i;		
			box = [diodeboxes objectAtIndex:n];
			for(int u=0;u<3;u++){
				int coln = i*3+u;
				int x;
				x = 2-u;
				NSColor * c = [GetPlugin(Players) playerColorLed:4];
				c = [c colorWithAlphaComponent:0];
				if(bokseringCols[coln] == 1){
					c = [GetPlugin(Players) playerColorLed:4];
					c = [c colorWithAlphaComponent:[alpha floatValue]];
				} else if(bokseringCols[coln] == 2){
					c = [GetPlugin(Players) playerColorLed:2];
					c = [c colorWithAlphaComponent:[alpha floatValue]];
				}
				for(int y=0;y<5;y++){
					[box addColor:c onLamp:ofPoint(x,y) withBlending:BLENDING_OVER];												   
				}				
			}
		}
		
		
		if([bokseringVerticalEffect floatValue] > 0){
			int greenPos = 5*[bokseringVerticalEffect floatValue]/100.0;
			int bluePos = 5-5*[bokseringVerticalEffect floatValue]/100.0;
			
			for(int i=0;i<4;i++){
				box = [diodeboxes objectAtIndex:i];
				
				for(int x = 0;x<3;x++){
					for(int y=0;y<5;y++){
						NSColor * c = [GetPlugin(Players) playerColorLed:4];
						c = [c colorWithAlphaComponent:0];
						if(y == greenPos && i < 2){
							c = [GetPlugin(Players) playerColorLed:4];
							c = [c colorWithAlphaComponent:[alpha floatValue]];
						} else if(y == bluePos && i > 1){
							c = [GetPlugin(Players) playerColorLed:2];
							c = [c colorWithAlphaComponent:[alpha floatValue]];
						}
						[box addColor:c onLamp:ofPoint(x,y) withBlending:BLENDING_OVER];				
					}
				}
			}
		}
		
		float * waveform = ofSoundGetSpectrum(7);
		
		timeSinceLastVolChange += 1.0/ofGetFrameRate();
		volCounter += waveform[4]*6;
		bokseringCounter++;
		if([bokseringBeatButton state] == NSOnState){
			if(!music->getIsPlaying()){
				music->play();
				NSDictionary* errorDict;
				NSAppleEventDescriptor* returnDescriptor = NULL;				
				NSAppleScript* scriptObject; 				
				scriptObject = [[NSAppleScript alloc] initWithSource:
								@"\
								set volume 0\n\
								" 		 
								];		
				
				returnDescriptor = [scriptObject executeAndReturnError: &errorDict];
				[scriptObject release];				
			}
			
		} else {
			if(music->getIsPlaying()){
				music->stop();
				NSDictionary* errorDict;
				NSAppleEventDescriptor* returnDescriptor = NULL;				
				NSAppleScript* scriptObject; 				
				scriptObject = [[NSAppleScript alloc] initWithSource:
								@"\
								set volume 100\n\
								" 		 
								];		
				
				returnDescriptor = [scriptObject executeAndReturnError: &errorDict];
				[scriptObject release];				
			}
		}
		if(timeSinceLastVolChange > 0.03){
			bokseringCurValue *= [bokseringWaveformEffect floatValue]/100.0;
			if(bokseringCurValue < 20*volCounter/(float)bokseringCounter)
				bokseringCurValue = 20*volCounter/(float)bokseringCounter;
			bokseringTime.erase(bokseringTime.begin());
			bokseringTime.push_back(round(bokseringCurValue));
			volCounter = 0;
			timeSinceLastVolChange = 0;
			bokseringCounter = 0;
		}
		
		if([bokseringWaveformEffect floatValue] > 0){
			//bokseringCurValue = 5*[bokseringWaveformEffect floatValue]/100.0;
			
			
			
			for(int i=0;i<4;i++){
				int n = i;
				
				if(i == 0)
					n = 1;
				if(i==1)
					n = 0;
				if(i == 2)
					n = 3;
				if(i==3)
					n = 2;
				box = [diodeboxes objectAtIndex:n];
				
				
				for(int u = 0;u<3;u++){
					for(int u = 0;u<3;u++){
						if(i < 2){
							int x = 2-u;
							
							int time = 5-(x+i*3);
							for(int y=0;y<5;y++){
								
								NSColor * c = [GetPlugin(Players) playerColorLed:4];
								c = [c colorWithAlphaComponent:0];
								if(5-y <= bokseringTime[time]){
									c = [GetPlugin(Players) playerColorLed:(i%2==0)?2:4];
									c = [c colorWithAlphaComponent:[alpha floatValue]];
								} 
								[box addColor:c onLamp:ofPoint(x,y) withBlending:BLENDING_OVER];				
							}
							
						}
						
						else {
							int x = 2-u;
							
							int time = (x+i*3)-6;
							for(int y=0;y<5;y++){
								
								NSColor * c = [GetPlugin(Players) playerColorLed:4];
								c = [c colorWithAlphaComponent:0];
								if(5-y <= bokseringTime[time]){						
									
									c = [GetPlugin(Players) playerColorLed:(i%2==0)?2:4];
									c = [c colorWithAlphaComponent:[alpha floatValue]];
								} 
								[box addColor:c onLamp:ofPoint(x,y) withBlending:BLENDING_OVER];				
							}
							
						}
						
					}
					
				}
			}
			
		}
		
		
		
		
		//Gradient
		//if([backgroundGradient state] == NSOnState){
		
		
		//	}
		
		
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

-(DMXEffectColumn*) effectColumn:(int)n{
	return columns[n];
}

-(IBAction) bokseringStepTime:(id)sender{
	bokseringTime.erase(bokseringTime.begin());
	bokseringTime.push_back(bokseringCurValue);
}


-(void)addColor:(NSColor*)c forCoordinate:(ofxPoint3f)coord withBlending:(int)blending{
	DiodeBox * box;
	for(box in diodeboxes){
		for(int y=0;y<5;y++){
			for(int x=0;x<3;x++){
				[box addColor:[c colorWithAlphaComponent:[box isLamp:ofPoint(x,y) atCoordinate:coord]] onLamp:ofPoint(x,y) withBlending:blending];
			}
		}
	}
}
@end
