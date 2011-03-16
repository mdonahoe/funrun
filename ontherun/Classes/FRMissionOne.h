//
//  FRMissionOne.h
//  ontherun
//
//  Created by Matt Donahoe on 3/14/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FRPoint.h"
#import "FRMap.h"
#import "FRPathSearch.h"
#import "toqbot.h"

/*
 
 Mission One.
 
 Objectives:
 1. Get to the drop point
 2. Chase after the target
 3. Get back to your hideout and await further instructions
 
 
 Current Problems:
 1. difficult to tell where the target is relative to you. need more information. How far away am i?
 "the target is on norfolk, running toward broadway"
 "the target is on norfolk, just passed broadway"
 
 2. pins dont show up in the mapview. wtf
 
 
 */


@interface FRMissionOne : NSObject <CLLocationManagerDelegate> {
	NSDate * start_time;
	NSDate * drop_time;
	NSDate * spotted_time;
	float target_speed;
	NSString * current_road;
	int current_objective;
	int ticks;
	FRPoint * droppoint;
	FRPoint * target;
	FRPoint * user;
	FRPoint * pursuer;
	FRPoint * base;
	NSArray * points;
	
	FRPathSearch * latestsearch;
	FRMap * themap;
	
	CLLocationManager * locationManager;
	NSObject * voicebot;
	toqbot * m2;
	NSMutableArray * toBeSpoken;
	
	
	NSArray * hurrylist;
	NSArray * countdown;
	
	int current_announcement;
	
}
@property(nonatomic,retain) NSArray * points;
- (id) initWithFileName:(NSString*)filename;
- (void) updatePosition:(id)obj;
- (void) ticktock;
- (void) startStandardUpdates;
- (void) newUserLocation:(CLLocation *)location;
- (void) speak:(NSString *)text;

@end
