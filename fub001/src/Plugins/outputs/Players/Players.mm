//
//  Players.mm
//  openFrameworks
//
//  Created by Fuck You Buddy on 12/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Players.h"


@implementation Players

-(void) initPlugin{
	for(int i=0;i<4;i++){
		players[i] = [[Player alloc] initWithN:i];
		[players[i] loadNibFile];
		
		NSView * dest;
		
		if(i == 0) dest = player1View; 		
		if(i == 1) dest = player2View; 
		if(i == 2) dest = player3View; 
		if(i == 3) dest = player4View; 		
		
		[[players[i] settingsView] setFrame:[dest bounds]];
		[dest addSubview:[players[i] settingsView]];
	}
}	

-(void) setup{
	for(int i=0;i<4;i++){
		[players[i] setup];
	}
}

-(void) update:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	for(int i=0;i<4;i++){
		[players[i] update];
	}
}

-(void) draw:(CFTimeInterval)timeInterval displayTime:(const CVTimeStamp *)outputTime{
	ofEnableAlphaBlending();
	for(int i=0;i<4;i++){
		[players[i] draw];
	}
}
/*
-(NSColor*) playerColor:(int)player{
	if(player == 0){
		return [player1color color];
	}
	if(player == 1){
		return [player2color color];
	}
	if(player == 2){
		return [player3color color];
	}
	if(player == 3){
		return [player4color color];
	}
}*/
@end
