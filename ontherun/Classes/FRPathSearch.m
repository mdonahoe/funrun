//
//  FRPathSearch.m
//  ontherun
//
//  Created by Matt Donahoe on 2/1/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "FRPathSearch.h"


@implementation FRPathSearch

- (id) initWithRoot:(FREdgePos *)r previous:(NSDictionary *)p distance:(NSDictionary *)d map:(FRMap *)m {
	self = [super init];
	if (self){
		root = r;
		[r retain];
		
		distance = [[NSDictionary alloc] initWithDictionary:d copyItems:YES];
		
		previous = [[NSDictionary alloc] initWithDictionary:p copyItems:YES];
		
		
		for (NSNumber * node in distance){
			if ([[previous objectForKey:node] intValue]==[node intValue]) NSLog(@"node is dupe %i",[node intValue]);
		}
		
		map = m;
		//[m retain]; maybe?
	}
	
	return self;
}
- (BOOL) containsPoint:(FREdgePos *)ep {
	
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
- (BOOL) rootIsFacing:(FREdgePos *)ep {
	/* 
	 useful for creating text descriptions of where things are relative to the root.
	 */
	
	if (ep.start == root.start && ep.end == root.end) {
		//NSLog(@"facing the same direction on the same edge");
		if (ep.position < root.position) {
			//NSLog(@"the root is behind ep");
			return YES;
		} else {
			//NSLog(@"the root is infront of ep");
			return NO;
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
	
	//NSLog(@"on different edges, follow the previous path back to the root nodes. which is it?");
	
	
	NSNumber * start = [NSNumber numberWithInt:ep.start];
	NSNumber * end = [NSNumber numberWithInt:ep.end];
	
	//pick a starting node that is in the pathsearch
	NSNumber * node;
	if ([previous objectForKey:start]) {
		node = start;
	} else { //start is not in path. assume that end is.
		node = end;
	}
	
	int i=200; //limit the potentially infinite loop.
	while (node && 0<i--) {
		//traverse the tree to the root nodes. careful, the two roots point to each other.
		if ([node intValue]==root.start) return YES;
		if ([node intValue]==root.end) return NO;
		node = [previous objectForKey:node];
	}
	
	[NSException raise:@"Traverse failed." format:@"node: %@, tries: %i", node,i];
	
	return NO;
}
- (BOOL) isFacingRoot:(FREdgePos *)ep {
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
- (FREdgePos *) move:(FREdgePos *)ep towardRootWithDelta:(float)dx {
	/*
	 moves a distance dx along an edge pointing toward the root
	 or to the edge start, whichever is shorter.
	 if it reaches the edge start, a new edge is formed that is closer to the root.
	
	 in future versions, we can always move dx, even it it means traversing multiple edges
	 and reaching the root.
	 */
	
	FREdgePos * x;
	
	
	if ([self isFacingRoot:ep]==NO) {
		//NSLog(@"not facing, flip so we can move forward");
		x = [map flipEdgePos:ep];
	} else {
		x = [[[FREdgePos alloc] init] autorelease];
		x.start = ep.start;
		x.end = ep.end;
		x.position = ep.position;
	}
	
	NSNumber * start = [NSNumber numberWithInt:x.start];
	x.position = MAX(0,x.position - dx);
	//if root and ep are on the same edge, it is possible to overshoot.
	
	
	
	if (x.position<=0 && [previous objectForKey:start]!=nil) {
		//NSLog(@"next edge");
		//move to a closer edge
		x.end = x.start;
		x.start = [[previous objectForKey:start] intValue];
		x.position = [map maxPosition:x];
	}
	
	
	return x;
}
- (FREdgePos *) move:(FREdgePos *)ep awayFromRootWithDelta:(float)dx {
	
	//we need to orient the vector, making sure it is point away from
	// the root.
	
	//setting ep might lose reference?? idk
	if ([self isFacingRoot:ep]) ep = [map flipEdgePos:ep];
	return [map move:ep forwardRandomly:dx];
}
- (float) distanceFromRoot:(FREdgePos*)ep {
	
	//check to see if the point is inside the path
	//if not, return a large number
	if ([self containsPoint:ep]==NO) {
		//NSLog(@"uncontained. returning large number");
		return 10000000000.0;
	}
	
	if (ep.start==root.start && ep.end == root.end) {
		//NSLog(@"distanceFrom: same edge, same direction");
		return ABS(ep.position - root.position);
	}
	
	if (ep.start==root.end && ep.end==root.start) {
		//NSLog(@"distanceFrom: same edge, opposite directions");
		return ABS(ep.position + root.position - [map maxPosition:ep]);
	}
	
	//NSLog(@"distanceFrom: different edges, rely on node distance + position");
	
	float position = ep.position;
	
	NSNumber * start = [NSNumber numberWithInt:ep.start];
	NSNumber * end = [NSNumber numberWithInt:ep.end];
	
	float length = [map edgeLengthFromStart:start toFinish:end];
	
	
	float dstart = [self nodeDistance:start];
	float dend = [self nodeDistance:end];
	
	return MIN(dstart+position,dend+length-position);
}
- (NSString *) directionFromRoot:(FREdgePos*)ep {
	
	//should probably make this more complicated, but for now this will work.
	//this is wrong. isRootFacing should be a different method. fuck.
	
	
	if ([self rootIsFacing:ep]) return @"infront of";
	return @"behind";

}
- (void) dealloc {
	[previous release];
	[distance release];
	[root release];
	[super dealloc];
}
- (FRMap *)getMap { return map;}
@end
