//
//  FRMissionOne.h
//  ontherun
//
//  Created by Matt Donahoe on 3/14/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FRMissionTemplate.h"

/*
 
 Mission One.
 
 Objectives:
 1. Find the target
 2. Chase after the target
 3. Drop off the stuff you found and await further instructions
 
 Current Problems:
 
 1. The game only works if you start from where it wants you to.
	- this is bad because if i lose, i have to run home to start again
	- instead, the game could build a level based on your current location
	- maybe even incorporate where you want to go
 2. Incorporate the building system into the app itself. download the map
 and the constraint file, and build the level.
 3. make a loading screen/voices.
 
 */


@interface FRMissionOne : FRMissionTemplate {
	NSDate * start_time;
	NSDate * rendezvous_time;
	NSDate * capture_time;
	
	float target_speed;
	
	FRPoint * target;
	
	FRPathSearch * rendezvous;
	
	NSArray * hurrylist;
	NSArray * countdown;
	
	int current_announcement;
	int current_objective;
	int ticks;
	
}

@end
