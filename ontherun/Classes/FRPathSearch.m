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
	return ep;
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
	NSNumber * start = [NSNumber numberWithInt:ep.start];
	NSNumber * end = [NSNumber numberWithInt:ep.end];
	float position = ep.position;
	
	//does not check for nil values, like it the point is not on path
	
	float dstart = [[distance objectForKey:start] floatValue];
	float dend = [[distance objectForKey:end] floatValue];
	float length = [map edgeLengthFromStart:start toFinish:end];
	
	return MIN(dstart+position,dend+length-position);
}
@end
