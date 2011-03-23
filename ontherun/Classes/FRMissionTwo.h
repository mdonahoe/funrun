//
//  FRMissionTwo.h
//  ontherun
//
//  Created by Matt Donahoe on 3/21/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FRMissionTemplate.h"

/* this mission is about escaping a manhunt
 
 you have to go to certain places without getting caught,
 and make it somewhere in a time limit
 
 what that story is, i dont know
 
 1. your last mission raised suspicion from the police. get out before they catch you, because we wont cover for you.
 2. the bad guys are out hunting for you.
 3. ??
 
 
 i need an array for FRPoints that represent the cops
 FRPoint last known position, where the cops all go to?
 
 simplest thing:
 
 there are four cops out to get you,
 and a goal position you need to get to.
 cops start at random places, and head toward your starting location.
 if they see you, they chase you.
 
 cops: go to the last known location. otherwise, move forward randomly
 
 */


@interface FRMissionTwo : FRMissionTemplate {
	NSMutableArray * enemies; //list of bad guy FRPoints
	FRPathSearch * lastseen_pos; // array of the last known positions for each of the cops.
	NSDate * lastseen_date;
	int healthpoints;
	NSDate * deadline; //time to the extraction point
	FRPathSearch * extraction;
	
}

@end
