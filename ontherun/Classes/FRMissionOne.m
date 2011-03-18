//
//  FRMissionOne.m
//  ontherun, turn-by-turn Directives, edge of your seat directions, real-time spoken action movie
//
//  Created by Matt Donahoe on 3/14/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "FRMissionOne.h"
#import "FRFileLoader.h"
#import "JSON.h"

@implementation FRMissionOne



- (id) initWithFilename:(NSString *)filename {
	//load the location data from a file. create the mission
	self = [super init];
	if (!self) return nil;
	
	
	FRFileLoader * loader = [[FRFileLoader alloc] initWithBaseURLString:@"http://toqbot.com/otr/test1/"];
	
	//load the mission
	[loader deleteCacheForFile:filename];
	NSString * missionstring = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:[loader pathForFile:filename]] encoding:NSUTF8StringEncoding];
	[loader release];
	NSDictionary * missiondata = [missionstring JSONValue];
	[missionstring release];
	
	ticks = 0;
	target_speed = 1.0;
	start_time = [[NSDate alloc] init]; //is this actually the current time?
	drop_time = [[NSDate alloc] initWithTimeIntervalSinceNow:250];
	
	//more points
	droppoint = [[FRPoint alloc] initWithDict:[missiondata objectForKey:@"droppoint"] onMap:themap];
	target = [[FRPoint alloc] initWithDict:[missiondata objectForKey:@"target"] onMap:themap];
	pursuer = [[FRPoint alloc] initWithDict:[missiondata objectForKey:@"pursuer"] onMap:themap];
	base = [[FRPoint alloc] initWithDict:[missiondata objectForKey:@"base"] onMap:themap];
	
	
	//only let target appear on the map for now
	[points addObject:target];
	[target setCoordinate:[themap coordinateFromEdgePosition:target.pos]];
	
	hurrylist = [[NSArray alloc] initWithArray:[missiondata objectForKey:@"hurrylist"]];
	countdown = [[NSArray alloc] initWithArray:[missiondata objectForKey:@"countdown"]];
	
	//states
	current_objective = 0;
	current_announcement = 0;
	
	return self;
}

- (void) ticktock {
	/*
	 This method is called once a second
	 
	 used for updating timers and NPC locations
	 
	 
	 

	 when the user pressed the headphone button,
	 the game should explicitly say what to do
	 
	 example:
	 "the target is 45m away on harvard street. 
	 make a left at the intersection of windsor and harvard st"
	 
	 ideally we do this in a way that doesnt reveal how
	 bad our GPS is.
	 
	 */
	
	
	FREdgePos * newpos;
	float dist;
	NSTimeInterval timeleft = [drop_time timeIntervalSinceNow];
	//NSLog(@"timeleft = %f",timeleft);
	
	
	
	
	//talk about how close the van is
	if (timeleft > 0 && current_announcement < [countdown count]) {
		NSArray * count = [countdown objectAtIndex:current_announcement];
		if (timeleft < [[count objectAtIndex:0] floatValue]/5.0){
			current_announcement++;
			[self speak:[count objectAtIndex:1]];
		}
	}
	
	//the target moves slowly and randomly until he sees you
	newpos = nil;
	if (current_objective < 3 && timeleft < 0){
		newpos = [themap move:target.pos forwardRandomly:target_speed];
	}
	
	NSLog(@"objective = %i, queue = %i",current_objective,[toBeSpoken count]);
	//what objective are we on? (game state)
	switch (current_objective) {
		case 0: //get to the drop point
			//if droppoint is not in latestsearch, this returns 10^9;
			dist = [latestsearch distanceFromRoot:droppoint.pos];
			
			//todo: calculate the player's estimated time of arrival at the drop point
			
			if (dist > 30 && timeleft < 60){
				[self speakIfEmpty:[hurrylist objectAtIndex:arc4random()%[hurrylist count]]];
			}
			
			if (dist < 30){
				current_objective++;
				[self speak:@"Alright, this is the drop point."];
				if (timeleft > 30) {
					[self speak:@"Wait for the target to arrive"];
				}
			}
			break;
		case 1: //wait for the target to arrive
			if (timeleft < 0) {
				current_objective++;
				[self speak:@"The target is in the open. Go get him."];
				spotted_time = [[NSDate alloc] initWithTimeIntervalSinceNow:30];
			}
			break;
		case 2: //follow the target
			
			dist = [latestsearch distanceFromRoot:newpos];
			//NSLog(@"timer = %f",[spotted_time timeIntervalSinceNow]);
			
			//during this object, Charlie should talk about stuff
			//eventually the suspect will realize that he has been followed
			
			if (dist < 30 && [spotted_time timeIntervalSinceNow] < 0) {
				current_objective++;
				[self speak:@"He sees you!"];
			}
			
			
			
			
			break;
		case 3: //chase the target down
			newpos = [latestsearch move:target.pos awayFromRootWithDelta:10*target_speed];
			
			dist = [latestsearch distanceFromRoot:newpos];
			
			if (dist < 15) {
				[self speak:@"You almost have him!"];
				ticks++;
				if (ticks>4){
					current_objective++;
					[self speak:@"Shoot him! BANG BANG BANG"]; //randomly miss? press action button
					[self speak:@"Good work. Now grab the device and get back to base"];
				}
			}
			
			if (dist > 100) {
				//you should lose somehow if he gets too far.
				
				//[self speak:@"You are going to lose him."]; //random?
			}
			
			break;
		case 4: //return to post
			dist = [latestsearch distanceFromRoot:base.pos];
			if (dist < 30){
				NSLog(@"yesh!");
				[self speak:@"Good work today agent. Head inside for a debriefing."];
				current_objective++;
			}
			
			
			break;
			
		default: //what?
			
			//exit the app somehow without losing the voice.
			//or display the debrief in app??
			
			break;
	}
	
	if (newpos && current_objective<4) {
		NSString * textualchange = [themap descriptionFromEdgePos:target.pos toEdgePos:newpos];
		if (textualchange) {
			[self speak:[NSString stringWithFormat:@"He just ran %@",textualchange]];
		} else {
			[self speakIfEmpty:[NSString stringWithFormat:@"He is heading %@",[themap descriptionOfEdgePos:newpos]]];
		}
		target.pos = newpos;
	}

	[super ticktock];
}

@end
