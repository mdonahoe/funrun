//
//  FRPointFollower.m
//  ontherun
//
//  Created by Matt Donahoe on 2/11/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "FRPointFollower.h"
#import "FRPathSearch.h"
#import "FRMission.h"

@implementation FRPointFollower
- (id) initWithDict:(NSDictionary*)dict onMap:(FRMap*)map {
	self = [super initWithDict:dict onMap:map];
	subtitle = @"FRPointFollower";
	return self;
}
	
- (void) updateForMission:(FRMission *)mission {
	/*
	 
	 called every second to update the position of the point.
	 
	 latestsearch is the latestest known position of the user in the form
	 of a PathSearch object, which provides methods for moving and measuring distance
	 relative to the user's location
	 
	 perhaps instead I should create methods that are simpler
	 
	 - point can see player
	 - point cant see player
	 - player is 50 m away in this direction.
	 
	 
	 */
	
	FRPathSearch * playerview = [mission getPlayerView];
	FRMap * themap = [mission getMap];
	
	if (playerview && [playerview containsPoint:pos]) {
		//NSLog(@"in path search");
		float dist = [playerview distanceFromRoot:pos];
		switch (mystate){
			case kPatrolling:
				self.pos = [themap move:pos forwardRandomly:0.5];
				if (dist<100){
					mystate = kFollowing;
					//say something
					[mission speakEventually:[NSString stringWithFormat:@"%@ is following %i meters %@ you",
										   title,
										   (int)[playerview distanceFromRoot:pos],
											  [playerview directionFromRoot:pos]]];
				}
				break;
			case kFollowing:
				self.pos = [playerview move:pos towardRootWithDelta:1.0];
				if (dist>150){
					mystate = kPatrolling;
					//we lost them.
					[mission speakEventually:[NSString stringWithFormat:@"You lost %@",title]];
				} else if (dist<20) {
					mystate = kClosing;
					//closing in!
					[mission speakEventually:[NSString stringWithFormat:@"%@ is closing in on you!",title]];
				} else {
					if (arc4random()%10==0) [mission speakIfYouCan:[NSString stringWithFormat:@"%@ is %i meters %@ you",
																 title,
																 (int)[playerview distanceFromRoot:pos],
																 [playerview directionFromRoot:pos]]];
					//still following
				}
				break;
			case kClosing:
				self.pos = [playerview move:pos towardRootWithDelta:1.0];
				if (dist<10){
					//this should do something more than say STAB. like reduce health or something
					[mission speakIfYouCan:@"STAB"];
				} else if (dist>40){
					mystate = kFollowing;
					//starting to lose them.
					[mission speakEventually:[NSString stringWithFormat:@"You are outrunning %@",title]];
				} else {
					//they are still about to get us.
					[mission speakIfYouCan:[NSString stringWithFormat:@"%i meters",(int)[playerview distanceFromRoot:pos]]];
				}
			default:
				break;
		}
		
	} else {
		//point is not in the pathsearch, so we cant do anything.
		self.pos = [themap move:pos forwardRandomly:0.5];
		
	}
}

@end
