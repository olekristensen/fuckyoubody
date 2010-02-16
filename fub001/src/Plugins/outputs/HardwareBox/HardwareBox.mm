//
//  DMXOutput.mm
//  openFrameworks
//
//  Created by Jonas Jongejan on 24/11/09.
//  Copyright 2009 HalfdanJ. All rights reserved.
//

#import "HardwareBox.h"
#include "ProjectionSurfaces.h"
#include "Tracking.h"



@implementation HardwareBox

-(void) initPlugin{
	thread = [[NSThread alloc] initWithTarget:self
									 selector:@selector(updateSerial:)
									   object:nil];
	serial = new ofSerial();	
	
	ok = connected = serial->setup("/dev/tty.usbserial-A9005fJy", 115200);
	cout<<"Connected: "<<connected<<endl;
	pthread_mutex_init(&mutex, NULL);
	serialBuffer = new vector<unsigned char>;
	inCommandProcess = false;
	commandInProcess = -1;
	arduinoState = projector1state = projector2state = xbeestate = 0;
	[thread start];	
	timeout = 0;
	
	xbeeLedOn = false;
	xbeeRSSI = 0;
	laserOn = false;
	
	startDmxChannel = 1;
	stopDmxChannel = 1;
	for(int i=0;i<100;i++){
		dmxValues[i] = 0;
	}
	
	timeSinceLastProjUpdate = 0;
	
	userDefaults = [[NSUserDefaults standardUserDefaults] retain];

	
	
	for(int i=0;i<8;i++){
		trackingFilter[i] = new Filter();	
		trackingFilter[i]->setNl(9.413137469932821686e-04, 2.823941240979846506e-03, 2.823941240979846506e-03, 9.413137469932821686e-04);
		trackingFilter[i]->setDl(1, -2.5818614306773719263, 2.2466666427559748864, -.65727470210265670262);
	}
	
	trackingDestinations[0] = new ofxPoint2f(0,0);
	trackingDestinations[1] = new ofxPoint2f(1,0);
	trackingDestinations[2] = new ofxPoint2f(1,1);
	trackingDestinations[3] = new ofxPoint2f(0,1);
	
}

