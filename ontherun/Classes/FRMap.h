//
//  FRMap.h
//  ontherun
//
//  Created by Matt Donahoe on 1/16/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "FREdgePos.h"

@class FRPathSearch;

@interface FRMap : NSObject {
	NSMutableDictionary * graph;
	NSMutableArray * edges;
	NSMutableDictionary * nodes;
}
- (id) initWithNodes:(NSMutableDictionary*)_nodes andRoads:(NSMutableArray *)roads;

//checks the distance to each edge segment, and returns to edge with the minimum distance
- (NSArray*) closest:(int)n edgesToPoint:(CLLocation*)p;
- (NSArray *) closestEdgeToPoint:(CLLocation *)p;


- (float) distanceFromEdge:(NSArray*)e toPoint:(CLLocation*)p;



//convert from latlon to EdgePos, using the map
- (FREdgePos *) edgePosFromPoint:(CLLocation *)p usingEdge:(NSArray *)edge;
- (FREdgePos *) edgePosFromPoint:(CLLocation *)p;

//convienence getter for edge length
- (float) edgeLengthFromStart:(NSNumber *)a toFinish:(NSNumber *)b;

//what is the max position for a given edge position
- (float) maxPosition:(FREdgePos *)ep;

- (NSString *) roadNameFromEdgePos:(FREdgePos *)ep;
- (NSString *) roadNameFromNode:(NSNumber*)n1 andNode:(NSNumber *)n2;

//does a BFS on the graph starting at the two nodes on the give edge, returns the resulting pathsearch object
- (FRPathSearch *) createPathSearchAt:(FREdgePos *)ep withMaxDistance:(NSNumber *)maxdist;

//avoids some edges
- (FRPathSearch *) createPathSearchAt:(FREdgePos *)ep withMaxDistance:(NSNumber *)maxdist avoidingEdges:(NSArray*)skipedges;
    
//moves forward, and chooses a new edge if need be.
- (FREdgePos *) move:(FREdgePos *)ep forwardRandomly:(float)dx;

//returns a random node that is connected to the given node
- (NSNumber *) randomNeighbor:(NSNumber *)node;

//number of neighboring nodes
- (int) numNeighbors:(NSNumber*)node;

//reverses the nodes and adjust the position accordingly
- (FREdgePos *) flipEdgePos:(FREdgePos *)ep;

//makes sure the edgepos is correct, raises and error otherwise (why bool?)
- (BOOL) isValidEdgePos:(FREdgePos *)ep;

//converts from edgepos back to lat-longs (for drawing purposes)
- (CLLocationCoordinate2D) coordinateFromEdgePosition:(FREdgePos *)ep;

//computes the text direction of an edge transition. turned "left" "straight" "right"
- (NSString *) directionFromEdgePos:(FREdgePos *)e1 toEdgePos:(FREdgePos *)e2;

//turned left/right on x street
- (NSString *) descriptionFromEdgePos:(FREdgePos *)e1 toEdgePos:(FREdgePos*)e2;

//toward a blah street
- (NSString *) descriptionOfEdgePos:(FREdgePos *)ep;

//check road names
- (BOOL) is:(FREdgePos *)e1 onSameRoadAs:(FREdgePos *)e2;
@end
