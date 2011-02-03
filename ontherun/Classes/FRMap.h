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
- (NSArray *) shortestPathBetweenA:(CLLocation *)a andB:(CLLocation *)b;
- (NSArray *) closestEdgeToPoint:(CLLocation *)p;
- (NSString *) closestRoad:(CLLocation *)p;
- (NSString *) textDirectionFromA:(CLLocation *)a toB:(CLLocation *)b;
- (NSString *) directionFromEdge:(NSArray *)e1 toEdge:(NSArray *)e2;
- (NSString *) compassDirectionOfEdge:(NSArray *)e;

//convert from latlon to EdgePos, using the map
- (EdgePos) edgePosFromPoint:(CLLocation *)p;

//convienence getter for edge length
- (float) edgeLengthFromStart:(NSNumber *)a toFinish:(NSNumber *)b;

//what is the max position for a given edge position
- (float) maxPosition:(EdgePos)ep;

- (FRPathSearch *) createPathSearchAt:(EdgePos)ep;
- (EdgePos) randompos;
- (NSArray *) getEdges;
- (EdgePos) move:(EdgePos)ep forwardRandomly:(float)dx;
- (NSNumber *) randomNeighbor:(NSNumber *)node;
@end