-(void) update:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	pthread_mutex_lock(&mutex);
	
	timeSinceLastProjUpdate ++;
	
	if(connected){
		[usbStatus setStringValue:@"USB Status: Connected"];
		[usbStatus setTextColor:[NSColor blackColor]];
		[[[controller controlPanel] hardwareStatus] setState:NSOnState];
	} else {
		[usbStatus setStringValue:@"USB Status: NOT Connected"];	
		[usbStatus setTextColor:[NSColor redColor]];
		[[[controller controlPanel] hardwareStatus] setState:NSOffState];
	}
	
	
	
	
	
	[buffersizeStatus setStringValue:[NSString stringWithFormat:@"Serial buffer size: %d", serialBuffer->size()]];
	[arduinoStatus setStringValue:[NSString stringWithFormat:@"Arduino status: %d", arduinoState]];
	
	
	[projector1Status setStringValue:[NSString stringWithFormat:@"Projector 1 status: %d %@", projector1state, [self getStatusFromCode:projector1state]]];
	[projector2Status setStringValue:[NSString stringWithFormat:@"Projector 2 status: %d %@", projector2state, [self getStatusFromCode:projector2state]]];
	[projector1Temperature setStringValue:[NSString stringWithFormat:@"Projector 1 temperature: %f %f %f",  projTemps[0], projTemps[1], projTemps[2]]];
	[projector2Temperature setStringValue:[NSString stringWithFormat:@"Projector 2 temperature: %f %f %f", projTemps[3], projTemps[4], projTemps[5]]];
	
	[xbeeStatus setStringValue:[NSString stringWithFormat:@"XBee status: %d, signal strength: %d", xbeestate, int(xbeeRSSI)]];
	if(xbeestate)
		[[[controller controlPanel] xbeeStatus] setState:NSOnState];
	else {
		[[[controller controlPanel] xbeeStatus] setState:NSOffState];
	}


	[xbeeSignalStrength setFloatValue:xbeeRSSI];
	
	[[[controller controlPanel] xbeeStrength] setFloatValue:xbeeRSSI*0.5];

	[xbeeLEDStatus setStringValue:[NSString stringWithFormat:@"XBee LED status: %d", xbeeLedOn]];
	[laserStatus setStringValue:[NSString stringWithFormat:@"Laser status: %d", laserOn]];
	
	pthread_mutex_unlock(&mutex);
	
	
	if([trackingScreen state] == NSOnState){
		ProjectionSurfacesObject * surf = [GetPlugin(ProjectionSurfaces) getProjectionSurfaceByName:"Front" surface:"Backwall"];
		if([tracker(0) numBlobs] == 4){
			
			Blob * b;
			ofxPoint2f center;
			int n= 0;
			for(b in [[GetPlugin(Tracking) trackerNumber:surf->trackerNumber] blobs]){
				center += [b centroid];
				n++;
			}
			center /= n;
			
			ofxPoint2f topLeft = center, topRight= center, bottomLeft= center, bottomRight= center;
			for(b in [[GetPlugin(Tracking) trackerNumber:surf->trackerNumber] blobs]){
				if(([b centroid].x < topLeft.x && [b centroid].y < topLeft.y)){
					topLeft = [b centroid];
				}
				if(([b centroid].x > topRight.x && [b centroid].y < topRight.y)){
					topRight = [b centroid];
				}
				if(([b centroid].x < bottomLeft.x && [b centroid].y > bottomLeft.y)){
					bottomLeft = [b centroid];
				}
				if(([b centroid].x > bottomRight.x && [b centroid].y > bottomRight.y)){
					bottomRight = [b centroid];
				}
			}
			
			
			trackingDestinations[0] = new ofxPoint2f( topLeft);
			trackingDestinations[1] = new ofxPoint2f( topRight);
			trackingDestinations[2] = new ofxPoint2f( bottomRight);
			trackingDestinations[3] = new ofxPoint2f( bottomLeft);
			for(int i=0;i<4;i++){
				surf->corners[i] = 	trackingDestinations[i];
			}
			
			[surf recalculate];
			
			ofxPoint2f pts[4];
			float s = 100.0;
			
			pts[0] = ofxPoint2f(0,0) + ofxPoint2f([offsetSliderX1 floatValue]/s , [offsetSliderY1 floatValue]/s);
			pts[1] = ofxPoint2f(surf->aspect,0) + ofxPoint2f([offsetSliderX2 floatValue]/s , [offsetSliderY2 floatValue]/s);
			pts[2] = ofxPoint2f(surf->aspect,1) + ofxPoint2f([offsetSliderX3 floatValue]/s , [offsetSliderY3 floatValue]/s);
			pts[3] = ofxPoint2f(0,1) + ofxPoint2f([offsetSliderX4 floatValue]/s , [offsetSliderY4 floatValue]/s);
			
			for(int i=0;i<4;i++){
				trackingDestinations[i] = new ofxPoint2f( [GetPlugin(ProjectionSurfaces) convertPoint:pts[i] toProjection:"Front" fromSurface:"Backwall"]);
			}
			
			
		}
		
		
		
		
		for(int i=0;i<4;i++){
			//cout<<surf->trackingDestinations[i]->x<<", "<<surf->trackingDestinations[i]->y<<"    ";
			surf->corners[i] = new ofxPoint2f(
											  trackingFilter[i*2]->filter(trackingDestinations[i]->x),
											  trackingFilter[i*2+1]->filter(trackingDestinations[i]->y)  );
			/*	surf->corners[i] = new ofxPoint2f(
			 surf->trackingFilter[i*2]->filter(surf->trackingDestinations[i]->x),
			 surf->trackingFilter[i*2+1]->filter(surf->trackingDestinations[i]->y)  );*/
			
		}				
		//cout<<endl;
		[surf recalculate];
		
		
		
		
		
	}
	
}

-(NSString *) getStatusFromCode:(int) code{
	NSString * status;
	switch (code) {
		case 0:
			status = @"On";
			break;
		case 80:
			status = @"Standby";
			break;
		case 40:
			status = @"Countdown";
			break;
		case 20:
			status = @"Cooling down";
			break;
		case 10:
			status = @"Power Malfunction";
			break;
		case 28:
			status = @"Cooling down at the temperature anomaly";
			break;
		case 24:
			status = @"Cooling down at Power Management mode";
			break;
		case 04:
			status = @"Power Management mode after Cooling down";
			break;
		case 21:
			status = @"Cooling down after the projector is turned off when the lamps are out.";
			
			break;
		case 81:
			status = @"Stand-by mode after Cooling down when the lamps are out.";
			break;
		case 88:
			status = @"Stand-by mode after Cooling down at the temperature anomaly.";
			break;
			
		default:
			status = @"????";
			break;
	}
	return status;
	
}


/*
 Get OK				254 (used for splitting buffers up)
 
 Get status:			255 - 1				
 returnbytes:	general - projector 1 - projector 2 - xbee
 
 Set dmx channel:	255 - 2 - dmx start - dmx stop (inkl) - dmx kanaler....
 
 Set xbee led:		255 - 3 - on/off
 
 Set laser:		255 - 4 - on/off
 
 Get proj status:		255 - 5 
 return bytes: proj1state - proj2state - proj1temp ..... - proj2temp .....
 
 Fire command on projector:		255 - 6 - Projector number - Byte1 - Byte2 
 
 
 */

