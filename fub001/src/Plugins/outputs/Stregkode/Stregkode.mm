//
//  Stregkode.m
//  openFrameworks
//
//  Created by Fuck You Buddy on 12/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Stregkode.h"
#include "Tracking.h"
#include "Players.h"

@implementation StregkodePlayer



@end


@implementation Stregkode
@synthesize percent, going, players, sound;

-(void) initPlugin{
	players = [[NSMutableArray array]retain];
	going = false;
	
		sound = new ofSoundPlayer();
		sound->loadSound("stregkode.aif");
}

-(void) update:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	if(going && percent < 1){
		percent += [speedSlider floatValue]*0.01*(1.0/ofGetFrameRate());
		
		PersistentBlob * pblob;
		TrackerObject* t = tracker(0);		
		for(pblob in [t persistentBlobs]){
			bool playerFound = false;
			StregkodePlayer * player;
			for(player in players){
				if(player->pid == pblob->pid){
					playerFound = true;
				}
			}
			
			if(!playerFound){
				if([pblob getLowestPoint].y > (1.0-percent)){
					StregkodePlayer * newp = [[StregkodePlayer alloc] init];
					newp->pid = pblob->pid;					
					newp->r = 255*[[GetPlugin(Players) playerColor:num] redComponent];
					newp->g = 255*[[GetPlugin(Players) playerColor:num] greenComponent];
					newp->b = 255*[[GetPlugin(Players) playerColor:num] blueComponent];
					newp->t = 0;
					newp->startM = 0.0f;
					newp->whiteAdd = 255.0f;
					[players addObject:newp];
					cout<<"Add "<<newp->pid<<"  "<<num<<endl;
					sound->setPan(0.5);
					sound->play();
					
					num ++;
					num = MIN(num,3);
				}
			}
			
		}
	}
	StregkodePlayer * player;
	
	for(player in players){
		player->t += (1.0/ofGetFrameRate());
		if(player->startM < 1.0){
			player->startM += [flashSpeedSlider floatValue]*(1.0/ofGetFrameRate()); 
		} else if(player->whiteAdd > 0){
			player->whiteAdd -= [flashSpeedSlider floatValue]*(1.0/ofGetFrameRate()) * 255.0;
		}
	}
}

-(void) draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	if(going){
		ofFill();
		ofSetColor(255, 0, 0);
		ofLine(0, 1.0-percent, 0.5, 1.0-percent);
		StregkodePlayer * player;
		
		for(player in players){
			float r = (MIN(player->r  + player->whiteAdd,255))* player->startM;
			float g =(MIN(player->g  + player->whiteAdd,255))* player->startM;
			float b = (MIN(player->b + player->whiteAdd,255)) * player->startM ;
			
			
			ofSetColor(r,g,b);
			
			PersistentBlob * pblob;
			for(pblob in [tracker(0) persistentBlobs]){
				if(pblob->pid == player->pid){
					Blob * blob;
					for(blob in [pblob blobs]){
						ofBeginShape();
						for(int i=0;i<[blob nPts];i++){
							ofVertex([blob pts][i].x, [blob pts][i].y);
						}
						ofEndShape(true);
					}
					
				}
			}
		}
	}
}

-(IBAction) go:(id)sender{
	[[self players] removeAllObjects];
	[self setPercent:0];
	[self setGoing:true]; 
	num = 0;
}
@end
