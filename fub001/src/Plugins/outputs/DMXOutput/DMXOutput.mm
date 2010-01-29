//
//  DMXOutput.mm
//  openFrameworks
//
//  Created by Jonas Jongejan on 24/11/09.
//  Copyright 2009 HalfdanJ. All rights reserved.
//

#import "DMXOutput.h"



@implementation Lamp

-(bool) updateDmx:(vector<unsigned char> *) serialBuffer mutex:(pthread_mutex_t)mutex{
}

@end


@implementation LedLamp
-(id) init{
	if([super init]){
		r = 0;
		g = 100;
		b = 100;
		a = 0;
		sentR = -1;
		sentG = -1;
		sentB = -1;
		sentA = -1;
		return self;
	}
	
	
}
-(void) setLamp:(float)_r g:(float)_g b:(float)_b a:(float)_a{
	r = _r;
	g = _g;
	b = _b;
	a = _a;
}

-(bool) updateDmx:(vector<unsigned char> *) serialBuffer mutex:(pthread_mutex_t)mutex{
	bool ret = true;
	if(channel > 0){					
		//		pthread_mutex_lock(&mutex);
		
		if(a > 254){
			a = 254;
		}
		if(r > 254){
			r = 254;
		}				
		if(g > 254){
			g = 254;
		}
		if(b > 254){
			b = 254;
		}
		
		int n;
		
		if(r != sentR ){
			sentR = r;
			serialBuffer->push_back((unsigned char)255);
			serialBuffer->push_back((unsigned char)channel);
			serialBuffer->push_back((unsigned char)r);
			ret = false;
		}
		if(g != sentG ){
			sentG = g;
			serialBuffer->push_back((unsigned char)255);
			serialBuffer->push_back((unsigned char)channel+1);
			serialBuffer->push_back((unsigned char)g);
			ret = false;
		}
		if(b != sentB){
			sentB = b;
			serialBuffer->push_back((unsigned char)255);
			serialBuffer->push_back((unsigned char)channel+2);
			serialBuffer->push_back((unsigned char)b);
			ret = false;
		}
		if(a != sentA){
			sentA = a;
			serialBuffer->push_back((unsigned char)255);
			serialBuffer->push_back((unsigned char)channel+3);
			serialBuffer->push_back((unsigned char)a);
			
			ret = false;
		}
		//		pthread_mutex_unlock(&mutex);
		
	}
	return ret;
}

-(NSColor*) getColor{
	return [NSColor colorWithCalibratedRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0];
}



@end

@implementation NormalLamp
-(id)init{
	if ([super init]) {
		sentValue = -1;
		value = 0;
		
		return self;
	}
}

-(bool) updateDmx:(vector<unsigned char> *) serialBuffer mutex:(pthread_mutex_t)mutex{
	bool ret = true;
	if(channel > 0){					
		//	pthread_mutex_lock(&mutex);
		
		if(value > 254){
			value = 254;
		}
		
		
		int n;
		
		//	if(value != sentValue ){
		//		cout<<channel<<"  "<<value<<endl;
		sentValue = value;
		
		serialBuffer->push_back((unsigned char)255);
		serialBuffer->push_back((unsigned char)channel);
		serialBuffer->push_back((unsigned char)value);
		ret = false;
		//	pthread_mutex_unlock(&mutex);
		
		//	}
		
	}
	return ret;
}



-(void) setLamp:(float)_v{
	value = _v;
}

@end


@implementation DiodeBox
@synthesize lamps;

-(id) initWithStartaddress:(int) address{
	if([super init]){
		startAddress = address;
		
		LedLamp * l[15];
		
		int x=0,y=0;
		for(int i=0;i<15;i++){
			
			l[i] = [[LedLamp alloc] init];
			l[i]->channel = address + i*4;
			l[i]->pos = new ofxPoint2f(x,y);
			l[i]->r = 255;
			l[i]->g = 255;
			l[i]->b = 255;
			l[i]->a = 255;
			x++;
			if(x >= 3){
				x = 0;
				y++;
			}
			
		}
		lamps = [[NSArray arrayWithObjects:l count:15] retain];
		
	} 
	return self;
}

-(void) addColor:(NSColor*)color onLamp:(ofPoint)p withBlending:(int)blending{
	LedLamp * lamp = [self getLampAtPoint:p];
	float curColors[3];
	curColors[0] = lamp->r/255.0;
	curColors[1] = lamp->g/255.0;
	curColors[2] = lamp->b/255.0;
	
	
	float newColors[4];
	newColors[0] = [color redComponent];
	newColors[1] = [color greenComponent];
	newColors[2] = [color blueComponent];
	newColors[3] = [color alphaComponent];	
	
	switch (blending) {
		case BLENDING_OVER:
			for(int i=0;i<3;i++){
				curColors[i] = newColors[i] * newColors[3] + curColors[i] * (1-newColors[3]);
			}	
			break;
		case BLENDING_ADD:
			for(int i=0;i<3;i++){
				curColors[i] += newColors[i] * newColors[3];
			}	
			break;
			
		case BLENDING_HIGHEST:
			for(int i=0;i<3;i++){
				curColors[i] = MAX(newColors[i] * newColors[3], curColors[i]);
			}	
			break;
		default:
			break;
	}
	
	lamp->r = curColors[0]*255.0;
	lamp->g = curColors[1]*255.0;
	lamp->b = curColors[2]*255.0;
}

