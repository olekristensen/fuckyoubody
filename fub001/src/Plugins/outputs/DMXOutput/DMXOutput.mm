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
	
	[backgroundColor setMidiControllersStartingWith:[[NSNumber alloc] initWithInt:i++ +(25*number)]];
	[backgroundColor setMidiLabelsPrefix:[NSString stringWithFormat:@"Box %i Background Color", number]];
	i+=3;
	[generalNumberColor setMidiControllersStartingWith:[[NSNumber alloc] initWithInt:i++ +(25*number)]];
	[generalNumberColor setMidiLabelsPrefix:[NSString stringWithFormat:@"Box %i General Number Color", number]];
	i+=3;
	[[generalNumberBlendmode midi] setController:[[NSNumber alloc] initWithInt:i++ +(25*number)]];
	[[generalNumberBlendmode midi] setLabel:[NSString stringWithFormat:@"Box %i General Number Blendmode", number]];
	
	[[generalNumberValue midi] setController:[[NSNumber alloc] initWithInt:i++ +(25*number)]];
	[[generalNumberValue midi] setLabel:[NSString stringWithFormat:@"Box %i General Number Value", number]];
	
	[noiseColor1 setMidiControllersStartingWith:[[NSNumber alloc] initWithInt:i++ +(25*number)]];
	[noiseColor1 setMidiLabelsPrefix:[NSString stringWithFormat:@"Box %i Noise Color From", number]];
	i+=3;
	
	[noiseColor2 setMidiControllersStartingWith:[[NSNumber alloc] initWithInt:i++ +(25*number)]];
	[noiseColor2 setMidiLabelsPrefix:[NSString stringWithFormat:@"Box %i Noise Color To", number]];
	i+=3;
	 
	[[noiseBlendMode midi] setController:[[NSNumber alloc] initWithInt:i++ +(25*number)]];
	[[noiseBlendMode midi] setLabel:[NSString stringWithFormat:@"Box %i Noise Blendmode", number]];
	
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
	c = [[noiseColor1 color] blendedColorWithFraction:ofRandom(0, 1) ofColor:[noiseColor2 color]];
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
	
	/*	pthread_mutex_lock(&mutex);
	 //Normal light
	 Lamp * lamp;
	 for(lamp in lamps){
	 if(lamp->channel > 18 && lamp->channel < 25){
	 if([trackingLight state] == NSOnState){
	 ((NormalLamp*)lamp)->value  = 254/2.0;
	 }
	 else {
	 ((NormalLamp*)lamp)->value  = 0;
	 }
	 }
	 if(lamp->channel == 6 || lamp->channel == 3 ||lamp->channel == 4 ||lamp->channel == 23){
	 ((NormalLamp*)lamp)->value  = [worklight intValue];
	 }
	 }
	 
	 
	 //Background
	 for(int i=0;i<5;i++){
	 for(int u=0;u<3;u++){
	 LedLamp * lamp = [self getLamp:u y:i];
	 NSColor * c = [backgroundColor color];
	 [lamp setLamp:[c redComponent]*254 g:[c greenComponent]*254 b:[c blueComponent]*254 a:[c alphaComponent]*254];
	 }
	 }
	 
	 //Gradient
	 if([backgroundGradient state] == NSOnState){
	 float hue, sat, bright, alph;
	 float add = 0.1;
	 [color getHue:&hue saturation:&sat brightness:&bright alpha:&alph];	
	 
	 for(int i=0;i<5;i++){
	 for(int u=0;u<3;u++){
	 LedLamp * lamp = [self getLamp:u y:i];
	 //NSColor * c = [color copy];
	 float h = hue+add*i + u*[backgroundGradientRotation floatValue];
	 if(h > 1)
	 h -= 1;
	 NSColor * c = [NSColor colorWithCalibratedHue:h saturation:sat brightness:bright alpha:alph];
	 [lamp setLamp:[c redComponent]*254 g:[c greenComponent]*254 b:[c blueComponent]*254 a:254];
	 }
	 }
	 
	 
	 hue += add*[backgroundGradientSpeed floatValue];
	 if(hue > 1){
	 hue -= 1;	
	 }
	 [color release];
	 color = [NSColor colorWithCalibratedHue:hue saturation:sat brightness:bright alpha:alph];
	 [color retain];
	 
	 }
	 
	 
	 
	 //Led counter 
	 
	 if([ledCounter state] == NSOnState){
	 
	 //	if(shownNumber != int(timeInterval)%10){
	 float seconds = ofGetElapsedTimeMillis() / 1000.0;
	 shownNumber = int(seconds)%10;
	 
	 //	shownNumber = int(ofRandom(0, 10));
	 //	[self makeNumber:int(timeInterval)%10 r:int(ofRandom(0, 254)) g:int(ofRandom(0, 254)) b:int(ofRandom(0, 254))];
	 
	 if([ledCounterFade state] == NSOnState){
	 
	 if(seconds - int(seconds) < 0.6){
	 master += 0.1;
	 if(master > 1) 
	 master = 1;
	 } else {
	 master -= 0.1;
	 if(master < 0) 
	 master = 0;	
	 }
	 
	 } else {
	 master = 1;	
	 }
	 
	 NSColor * c = [ledCounterColor color];		
	 [self makeNumber:shownNumber r:[c redComponent]*254 g:[c greenComponent]*254 b:[c blueComponent]*254 a:[c alphaComponent]*190*master];
	 for(int i=0;i<5;i++){
	 for(int u=0;u<3;u++){
	 LedLamp * lamp = [self getLamp:u y:i];
	 if(lamp->a > 0){
	 
	 //				lamp->a = ofRandom(0, 190*master);
	 }
	 }
	 }
	 
	 }
	 
	 float x = controlMouseY / 300.0;
	 
	 for(int i=0;i<5;i++){
	 for(int u=0;u<3;u++){
	 LedLamp * lamp = [self getLamp:u y:i];
	 if(x > (6 - i)/5.0){  
	 if(i == 0)
	 [lamp setLamp:254 g:0 b:0 a:254];
	 else if(i == 1 || i == 1)
	 [lamp setLamp:254 g:254 b:0 a:254];
	 else
	 [lamp setLamp:0 g:254 b:0 a:254];
	 }
	 }
	 }
	 
	 pthread_mutex_unlock(&mutex);
	 */	
	//	}
}

