//
//  FRTrigger.m
//  ontherun
//
//  Created by Matt Donahoe on 1/5/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "FRTrigger.h"

@implementation FRTrigger

@synthesize active,name,point,ons,offs,swaptargets;

- (id) initWithDict:(NSDictionary*)dict {
	self = [super init];
	
	if (self) {
		name = [[NSString alloc] initWithString:[dict objectForKey:@"name"]];
		NSNumber * c = [dict objectForKey:@"countdown"];
		if (c!=nil){
			countdown = [c floatValue];
		} else {
			countdown = -1;
		}
		
		NSNumber * lt = [dict objectForKey:@"lessthan"];
		if (lt!=nil){
			lessthan = [lt floatValue];
		} else {
			lessthan = 0;
		}
		
		NSNumber * gt = [dict objectForKey:@"greaterthan"];
		if (gt!=nil){
			greaterthan = [gt floatValue];
		} else {
			greaterthan = 10000000000000; //big number
		}
		lastdistance = -1.0;
		dictme = dict;
		[dictme retain];
	}
	
	return self;
}
- (void) ticktock {
	if (countdown>0) countdown--;
	if (countdown==0) {
		[self execute];
		countdown = -1;
	}
}
- (NSString *)displayname {
	return [NSString stringWithFormat:@"%@:%1.1f %1.1f",name,countdown,lastdistance];
}
- (void) setDelegate:(id)x {
	delegate = x;
}
- (void) activate {
	active = YES;
	//if (countdown<0) return;
	//[self performSelector:@selector(execute) withObject:self afterDelay:countdown];
}
- (void) deactivate {
	//[NSObject cancelPreviousPerformRequestsWithTarget:self];
	active = NO;
}
- (void) execute {
	//speak or play sound
	NSLog(@"trig %@ has succeeded!",name);
	[self deactivate];
	for (FRTrigger * trig in ons){
		[trig activate];
	}
	for (FRTrigger * trig in offs){
		[trig deactivate];
	}
	//for (pair in swaptargets){
		
	//}
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:name message:@"trigger succeeded" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil] autorelease];
    // optional - add more buttons:
    [alert addButtonWithTitle:@"cool"];
    [alert show];
	if (delegate) [delegate triggered];
}
- (float) checkdistancefrom:(CLLocation *)user {
	if (point==nil || active==NO) return -1.0;
	float d = [point.pos distanceFromLocation:user];
	if (d < lessthan || d > greaterthan) {
		[self execute];
	}
	lastdistance = d;
	return d;
}
- (void) finishByUsingTriggerList:(NSArray *)triggers andPointList:(NSArray*)points {

	NSMutableArray * _ons = [NSMutableArray arrayWithCapacity:3];
	for (NSString * nm in [dictme objectForKey:@"ons"]){
		for (FRTrigger * trig in triggers){
			if ([nm isEqualToString:trig.name]) [_ons addObject:trig];
		}
	}
	ons = [[NSArray alloc] initWithArray:_ons];
	
	NSMutableArray * _offs = [NSMutableArray arrayWithCapacity:3];
	for (NSString * nm in [dictme objectForKey:@"ons"]){
		for (FRTrigger * trig in triggers){
			if ([nm isEqualToString:trig.name]) [_ons addObject:trig];
		}
	}
	offs = [[NSArray alloc] initWithArray:_offs];
	
	NSString * pname = [dictme objectForKey:@"point"];
	if (pname!=nil){
		NSLog(pname);
		for (FRPoint * pt in points){
			if ([pname isEqualToString:pt.name]) {
				point = pt;
				NSLog(@"trig %@ points to %@",name,point.name);
			}
		}
		[point retain];
	}
	
	if ([[dictme objectForKey:@"active"] boolValue]) [self activate];
	[dictme release];
	dictme = nil;
	
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
		NSString * temp = name;
        name = [NSString stringWithFormat:@"good - %@",temp];
		[name retain];
		[temp release];
    }
	[delegate triggered];
}
@end
