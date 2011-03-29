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
 1. Get to the drop point
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
 
 
 todo
 (done)1. parse the map, getting rid of (null) street names
 2. detect when he turns around.
 (done)3. prevent repeating the same shit.
 4. "he is heading toward blah street" should happen less frequently
 5. it might be possible to pass him, which would be annoying. better user model, perhaps lines.
 6. "he turned down x street, heading toward y street. cut him off by taking z street"
 7. remove dead ends
 8. some turns dont get announced. wtf?! (this could be because it is moving too fast and passes over an edge)
 9. keep track of whether we said a road or not. try not to repeat it.
 10. if the enemy is on the shortest path between where i am and where i was, we probably got him.
 */


@interface FRMissionOne : FRMissionTemplate {
	NSDate * start_time;
	NSDate * drop_time;
	NSDate * spotted_time;
	
	float target_speed;
	
	FRPoint * droppoint;
	FRPoint * target;
	FRPoint * pursuer;
	FRPoint * base;
	
	NSArray * hurrylist;
	NSArray * countdown;
	
	int current_announcement;
	int current_objective;
	int ticks;
	
}

@end