-(void) updateDmx:(id)param{
	/*
	 if(connected){
	 
	 while(1){
	 
	 //		cout<<"Buffer size: "<<serialBuffer->size()<<endl;
	 if(serial->available()){
	 serial->flush(true, false);
	 ok = true;
	 //			cout<<"Flush"<<endl;
	 }
	 if(ok){	
	 //			cout<<"OK"<<endl;
	 if(serialBuffer->size() > 0){
	 //				cout<<"Prepare to send ";
	 int n = MIN(90,serialBuffer->size());
	 //				cout<<n<<" bytes"<<endl;
	 unsigned char * bytes = new unsigned char[n];;
	 for(int i=0;i<n;i++){				
	 bytes[i] = serialBuffer->at(0);
	 serialBuffer->erase(serialBuffer->begin());
	 }
	 //				cout<<"Send "<<n<<" bytes"<<endl;
	 serial->writeBytes(bytes, n);
	 ok = false;
	 } else {
	 //				cout<<"make buffer"<<endl;
	 int n=0;
	 pthread_mutex_lock(&mutex);
	 
	 Lamp * lamp;
	 if(master != sentMaster ){
	 sentMaster = master;
	 //					serial->writeBytes(buffer, 3);
	 serialBuffer->push_back((unsigned char)255);
	 serialBuffer->push_back((unsigned char)0);
	 serialBuffer->push_back((unsigned char)round(master*254));
	 }
	 
	 for(lamp in lamps){
	 
	 if(![lamp updateDmx:serialBuffer mutex:mutex]){
	 n++;
	 
	 }
	 
	 }
	 pthread_mutex_unlock(&mutex);
	 
	 //								cout<<"make buffer end"<<endl;
	 }
	 }
	 
	 
	 [NSThread sleepForTimeInterval:0.003];
	 }
	 }*/
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
