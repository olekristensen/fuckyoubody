//
//  DMXOutput.mm
//  openFrameworks
//
//  Created by Jonas Jongejan on 24/11/09.
//  Copyright 2009 HalfdanJ. All rights reserved.
//

#import "DMXOutput.h"

@implementation LedLamp
-(id) init{
	r = 0;
	g = 100;
	b = 100;
	a = 0;
	sentR = -1;
	sentG = -1;
	sentB = -1;
	sentA = -1;
	
}
-(void) setLamp:(float)_r g:(float)_g b:(float)_b a:(float)_a{
	r = _r;
	g = _g;
	b = _b;
	a = _a;
}

-(void) update{
	
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
	serial->setup("/dev/tty.usbserial-A6008iyw", 115200);
	
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
	
	ok = true;
	master = 254;
	sentMaster = -1;
	pthread_mutex_init(&mutex, NULL);
	
	
	color = [NSColor blueColor];
	shownNumber = -1;
	[thread start];
	
}

-(void) controlDraw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)timeStamp{
	ofSetColor(0, 0, 0, 255);
	glPushMatrix();
	glTranslated(30, 30, 0);
	LedLamp * lamp;
	for(lamp in lamps){
		ofCircle(lamp->pos->x*30.0, lamp->pos->y*30.0, 10);
		
	}
	
	glPopMatrix();
	
}

-(void) update:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)timeStamp{
	/*	
	 float hue, sat, bright, alph;
	 float add = 0.1;
	 [color getHue:&hue saturation:&sat brightness:&bright alpha:&alph];
	 
	 
	 for(int i=0;i<5;i++){
	 for(int u=0;u<3;u++){
	 LedLamp * lamp = [self getLamp:u y:i];
	 //NSColor * c = [color copy];
	 float h = hue+add*i;
	 if(h > 1)
	 h -= 1;
	 NSColor * c = [NSColor colorWithCalibratedHue:h saturation:sat brightness:bright alpha:alph];
	 [lamp setLamp:[c redComponent]*254 g:[c greenComponent]*254 b:[c blueComponent]*254 a:254];
	 }
	 }
	 
	 
	 hue += add*0.02;
	 if(hue > 1){
	 hue -= 1;	
	 }
	 [color release];
	 color = [NSColor colorWithCalibratedHue:hue saturation:sat brightness:bright alpha:alph];
	 [color retain];
	 */
	
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
	//	[self makeNumber:shownNumber r:254 g:254 b:254];
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
			LedLamp * lamp;
			
			for(lamp in lamps){
				//cout << i << ": " << lamps[i].channel << endl;
				if(lamp->channel > 0){
					//				ofxPoint2f p = ofxPoint2f(mouseX, mouseY);
					
					pthread_mutex_lock(&mutex);
					
					/*float a = 0;
					 
					 float d = p.distance(lamps[i].pos);
					 d = (radius-d)/radius;
					 a = d;
					 if(a > 1){
					 a = 1;
					 }
					 if(a < 0){
					 a = 0;	
					 }
					 */
					/*	if(a < 0.1)
					 a = 0;
					 
					 if(a < 0.5)
					 a = 0;
					 else 
					 a = 1;*/
					/*lamps[i].a =255;
					 lamps[i].r += ((r-lamps[i].r  )*a + (r2-lamps[i].r  )*(1.0-a) ) * 0.092;		
					 lamps[i].g += ((g-lamps[i].g  )*a + (g2-lamps[i].g  )*(1.0-a) ) * 0.092;		
					 lamps[i].b += ((b-lamps[i].b  )*a + (b2-lamps[i].b  )*(1.0-a) ) * 0.092;		
					 
					 
					 
					 if(lamps[i].isOldAndSucks){
					 lamps[i].a = (lamps[i].a * (190-6) / 254) + 6;
					 }
					 */
					if(lamp->a > 254){
						lamp->a = 254;
					}
					if(lamp->r > 254){
						lamp->r = 254;
					}				
					if(lamp->g > 254){
						lamp->g = 254;
					}
					if(lamp->b > 254){
						lamp->b = 254;
					}
					pthread_mutex_unlock(&mutex);
					
					//					unlock();
					
					
					
					//unsigned char *mBuf= new unsigned char[3*4];
					int n;
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
					if(lamp->r != lamp->sentR ){
						lamp->sentR = lamp->r;
						unsigned char *buffer = new unsigned char[3];
						buffer[0] = (unsigned char)255;
						buffer[1] = (unsigned char)lamp->channel;
						buffer[2] = (unsigned char)lamp->r;
						serial->writeBytes(buffer, 3);
						delete buffer;
						ok = false;
					}
					if(lamp->g != lamp->sentG ){
						lamp->sentG = lamp->g;
						unsigned char *buffer = new unsigned char[3];
						buffer[0] = (unsigned char)255;
						buffer[1] = (unsigned char)lamp->channel+1;
						buffer[2] = (unsigned char)lamp->g;
						serial->writeBytes(buffer, 3);
						delete buffer;
						ok = false;
					}
					if(lamp->b != lamp->sentB){
						lamp->sentB = lamp->b;
						unsigned char *buffer = new unsigned char[3];
						buffer[0] = (unsigned char)255;
						buffer[1] = (unsigned char)lamp->channel+2;
						buffer[2] = (unsigned char)lamp->b;
						serial->writeBytes(buffer, 3);
						delete buffer;
						ok = false;
					}
					if(lamp->a != lamp->sentA){
						lamp->sentA = lamp->a;
						unsigned char *buffer = new unsigned char[3];
						buffer[0] = (unsigned char)255;
						buffer[1] = (unsigned char)lamp->channel+3;
						buffer[2] = (unsigned char)lamp->a;
						serial->writeBytes(buffer, 3);
						delete buffer;
						ok = false;
						/*	if(!alphaSet){
						 unsigned char *buffer = new unsigned char[3];
						 buffer[0] = (unsigned char)255;
						 buffer[1] = (unsigned char)1;
						 buffer[2] = (unsigned char)lamp->channel+3;
						 serial->writeBytes(buffer, 3);
						 delete buffer;
						 ok = false;
						 }*/
					}
				}
			}
			
			
		}
		
		
		[NSThread sleepForTimeInterval:0.02];
	}
}
@end
