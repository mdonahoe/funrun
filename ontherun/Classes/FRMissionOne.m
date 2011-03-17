//
//  FRMissionOne.m
//  ontherun, turn-by-turn Directives, edge of your seat directions, real-time spoken action movie
//
//  Created by Matt Donahoe on 3/14/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "FRMissionOne.h"
#import "FRFileLoader.h"
//#import "ASIFormDataRequest.h"
#import "JSON.h"
@implementation FRMissionOne


@synthesize points;
- (id) initWithFilename:(NSString *)filename {
	//load the location data from a file. create the mission
	self = [super init];
	if (!self) return nil;
	
	
	//link to /Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS4.2.sdk/System/Library/PrivateFrameworks/VoiceServices.framework
	voicebot = [[NSClassFromString(@"VSSpeechSynthesizer") alloc] init];
	[voicebot setDelegate:self];
	toBeSpoken = [[NSMutableArray alloc] initWithObjects:@"and load",nil];
	
	//communication with server
	m2 = [[toqbot alloc] init];
	
	//init the fileloader so we can skip network downloads if already cached
	NSAutoreleasePool * thepool = [[NSAutoreleasePool alloc] init];
	FRFileLoader * loader = [[FRFileLoader alloc] initWithBaseURLString:@"http://toqbot.com/otr/test1/"];
	
	//load the map
	NSDictionary * mapdata = [[NSString stringWithContentsOfFile:[loader pathForFile:@"mapdata.json"]
														encoding:NSUTF8StringEncoding
														   error:NULL] JSONValue];
	themap = [[FRMap alloc] initWithNodes:[mapdata objectForKey:@"nodes"] andRoads:[mapdata objectForKey:@"roads"]];
	
	[loader deleteCacheForFile:filename];
	NSString * missionstring = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:[loader pathForFile:filename]] encoding:NSUTF8StringEncoding];
	[loader release];
	[thepool release];
	NSDictionary * missiondata = [missionstring JSONValue];
	[missionstring release];
	
	ticks = 0;
	//uhuh
	previously_said = nil;
	target_speed = 1.0;
	start_time = [[NSDate alloc] init]; //is this actually the current time?
	drop_time = [[NSDate alloc] initWithTimeIntervalSinceNow:-10];
	user = [[FRPoint alloc] initWithDict:[NSDictionary dictionaryWithObject:@"user" forKey:@"name"] onMap:themap];
	droppoint = [[FRPoint alloc] initWithDict:[missiondata objectForKey:@"droppoint"] onMap:themap];
	target = [[FRPoint alloc] initWithDict:[missiondata objectForKey:@"target"] onMap:themap];
	pursuer = [[FRPoint alloc] initWithDict:[missiondata objectForKey:@"pursuer"] onMap:themap];
	base = [[FRPoint alloc] initWithDict:[missiondata objectForKey:@"base"] onMap:themap];
	
	points = [[NSArray alloc] initWithObjects:user,droppoint,target,pursuer,base,nil];
	for (FRPoint * pt in points){
		[pt setCoordinate:[themap coordinateFromEdgePosition:pt.pos]];
	}
	
	hurrylist = [[NSArray alloc] initWithArray:[missiondata objectForKey:@"hurrylist"]];
	countdown = [[NSArray alloc] initWithArray:[missiondata objectForKey:@"countdown"]];
	
	//use toqbot for gps position updates
	if (1){
		[m2 loadObjectForKey:@"userpos" toDelegate:self usingSelector:@selector(updatePosition:)];
	} else {
		[self startStandardUpdates];
	}
	[self speak:@"Lock"];
	
	
	current_objective=3;
	
	
	return self;
}
- (void) speak:(NSString *)text {
	//NSLog(@"speak: %@",text);
	//return;
	if ([previously_said isEqualToString:text]) return; //dont repeat yourself
	if ([voicebot isSpeaking]){
		[toBeSpoken addObject:text];
	} else {
		[voicebot startSpeakingString:text];
	}
	[text retain];
	[previously_said release];
	previously_said = text;
}
- (void) speakIfEmpty:(NSString *) text {
	//NSLog(@"speakIfEmpty:%@",text);
	//return;
	if ([previously_said isEqualToString:text]) return; //dont repeat yourself
	if (![voicebot isSpeaking]) {
		[voicebot startSpeakingString:text];
		[text retain];
		[previously_said release];
		previously_said = text;
	}
}
- (void) speechSynthesizer:(NSObject *) synth didFinishSpeaking:(BOOL)didFinish withError:(NSError *) error { 
	// Handle the end of speech here 
	if ([toBeSpoken count]){
		[self speak:[toBeSpoken objectAtIndex:0]];
		[toBeSpoken removeObjectAtIndex:0];
	}
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
	
	NSString * direction;
	
	
	
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
	
	NSLog(@"objective = %i",current_objective);
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
			//todo
			//1. parse the map, getting rid of (null) street names
			//2. detect when he turns around.
			//3. prevent repeating the same shit.
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
	
	//send data to server for viz
	if (0){
		NSMutableDictionary * data = [NSMutableDictionary dictionaryWithCapacity:2];
		CLLocationCoordinate2D targetcoord = [themap coordinateFromEdgePosition:target.pos];
		[data setObject:[NSNumber numberWithInt:current_objective] forKey:@"objective"];
		[data setObject:[NSNumber numberWithFloat:targetcoord.latitude] forKey:@"lat"];
		[data setObject:[NSNumber numberWithFloat:targetcoord.longitude] forKey:@"lon"];
		[m2 sendObject:data forKey:@"mission1_target"];
	} else {
		for (FRPoint * pt in points){
			[pt setCoordinate:[themap coordinateFromEdgePosition:pt.pos]];
		}
	}
	[self performSelector:@selector(ticktock) withObject:nil afterDelay:1.0];
};
- (void) updatePosition:(id)obj {
	
	float lat = [[obj objectForKey:@"lat"] floatValue];
	float lon = [[obj objectForKey:@"lon"] floatValue];
	
	CLLocation * ll = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
	[self newUserLocation:ll];
	[ll release];
	
}
- (void) startStandardUpdates{
    // Create the location manager if this object does not
    // already have one.
    if (nil == locationManager) 
		locationManager = [[CLLocationManager alloc] init];
	
	locationManager.delegate = self;
	locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	
	// Set a movement threshold for new events.
	locationManager.distanceFilter = 1.0;
	
	[locationManager startUpdatingLocation];
}
// Delegate method from the CLLocationManagerDelegate protocol.
- (void) locationManager:(CLLocationManager *)manager
	 didUpdateToLocation:(CLLocation *)newLocation
			fromLocation:(CLLocation *)oldLocation
{
	if (newLocation.horizontalAccuracy>100) return;
	if (newLocation.coordinate.latitude==oldLocation.coordinate.latitude && newLocation.coordinate.longitude==oldLocation.coordinate.longitude){
		NSLog(@"gps update is identical, skipping recalculations");
		return;
	}
	
	[self newUserLocation:newLocation];
	
}
- (void) newUserLocation:(CLLocation *)location {
	/*
	 This method is called whenever a new user location
	 update is available.
	 
	 a new point comes from the network
	 or the gps
	 */
	
	
	//Cancer man
	NSLog(@"newUserLocation: %@",location);
	
	//convert to map coordinates
	FREdgePos * ep = [themap edgePosFromPoint:location];
	
	//say something. helps with gps debugging
	if (arc4random()%10==0) [self speakIfEmpty:@"click"];
	
	//speak the current road, if it changed
	NSString * roadname = [themap roadNameFromEdgePos:ep];
	if ([roadname isEqualToString:current_road]==NO && roadname){
		[roadname retain];
		[current_road release];
		current_road = roadname;
		[self speak:current_road];
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
