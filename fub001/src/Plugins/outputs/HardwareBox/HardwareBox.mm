//
//  DMXOutput.mm
//  openFrameworks
//
//  Created by Jonas Jongejan on 24/11/09.
//  Copyright 2009 HalfdanJ. All rights reserved.
//

#import "HardwareBox.h"




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
	arduinoState = xbeestate = 0;
	projector1state = projector2state = -1; 
	[projectorButton setEnabled:NO];
	[projectorButton setState:NSMixedState];
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
}

-(void) update:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	pthread_mutex_lock(&mutex);
	
	timeSinceLastProjUpdate ++;
	
	if(connected){
		[usbStatus setStringValue:@"USB Status: Connected"];
		[usbStatus setTextColor:[NSColor blackColor]];
		// NOT THIS ONE handled later by states from projectors - [projectorButton setEnabled:NO];
		[xbeeLedButton setEnabled:YES];
		[laserButton setEnabled:YES];
	} else {
		[usbStatus setStringValue:@"USB Status: NOT Connected"];	
		[usbStatus setTextColor:[NSColor redColor]];
		[projectorButton setEnabled:NO];
		[xbeeLedButton setEnabled:NO];
		[laserButton setEnabled:NO];
	}
	
	[buffersizeStatus setStringValue:[NSString stringWithFormat:@"Serial buffer size: %d", serialBuffer->size()]];
	[arduinoStatus setStringValue:[NSString stringWithFormat:@"Arduino status: %d", arduinoState]];
	
	if(projector1state > -1 && projector2state > -1){
		if (![projectorButton isEnabled]) {
			if (projector1state == 0 || projector2state == 0) {
				projectorsOn = true;
				[projectorButton setState:NSOnState];	
			} else {
				projectorsOn = false;
				[projectorButton setState:NSOffState];	
			}
			[projectorButton setEnabled:YES];
		}
	}
	
	if ([projectorButton isEnabled]) {
		
		if(projectorsOn && [projectorButton state] == NSOffState){
			projectorsOn = false;
			for(int i=0;i<2;i++){
				serialBuffer->push_back(255);
				serialBuffer->push_back(6);
				serialBuffer->push_back(i);
				serialBuffer->push_back('0');
				serialBuffer->push_back('0');
			}
		}
		
		if(!projectorsOn && [projectorButton state] == NSOnState){
			projectorsOn = true;
			for(int i=0;i<2;i++){
				serialBuffer->push_back(255);
				serialBuffer->push_back(6);
				serialBuffer->push_back(i);
				serialBuffer->push_back('0');
				serialBuffer->push_back('1');
			}
		}
		
	}
	
	[projector1Status setStringValue:[NSString stringWithFormat:@"Projector 1 status: %d %@", projector1state, [self getStatusFromCode:projector1state]]];
	[projector1Temperature setStringValue:[NSString stringWithFormat:@"Projector 1 temperature: %f %f %f",  projTemps[0], projTemps[1], projTemps[2]]];
	[projector2Status setStringValue:[NSString stringWithFormat:@"Projector 2 status: %d %@", projector2state, [self getStatusFromCode:projector2state]]];
	[projector2Temperature setStringValue:[NSString stringWithFormat:@"Projector 2 temperature: %f %f %f", projTemps[3], projTemps[4], projTemps[5]]];
	
	if(xbeeLedOn && [xbeeLedButton state] == NSOffState){
		xbeeLedOn = false;
		serialBuffer->push_back(255);
		serialBuffer->push_back(3);
		serialBuffer->push_back(xbeeLedOn);
	}
	
	if(!xbeeLedOn && [xbeeLedButton state] == NSOnState){
		xbeeLedOn = true;
		serialBuffer->push_back(255);
		serialBuffer->push_back(3);
		serialBuffer->push_back(xbeeLedOn);
	}
	
	[xbeeLEDStatus setStringValue:[NSString stringWithFormat:@"XBee LED status: %d", xbeeLedOn]];
	[xbeeStatus setStringValue:[NSString stringWithFormat:@"XBee status: %d, signal strength: %d", xbeestate, int(xbeeRSSI)]];
	[xbeeSignalStrength setFloatValue:xbeeRSSI];
	
	if(laserOn && [laserButton state] == NSOffState){
		laserOn = false;
		serialBuffer->push_back(255);
		serialBuffer->push_back(4);
		serialBuffer->push_back(0);
		serialBuffer->push_back(laserOn);
		
		serialBuffer->push_back(255);
		serialBuffer->push_back(4);
		serialBuffer->push_back(1);
		serialBuffer->push_back(laserOn);
	}
	
	if(!laserOn && [laserButton state] == NSOnState){
		laserOn = true;
		serialBuffer->push_back(255);
		serialBuffer->push_back(4);
		serialBuffer->push_back(0);
		serialBuffer->push_back(laserOn);
		
		serialBuffer->push_back(255);
		serialBuffer->push_back(4);
		serialBuffer->push_back(1);
		serialBuffer->push_back(laserOn);
	}
	
	[laserStatus setStringValue:[NSString stringWithFormat:@"Laser status: %d", laserOn]];
	
	pthread_mutex_unlock(&mutex);
	
}

-(NSString *) getStatusFromCode:(int) code{
	NSString * status;
	switch (code) {
		case 0:
			status = @"On";
			break;
		case 04:
			status = @"Power Management mode after Cooling down";
			break;
		case 10:
			status = @"Power Malfunction";
			break;
		case 40:
			status = @"Countdown";
			break;
		case 20:
			status = @"Cooling down";
			break;
		case 21:
			status = @"Cooling down after the projector is turned off when the lamps are out.";
			break;
		case 24:
			status = @"Cooling down at Power Management mode";
			break;
		case 28:
			status = @"Cooling down at the temperature anomaly";
			break;
		case 80:
			status = @"Standby";
			break;
		case 81:
			status = @"Stand-by mode after Cooling down when the lamps are out.";
			break;
		case 88:
			status = @"Stand-by mode after Cooling down at the temperature anomaly.";
			break;
		case -1:
			status = @"No serial connection.";
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
						xbeeRSSI += ((float)buffer[4]-(float)xbeeRSSI)/300.0;
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
					ok = false;
				} else {
					int n=0;
					pthread_mutex_lock(&mutex);
					
					if(timeSinceLastProjUpdate > 200){
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
@end
