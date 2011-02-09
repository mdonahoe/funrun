//
//  FRPathSearch.m
//  ontherun
//
//  Created by Matt Donahoe on 2/1/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "FRPathSearch.h"


@implementation FRPathSearch

- (id) initWithRoot:(EdgePos)r previous:(NSDictionary *)p distance:(NSDictionary *)d map:(FRMap *)m {
	self = [super init];
	if (self){
		root = r;
		
		distance = [[NSDictionary alloc] initWithDictionary:d copyItems:YES];
		
		previous = [[NSDictionary alloc] initWithDictionary:p copyItems:YES];
		
		map = m;
		//[m retain]; maybe?
	}
	
	return self;
}
- (BOOL) containsPoint:(EdgePos)ep {
	
	//check to see if the the given position is on the path.
	//(for example, if we did a BFS with a maxdist, it might not be)
	//or if the graph is not fully connected.
	
	return ([distance objectForKey:[NSNumber numberWithInt:ep.start]]!=nil ||
			[distance objectForKey:[NSNumber numberWithInt:ep.end]]!=nil);
	
}
- (float) nodeDistance:(NSNumber *)node {
	NSNumber * dist = [distance objectForKey:node];
	if (dist) return [dist floatValue];
	return 10000000000.0; // node not in pathsearch, return large number
}
- (BOOL) isFacingRoot:(EdgePos)ep {
	/* 
	 helper function for several methods
	 
	 
	 doesnt deal with point-not-contained errors
	 */
	
	if (ep.start == root.start && ep.end == root.end) {
		//NSLog(@"facing the same direction on the same edge");
		if (ep.position < root.position) {
			//NSLog(@"the root is behind ep");
			return NO;
		} else {
			//NSLog(@"the root is infront of ep");
			return YES;
		}
		
	}
	
	if(ep.start == root.end && ep.end ==root.start) {
		//NSLog(@"facing opposite directions on the same edge");
		if (ep.position + root.position < [map maxPosition:ep]){
			//NSLog(@"points are back to back");
			return NO;
		} else {
			//NSLog(@"points are face to face");
			return YES;
		}
	}

	//NSLog(@"on different edges, which of ep's nodes is closer to the root?");
	
	NSNumber * start = [NSNumber numberWithInt:ep.start];
	NSNumber * end = [NSNumber numberWithInt:ep.end];
	
	float dstart = [self nodeDistance:start];
	float dend = [self nodeDistance:end];
	
	//if start is closer, we are facing root
	return (dstart < dend);
}
- (EdgePos) move:(EdgePos)ep towardRootWithDelta:(float)dx {
	/*
	 moves a distance dx along an edge pointing toward the root
	 or to the edge start, whichever is shorter.
	 if it reaches the edge start, a new edge is formed that is closer to the root.
	
	 in future versions, we can always move dx, even it it means traversing multiple edges
	 and reaching the root.
	 */
	
	if ([self isFacingRoot:ep]==NO) {
		NSLog(@"not facing, flip so we can move forward");
		ep = [map flipEdgePos:ep];
	}
	
	NSNumber * start = [NSNumber numberWithInt:ep.start];
	ep.position = MAX(0,ep.position - dx);
	//if root and ep are on the same edge, it is possible to overshoot.
	
	
	
	if (ep.position<=0 && [previous objectForKey:start]!=nil) {
		NSLog(@"next edge");
		//move to a closer edge
		ep.end = ep.start;
		ep.start = [[previous objectForKey:start] intValue];
		ep.position = [map maxPosition:ep];
	}
	
	
	return ep;
}
- (EdgePos) move:(EdgePos)ep awayFromRootWithDelta:(float)dx {
	
	//we need to orient the vector, making sure it is point away from
	// the root.
	
	if ([self isFacingRoot:ep]) ep = [map flipEdgePos:ep];
	return [map move:ep forwardRandomly:dx];
}
- (float) distanceFromRoot:(EdgePos)ep {
	
	//check to see if the point is inside the path
	//if not, return a large number
	if ([self containsPoint:ep]==NO) {
		NSLog(@"uncontained. returning large number");
		return 10000000000.0;
	}
	
	if (ep.start==root.start && ep.end == root.end) {
		NSLog(@"distanceFrom: same edge, same direction");
		return ABS(ep.position - root.position);
	}
	
	if (ep.start==root.end && ep.end==root.start) {
		NSLog(@"distanceFrom: same edge, opposite directions");
		return ABS(ep.position + root.position - [map maxPosition:ep]);
	}
	
	NSLog(@"distanceFrom: different edges, rely on node distance + position");
	
	float position = ep.position;
	
	NSNumber * start = [NSNumber numberWithInt:ep.start];
	NSNumber * end = [NSNumber numberWithInt:ep.end];
	
	float length = [map edgeLengthFromStart:start toFinish:end];
	
	
	float dstart = [self nodeDistance:start];
	float dend = [self nodeDistance:end];
	
	return MIN(dstart+position,dend+length-position);
}
- (NSString *) directionFromRoot:(EdgePos)ep {
	
	//should probably make this more complicated, but for now this will work.
	//this is wrong. isRootFacing should be a different method. fuck.
	
	
	if ([self isFacingRoot:ep]) return @"infront of";
	return @"behind";

}
- (void) dealloc {
	[previous release];
	[distance release];
	[super dealloc];
}

@end
