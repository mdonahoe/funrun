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

- (NSString *) closestRoad:(CLLocation *)p {
	NSArray * edge = [self closestEdgeToPoint:p];
	return [[[graph objectForKey:[edge objectAtIndex:0]] objectForKey:[edge objectAtIndex:1]] objectForKey:@"name"];
}
- (NSArray *) closestEdgeToPoint:(CLLocation *)p {
	float mindist = 10000000000000; //big number
	NSArray * closest_edge = nil;
	
	for (NSArray * edge in edges){
		NSNumber * i = [edge objectAtIndex:0];
		NSNumber * j = [edge objectAtIndex:1];
		float a = [p distanceFromLocation:[nodes objectForKey:i]];
		float b = [self edgeLengthFromStart:i toFinish:j];
		float c = [p distanceFromLocation:[nodes objectForKey:j]];
		//NSLog(@"a=%f, b=%f, c=%f",a,b,c);
		
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
		//NSLog(@"h=%f and mindist=%f",h,mindist);
		if (h < mindist){
			//NSLog(@"edge = %@",edge);
			mindist = h;
			closest_edge = edge;
		}
	}
	if (closest_edge==nil) NSLog(@" NIL TOWN! bummer");
	return closest_edge;
}
- (EdgePos) edgePosFromPoint:(CLLocation *)p {
	
	EdgePos ep;
	
	NSArray * edge = [self closestEdgeToPoint:p];
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
- (float) edgeLengthFromStart:(NSNumber *)a toFinish:(NSNumber *)b {
	return [[[[graph objectForKey:a] objectForKey:b] objectForKey:@"length"] floatValue];
}
- (float) maxPosition:(EdgePos)ep {
	return [self edgeLengthFromStart:[NSNumber numberWithInt:ep.start] toFinish:[NSNumber numberWithInt:ep.end]];
}
- (FRPathSearch *) createPathSearchAt:(EdgePos)ep withMaxDistance:(NSNumber *)maxdist{
	NSMutableArray * queue = [NSMutableArray arrayWithCapacity:3];
	NSMutableDictionary * previous = [NSMutableDictionary dictionary];
	NSMutableDictionary * distance = [NSMutableDictionary dictionary];
	
	
	//edgePos is a struct with ints. convert to objects for use as keys
	NSNumber * a = [NSNumber numberWithInt:ep.start];
	NSNumber * b = [NSNumber numberWithInt:ep.end];
	
	//add edge nodes to queue
	[queue addObject:a];
	[queue addObject:b];
	

	//set their distances appropriately
	[distance setObject:[NSNumber numberWithFloat:ep.position] forKey:a];
	[distance setObject:[NSNumber numberWithFloat:[self edgeLengthFromStart:a toFinish:b] - ep.position] forKey:b];
	
	//set their previous nodes to each other
	[previous setObject:a forKey:b];
	[previous setObject:b forKey:a];
	
	
	//travel the tree
	while ([queue count]>0){
		NSNumber * node = [queue objectAtIndex:0];
		[queue removeObjectAtIndex:0];
		float nodedist = [[distance objectForKey:node] floatValue];
		for (NSNumber * neighbor in [graph objectForKey:node]){
			float dist = [self edgeLengthFromStart:node toFinish:neighbor] + nodedist;
			if (maxdist && [maxdist floatValue] < dist) continue; //dont add nodes that are too far from the root
			if ([distance objectForKey:neighbor]==nil || dist < [[distance objectForKey:neighbor] floatValue]){
				[distance setObject:[NSNumber numberWithFloat:dist] forKey:neighbor];
				[previous setObject:node forKey:neighbor];
				[queue addObject:neighbor];
			}
		}
	}
	
	
	FRPathSearch * ps = [[FRPathSearch alloc] initWithRoot:ep previous:previous distance:distance map:self];
	return ps;
}
- (EdgePos) randompos {
	
	//choose a random starting node
	int i=0;
	int n=[nodes count];
	NSNumber * start;
	for (NSNumber * node in nodes){
		if (arc4random()%(++i) == 0) start = node;
	}
	
	//choose a random neighbor (replace with @selector(randomNeighbor:))
	i=0;
	NSDictionary * neighbors = [graph objectForKey:start];
	n = [neighbors count];
	NSNumber * end;
	for (NSNumber * node in neighbors){
		if (arc4random()%(++i)==0) end = node;
	}
	
	//move a random distance along that edge
	float length = [self edgeLengthFromStart:start toFinish:end];
	float position = length * (arc4random()%1000000)/1000000.0;
	
	//return the EdgePos
	EdgePos x;
	x.start = [start intValue];
	x.end = [end intValue];
	x.position = position;
	return x;
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
- (EdgePos) flipEdgePos:(EdgePos)ep {
	int temp = ep.start;
	ep.start = ep.end;
	ep.end = temp;
	ep.position = [self maxPosition:ep] - ep.position;
	
	[self isValidEdgePos:ep];
	NSLog(@"flip succeeded");
	return ep;
}
- (BOOL) isValidEdgePos:(EdgePos)ep {
	NSNumber * start = [NSNumber numberWithInt:ep.start];
	NSNumber * end = [NSNumber numberWithInt:ep.end];
	NSDictionary * neighbors = [graph objectForKey:start];
	if (neighbors==nil) {
		[NSException raise:@"Invalid start value" format:@"start of %i is invalid", ep.start];
		return NO;
	}
	NSDictionary * data = [neighbors objectForKey:end];
	if (data==nil) {
		[NSException raise:@"Invalid end value" format:@"end of %i is invalid", ep.end];
		return NO;
	}
	NSNumber * length = [data objectForKey:@"length"];
	if (length==nil) {
		[NSException raise:@"Edge has no length set" format:@"edge = %@", data];
		return NO;
	}
	if ([length floatValue] < ep.position) {
		[NSException raise:@"Position is longer than edge" format:@"position %f > %f length", ep.position, [length floatValue]];
		return NO;
	}
	return YES;
}
- (EdgePos) move:(EdgePos)ep forwardRandomly:(float)dx {
	NSNumber * start = [NSNumber numberWithInt:ep.start];
	NSNumber * end = [NSNumber numberWithInt:ep.end];	
	float position = ep.position;
	
	//NSLog(@"start %@, end %@, pos %f",start,end,position);
	
	position = MAX(0,position - dx);
	
	if (position<=0) {
		int old = [end intValue];
		int i = 0;
		end = start;
		
		//avoid going backward
		do {
			start = [self randomNeighbor:end];
		} while ([start intValue]==old && i++ < 10);
		
		position = [self edgeLengthFromStart:start toFinish:end];
		//NSLog(@"moved nodes: start %@, end %@, pos: %f",start,end,position);
	}
	
	EdgePos x;
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
- (CLLocationCoordinate2D) coordinateFromEdgePosition:(EdgePos)ep {
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
@end
