//
//  TheKeyMission.m
//  ontherun
//
//  Created by Matt Donahoe on 5/13/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "TheKeyMission.h"


/*
 what happens in this mission?
 
 check out a number of locations.
 then get chased.
 outrun that person
 go home.
 
 1. how many places? more places means more pathsearchs to place the points
 2. the final chase needs to be of a certain length
 3. the chase needs to be interesting
 4. James Bond!
 5. 
 
 
 
 */

@implementation TheKeyMission

- (id) initWithLocation:(CLLocation *)l distance:(float)dist destination:(CLLocation *)dest viewControl:(UIViewController *)vc{
    self = [super initWithLocation:l distance:dist destination:dest viewControl:vc];
    if (!self) return nil;
    
    
    pointA = [[FRPoint alloc] initWithName:@"first"];
    pointB = [[FRPoint alloc] initWithName:@"second"];
    pointC = [[FRPoint alloc] initWithName:@"third"];
    
    dude = [[FRPoint alloc] initWithName:@"dude"];
    
    
    //position these points such that the total distance is correct
    //th final run should be the longest part. that chase sequence needs to last awhile.
    

    
    return self;
}

@end
