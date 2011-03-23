//
//  FRPoint.m
//  ontherun
//
//  Created by Matt Donahoe on 1/5/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "FRPoint.h"
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
- (id) initWithName:(NSString *)name{
	self = [super init];
	if (!self) return nil;
	self.title = name;
	self.subtitle = @"named";
	return self;
}

- (CLLocationCoordinate2D)coordinate
{
	//NSLog(@"coord called");
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
@end
