//
//  Players.mm
//  openFrameworks
//
//  Created by Fuck You Buddy on 12/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Players.h"


@implementation Players
@synthesize player1color, player2color, player3color, player4color;

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
}
@end
