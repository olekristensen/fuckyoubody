//
//  _ExampleOutput.mm
//  openFrameworks
//
//  Created by Jonas Jongejan on 15/11/09.

#import "_ExampleOutput.h"

@implementation _ExampleOutput
@synthesize s;

-(void) initPlugin{
	NSLog(@"hmmmmmm");
	s = [NSString stringWithString:@"hmmm"];
	NSLog(s);
}

-(IBAction) pressButton:(id)sender{
	NSLog(@"Button pressed");
	[text setStringValue:s];
}

@end
