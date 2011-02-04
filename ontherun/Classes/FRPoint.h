//
//  FRPoint.h
//  ontherun
//
//  Created by Matt Donahoe on 1/5/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "FRMap.h"


/*
 
 It is getting difficult to create different point behaviors and control them all from
 a single view. FRPoint should be a base class, that does but has a position and a name.
 
 Further subclasses can have other behaviors
 
 For example, an attacker class can follow the user around.
 but perhaps it would be best just to add a state variable.
 
 status = @"waiting"
 
 That way the smart controller can see changes in status.
 
 
 
 
 
 */


@interface FRPoint : NSObject {
	NSString * name;
	EdgePos pos;
	FRPoint * target;
	float speed;
	NSDictionary * dictme;
	FRMap * map;
	NSString * status;
}


@property(nonatomic,retain) NSString * name;
@property(assign) EdgePos pos;
@property(nonatomic,retain) FRPoint * target;
@property(readonly) NSDictionary * dictme;
@property(nonatomic,retain) NSString * status;
- (id) initWithDict:(NSDictionary*)dict;
@end
