//
//  FRPoint.m
//  ontherun
//
//  Created by Matt Donahoe on 1/5/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "FRPoint.h"
#import "FRMission.h"
#define ARC4RANDOM_MAX      0x100000000

@implementation FRPoint
@synthesize title,pos,dictme,subtitle;

- (id) initWithDict:(NSDictionary*)dict onMap:(FRMap*)map {
	self = [super init];
	
	if (self) {
		
		self.title = [dict objectForKey:@"name"];
		dictme = dict;
		[dictme retain];
		self.subtitle = @"FRPoint";
		mystate = kPointNew;
		
		
		NSArray * latlon = [dictme objectForKey:@"pos"];
		if (latlon) {
			CLLocation * p = [[CLLocation alloc] initWithLatitude:[[latlon objectAtIndex:0] floatValue]
														longitude:[[latlon objectAtIndex:1] floatValue]];
			self.pos = [map edgePosFromPoint:p];
			[p release];
			
			float randomradius = [[dictme objectForKey:@"randomradius"] floatValue];
			if (arc4random()%2) self.pos = [map flipEdgePos:self.pos];
			if (randomradius > 0) {
				self.pos = [map move:self.pos forwardRandomly:((float)arc4random()/ARC4RANDOM_MAX)*randomradius];
			}
			
		}
		
	}
	
	return self;
}

- (CLLocationCoordinate2D)coordinate;
{
	//if i make the view draggable, i can expect calls to this method from the mkmapview
    return mycoordinate;
	
	//it should set the FREdgePos accordingly, without messing up the direction or loooping
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
