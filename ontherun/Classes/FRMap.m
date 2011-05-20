//
//  FRMap.m
//  ontherun
//
//  Created by Matt Donahoe on 1/16/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//
//
#import "FRMap.h"
#import "FRPathSearch.h"

@implementation FRMap
- (id) initWithNodes:(NSMutableDictionary*)_nodes andRoads:(NSMutableArray *)roads {
	self = [super init];
	if (self){
		NSNumberFormatter * f = [[[NSNumberFormatter alloc] init] autorelease];
		[f setNumberStyle:NSNumberFormatterDecimalStyle];
		
		nodes = [[NSMutableDictionary alloc] initWithCapacity:100];
		
		for (NSString * node_id in _nodes){
			NSDictionary * node = [_nodes objectForKey:node_id];
			float lat = [[node objectForKey:@"lat"] floatValue];
			float lon = [[node objectForKey:@"lon"] floatValue];
			CLLocation * p = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
			[nodes setObject:p forKey:[f numberFromString:node_id]];
		}
		
		edges = [[NSMutableArray alloc] initWithCapacity:100];
		graph = [[NSMutableDictionary alloc] init];
		for (NSDictionary * road in roads){
			NSNumber * previous = nil;
			for (NSNumber * node in [road objectForKey:@"nodes"]) {
				if (previous!=nil) {
					//add node tuple to list of edges
					[edges addObject:[[NSArray alloc] initWithObjects:previous,node,nil]];
					
					//create the inner dictionaries, if they dont exist yet.
					if ([graph objectForKey:previous]==nil) [graph setObject:[[NSMutableDictionary alloc] initWithCapacity:3] forKey:previous];
					if ([graph objectForKey:node]==nil) [graph setObject:[[NSMutableDictionary alloc] initWithCapacity:3] forKey:node];
					
					//calculate the distance between nodes
					float length = [(CLLocation *)[nodes objectForKey:previous] distanceFromLocation:(CLLocation *)[nodes objectForKey:node]];
					NSNumber * dist = [NSNumber numberWithFloat:length];
					//[dist retain];
					//save dist and road name in a dictionary
					NSMutableDictionary * edge = [NSMutableDictionary dictionaryWithCapacity:3];
					[edge setObject:dist forKey:@"length"];
					if ([road objectForKey:@"name"]!=nil) [edge setObject:[road objectForKey:@"name"] forKey:@"name"];
					NSDictionary * edge2 = [NSDictionary dictionaryWithDictionary:edge];
					
					//add that dictionary to the graph, accessible bidirectionally
					[(NSMutableDictionary *)[graph objectForKey:previous] setObject:edge2 forKey:node];
					[(NSMutableDictionary *)[graph objectForKey:node] setObject:edge2 forKey:previous];
				}
				previous = node;
			}
		}
		
		
	}
	return self;
}
- (NSArray *) closestEdgeToPoint:(CLLocation *)p {
	float mindist = 10000000000000; //big number
	NSArray * closest_edge = nil;
	
	for (NSArray * edge in edges){
		float h = [self distanceFromEdge:edge toPoint:p];
        if (h < mindist){
            mindist = h;
            closest_edge = edge;
        }
	}
    
	if (closest_edge==nil) NSLog(@" NIL TOWN! bummer");
	return closest_edge;
}
- (NSArray*) closest:(int)n edgesToPoint:(CLLocation*)p{
    NSMutableArray * closest = [[[NSMutableArray alloc] initWithCapacity:n] autorelease];
    NSMutableArray * scores = [[[NSMutableArray alloc] initWithCapacity:n] autorelease];
    
    for (NSArray * edge in edges){
        float h = [self distanceFromEdge:edge toPoint:p];
        int i;
        for (i=0;i<[closest count];i++) {
            if ([[scores objectAtIndex:i] floatValue] > h){
                [closest insertObject:edge atIndex:i];
                [scores insertObject:[NSNumber numberWithFloat:h] atIndex:i];
                break;
            }
        }
        if ([closest count] < n && i==[closest count]){
            [closest addObject:edge];
            [scores addObject:[NSNumber numberWithFloat:h]];
        }
        
        
    }
    
    return [NSArray arrayWithArray:closest];
    
}
- (float) distanceFromEdge:(NSArray*)e toPoint:(CLLocation*)p{
    NSNumber * i = [e objectAtIndex:0];
    NSNumber * j = [e objectAtIndex:1];
    float a = [p distanceFromLocation:[nodes objectForKey:i]];
    float b = [self edgeLengthFromStart:i toFinish:j];
    float c = [p distanceFromLocation:[nodes objectForKey:j]];
    
    float a2 = a*a;
    float b2 = b*b;
    float c2 = c*c;
    float h;
    if (c2>a2+b2) {
        h = a;
    } else if (a2>b2+c2) {
        h = c;
    } else {
        float s = (a+b+c)/2.0;
        float area = sqrtf(s*(s-a)*(s-b)*(s-c));
        h = 2*area/b;		
    }
    
    return h;
}
- (FREdgePos *) edgePosFromPoint:(CLLocation *)p usingEdge:(NSArray *)edge{
    FREdgePos * ep = [[[FREdgePos alloc] init] autorelease];
	
	NSNumber * i = [edge objectAtIndex:0];
	NSNumber * j = [edge objectAtIndex:1];
	
	ep.start = [i intValue];
	ep.end = [j intValue];
	
	float a = [p distanceFromLocation:[nodes objectForKey:i]];
	float b = [self edgeLengthFromStart:i toFinish:j];
	float c = [p distanceFromLocation:[nodes objectForKey:j]];
    
	
	float a2 = a*a;
	float b2 = b*b;
	float c2 = c*c;
	if (c2>a2+b2) {
		ep.position = 0;
	} else if (a2>b2+c2) {
		ep.position = b;
	} else {
		float s = (a+b+c)/2.0;
		float area = sqrtf(s*(s-a)*(s-b)*(s-c));
		float h = 2*area/b;
		ep.position = sqrtf(a2-h*h); //hopefully never -1
	}
	return ep;
}
- (FREdgePos *) edgePosFromPoint:(CLLocation *)p {
	NSArray * edge = [self closestEdgeToPoint:p];
	return [self edgePosFromPoint:p usingEdge:edge];
}
- (float) edgeLengthFromStart:(NSNumber *)a toFinish:(NSNumber *)b {
	return [[[[graph objectForKey:a] objectForKey:b] objectForKey:@"length"] floatValue];
}
- (float) maxPosition:(FREdgePos *)ep {
	return [self edgeLengthFromStart:[NSNumber numberWithInt:ep.start] toFinish:[NSNumber numberWithInt:ep.end]];
}
- (NSString *) roadNameFromEdgePos:(FREdgePos *)ep{
	return [self roadNameFromNode:[ep startObj] andNode:[ep endObj]];
}
- (NSString *) roadNameFromNode:(NSNumber *)n1 andNode:(NSNumber*)n2{
	return [[[graph objectForKey:n1] objectForKey:n2] objectForKey:@"name"];
}
- (BOOL) ep:(FREdgePos*)ep isFacingOther:(FREdgePos*)other {
    //only works if they are on the same edge;
    if (ep.start==other.start) return ep.position > other.position;
    return ep.position > [self maxPosition:other] - other.position;
}
- (FRPathSearch *) createPathSearchAt:(FREdgePos *)ep withMaxDistance:(NSNumber *)maxdist {

    return [self createPathSearchAt:ep withMaxDistance:maxdist avoidingEdges:nil];
}
- (FRPathSearch *) createPathSearchAt:(FREdgePos *)ep withMaxDistance:(NSNumber *)maxweight avoidingEdges:(NSArray*)skipedges{
    NSMutableArray * queue = [NSMutableArray arrayWithCapacity:3];
	NSMutableDictionary * previous = [NSMutableDictionary dictionary];
	NSMutableDictionary * distance = [NSMutableDictionary dictionary];
	NSMutableDictionary * weight = [NSMutableDictionary dictionary];
	
    float penalty = 500.0;
    
	//edgePos is a object with ints. convert to objects for use as keys
	NSNumber * a = [ep startObj];
	NSNumber * b = [ep endObj];
	
	//add edge nodes to queue
	[queue addObject:a];
	[queue addObject:b];
	

	//set their distances appropriately
	[distance setObject:[NSNumber numberWithFloat:ep.position] forKey:a];
	[distance setObject:[NSNumber numberWithFloat:[self edgeLengthFromStart:a toFinish:b] - ep.position] forKey:b];
	
    
    
    float a_weight = [[distance objectForKey:a] floatValue];
    float b_weight = [[distance objectForKey:b] floatValue];
    
    //set their weights according to skipedges
    for (FREdgePos * skip_ep in skipedges){
        if (![skip_ep onSameEdgeAs:ep]) continue;
        if ([self ep:ep isFacingOther:skip_ep]){
            a_weight+=penalty;
        } else {
            b_weight+=penalty;
        }
    }
    
    [weight setObject:[NSNumber numberWithFloat:a_weight] forKey:a];
    [weight setObject:[NSNumber numberWithFloat:b_weight] forKey:b];
    
	//set their previous nodes to each other
	[previous setObject:a forKey:b];
	[previous setObject:b forKey:a];
	
	
	//travel the tree
	while ([queue count]>0){
		NSNumber * node = [queue objectAtIndex:0];
		[queue removeObjectAtIndex:0];
		float nodedist = [[distance objectForKey:node] floatValue];
        float nodeweight = [[weight objectForKey:node] floatValue];
        
		for (NSNumber * neighbor in [graph objectForKey:node]){
			
            //skip if this edge is in the avoid list
            float dist = [self edgeLengthFromStart:node toFinish:neighbor];
            float neighborweight = nodeweight + dist;
            
            for (FREdgePos * skip_ep in skipedges){
                if ([skip_ep onEdgeFromA:node toB:neighbor]) neighborweight+=penalty;
            }
            
            if (maxweight && [maxweight floatValue] < neighborweight) continue; //dont add nodes that are too costly
			
            if ([weight objectForKey:neighbor]==nil || neighborweight < [[weight objectForKey:neighbor] floatValue]){
				[weight setObject:[NSNumber numberWithFloat:neighborweight] forKey:neighbor];
                [distance setObject:[NSNumber numberWithFloat:dist+nodedist] forKey:neighbor];
				[previous setObject:node forKey:neighbor];
				[queue addObject:neighbor];
			}
		}
	}
	
	// should autorelease this. memory leak possible
    //we no longer need the weights in order to create the path search. though it doesnt incorporate distances to badguys
    FRPathSearch * ps = [[FRPathSearch alloc] initWithRoot:ep previous:previous distance:distance map:self];
    return ps;
}
- (NSNumber *) randomNeighbor:(NSNumber *)node {
	int i=0;
	NSDictionary * neighbors = [graph objectForKey:node];
	NSNumber * rnode;
	for (NSNumber * neighbor in neighbors){
		if (arc4random()%(++i)==0) rnode = neighbor;
	}
	return rnode;
}
- (FREdgePos *) flipEdgePos:(FREdgePos*)ep {
	FREdgePos * x = [[[FREdgePos alloc] init] autorelease];
	x.start = ep.end;
	x.end = ep.start;
	x.position = [self maxPosition:ep] - ep.position;
	
	[self isValidEdgePos:x];
	return x;
}
- (BOOL) isValidEdgePos:(FREdgePos *)ep {
	NSNumber * start = [NSNumber numberWithInt:ep.start];
	NSNumber * end = [NSNumber numberWithInt:ep.end];
	NSDictionary * neighbors = [graph objectForKey:start];
	if (neighbors==nil) {
		[NSException raise:@"Invalid start value" format:@"start of %i is has no neighbors. %@", ep.start, ep];
		return NO;
	}
	NSDictionary * data = [neighbors objectForKey:end];
	if (data==nil) {
		[NSException raise:@"Invalid end value" format:@"end of %i is not a neighbor of start. %@", ep.end, ep];
		return NO;
	}
	NSNumber * length = [data objectForKey:@"length"];
	if (length==nil) {
		[NSException raise:@"Edge has no length set" format:@"edge = %@", data];
		return NO;
	}
	if ([length floatValue] < ep.position) {
		[NSException raise:@"Position is longer than edge" format:@"position %f > %f length. %@", ep.position, [length floatValue], ep];
		return NO;
	}
	return YES;
}
- (int) numNeighbors:(NSNumber*)node{
    return [[graph objectForKey:node] count];
}
- (FREdgePos *) move:(FREdgePos *)ep forwardRandomly:(float)dx {
	/*
	 
	 Move forward along an edge.
	 If the start of the edge is reached, it chooses a connected edge at random
	 
	 
	 The point will keep moving from edge to edge until dx is consumed.
	 */
	NSNumber * start = [ep startObj];
	NSNumber * end = [ep endObj];	
	float position = ep.position;
	
	position = position - dx;
	
	while (position<=0) {
		int old = [end intValue];
		int i = 0;
		end = start;
		
		//avoid going backward, but turn around if you have to.
		do {
			start = [self randomNeighbor:end];
		} while ([start intValue]==old && i++ < 10);
		
		position = [self edgeLengthFromStart:start toFinish:end] + position;
	}
	
	FREdgePos * x = [[[FREdgePos alloc] init] autorelease];
	x.start = [start intValue];
	x.end = [end intValue];
	x.position = position;
	return x;
	
}
- (void) dealloc {
	[nodes release];
	[edges release];
	[graph release];
	[super dealloc];
}
- (CLLocationCoordinate2D) coordinateFromEdgePosition:(FREdgePos*)ep {
	/*
	 use an interpolation formula to find a position between two points
	 
	 Eventually I should look at the midpoint formula from this website
	 
	 http://www.movable-type.co.uk/scripts/latlong.html
	 var Bx = Math.cos(lat2) * Math.cos(dLon);
	 var By = Math.cos(lat2) * Math.sin(dLon);
	 var lat3 = Math.atan2(Math.sin(lat1)+Math.sin(lat2),
						   Math.sqrt( (Math.cos(lat1)+Bx)*(Math.cos(lat1)+Bx) + By*By) ); 
	var lon3 = lon1 + Math.atan2(By, Math.cos(lat1) + Bx);
	 
	 
	but currently im doing simple linear version, which will probably be fine for now, since the distances are closee
	 and we arent crossing the date line.
	 
	 */
	
	CLLocation * start = [nodes objectForKey:[NSNumber numberWithInt:ep.start]];
	CLLocation * end = [nodes objectForKey:[NSNumber numberWithInt:ep.end]];
	
	float fraction = ep.position / [self maxPosition:ep];
	
	CLLocationCoordinate2D theCoordinate;
    theCoordinate.latitude = (1-fraction)*start.coordinate.latitude + fraction*end.coordinate.latitude;
    theCoordinate.longitude = (1-fraction)*start.coordinate.longitude + fraction*end.coordinate.longitude;
    return theCoordinate; 
}
- (NSString *) directionFromEdgePos:(FREdgePos *)e1 toEdgePos:(FREdgePos *)e2{
	//does NOT work unless the edges are connected. 
	//Could be a problem for fast moving objects
	
	if (e1.start==e2.start) return nil;//@"edges are the same";
	if (e1.start!=e2.end) {
		NSLog(@"edges dont connect");
		return nil;
	}
	CLLocation * a = [nodes objectForKey:[e1 endObj]];
	CLLocation * b = [nodes objectForKey:[e1 startObj]];
	CLLocation * c = [nodes objectForKey:[e2 startObj]];
	
	float dx1 = [b coordinate].longitude - [a coordinate].longitude;
	float dy1 = [b coordinate].latitude - [a coordinate].latitude;
	float dx2 = [c coordinate].longitude - [b coordinate].longitude;
	float dy2 = [c coordinate].latitude - [b coordinate].latitude;
	
	//should detect turning around?
	float sinangle =  (dx1*dy2-dy1*dx2)/sqrtf(dx1*dx1+dy1*dy1)/sqrtf(dx2*dx2+dy2*dy2);
	if (sinangle > .5) return @"left";
	if (sinangle < -.5) return @"right";
	return @"straight";
	
}
- (NSString *) descriptionOfEdgePos:(FREdgePos *)ep {
	//(on harvard st,) heading toward windsor street
	//(someday) heading toward the drop point? or charlie could say that actually
	NSNumber * goal = [ep startObj];
	NSNumber * prev = [ep endObj];
	NSString * currentroad = [self roadNameFromEdgePos:ep];
	NSDictionary * neighbors;
	while (1){
		//move forward down the line until we hit an intersection or a dead end
		neighbors = [graph objectForKey:goal];
		if ([neighbors count]!=2) break;
		NSNumber * newgoal = [[neighbors allKeys] objectAtIndex:0];
		if ([newgoal intValue]==[prev intValue]) //[newgoal isEqual:prev]
			newgoal = [[neighbors allKeys] objectAtIndex:1];
		prev = goal;
		goal = newgoal;
	}
	NSString * text;
	switch ([neighbors count]) {
		case 0:
			text = @"lost";
			break;
		case 1:
			text = @"toward a Dead End";
			break;
		case 2:
			text = @"code error!";
			break;
		default://3 or more
			//now we need to find a road that isnt the road we are currently on
			for (NSNumber * neighbor in neighbors){
				text = [self roadNameFromNode:goal andNode:neighbor];
				if (![text isEqual:currentroad]) break;
			}
			//this could still be the current road, but not a big deal
			text = [NSString stringWithFormat:@"toward %@",text];
			break;
	}
	return text;
	
	
}
- (NSString *) descriptionFromEdgePos:(FREdgePos *)e1 toEdgePos:(FREdgePos*)e2 {
	//just passed x street
	
	NSString * direction = [self directionFromEdgePos:e1 toEdgePos:e2];
	if (!direction) return nil;
	
	if (![direction isEqualToString:@"straight"]){
		//left or right
		return [NSString stringWithFormat:@"%@ on %@",direction,[self roadNameFromEdgePos:e2]];
	}
	
	
	//perhaps he turned, but not enough for the directionFromEdgePos:toEdgePos: method to catch
	//check to see if he turned onto a new road.
	if (![[self roadNameFromEdgePos:e1] isEqualToString:[self roadNameFromEdgePos:e2]]){
		return [NSString stringWithFormat:@"onto %@",[self roadNameFromEdgePos:e2]];
	}
	
	//he definitely went straight
	//check to see if he passed a road
		
	NSDictionary * neighbors = [graph objectForKey:[e1 startObj]];
	NSMutableArray * nottaken = [NSMutableArray arrayWithCapacity:2];
	for (NSNumber * neighbor in neighbors){
		int n = [neighbor intValue];
		if (n==e1.end || n==e2.start) continue;
		[nottaken addObject:neighbor];
	}
	if ([nottaken count]==0) return nil; //he didnt pass anything

		
	NSString * road = [self roadNameFromNode:[nottaken objectAtIndex:0] andNode:[e1 startObj]];
	return [NSString stringWithFormat:@"passed %@",road];
}

- (BOOL) is:(FREdgePos *)e1 onSameRoadAs:(FREdgePos *)e2{
	return [[self roadNameFromEdgePos:e1] isEqualToString:[self roadNameFromEdgePos:e2]];
}
@end
