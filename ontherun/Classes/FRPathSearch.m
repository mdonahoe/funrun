//
//  FRPathSearch.m
//  ontherun
//
//  Created by Matt Donahoe on 2/1/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "FRPathSearch.h"


@implementation FRPathSearch
@synthesize root;
- (id) initWithRoot:(FREdgePos *)r previous:(NSDictionary *)p distance:(NSDictionary *)d map:(FRMap *)m {
	self = [super init];
	if (self){
		self.root = r;
		
		distance = [[NSDictionary alloc] initWithDictionary:d copyItems:YES];
		
		previous = [[NSDictionary alloc] initWithDictionary:p copyItems:YES];
		
		
		for (NSNumber * node in distance){
			if ([[previous objectForKey:node] intValue]==[node intValue]) NSLog(@"node is dupe %i",[node intValue]);
		}
		
		[m retain];
		map = m;
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
- (FREdgePos *) moveCloserToRoot:(FREdgePos *)ep{
    FREdgePos * x;
	
	
	if ([self isFacingRoot:ep]==NO) {
		//NSLog(@"not facing, flip so we can move forward");
		x = [map flipEdgePos:ep];
	} else {
		x = [[[FREdgePos alloc] init] autorelease];
		x.start = ep.start;
		x.end = ep.end;
	}
	
    x.position = 0;
	
    NSNumber * next = [previous objectForKey:[x startObj]];
	if (next!=nil) {
		//move to a closer edge
		x.end = x.start;
		x.start = [next intValue];
    }
    
	return x;
}
- (FREdgePos *) move:(FREdgePos *)ep towardRootWithDelta:(float)dx {
	/*
	 moves a distance dx along an edge pointing toward the root
     jumps to the next closer edge if necessary, repeating until dx is consumed.
     
     
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
	
	x.position = x.position - dx;
	//if root and ep are on the same edge, it is possible to overshoot.
	
	
	
	while (x.position<=0 && [previous objectForKey:[x startObj]]!=nil) {
		//move to a closer edge
		x.end = x.start;
		x.start = [[previous objectForKey:[x startObj]] intValue];
		x.position = [map maxPosition:x] + x.position;
	}
	
	
	return x;
}
- (FREdgePos *) move:(FREdgePos *)ep awayFromRootWithDelta:(float)dx {
	
	//we need to orient the vector, making sure it is point away from
	// the root.
	
	//setting ep might lose reference?? idk
	if ([self isFacingRoot:ep]) ep = [map flipEdgePos:ep];
	
	
	//now move forward randomly.
	//would be better to look at the pathsearch and move optimally
    
    
    return [map move:ep forwardRandomly:dx];
}
- (float) distanceFromRoot:(FREdgePos*)ep {
	
	//check to see if the point is inside the path
	//if not, return a large number
	if ([self containsPoint:ep]==NO) {
		return 10000000000.0;
	}
	
	if (ep.start==root.start && ep.end == root.end) {
		return ABS(ep.position - root.position);
	}
	
	if (ep.start==root.end && ep.end==root.start) {
		return ABS(ep.position + root.position - [map maxPosition:ep]);
	}
	
	
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
	
	
	if ([self rootIsFacing:ep]) return @"infront of";
	return @"behind";

}
- (NSString *) directionToRoot:(FREdgePos *)ep{
	//turn by turn directions
	if (![self containsPoint:ep]) return @"an unknown direction";
	
	//"turn right on maverick street"
	
	//it would be nice if these methods avoided badguys
	//move toward root until you hit a different street.
	//calculate direction needed to turn
	

	
	if (![self isFacingRoot:ep]) {
		return @"turn around";
	}
	
	NSString * start_road = [map roadNameFromEdgePos:ep];
	if ([start_road isEqualToString:[map roadNameFromEdgePos:root]]){
		return [NSString stringWithFormat:@"continue on %@",start_road];
	}
	
	NSString * current_road = nil;
	FREdgePos * prev = nil;
	
	do {//potential infinite loop
		prev = ep;
		ep = [self moveCloserToRoot:ep];
		current_road = [map roadNameFromEdgePos:ep];
	} while ([start_road isEqualToString:current_road]);
	
	
	return [NSString stringWithFormat:@"turn %@",[map descriptionFromEdgePos:prev toEdgePos:ep]];
}
- (NSArray *) directionsToRoot:(FREdgePos *)ep{
	//turn by turn directions
    NSMutableArray * directions = [NSMutableArray array];
    
	if (![self containsPoint:ep]) return nil;
	
	//"turn right on maverick street"
	
	//move toward root until you hit a different street.
	//calculate direction needed to turn
	
    
	
	if (![self isFacingRoot:ep]) {
        
		[directions addObject:@"turn around"];
        ep = [map flipEdgePos:ep];
	}
    
    NSString * start_road = [map roadNameFromEdgePos:ep];
    while (![ep onSameEdgeAs:root]){
        NSString * current_road = nil;
        FREdgePos * prev = nil;
        
        do {//go forward until we switch roads (potential infinite loop)
            prev = ep;
            ep = [self moveCloserToRoot:ep];
            current_road = [map roadNameFromEdgePos:ep];
            
        } while ([start_road isEqualToString:current_road] && ![ep onSameEdgeAs:root]);
        
        //get the description for this change
        NSString * desc = [map descriptionFromEdgePos:prev toEdgePos:ep];
        if (desc) {
            [directions addObject:[NSString stringWithFormat:@"turn %@",desc]];
        } else {
            NSLog(@"no description available. ep is likely on root edge True==%i. current_road=%@, start_road=%@",[ep onSameEdgeAs:root],current_road,start_road);
        }
        start_road = current_road;
    }
    [directions addObject:[NSString stringWithFormat:@"continue on %@ to your destination",start_road]];
    return [NSArray arrayWithArray:directions];
}
- (FREdgePos *) edgePosThatIsDistance:(float)d fromRootAndOther:(FRPathSearch*)p {
	//useful for finding points that are a certain distance from two nodes.
	//possible to fail like crazy if the max_dists of the pathsearches arent long enough
	
	
	NSNumber * closest_node = nil;
	float smallest_difference = 1000000000.0;
	float dist;
	float diff;
	for (NSNumber * node in distance){
		dist = [[distance objectForKey:node] floatValue]+[p nodeDistance:node];
		diff = ABS(dist - d);
		if (diff < smallest_difference){
			smallest_difference = diff;
			closest_node = node;
		}
	}
	//somehow i need to return an edgepos. i might just be lame with this.
	FREdgePos * ep = [[[FREdgePos alloc] init] autorelease];
	ep.start = [closest_node intValue];
	ep.end = [[previous objectForKey:closest_node] intValue];
	ep.position = 1.0; //1m from the point. hackity hack.
	return ep;
}
- (FREdgePos *) forkPoint:(FREdgePos*)ep{
    
    
    //travel toward root until you find a side street
    NSNumber * node = [ep startObj];
    NSNumber * prev = [ep endObj];
    int i=0;
    while ([map numNeighbors:node]<3 && i++<50){
        prev = node;
        node = [previous objectForKey:node];
    }
    
    //failed
    if (i>=50){
        [NSException raise:@"Unable to fork" format:@"start of %i. %@", ep.start, ep];
		return nil;
    }
    
    //get a node on the side street
    i=0;
    NSNumber * next = [previous objectForKey:node];
    NSNumber * sidenode = next;
    while (i++<50 && (sidenode==next || sidenode == prev)){
        sidenode = [map randomNeighbor:node];
    }
    
    //return a position off that side street.
    FREdgePos * x = [[[FREdgePos alloc] init] autorelease];
    x.start = [sidenode intValue];
    x.end = [node intValue];
    x.position = 1;
    return x;
}
- (BOOL) edgepos:(FREdgePos*)A isOnPathFromRootTo:(FREdgePos*)B{
    int i=0;
    do {
        if ([A onSameEdgeAs:B]) return YES;
        if ([B onSameEdgeAs:root]) return NO;
        B = [self moveCloserToRoot:B];
        i++;
    } while (i<1000);
    NSLog(@"Loop exceeded expectations.");
    return NO;
}
- (void) dealloc {
	[previous release];
	[distance release];
	[root release];
	[map release];
	[super dealloc];
}
- (FRMap *)getMap { return map;}
@end
