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
		
		for (NSDictionary * road in roads){
			NSNumber * previous = nil;
			for (NSNumber * node in [road objectForKey:@"nodes"]) {
				if (previous!=nil) [edges addObject:[[NSArray alloc] initWithObjects:previous,node,nil]];
				previous = node;
			}
		}
		
		graph = [[NSMutableDictionary alloc] init];
		for (NSArray * edge in edges){
			NSString * a = [edge objectAtIndex:0];
			NSString * b = [edge objectAtIndex:1];
			if ([graph objectForKey:a]==nil) [graph setObject:[[NSMutableDictionary alloc] initWithCapacity:3] forKey:a];
			if ([graph objectForKey:b]==nil) [graph setObject:[[NSMutableDictionary alloc] initWithCapacity:3] forKey:b];
			
			float length = [(CLLocation *)[nodes objectForKey:a] distanceFromLocation:(CLLocation *)[nodes objectForKey:b]];
			NSNumber * dist = [NSNumber numberWithFloat:length];
			[(NSMutableDictionary *)[graph objectForKey:a] setObject:dist forKey:b];
			[(NSMutableDictionary *)[graph objectForKey:b] setObject:dist forKey:a];
			
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
	//NSLog(@"this be the edge %@",closest_edge);
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
			float dist = [[[graph objectForKey:node] objectForKey:neighbor] floatValue] + [[distance objectForKey:neighbor] floatValue];
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
		[path2 addObject:end];
	}
	NSLog(@"data time! %@",path2);
	return path;
}
- (NSArray *) closestEdgeToPoint:(CLLocation *)p {
	float mindist = 10000000000000; //big number
	NSArray * closest_edge;
	
	for (NSArray * edge in edges){
		NSNumber * i = [edge objectAtIndex:0];
		NSNumber * j = [edge objectAtIndex:1];
		float a = [p distanceFromLocation:[nodes objectForKey:i]];
		float b = [[[graph objectForKey:i] objectForKey:j] floatValue];
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
		if (h < mindist){
			mindist = h;
			closest_edge = edge;
		}
	}
	return closest_edge;
}
- (void) dealloc {
	[nodes release];
	[edges release];
	[graph release];
}
@end
