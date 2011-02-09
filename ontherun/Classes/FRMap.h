//
//  FRMap.h
//  ontherun
//
//  Created by Matt Donahoe on 1/16/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef struct _edgepos {
	int start;
	int end;
	float position;
} EdgePos;

@class FRPathSearch;

@interface FRMap : NSObject {
	NSMutableDictionary * graph;
	NSMutableArray * edges;
	NSMutableDictionary * nodes;
}
- (id) initWithNodes:(NSMutableDictionary*)_nodes andRoads:(NSMutableArray *)roads;

//checks the distance to each edge segment, and returns to edge with the minimum distance
- (NSArray *) closestEdgeToPoint:(CLLocation *)p;

//returns the road name of the current edge
- (NSString *) closestRoad:(CLLocation *)p;

//convert from latlon to EdgePos, using the map
- (EdgePos) edgePosFromPoint:(CLLocation *)p;

//convienence getter for edge length
- (float) edgeLengthFromStart:(NSNumber *)a toFinish:(NSNumber *)b;

//what is the max position for a given edge position
- (float) maxPosition:(EdgePos)ep;

//does a BFS on the graph starting at the two nodes on the give edge, returns the resulting pathsearch object
- (FRPathSearch *) createPathSearchAt:(EdgePos)ep withMaxDistance:(NSNumber *)maxdist;

//chooses a random edge, and a random position along that edge
- (EdgePos) randompos;

//moves forward, and chooses a new edge if need be.
- (EdgePos) move:(EdgePos)ep forwardRandomly:(float)dx;

//returns a random node that is connected to the given node
- (NSNumber *) randomNeighbor:(NSNumber *)node;

//reverses the nodes and adjust the position accordingly
- (EdgePos) flipEdgePos:(EdgePos)ep;

//makes sure the edgepos is correct, raises and error otherwise (why bool?)
- (BOOL) isValidEdgePos:(EdgePos)ep;

//converts from edgepos back to lat-longs (for drawing purposes)
- (CLLocationCoordinate2D) coordinateFromEdgePosition:(EdgePos)ep;
@end
