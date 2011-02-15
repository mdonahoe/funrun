//
//  FRPointSequence.m
//  ontherun
//
//  Created by Matt Donahoe on 2/15/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "FRPointSequence.h"
#import "FRPathSearch.h"
#import "FRMission.h"

@implementation FRPointSequence
- (id) initWithDict:(NSDictionary*)dict onMap:(FRMap*)map {
	self = [super init];
	
	if (self) {
		
		self.title = [dict objectForKey:@"name"];
		dictme = dict;
		[dictme retain];
		self.subtitle = @"FRPointSequence";
		mystate = 0;
		NSMutableArray * temppos = [[NSMutableArray alloc] init];
		
		for (NSArray * latlon in [dict objectForKey:@"positions"]){
			CLLocation * p = [[CLLocation alloc] initWithLatitude:[[latlon objectAtIndex:0] floatValue]
														longitude:[[latlon objectAtIndex:1] floatValue]];
			
			[temppos addObject:[map edgePosFromPoint:p]];
			[p release];
		}
		
		positions = [[NSArray alloc] initWithArray:temppos];
		[temppos release];
		messages = [[NSArray alloc] initWithArray:[dict objectForKey:@"messages"]];
		self.pos = [positions objectAtIndex:mystate];
	}
	
	return self;
}
- (void) updateForMission:(FRMission *)mission {
	
	FRPathSearch * playerview = [mission getPlayerView];
	
	if (playerview && mystate < [positions count] && [playerview containsPoint:self.pos]) {
		//NSLog(@"in path search");
		float dist = [playerview distanceFromRoot:self.pos];
		if (dist < 20) {
			//reached the point
			[mission speakEventually:[messages objectAtIndex:mystate]];
			mystate++;
			
			//once it runs out of states, do nothing. (remove from mission.points?)
			if (mystate < [positions count]) self.pos = [positions objectAtIndex:mystate];
		}
	}
}


@end
