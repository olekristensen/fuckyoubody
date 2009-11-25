//
//  DMXOutput.mm
//  openFrameworks
//
//  Created by Jonas Jongejan on 24/11/09.
//  Copyright 2009 HalfdanJ. All rights reserved.
//

#import "DMXOutput.h"

@implementation Lamp

-(void) updateDmx:(ofSerial *)serial mutex:(pthread_mutex_t)mutex{	
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

-(bool) updateDmx:(ofSerial *)serial mutex:(pthread_mutex_t)mutex{
	bool ret = true;
	if(channel > 0){					
		pthread_mutex_lock(&mutex);
		
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
		pthread_mutex_unlock(&mutex);
		
		int n;
		
		if(r != sentR ){
			sentR = r;
			unsigned char *buffer = new unsigned char[3];
			buffer[0] = (unsigned char)255;
			buffer[1] = (unsigned char)channel;
			buffer[2] = (unsigned char)r;
			serial->writeBytes(buffer, 3);
			delete buffer;
			ret = false;
		}
		if(g != sentG ){
			sentG = g;
			unsigned char *buffer = new unsigned char[3];
			buffer[0] = (unsigned char)255;
			buffer[1] = (unsigned char)channel+1;
			buffer[2] = (unsigned char)g;
			serial->writeBytes(buffer, 3);
			delete buffer;
			ret = false;
		}
		if(b != sentB){
			sentB = b;
			unsigned char *buffer = new unsigned char[3];
			buffer[0] = (unsigned char)255;
			buffer[1] = (unsigned char)channel+2;
			buffer[2] = (unsigned char)b;
			serial->writeBytes(buffer, 3);
			delete buffer;
			ret = false;
		}
		if(a != sentA){
			sentA = a;
			unsigned char *buffer = new unsigned char[3];
			buffer[0] = (unsigned char)255;
			buffer[1] = (unsigned char)channel+3;
			buffer[2] = (unsigned char)a;
			serial->writeBytes(buffer, 3);
			delete buffer;
			ret = false;
		}
	}
	return ret;
}



@end

@implementation NormalLamp
-(id)init{
	if ([super init]) {
		sentValue = -1;
		value = 100;
		
		return self;
	}
}

-(bool) updateDmx:(ofSerial *)serial mutex:(pthread_mutex_t)mutex{
	bool ret = true;
	if(channel > 0){					
		pthread_mutex_lock(&mutex);
		
		if(value > 254){
			value = 254;
		}
		
		pthread_mutex_unlock(&mutex);
		
		int n;
		
		if(value != sentValue ){
			cout<<channel<<"  "<<value<<endl;
			sentValue = value;
			unsigned char *buffer = new unsigned char[3];
			buffer[0] = (unsigned char)255;
			buffer[1] = (unsigned char)channel;
			buffer[2] = (unsigned char)value;
			serial->writeBytes(buffer, 3);
			delete buffer;
			ret = false;
		}
		
	}
	return ret;
}



-(void) setLamp:(float)_v{
	value = _v;
}

@end



@implementation DMXOutput

-(void) makeNumber:(int)n r:(float)_r g:(float)_g b:(float)_b {
	int array[15];
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
	
	int x = 0;
	int y = 0;
	pthread_mutex_lock(&mutex);
	
	for(int i=0;i<15;i++){
		if(array[i] == 1){
			[[self getLamp:x y:y] setLamp:_r g:_g b:_b a:array[i]*254];		
		}
		x ++;
		if(x> 2){
			x = 0;
			y++;
		}
	}
	pthread_mutex_unlock(&mutex);
	
	
}

-(LedLamp*) getLamp:(int)x y:(int)y{
	LedLamp * lamp;
	for(lamp in lamps){
		if(lamp->pos->x == x && lamp->pos->y == y){
			return lamp;
		}
	}
}


-(void) initPlugin{
	thread = [[NSThread alloc] initWithTarget:self
									 selector:@selector(updateDmx:)
									   object:nil];
	serial = new ofSerial();
	
	lamps = [[NSMutableArray array] retain];
	int dir = -1;
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
	/*
	for(int i=0;i<25;i++){
		NormalLamp * lamp = [[NormalLamp alloc] init];
		lamp->channel = i;	
		[lamps addObject:lamp];
	}*/
	
	ok = serial->setup("/dev/tty.usbserial-A6008iyw", 115200);

	master = 254;
	sentMaster = -1;
	pthread_mutex_init(&mutex, NULL);
	
	
	color = [NSColor blueColor];
	shownNumber = -1;
	[thread start];
	
}

-(void) controlDraw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)timeStamp{
	ofEnableAlphaBlending();
	glPushMatrix();
	glTranslated(30, 30, 0);
	LedLamp * lamp;
	for(lamp in lamps){
		ofSetColor(lamp->r, lamp->g, lamp->b, lamp->a);
		ofCircle(lamp->pos->x*30.0, lamp->pos->y*30.0, 10);
		
	}
	
	glPopMatrix();
	
}

-(void) update:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)timeStamp{
	
	float hue, sat, bright, alph;
	float add = 0.1;
	[color getHue:&hue saturation:&sat brightness:&bright alpha:&alph];
	
	
	for(int i=0;i<5;i++){
		for(int u=0;u<3;u++){
			LedLamp * lamp = [self getLamp:u y:i];
			//NSColor * c = [color copy];
			float h = hue+add*i + u*0.1;
			if(h > 1)
				h -= 1;
			NSColor * c = [NSColor colorWithCalibratedHue:h saturation:sat brightness:bright alpha:alph];
			[lamp setLamp:[c redComponent]*254 g:[c greenComponent]*254 b:[c blueComponent]*254 a:254];
		}
	}
	
	
	hue += add*0.2;
	if(hue > 1){
		hue -= 1;	
	}
	[color release];
	color = [NSColor colorWithCalibratedHue:hue saturation:sat brightness:bright alpha:alph];
	[color retain];
	
	
	for(int i=0;i<5;i++){
		for(int u=0;u<3;u++){
			LedLamp * lamp = [self getLamp:u y:i];
			[lamp setLamp:0 g:0 b:0 a:0];
		}
	}
	
	
	
	//	if(shownNumber != int(timeInterval)%10){
	shownNumber = int(timeInterval)%10;
	//	shownNumber = int(ofRandom(0, 10));
	//		[self makeNumber:int(timeInterval)%10 r:int(ofRandom(0, 254)) g:int(ofRandom(0, 254)) b:int(ofRandom(0, 254))];
	if(timeInterval - int(timeInterval) < 0.6){
		master += 0.1;
		if(master > 1) 
			master = 1;
	} else {
		master -= 0.1;
		if(master < 0) 
			master = 0;	
	}
	//[self makeNumber:shownNumber r:254*master g:254*master b:254*master];
	
	
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
	
	
	//	}
}

-(void) updateDmx:(id)param{
	while(1){
		if(serial->available()){
			serial->flush(true, false);
			ok = true;
		}
		if(ok){			
			Lamp * lamp;
			for(lamp in lamps){
				if(master != sentMaster ){
					sentMaster = master;
					unsigned char *buffer = new unsigned char[3];
					buffer[0] = (unsigned char)255;
					buffer[1] = (unsigned char)0;
					buffer[2] = (unsigned char)round(master*254);
					serial->writeBytes(buffer, 3);
					delete buffer;
					ok = false;
				}
				if(![lamp updateDmx:serial mutex:mutex]){
					ok = false;
				}
				
			}
			
			
		}
		
		
		[NSThread sleepForTimeInterval:0.02];
	}
}
@end
