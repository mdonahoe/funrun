//
//  FRPointTimerList.m
//  ontherun
//
//  Created by Matt Donahoe on 3/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FRPointTimerList.h"
#import "FRPathSearch.h"
#import "FRMission.h"

@implementation FRPointTimerList
- (id) initWithDict:(NSDictionary*)dict onMap:(FRMap*)map {
	self = [super init];
	
	if (self) {
		
		self.title = [dict objectForKey:@"name"];
		dictme = dict;
		[dictme retain];
		self.subtitle = @"FRPointTimerList";
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
		times = [[NSArray alloc] initWithArray:[dict objectForKey:@"times"]];
		self.pos = [positions objectAtIndex:mystate];
		
		timer = [[times objectAtIndex:mystate] intValue];
	}
	
	return self;
}
- (void) updateForMission:(FRMission *)mission {
	
	if (mystate >= [positions count] || timer <= 0) return;
	
	FRPathSearch * playerview = [mission getPlayerView];
	
	timer--;
	if (timer==0){
		[mission speakEventually:@"time's up"];
		return;
	}
	
	if (timer%5==0 || timer< 5){
		[mission speakIfYouCan:[NSString stringWithFormat:@"%i",timer]];
		return;
	}
	
	if (playerview && [playerview containsPoint:self.pos]) {
		//NSLog(@"in path search");
		float dist = [playerview distanceFromRoot:self.pos];
		if (dist < 30) {
			//reached the point
			[mission speakEventually:[messages objectAtIndex:mystate]];
			mystate++;
			
			//once it runs out of states, do nothing. (remove from mission.points?)
			if (mystate < [positions count]) {
				self.pos = [positions objectAtIndex:mystate];
				timer = [[times objectAtIndex:mystate] intValue];
			}
		} else {
			if (arc4random()%10==0) [mission speakIfYouCan:[NSString stringWithFormat:@"you are %i meters from the checkpoint",(int)dist]];
		}
	}
}
@end
