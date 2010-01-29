//
//  Player.mm
//  openFrameworks
//
//  Created by Fuck You Buddy on 29/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Player.h"
#include "Tracking.h"

@implementation Player
@synthesize settingsView;

-(id) initWithN:(int)n{
	if([super init]){
		playerNumber = n;
		addNewBlob = NO;
	}
	return self;
}


- (BOOL) loadNibFile {	
	if (![NSBundle loadNibNamed:@"Player"  owner:self]){
		NSLog(@"Warning! Could not load the nib for camera ");
		return NO;
	}
	
	[title setStringValue:[NSString stringWithFormat:@"Playah %d",playerNumber+1]];
	
	[name bind:@"value"
	  toObject:[NSUserDefaultsController sharedUserDefaultsController]
   withKeyPath:[NSString stringWithFormat:@"values.player.%i.name", playerNumber+1]
	   options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
										   forKey:@"NSContinuouslyUpdatesValue"]];
	
	[color  bind:@"red"
		toObject:[NSUserDefaultsController sharedUserDefaultsController]
	 withKeyPath:[NSString stringWithFormat:@"values.player.%i.red", playerNumber+1]
		 options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
											 forKey:@"NSContinuouslyUpdatesValue"]];
	
	
	[[addTopButton midi] setChannel: [[NSNumber alloc] initWithInt:4]];
	[[addTopButton midi] setController: [[NSNumber alloc] initWithInt:12+(20*playerNumber)]];
	[[addTopButton midi] setLabel: [NSString stringWithFormat:@"Player %i - Tilføj top blob", playerNumber]];
	
	[[addRightButton midi] setChannel: [[NSNumber alloc] initWithInt:4]];
	[[addRightButton midi] setController: [[NSNumber alloc] initWithInt:13+(20*playerNumber)]];
	[[addRightButton midi] setLabel: [NSString stringWithFormat:@"Player %i - Tilføj højre blob", playerNumber]];
	
	[[addBottomButton midi] setChannel: [[NSNumber alloc] initWithInt:4]];
	[[addBottomButton midi] setController: [[NSNumber alloc] initWithInt:14+(20*playerNumber)]];
	[[addBottomButton midi] setLabel: [NSString stringWithFormat:@"Player %i - Tilføj bund blob", playerNumber]];
	
	[[addLeftButton midi] setChannel: [[NSNumber alloc] initWithInt:4]];
	[[addLeftButton midi] setController: [[NSNumber alloc] initWithInt:15+(20*playerNumber)]];
	[[addLeftButton midi] setLabel: [NSString stringWithFormat:@"Player %i - Tilføj venstre blob", playerNumber]];
	
	[[resetBlobButton midi] setChannel: [[NSNumber alloc] initWithInt:4]];
	[[resetBlobButton midi] setController: [[NSNumber alloc] initWithInt:16+(20*playerNumber)]];
	[[resetBlobButton midi] setLabel: [NSString stringWithFormat:@"Player %i - Reset blob", playerNumber]];
	
	
	return YES;
}


-(void) setup{
	
}
-(void) draw{
	
}
-(void) update{
	PersistentBlob * pblob;
	

	for(int i=0;i<pblobs.size();i++){
		BOOL pblobFound = NO;
		for(pblob in [tracker(0) persistentBlobs]){
			if(pblob->pid == pblobs[i])
				pblobFound = YES;
		}
		
		if(!pblobFound){
			pblobs.erase(pblobs.begin()+i);
		//	[numberPBlobs setIntValue:pblob.size()];
		}
	}
	
	if(addNewBlob){
		
		
		addNewBlob = NO;
	}
}



-(IBAction) addTopButton:(id)sender{
	addRule = new ofxVec2f(0,-1);
	addNewBlob = YES;	
}
-(IBAction) addRightButton:(id)sender{
	addRule = new ofxVec2f(1,0);
	addNewBlob = YES;
}
-(IBAction) addBottomButton:(id)sender{
	addRule = new ofxVec2f(0,1);
	addNewBlob = YES;
}
-(IBAction) addLeftButton:(id)sender{
	addRule = new ofxVec2f(-1,0);
	addNewBlob = YES;	
}
-(IBAction) resetBlobButton:(id)sender{
	pblobs.clear();
//	[numberPBlobs setIntValue:pblob.size()];
}


@end
