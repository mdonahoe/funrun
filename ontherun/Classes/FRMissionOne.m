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
#import "LocationPicker.h"
#import "FRMapViewController.h"
#import "FRSummaryViewController.h"

@implementation FRMissionOne



- (id) initWithLocation:(CLLocation *)l viewControl:(UIViewController*)vc {
	self = [super initWithLocation:l viewControl:vc];
	if (!self) return nil;
	//load the location data from a file. create the mission
	
	FRFileLoader * loader = [[FRFileLoader alloc] initWithBaseURLString:@"http://toqbot.com/otr/test1/"];
	
	//load the mission
	NSString * filename = @"mission_one3.js";
	[loader deleteCacheForFile:filename];
	NSString * missionstring = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:[loader pathForFile:filename]] encoding:NSUTF8StringEncoding];
	[loader release];
	NSDictionary * missiondata = [missionstring JSONValue];
	[missionstring release];
	
	ticks = 0;
	target_speed = 1.0;
	start_time = [[NSDate alloc] init]; //is this actually the current time?
	capture_time = nil;
	rendezvous_time = nil;
	
	
	hurrylist = [[NSArray alloc] initWithArray:[missiondata objectForKey:@"hurrylist"]];
	countdown = [[NSArray alloc] initWithArray:[missiondata objectForKey:@"countdown"]];
	
	
	//we will create these after the player selects a rendezvous point
	target = nil;
	rendezvous = nil;
	
	//states
	current_objective = 0;
	current_announcement = 0;
	
	return self;
}
- (void) pickPoint {
	//this is called when the player reads the briefing and decides to select the destination.
	//perhaps this step can be incorporated into the briefing itself.
	// "you need to get out of there. Choose an evac point and we will be there in 5 minutes to pick you up"
	// "The evac point must be at least a mile from your current location. the cops are coming, and we dont want to be spotted."
	
	//this method needs to exist for both missions.
	//once the mission begins, you cant change this location
	
	//for mission one:
	//"you need to chase down this guy and get his stuff. then head to a dropoff point to meet our agent and do the handoff."
	
	FRPoint * rendezvous_point = [[[FRPoint alloc] initWithName:@"extraction point"] autorelease];
	[rendezvous_point setCoordinate:[themap coordinateFromEdgePosition:player.pos]];
	
	LocationPicker * lp = 
	[[[LocationPicker alloc] initWithAnnotation:rendezvous_point delegate:self] autorelease];
	[self.viewControl.navigationController pushViewController:lp animated:YES];
}
- (void) pickedLocation:(CLLocationCoordinate2D)location {
	//the location picker has returned a lat-lon for the destination coordinate.
	//use it to finish building the mission map.
	//make it so that cops are positioned along the way.
	
	
	NSLog(@"location has been picked");
	//[self.viewControl.navigationController popViewControllerAnimated:YES];
	CLLocation * l = [[[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude] autorelease];
	FRPoint * rendezvous_point = [[[FRPoint alloc] initWithName:@"rendezvous point"] autorelease];
	rendezvous_point.pos = [themap edgePosFromPoint:l];
	[rendezvous release];
	rendezvous = [themap createPathSearchAt:rendezvous_point.pos withMaxDistance:[NSNumber numberWithFloat:1450.0]];
	[points addObject:rendezvous_point];
	
	[target release];
	target = [[FRPoint alloc] initWithName:@"target"];
	
	//unlike towardRootWithDelta, awayFromRootWithDelta traverses multiple edges at once
	target.pos = [rendezvous move:rendezvous_point.pos awayFromRootWithDelta:600];
	
	[points removeAllObjects];
	[points addObject:player];
	[points addObject:rendezvous_point];
	[points addObject:target];
	
	for (FRPoint * pt in points){
		[pt setCoordinate:[themap coordinateFromEdgePosition:pt.pos]];
	}
	[self.viewControl setDest:[themap roadNameFromEdgePos:rendezvous_point.pos]];
	[self.viewControl setText:@"blah dee blah blah"];
	[self.viewControl initializedMission:self];
}
- (void) startup {
	[self speak:@"Agent, you must find the target before he escapes"];
	[self ticktock];
	FRMapViewController * mv = 
	[[[FRMapViewController alloc] initWithNibName:@"FRMapViewController" bundle:nil] autorelease];
	
	
	[self.viewControl.navigationController pushViewController:mv animated:YES];
	self.viewControl = mv;
	self.viewControl.navigationItem.rightBarButtonItem = 
	[[[UIBarButtonItem alloc] initWithTitle:@"Abort"
									  style:UIBarButtonItemStylePlain
									 target:self
									 action:@selector(abort)] autorelease];
	
	[mv.mapView addAnnotations:points];
	
}
- (void) abort {
	FRSummaryViewController * summary =
	[[FRSummaryViewController alloc] initWithNibName:@"FRSummaryViewController" bundle:nil];
	[self.viewControl.navigationController pushViewController:summary animated:YES];
	self.viewControl.navigationItem.rightBarButtonItem = nil;
	self.viewControl = summary;
	summary.status.text = @"IT WAS ABORT!";
	[summary release];
	[super abort];
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
	NSTimeInterval timeleft;
	if (rendezvous_time) timeleft = [rendezvous_time timeIntervalSinceNow];
	//NSLog(@"timeleft = %f",timeleft);
	
	
	
	
	/* time until van leaves
	 if (timeleft > 0 && current_announcement < [countdown count]) {
		NSArray * count = [countdown objectAtIndex:current_announcement];
		if (timeleft < [[count objectAtIndex:0] floatValue]/5.0){
			current_announcement++;
			[self speak:[count objectAtIndex:1]];
		}
	}
	*/
	
	
	
	
	//the target moves slowly and randomly until he sees you
	newpos = nil;
	if (current_objective < 2){
		newpos = [themap move:target.pos forwardRandomly:target_speed];
	}
	
	NSLog(@"objective = %i, queue = %i",current_objective,[toBeSpoken count]);
	//what objective are we on? (game state)
	switch (current_objective) {
		case 0: //find the target
			
			dist = [latestsearch distanceFromRoot:newpos];
			NSLog(@"dist = %f",dist);
			//during this object, Charlie should talk about stuff
			
			if (dist < 30) {
				current_objective++;
				[self speak:@"He sees you!"];
			}
			
			
			
			
			break;
		case 1: //chase the target down
			newpos = [latestsearch move:target.pos awayFromRootWithDelta:10*target_speed];
			
			dist = [latestsearch distanceFromRoot:newpos];
			
			if (dist < 15) {
				[self speak:@"You almost have him!"];
				ticks++;
				if (ticks>4){
					current_objective++;
					[self speak:@"Shoot him! BANG BANG BANG"]; //randomly miss? press action button
					[self speak:@"Good work. Now grab the device and get back to base"];
					capture_time = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
					rendezvous_time = [[NSDate alloc] initWithTimeIntervalSinceNow:4*60]; //four minutes
				}
			}
			
			if (dist > 100) {
				//you should lose somehow if he gets too far.
				
				//[self speak:@"You are going to lose him."]; //random?
			}
			
			break;
		case 2: //get to the retrieval van
			dist = [rendezvous distanceFromRoot:player.pos];
			if (dist < 30){
				NSLog(@"yesh!");
				[self speak:@"Good work today agent. Head inside for a debriefing."];
				current_objective++;
			} else if (timeleft<0){
				[self speak:@"The van has left. Failed"];
				[self abort];
				return; //probably going to mess something up.
			}
			
			break;
			
		default: //what?
			
			//exit the app somehow without losing the voice.
			//or display the debrief in app??
			
			break;
	}
	
	if (newpos) {
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
- (void) dealloc {
	[start_time release];
	[capture_time release];
	[rendezvous release];
	[rendezvous_time release];
	[target release];
	[hurrylist release];
	[countdown release];
	[super dealloc];
}
@end