-(LedLamp*) getLampAtPoint:(ofPoint)point{
	return [lamps objectAtIndex:int(point.x+point.y*3)];
}

-(void) reset{
	LedLamp * lamp;
	for(lamp in lamps){
		lamp->r = 0;
		lamp->g = 0;
		lamp->b = 0;
	}
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
	
	
	
	
	diodeboxes = [[NSMutableArray array] retain];
	for(int i=0;i<4;i++){
		DiodeBox * box = [[DiodeBox alloc] initWithStartaddress:1+i*15];
		[diodeboxes addObject:box];
	}
	
	/*		int dir = -1;
	 int x = 2;
	 int y = 4;
	 int c = 25;
	 for (int i=0; i<15; i++) {
	 LedLamp * lamp = [[LedLamp alloc] init];
	 lamp->pos = new ofxPoint2f(x,y);
	 lamp->channel = c;
	 c += 4;
	 
	 x += dir;
	 
	 if(x < 0){
	 x = 0;
	 y--;
	 dir *= -1;
	 }
	 
	 if(x > 2){
	 x = 2;
	 y--;
	 dir *= -1;	
	 }
	 [lamps addObject:lamp];
	 }
	 
	 for(int i=19;i<25;i++){
	 
	 if (i != 23) {
	 NormalLamp * lamp = [[NormalLamp alloc] init];
	 lamp->channel = i;
	 lamp->value = 254/2.0;
	 [lamps addObject:lamp];
	 }
	 
	 }
	 
	 NormalLamp *  lamp2 = [[NormalLamp alloc] init];
	 lamp2->channel = 6;
	 lamp2->value = 120;
	 [lamps addObject:lamp2];
	 
	 NormalLamp *  lamp3 = [[NormalLamp alloc] init];
	 lamp3->channel = 3;
	 lamp3->value = 120;
	 [lamps addObject:lamp3];
	 
	 NormalLamp *  lamp4 = [[NormalLamp alloc] init];
	 lamp4->channel = 4;
	 lamp4->value = 120;
	 [lamps addObject:lamp4];
	 
	 NormalLamp * lamp5 = [[NormalLamp alloc] init];
	 lamp5->channel = 23;
	 lamp5->value = 254/2.0;
	 [lamps addObject:lamp5];
	 
	 
	 ok = connected = serial->setup("/dev/tty.usbserial-A6008iyw", 115200);
	 cout<<"Connected: "<<connected<<endl;
	 master = 254;
	 sentMaster = -1;
	 pthread_mutex_init(&mutex, NULL);
	 serialBuffer = new vector<unsigned char>;
	 
	 color = [NSColor blueColor];
	 shownNumber = -1;
	 [thread start];*/
	
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
						/*	
						 
						 for(int x=4;x<19;x+= 5){
						 for(int a=0;a<360;a+=70*(20-x)/20.0){								
						 glPushMatrix();{
						 glRotated(a, 0, 0, 1);
						 glTranslated(x, 0, 0);
						 ofSetColor(255, 0, 0, lamp->r);
						 ofCircle(0, -2, 1);
						 ofSetColor(0, 255, 0, lamp->g);
						 ofCircle(0, 2, 1);
						 ofSetColor(0, 0, 255, lamp->b);
						 ofCircle(-2, 0, 1);
						 
						 
						 }glPopMatrix();
						 }
						 }*/
						
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
		
		
		//Background
		for(int x=0;x<3;x++){
			for(int y=0;y<5;y++){
				[box addColor:[backgroundColor color] onLamp:ofPoint(x,y) withBlending:0];
			}
		}
		
		//Number
		if([generalNumberAlpha floatValue] > 0){
			int number;
			switch (n) {
				case 0:
					number = [generalNumber1 intValue];
					break;
				case 1:
					number = [generalNumber2 intValue];
					break;
				case 2:
					number = [generalNumber3 intValue];
					break;
				case 3:
					number = [generalNumber4 intValue];
					break;
				default:
					break;
			}
			
			bool flags[15];
			[self makeNumber:number intoArray:flags];
			
			int num = 0;
			for(int y=0;y<5;y++){
				for(int x=0;x<3;x++){
					NSColor * c;
					if(!flags[num]){
						c = [NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0];
					} else {
						c = [NSColor colorWithCalibratedRed:0.5 green:0 blue:0 alpha:[generalNumberAlpha floatValue]/[generalNumberAlpha maxValue]];	
					}
					[box addColor:c onLamp:ofPoint(x,y) withBlending:BLENDING_OVER];
					num++;
				}
			}
		}
		
		//Random noise
		if([noiseAlpha floatValue] > 0){
			for(int y=0;y<5;y++){
				for(int x=0;x<3;x++){
					NSColor * c = [[noiseColor1 color] blendedColorWithFraction:ofRandom(0, 1) ofColor:[noiseColor2 color]];
					c = [c colorWithAlphaComponent:[noiseAlpha floatValue]/[noiseAlpha maxValue]];
					[box addColor:c onLamp:ofPoint(x,y) withBlending:[noiseBlending selectedSegment]];

				}
			}
		}
		
		
		
		
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