-(void) updateSerial:(id)param{
	
	if(connected){
		
		while(1){
			timeout++;
			if(timeout > 1000){
				cout<<"Timeout to arduino... Trying again"<<endl;
				timeout = 0;
				ok = true;
				inCommandProcess = false;
				commandInProcess = -1;
			}
			while(serial->available() > 0){
				timeout = 0;
				//cout<<"Theres data on the way. Command: "<<commandInProcess<<" on the way: "<<serial->available() <<endl;
				bool needMoreData = false;
				int n=serial->available();
				
				unsigned char buffer[100];
				switch (commandInProcess) {
					case 1:						
						serial->readBytes(buffer, 5);	
						arduinoState = buffer[0];
						projector1state = buffer[1];
						projector2state = buffer[2];
						xbeestate = buffer[3];
						xbeeRSSI += ((float)buffer[4]-(float)xbeeRSSI)/33.0;
						serial->flush(true, false);
						
						break;
						
					case 3: //XBee LED
						serial->readBytes(buffer, n);	
						/*						cout<<"XBee led: ";
						 for(int i=0;i<n;i++){
						 cout<<(int)buffer[i]<<"  ";							
						 }
						 cout<<endl;*/
						serial->flush(true, false);						
						break;
						
					case 4: //Laser
						serial->readBytes(buffer, n);	
						serial->flush(true, false);						
						break;
						
					case 5:
						serial->readBytes(buffer, n);	
						serial->flush(true, false);			
						//						cout<<"Got proj state: "<<(int)buffer[0]<<"  "<<(int)buffer[1]<<"  "<<(char)buffer[2]<<"   "<<(char*)buffer<<endl;
						projector1state = (int)buffer[0];
						projector2state = (int)buffer[1];
						
						/*for(int i=2;i<2+7*6;i++){
						 cout<<i<<":  "<<(char)buffer[i]<<"  /   "<<(int)buffer[i]<<endl;
						 }
						 
						 for(int i=0;i<6;i++){
						 projTemps[i] = 0;
						 projTemps[i] += 10*((int)buffer[3+7*i]-48);
						 projTemps[i] += (int)buffer[4+7*i]-48;						
						 projTemps[i] += ((int)buffer[6+7*i]-48)/10.0;		
						 cout<<"Temp "<<i<<"  "<<projTemps[i]<<endl;
						 }*/
						break;
						
					default:
						
						serial->flush(true, false);
						break;
				}
				
				
				if(!needMoreData){
					inCommandProcess = false;
					commandInProcess = -1;
					ok = true; 
				}
			}
			if(ok){	
				if(serialBuffer->size() > 0){
					int n = serialBuffer->size();
					unsigned char * bytes = new unsigned char[n+1];;
					
					for(int i=0;i<n;i++){
						bytes[i] = serialBuffer->at(0);
						//		cout<<(int)bytes[i]<<endl;
						
						if(bytes[i] == 255 && inCommandProcess){
							//Begin of new commando
							n = i;
						} else {
							if(bytes[i] == 255){
								inCommandProcess = true;
							}
							else if(inCommandProcess && commandInProcess == -1){
								commandInProcess = bytes[i];
								//	cout<<"Command in process: "<<(int)bytes[i]<<endl;
							}
							serialBuffer->erase(serialBuffer->begin());
						}
					}
					//bytes[n] = 254; //End of send signal
					/*					
					 cout<<"Send "<<n<<"bytes: ";
					 for(int i=0;i<n;i++){
					 cout<<(int)bytes[i]<<"  ";
					 }
					 cout<<endl;
					 */					
					serial->writeBytes(bytes, n);
					delete bytes;
					ok = false;
				} else {
					int n=0;
					pthread_mutex_lock(&mutex);
					
					if(([laserButton state] == NSOnState) != laserOn){
						laserOn = ([laserButton state] == NSOnState);
						serialBuffer->push_back(255);
						serialBuffer->push_back(4);
						serialBuffer->push_back(0);
						
						serialBuffer->push_back(laserOn);
						serialBuffer->push_back(255);
						serialBuffer->push_back(4);
						serialBuffer->push_back(1);
						
						serialBuffer->push_back(laserOn);
					} else if(([ledButton state] == NSOnState) != xbeeLedOn){
						xbeeLedOn = ([ledButton state] == NSOnState);						
						serialBuffer->push_back(255);
						serialBuffer->push_back(3);
						serialBuffer->push_back(xbeeLedOn);
					}
					else if(timeSinceLastProjUpdate > 200){
						serialBuffer->push_back(255);
						serialBuffer->push_back(5);					
						timeSinceLastProjUpdate = 0;
					} else {
						
						serialBuffer->push_back(255);
						serialBuffer->push_back(2);
						serialBuffer->push_back(startDmxChannel);
						serialBuffer->push_back(stopDmxChannel);
						for(int i=startDmxChannel;i<= stopDmxChannel;i++){
							serialBuffer->push_back(dmxValues[i]);
						}
						
						serialBuffer->push_back(255);
						serialBuffer->push_back(1);
					}
					pthread_mutex_unlock(&mutex);
					
				}
			}
			
			
			[NSThread sleepForTimeInterval:0.003];
		}
	}
}

