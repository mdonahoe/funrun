//
//  FRPointSequence.m
//  ontherun
//
//  Created by Matt Donahoe on 2/15/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "FRPointSequence.h"


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
		
		for (NSDictionary * latlon in [dict objectForKey:@"positions"]){
			CLLocation * p = [[CLLocation alloc] initWithLatitude:[[latlon objectAtIndex:0] floatValue]
														longitude:[[latlon objectAtIndex:1] floatValue]];
			
			[temppos addObject:[map edgePosFromPoint:p]];
			[p release];
		}
		
		positions = [[NSArray alloc] initWithArray:temppos];
		messages = [[NSArray alloc] initWithArray:[dict objectForKey:@"messages"]];
		self.pos = [positions objectAtIndex:mystate];
	}
	
	return self;
}
@end
