//
//  FRPoint.m
//  ontherun
//
//  Created by Matt Donahoe on 1/5/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "FRPoint.h"


@implementation FRPoint
@synthesize name,pos,target,dictme,status;

- (id) initWithDict:(NSDictionary*)dict {
	self = [super init];
	
	if (self) {
		
		name = [dict objectForKey:@"name"];
		NSNumber * s = [dict objectForKey:@"speed"];
		if (s!=nil) {
			speed = [s floatValue];
		} else {
			speed = 0;
		}
		dictme = dict;
		[dictme retain];
		status = @"init";
	}
	
	return self;
}
@end