-(IBAction) toggleXBeeLed:(id)sender{
	pthread_mutex_lock(&mutex);
	
	xbeeLedOn = !xbeeLedOn;
	serialBuffer->push_back(255);
	serialBuffer->push_back(3);
	serialBuffer->push_back(xbeeLedOn);
	pthread_mutex_unlock(&mutex);
	
}

-(IBAction) toggleLaser:(id)sender{
	pthread_mutex_lock(&mutex);
	laserOn = !laserOn;
	serialBuffer->push_back(255);
	serialBuffer->push_back(4);
	serialBuffer->push_back(0);
	
	serialBuffer->push_back(laserOn);
	serialBuffer->push_back(255);
	serialBuffer->push_back(4);
	serialBuffer->push_back(1);
	
	serialBuffer->push_back(laserOn);
	
	pthread_mutex_unlock(&mutex);
	
}

-(IBAction) turnProjectorOn:(id)sender{
	pthread_mutex_lock(&mutex);
	for(int i=0;i<2;i++){
		serialBuffer->push_back(255);
		serialBuffer->push_back(6);
		serialBuffer->push_back(i);
		serialBuffer->push_back('0');
		serialBuffer->push_back('0');
	}
	pthread_mutex_unlock(&mutex);	
}
-(IBAction) turnProjectorOff:(id)sender{
	pthread_mutex_lock(&mutex);
	for(int i=0;i<2;i++){
		serialBuffer->push_back(255);
		serialBuffer->push_back(6);
		serialBuffer->push_back(i);
		serialBuffer->push_back('0');
		serialBuffer->push_back('1');
	}
	pthread_mutex_unlock(&mutex);		
}
-(void) setDmxValue:(int)val onChannel:(int)channel{
	
	//if(channel < 40){
	if(channel > stopDmxChannel)
		stopDmxChannel = channel;
	
	dmxValues[channel] = ofClamp(val, 0,252);
	//	dmxValues[channel] = 252;
	
	/*	if(channel % 4 == 1){
	 dmxValues[channel] = 252;
	 } else if(channel % 4 == 0){
	 dmxValues[channel] = 252;
	 }else if(channel % 4 == 2){
	 dmxValues[channel] = 252;
	 cout<<ofClamp(val, 0,251)<<"   "<<val<<endl;
	 } else if(channel % 4 == 3){
	 dmxValues[channel] = ofClamp(val, 0,251);
	 
	 }*/
	
	//}
}

-(IBAction) resetLensshift:(id)sender{
	pthread_mutex_lock(&mutex);
	
	for(int i=0;i<2;i++){
		for(int u=0;u<40;u++){
			serialBuffer->push_back(255);
			serialBuffer->push_back(6);
			serialBuffer->push_back(i);
			serialBuffer->push_back('5');
			serialBuffer->push_back('E');
		}
		
	}
	pthread_mutex_unlock(&mutex);		
	
}

-(IBAction) pos1Lensshift:(id)sender{
	pthread_mutex_lock(&mutex);
	
	for(int i=0;i<2;i++){
		for(int u=0;u<9;u++){
			
			serialBuffer->push_back(255);
			serialBuffer->push_back(6);
			serialBuffer->push_back(i);
			serialBuffer->push_back('5');
			serialBuffer->push_back('D');
		}
	}	
	pthread_mutex_unlock(&mutex);		
	
}
-(IBAction) pos2Lensshift:(id)sender{
	
}
-(IBAction) revertScreen:(id)sender{
	ProjectionSurfacesObject * surface = [GetPlugin(ProjectionSurfaces) getProjectionSurfaceByName:"Front" surface:"Backwall"];
	for(int i=0;i<4;i++){
		surface->corners[i]->x = [userDefaults doubleForKey:[NSString stringWithFormat:@"projector%d.surface%d.corner%d.x",0, 1, i]];
		surface->corners[i]->y = [userDefaults doubleForKey:[NSString stringWithFormat:@"projector%d.surface%d.corner%d.y",0, 1, i]];
	}
	surface->aspect = [userDefaults doubleForKey:[NSString stringWithFormat:@"projector%d.surface%d.aspect",0, 1]];
	[surface recalculate];
}
@end
