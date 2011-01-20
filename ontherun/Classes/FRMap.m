//
//  FRMap.m
//  ontherun
//
//  Created by Matt Donahoe on 1/16/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "FRMap.h"


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
- (NSArray *) shortestPathBetweenA:(CLLocation *)a andB:(CLLocation *)b {
	
	NSMutableArray * queue = [NSMutableArray arrayWithCapacity:3];
	NSMutableDictionary * previous = [NSMutableDictionary dictionaryWithCapacity:3];
	NSMutableDictionary * distance = [NSMutableDictionary dictionaryWithCapacity:3];
	
	//find the closest edge to a
	NSArray * closest_edge = [self closestEdgeToPoint:a];
	//add the nodes on that edge to the queue
	for (NSNumber * node in closest_edge){
		[queue addObject:node];
		float dist = [a distanceFromLocation:[nodes objectForKey:node]];
		[distance setObject:[NSNumber numberWithFloat:dist] forKey:node];
	}
	
	//travel the tree
	while ([queue count]>0){
		NSNumber * node = [queue objectAtIndex:0];
		[queue removeObjectAtIndex:0];
		for (NSNumber * neighbor in [graph objectForKey:node]){
			float dist = [[[[graph objectForKey:node] objectForKey:neighbor] objectForKey:@"length"] floatValue] + [[distance objectForKey:neighbor] floatValue];
			if ([distance objectForKey:neighbor]==nil || dist < [[distance objectForKey:neighbor] floatValue]){
				[distance setObject:[NSNumber numberWithFloat:dist] forKey:neighbor];
				[previous setObject:node forKey:neighbor];
				[queue addObject:neighbor];
			}
		}
	}
	
	//now find the closest edge to b
	closest_edge = [self closestEdgeToPoint:b];
	
	//choose the node attached to this edge that has the shortest distance
	NSNumber * end;
	float mindist = 1000000000000; //big number
	for (NSNumber * node in closest_edge){
		float dist = [[distance objectForKey:node] floatValue] + [b distanceFromLocation:[nodes objectForKey:node]];
		if (dist < mindist){
			mindist = dist;
			end = node;
		}
	}
	
	//create the path from the previous dict
	NSMutableArray * path = [NSMutableArray arrayWithObject:[nodes objectForKey:end]];
	NSMutableArray * path2 = [NSMutableArray arrayWithObject:end];
	while ([previous objectForKey:end]!=nil){
		end = [previous objectForKey:end];
		[path addObject:[nodes objectForKey:end]];
		[path2 insertObject:end atIndex:0];
	}
	//NSLog(@"data time! %@",path2);
	return path2;
}
- (NSString *) textDirectionFromA:(CLLocation *)a toB:(CLLocation *)b {
	//get the shortest path;
	NSArray * path = [self shortestPathBetweenA:a andB:b];
	NSLog(@"path length = %i",[path count]);
	//get the name of the street you are on
	NSArray * closestEdge = [self closestEdgeToPoint:a];
	NSString * currentRoad = [[[graph objectForKey:[closestEdge objectAtIndex:0]] objectForKey:[closestEdge objectAtIndex:1]] objectForKey:@"name"];
	NSMutableArray * newpath = [NSMutableArray arrayWithArray:path];
	NSNumber * other;
	if ([[path objectAtIndex:0] isEqualToNumber:[closestEdge objectAtIndex:0]]){
		other = [closestEdge objectAtIndex:1];
	} else {
		other = [closestEdge objectAtIndex:0];
	}
	[newpath insertObject:other atIndex:0];
	
	//walk down the path until a turn
	//(assumes path is longer than 2)
	NSString * nextRoad = nil;
	NSNumber * intersection = nil;
	NSString * turn = nil;
	for (float i=2;i<[newpath count];i++){
		NSArray * e1 = [newpath subarrayWithRange:NSMakeRange(i-2,2)];
		NSArray * e2 = [newpath subarrayWithRange:NSMakeRange(i-1,2)];
		turn = [self directionFromEdge:e1 toEdge:e2];
		if ([turn isEqualToString:@"straight"]==NO){
			//get the name of the street you turn on
			nextRoad = [[[graph objectForKey:[e2 objectAtIndex:0]] objectForKey:[e2 objectAtIndex:1]] objectForKey:@"name"];
			intersection = [newpath objectAtIndex:i-1];
			break;
		}
	}
	
	NSString * message;
	float distance;
	//if there isnt a turn, just get the distance to the end. (perhaps use b instead?)	 
	if (intersection==nil) {
		distance = [a distanceFromLocation:b];
		message = [NSString stringWithFormat:@"Go %f meters down %@",distance,currentRoad];
	} else {
		//get distance from a to intersection
		distance = [a distanceFromLocation:[nodes objectForKey:intersection]];
		message = [NSString stringWithFormat:@"Go %f meters down %@ and then turn %@ on %@",distance,currentRoad,turn,nextRoad];
	}
	return message;
	
	
	//support paths that are short and have no turns
}
- (NSString *) closestRoad:(CLLocation *)p{
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
		float b = [[[[graph objectForKey:i] objectForKey:j] objectForKey:@"length"] floatValue];
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
- (NSString *) directionFromEdge:(NSArray *)e1 toEdge:(NSArray *)e2{
	float dx1 = [[nodes objectForKey:[e1 objectAtIndex:1]] coordinate].longitude - [[nodes objectForKey:[e1 objectAtIndex:0]] coordinate].longitude;
	float dy1 = [[nodes objectForKey:[e1 objectAtIndex:1]] coordinate].latitude - [[nodes objectForKey:[e1 objectAtIndex:0]] coordinate].latitude;
	float dx2 = [[nodes objectForKey:[e2 objectAtIndex:1]] coordinate].longitude - [[nodes objectForKey:[e2 objectAtIndex:0]] coordinate].longitude;
	float dy2 = [[nodes objectForKey:[e2 objectAtIndex:1]] coordinate].latitude - [[nodes objectForKey:[e2 objectAtIndex:0]] coordinate].latitude;
	float sinangle =  (dx1*dy2-dy1*dx2)/sqrtf(dx1*dx1+dy1*dy1)/sqrtf(dx2*dx2+dy2*dy2);
	if (sinangle > .5) return @"left";
	if (sinangle < -.5) return @"right";
	return @"straight";
}
- (NSString *) compassDirectionOfEdge:(NSArray *)e {
	float dx = [[nodes objectForKey:[e objectAtIndex:1]] coordinate].longitude - [[nodes objectForKey:[e objectAtIndex:0]] coordinate].longitude;
	float dy = [[nodes objectForKey:[e objectAtIndex:1]] coordinate].latitude - [[nodes objectForKey:[e objectAtIndex:0]] coordinate].latitude;
	if (abs(dx)>abs(dy)){
		if (dx>0) return @"east";
		return @"west";
	}
	if (dy>0) return @"north";
	return @"south";

}
- (void) dealloc {
	[super dealloc];
	[nodes release];
	[edges release];
	[graph release];
}
@end
