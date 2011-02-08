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
- (EdgePos) move:(EdgePos)ep awayFromRootWithDelta:(float)dx {
	
	//check to see if the point is inside the path
	//if not, return it untouched.
	if ([self containsPoint:ep]==NO) return ep;
	
	//we need to orient the vector, making sure it is point away from
	// the root.
	
	if (ep.start == root.start && ep.end == root.end) {
		NSLog(@"facing the same direction on the same edge");
		if (ep.position < root.position) {
			NSLog(@"the root is behind ep");
		} else {
			NSLog(@"the root is infront of ep");
			//switch
			ep = [map flipEdgePos:ep];
		}
		
	} else if(ep.start == root.end && ep.end ==root.start) {
		NSLog(@"facing opposite directions on the same edge");
		if (ep.position + root.position < [map maxPosition:ep]){
			NSLog(@"root is behind ep");
			
		} else {
			NSLog(@"root is infront of ep");
			//switch
			ep = [map flipEdgePos:ep];
		}
	} else {
		NSLog(@"on different edges, which of ep's nodes is closer to the root?");
		
		NSNumber * start = [NSNumber numberWithInt:ep.start];
		NSNumber * end = [NSNumber numberWithInt:ep.end];
		
		float position = ep.position;
		
		float dstart = [[distance objectForKey:start] floatValue];
		float dend = [[distance objectForKey:end] floatValue];
		float length = [map edgeLengthFromStart:start toFinish:end];
		
		if (dstart + position < dend - position + length) {
			NSLog(@"end is farther away. swap");
			ep.start = [end intValue];
			ep.end = [start intValue];
			ep.position = length-position;
		}
	}
	[map isValidEdgePos:ep];
	return [map move:ep forwardRandomly:dx];
}
- (BOOL) containsPoint:(EdgePos)ep {
	
	//check to see if the the given position is on the path.
	//(for example, if we did a BFS with a maxdist, it might not be)
	//or if the graph is not fully connected.
	
	return ([distance objectForKey:[NSNumber numberWithInt:ep.start]]!=nil ||
			[distance objectForKey:[NSNumber numberWithInt:ep.end]]!=nil);
	
}
- (EdgePos) move:(EdgePos)ep towardRootWithDelta:(float)dx {
	//moves a distance dx along an edge pointing toward the root
	//or to the edge start, whichever is shorter.
	// if it reaches the edge start, a new edge is formed that is closer to the root.
	
	//in future versions, we can always move dx, even it it means traversing multiple edges
	// and reaching the root.
	
	//check to see if the point is inside the path
	//if not, return it untouched.
	if ([self containsPoint:ep]==NO) return ep;
	
	NSNumber * start = [NSNumber numberWithInt:ep.start];
	NSNumber * end = [NSNumber numberWithInt:ep.end];
	
	float position = ep.position;
	//NSLog(@"start %@, end %@, pos %f",start,end,position);
	
	float dstart = [[distance objectForKey:start] floatValue];
	float dend = [[distance objectForKey:end] floatValue];
	float length = [map edgeLengthFromStart:start toFinish:end];
	
	//NSLog(@"ds=%f,de=%f,length = %f",dstart,dend,length);
	
	if (dstart + position > dend - position + length) {
		//b is closer
		NSNumber * temp = start;
		start = end;
		end = temp;
		position = length-position;
		//NSLog(@"switch direction: start %@, end %@, pos: %f",start,end,position);
	}
	
	position = MAX(0,position - dx);
	
	if (position<=0 && [previous objectForKey:start]!=nil) {
		end = start;
		start = [previous objectForKey:start];
		position = [map edgeLengthFromStart:start toFinish:end];
		//NSLog(@"moved nodes: start %@, end %@, pos: %f",start,end,position);
	}
	
	EdgePos x;
	x.start = [start intValue];
	x.end = [end intValue];
	x.position = position;
	return x;
}
- (float) distanceFromRoot:(EdgePos)ep {
	
	//check to see if the point is inside the path
	//if not, return a large number
	if ([self containsPoint:ep]==NO) return 10000000000.0;
	
	NSNumber * start = [NSNumber numberWithInt:ep.start];
	NSNumber * end = [NSNumber numberWithInt:ep.end];
	float position = ep.position;
	
	//does not check for nil values, like it the point is not on path
	
	float dstart = [[distance objectForKey:start] floatValue];
	float dend = [[distance objectForKey:end] floatValue];
	float length = [map edgeLengthFromStart:start toFinish:end];
	
	return MIN(dstart+position,dend+length-position);
}
- (NSString *) directionFromRoot:(EdgePos)ep {
	
	//check to see if the point is inside the path
	//if not, return it untouched.
	if ([self containsPoint:ep]==NO) return @"unknown";
	
	NSString * direction;
	if (ep.start == root.start && ep.end==root.end) {
		NSLog(@"same edge, same direction");
		if (ep.position > root.position) {
			direction = @"behind";
		} else {
			direction = @"infront";
		}	
	} else if (ep.start == root.end && ep.end == root.start) {
		NSLog(@"same edge, opposite directions");
		float p = [map maxPosition:ep] - ep.position;
		if (p > root.position) {
			direction = @"behind";
		} else {
			direction = @"infront";
		}
	} else {
		NSLog(@"//different edges");
		NSNumber * node = [NSNumber numberWithInt:ep.start];
		while ([previous objectForKey:node]!=nil) node = [previous objectForKey:node];
		if ([node intValue]==root.start){
			//infront
			direction = @"infront";
		} else if ([node intValue]==root.end) {
			//behind
			direction = @"behind";
		} else {
			//neither infront nor behind. node is not in search space, or bug
			direction = @"out of view";
		}
	}
	return direction;
}
- (void) dealloc {
	[previous release];
	[distance release];
	[super dealloc];
}

@end
