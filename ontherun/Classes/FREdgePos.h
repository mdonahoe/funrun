//
//  FREdgePos.h
//  ontherun
//
//  Created by Matt Donahoe on 2/15/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 
 A FREdgePos represents a position on a network of edges.
 
 Since this game is meant to be played along streets,
 we want to make sure that all the characters move along streets, and not through buildings.
 
 As a result, I chose to represent character positions not as X,Y or latitude,longitude
 but instead as a distance between two nodes in the graph. That graph is made from roads and nodes in the map
 data provided by OpenStreetMap.
 
 
 The edgepos uses 3 number to represent a location.
 The first two are the nodes IDs of the two nodes that make up the edge.
 The third is the distance to travel along that edge from start to end.
 
 Order matters: position is the distance from "start" toward "end".
 As a result, I can encode direction in the order.
 
 Imagine a an edge with total length 10.0 formed by the nodes 0 and 1
 
 edge positions start=0 end=1 position=3.0; start=1,end=0,position=7.0 
 are the same point in space, but are point in different directions.
 
 By convention, points are facing their "start" node.
 Thus point move forward by reducing their position value
 until it reaches zero. At which point end=start and start= a new node
 
 */



@interface FREdgePos : NSObject {
	int start;
	int end;
	float position;
}
@property(assign) int start;
@property(assign) int end;
@property(assign) float position;
- (NSNumber *) startObj;
- (NSNumber *) endObj;
@end
