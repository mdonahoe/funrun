//
//  FRPoint.h
//  ontherun
//
//  Created by Matt Donahoe on 1/5/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "FREdgePos.h"
#import "FRMap.h"
/*
 
 It is getting difficult to create different point behaviors and control them all from
 a single view. FRPoint should be a base class, that does but has a position and a name.
 
 Further subclasses can have other behaviors
 
 For example, an attacker class can follow the user around.
 but perhaps it would be best just to add a state variable.
 
 New method for organizing this
 
 
 the mission object *should* handle the descriptions of where things are
 points have two methods:
 - inPlayerView
 - notInPlayerView
 
 one of these methods gets called each update.
 the point is responsible for:
	1. changing its position
	2. playing any sound effects
	3. changing state
	4. emitting messages to other points
 
 the mission object is responsible for
	1. aggregating the Point information into descriptions for the player.
	2. managing messages passed between points
	3. calculating distances between points and player
 
 
 
 
 
 
 */

#define kPointNew 0
#define kPointSeen 1



@class FRMission;

@interface FRPoint : NSObject <MKAnnotation>{
	NSString * title;
	FREdgePos * pos;
	NSDictionary * dictme;
	NSString * subtitle;
	CLLocationCoordinate2D mycoordinate;
	int mystate;
}


@property(nonatomic, retain) FREdgePos * pos;
@property(readonly) NSDictionary * dictme;
@property(nonatomic,retain) NSString * title;
@property(nonatomic,retain) NSString * subtitle;
- (CLLocationCoordinate2D)coordinate;
- (void) setCoordinate:(CLLocationCoordinate2D)newCoordinate;
- (id) initWithDict:(NSDictionary*)dict onMap:(FRMap*)map;
- (void) updateForMission:(FRMission *)mission;

@end
