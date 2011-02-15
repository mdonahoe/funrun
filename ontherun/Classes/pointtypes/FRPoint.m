//
//  FRPoint.m
//  ontherun
//
//  Created by Matt Donahoe on 1/5/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "FRPoint.h"
#import "FRMission.h"

@implementation FRPoint
@synthesize title,pos,dictme,subtitle;





- (id) initWithDict:(NSDictionary*)dict {
	self = [super init];
	
	if (self) {
		
		self.title = [dict objectForKey:@"name"];
		dictme = dict;
		[dictme retain];
		self.subtitle = @"FRPoint";
		mystate = kPointNew;
	}
	
	return self;
}

- (CLLocationCoordinate2D)coordinate;
{
    return mycoordinate;
}
- (void) setCoordinate:(CLLocationCoordinate2D)newCoordinate {
	mycoordinate = newCoordinate;
}

- (void) dealloc {
	[dictme release];
	[super dealloc];
}


- (void) updateForMission:(FRMission*)mission {
	//normal points dont move or do anything.
	//maybe they should announce when you get near them
	
	
	FRPathSearch * playerview = [mission getPlayerView];
	if (!playerview || ![playerview containsPoint:pos]) {
		mystate = kPointNew; //reset;
		return;
	}
	if (mystate == kPointSeen) return;
	
	float dist = [playerview distanceFromRoot:pos];
	if (dist < 20){
		mystate = kPointSeen;
		[mission speakEventually:title];
	}
	
	
	
}
@end
