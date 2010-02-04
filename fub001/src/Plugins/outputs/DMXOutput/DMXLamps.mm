//
//  DMXLamps.m
//  openFrameworks
//
//  Created by Fuck You Buddy on 02/02/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DMXLamps.h"



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
@synthesize lamps, number;

-(id) initWithStartaddress:(int) address{
	if([super init]){
		startAddress = address;
		
		LedLamp * l[15];
		
		int x=0,y=0;
		for(int i=0;i<15;i++){
			
			l[i] = [[LedLamp alloc] init];
			l[i]->channel = address + i*4;
			l[i]->pos = new ofxPoint2f(x,y);
			l[i]->r = 0;
			l[i]->g = 0;
			l[i]->b = 0;
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
		case BLENDING_MULT:
			for(int i=0;i<3;i++){
				curColors[i] *= (1-newColors[3]) + newColors[i] * newColors[3];
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


-(BOOL)isLamp:(ofxPoint2f)lampPos atCoordinate:(ofxPoint3f)cord{
	ofxPoint3f p;
	p.y = lampPos.y;
	if(number == 0 || number == 1)
		p.x = 0;
	else 
		p.x = 1;
	
	switch (number) {
		case 0:
			p.z = 2-lampPos.x;
			break;
		case 1:
			p.z = 6-lampPos.x;
			break;
		case 2:
			p.z = lampPos.x+4;
			break;
		case 3:
			p.z = lampPos.x;			
			break;
		default:
			break;
	}
	
	return(p.distance(cord) < 0.4);
} 


@end
