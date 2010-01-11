//
//  Lines.mm
//  openFrameworks
//
//  Created by Fuck You Buddy on 11/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Lines.h"
#import "Tracking.h"

@implementation Lines

-(void) draw:(const CVTimeStamp *)outputTime{
	PersistentBlob * pblob;
	TrackerObject* t = tracker([trackingDirection selectedSegment]);
	for(pblob in [t persistentBlobs]){
		
	}
}


@end
