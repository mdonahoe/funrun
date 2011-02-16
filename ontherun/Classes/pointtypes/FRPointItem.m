//
//  FRPointItem.m
//  ontherun
//
//  Created by Matt Donahoe on 2/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FRPointItem.h"
#import "FRPathSearch.h"
#import "FRMission.h"

@implementation FRPointItem
- (void) updateForMission:(FRMission *)mission {
	
	FRPathSearch * playerview = [mission getPlayerView];
	
	if (playerview && [playerview containsPoint:pos]) {
		float dist = [playerview distanceFromRoot:pos];
		switch (mystate){
			case kOutOfSight:
				if (dist<50){
					mystate = kInSight;
					//say something
					[mission speakEventually:[NSString stringWithFormat:@"There is a %@ %i meters %@ you",
											  title,
											  (int)[playerview distanceFromRoot:pos],
											  [playerview directionFromRoot:pos]]];
				}
				break;
			case kInSight:
				if (dist>100){
					mystate = kOutOfSight;
					//we lost them.
				} else if (dist<10) {
					mystate = kPickedUp;
					//closing in!
					[mission speakEventually:[NSString stringWithFormat:@"%You picked up %@",title]];
				}
				break;
			default:
				break;
		}
		
	}
}

@end
