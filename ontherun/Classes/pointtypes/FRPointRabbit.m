//
//  FRPointRabbit.m
//  ontherun
//
//  Created by Matt Donahoe on 2/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FRPointRabbit.h"
#import "FRPathSearch.h"
#import "FRMission.h"

@implementation FRPointRabbit
- (id) initWithDict:(NSDictionary*)dict onMap:(FRMap*)map {
	self = [super initWithDict:dict onMap:map];
	subtitle = @"FRPointRabbit";
	return self;
}
- (void) updateForMission:(FRMission *)mission {

	FRPathSearch * playerview = [mission getPlayerView];
	
	if (playerview && [playerview containsPoint:pos]) {
		float dist = [playerview distanceFromRoot:pos];
		switch (mystate){
			case kHappy:
				if (dist<30){
					mystate = kScared;
					//say something
					[mission speakEventually:[NSString stringWithFormat:@"You scared %@",title]];
				}
				break;
			case kScared:
				self.pos = [playerview move:pos awayFromRootWithDelta:2.0];
				if (dist>150){
					mystate = kHappy;
					//we lost them.
					[mission speakEventually:[NSString stringWithFormat:@"You cant see %@",title]];
				} else if (dist<5) {
					mystate = kDead;
					//closing in!
					[mission speakEventually:[NSString stringWithFormat:@"You caught %@",title]];
				} else {
					if (arc4random()%5==0) [mission speakIfYouCan:[NSString stringWithFormat:@"%@ is %i meters %@ you",
																	title,
																	(int)[playerview distanceFromRoot:pos],
																	[playerview directionFromRoot:pos]]];
					//still following
				}
				break;
			case kDead:
				//dead. do nothing ever again.
				break;
			default:
				break;
		}
		
	} else {
		//point is not in the pathsearch
	}
}
@end
