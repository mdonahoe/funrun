//
//  FRMissionChase.m
//  ontherun
//
//  Created by Matt Donahoe on 3/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FRMissionChase.h"
#import "FRMap.h"
#import "FRPathSearch.h"

@implementation FRMissionChase

- (id) init {
	self = [super init];
	
	target = [[FRPoint alloc] initWithDict:[NSDictionary dictionaryWithObject:@"target" forKey:@"name"] onMap:themap];
	target.pos = nil;
	running = NO;
	return self;
}

- (void) ticktock {
	//this method does not get called until there is a update for the player's position
	NSLog(@"count = %i",[toBeSpoken count]);
	if (target.pos==nil){
		target.pos = [themap move:player.pos forwardRandomly:500.0];
		running = NO;
		[self speak:[NSString stringWithFormat:@"new target acquired on %@",[themap roadNameFromEdgePos:target.pos]]];
	}
	
	float dist = [latestsearch distanceFromRoot:target.pos];
	if (dist<30){
		[self speak:@"You caught the target"];
		target.pos = nil;
	} else if (dist < 100 && running==NO){
		running=YES;
		[self speak:@"You've been spotted."];
	} else if (dist > 150 && running){
		running = NO;
		[self speak:@"The target has stopped running"];
	} else if (dist > 1000){
		[self speak:@"The target got away"];
		target.pos = nil;
	}
	
	if (target.pos){
		
		if ([latestsearch containsPoint:target.pos] && [themap is:player.pos onSameRoadAs:target.pos]){
			NSLog(@"%f == %i",dist,((int)(dist/25))*25);
			[self speak:[NSString stringWithFormat:@"The target is %i meters %@ you",((int)(dist/25))*25,[latestsearch directionFromRoot:target.pos]]];
		}
		
		FREdgePos * newpos;
		if (running){
			newpos = [latestsearch move:target.pos awayFromRootWithDelta:3.0];
		} else {
			newpos = [themap move:target.pos forwardRandomly:1.0];
		}
		
		if (newpos) {
			NSString * textualchange = [themap descriptionFromEdgePos:target.pos toEdgePos:newpos];
			if (textualchange) {
				NSString * action = @"went";
				if (running) action = @"ran";
				[self speak:[NSString stringWithFormat:@"He just %@ %@",action,textualchange]];
			} else {
				
				if (![themap is:player.pos onSameRoadAs:newpos]) [self speakIfEmpty:[NSString stringWithFormat:@"He is heading %@",[themap descriptionOfEdgePos:newpos]]];
			}
			target.pos = newpos;
		}
	}
	
	[super ticktock];
}
@end
