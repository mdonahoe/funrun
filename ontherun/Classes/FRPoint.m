//
//  FRPoint.m
//  ontherun
//
//  Created by Matt Donahoe on 1/5/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "FRPoint.h"


@implementation FRPoint
@synthesize title,pos,target,dictme,subtitle,mystate;





- (id) initWithDict:(NSDictionary*)dict {
	self = [super init];
	
	if (self) {
		
		self.title = [dict objectForKey:@"name"];
		NSNumber * s = [dict objectForKey:@"speed"];
		if (s!=nil) {
			speed = [s floatValue];
		} else {
			speed = 0;
		}
		dictme = dict;
		[dictme retain];
		self.subtitle = @"init";
		mystate = FRPointPatrolling;
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

@end
