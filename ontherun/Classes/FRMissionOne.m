//
//  FRMissionOne.m
//  ontherun, turn-by-turn Directives, edge of your seat directions, real-time spoken action movie
//
//  Created by Matt Donahoe on 3/14/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "FRMissionOne.h"


@implementation FRMissionOne

- (id) initWithFilename:(NSString *)filename {
	//load the location data from a file. create the mission
	self = [super init];
	if (!self) return nil;
	
	NSDictionary * filedata; //= jsonValue of file
	
	//
	start_time = [[NSDate alloc] init]; //is this actually the current time?
	
	user = [[FRPoint alloc] initWithDict:[NSDictionary dictionaryWithObject:@"user" forKey:@"name"] onMap:themap];
	droppoint = [[FRPoint alloc] initWithDict:[filedata objectForKey:@"droppoint"] onMap:themap];
	target = [[FRPoint alloc] initWithDict:[filedata objectForKey:@"target"] onMap:themap];
	pursuer = [[FRPoint alloc] initWithDict:[filedata objectForKey:@"pursuer"] onMap:themap];
	base = [[FRPoint alloc] initWithDict:[filedata objectForKey:@"base"] onMap:themap];
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
	
	
	NSDate * now = [NSDate date];
	
	
	//talk about how close the van is
	if (current_objective  < 2) {
		NSTimeInterval timeleft = [now timeIntervalSinceDate:drop_time];
		NSLog(@"timeleft = %f",timeleft);
		if (timeleft < [[timestates objectAtIndex:current_announcement] floatValue]){
			current_announcement++;
			[self speak:[announcements objectAtIndex:current_announcement]];
		}
	}
	switch (current_objective) {
		case 0: //get to the drop point
			float dist = [latestsearch distanceFromRoot:droppoint]; //careful, this might not work
			
			//todo: calculate the player's estimated time of arrival at the drop point
			
			if (dist > 30 && timeleft < 60){
				
				[self speak:[hurrylist objectAtIndex:rand()]]; //fake random. FIX
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
			}
			break;
		case 2: //follow the target
		
			EdgePos * newpos = [themap move:target.pos forwardRandomly:target_speed];
			NSString * textualchange = [themap textFromEdgePos:target.pos toEdgePos:newpos];
			if (textualchange) [self speak:[NSString stringWithFormat:@"He went %@",textualchange]];
			target.pos = newpos;
			
			float dist = [user.pos distanceFromRoot:target.pos];
			
			if (dist < 30) {
				current_objective++;
				[self speak:@"He sees you!"];
			}
			
			
			
			
			break;
		case 3: //chase the target down
			EdgePos * newpos = [themap move:target.pos forwardRandomly:3*target_speed];
			
			NSString * textualchange = [themap textFromEdgePos:target.pos toEdgePos:newpos];
			if (textualchange) [self speak:[NSString stringWithFormat:@"He ran %@",textualchange]];
			target.pos = newpos;
			
			float dist = [user.pos distanceFromRoot:target.pos];
			
			if (dist < 15) {
				current_objective++;
				[self speak:@"Shoot him! BANG BANG BANG"]; //randomly miss? press action button
				[self speak:@"Good work. Now grab the device and get back to base"];
			}
			
			if (dist > 100) {
				[self speak:@"You are going to lose him."]; //random?
			}
			
			break;
		case 4: //return to post
			float dist = [user.pos distanceFromRoot:base.pos];
			if (dist < 30){
				[self speak:@"Good work today agent. Head inside for a debriefing."];
				current_objective++;
			}
			
			
			break;
			
		default: //what?
			
			//exit the app somehow without losing the voice.
			//or display the debrief in app??
			
			break;
	}
	
	[self performSelector:@selector(ticktock) withObject:nil afterDelay:1.0];
};
- (void) newUserLocation:(CLLocation *)location {
	/*
	 This method is called whenever a new user location
	 update is available.
	 
	 a new point comes from the network
	 or the gps
	 */
	
	
	
	
	NSLog(@"newUserLocation: %@",location);
	
	//convert to map coordinates
	FREdgePos * ep = [themap edgePosFromPoint:location];
	
	//say something. helps with gps debugging
	if (arc4random()%10==0) [self speakIfYouCan:@"click"];
	
	
	//speak the current road, if it changed
	NSString * roadname = [themap roadNameFromEdgePos:ep];
	if ([roadname isEqualToString:current_road]==NO && roadname){
		[roadname retain];
		[current_road release];
		current_road = roadname;
		[self speakEventually:current_road];
	}
	
	if (latestsearch) {
		//we already have a position
		//ensure that the direction of our new point is facing away from the old one.
		user.pos = [latestsearch move:ep awayFromRootWithDelta:0];
	} else {
		user.pos = ep;
		//start the updates
		[self performSelector:@selector(ticktock) withObject:nil afterDelay:1.0]; 
	}
	
	[latestsearch release];
	latestsearch = [themap createPathSearchAt:user.pos withMaxDistance:[NSNumber numberWithFloat:200.0]];
}

@end
