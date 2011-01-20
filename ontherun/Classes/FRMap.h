//
//  FRMap.h
//  ontherun
//
//  Created by Matt Donahoe on 1/16/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

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

@end
