//
//  FRMissionTwo.m
//  ontherun
//
//  Created by Matt Donahoe on 3/21/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "FRMissionTwo.h"
#import "FRSummaryViewController.h"
#import "FRBriefingViewController.h"
#import "FRMapViewController.h"
#import "LocationPicker.h"

@implementation FRMissionTwo
- (id)initWithLocation:(CLLocation *)l viewControl:(UIViewController *)vc{
	self = [super initWithLocation:l viewControl:vc];
	if (!self) return nil;
	[self.viewControl setText:@"SWEET"];
	return self;
}

- (void) ticktock {

	//anounce time remaining
	//announce closest cop
	//move cops toward their lastknown location
	if (healthpoints < 0) return;
	
	for (FRPoint * cop in enemies){
		FREdgePos * newpos;
		float dist = [latestsearch distanceFromRoot:cop.pos];
		if (dist <100){
			
			if (dist < 30 && arc4random()%4==0){
				[self speak:@"bang"];
				if (arc4random()%10==0){
					[self speak:@"you've been shot"];
					healthpoints--;
					if (healthpoints<0){
						[self speak:@"you are dead. mission failed"];
					}
				}
			} else {
				if (ABS([lastseen_date timeIntervalSinceNow]) > 30) [self speak:@"they see you. RUN!"];
			}
			
			[latestsearch retain];
			[lastseen_pos release];
			lastseen_pos = latestsearch;
			
			[lastseen_date release];
			lastseen_date = [[NSDate alloc] init]; //now
			
		}
		NSTimeInterval timesince = ABS([lastseen_date timeIntervalSinceNow]);
		float myradius = [lastseen_pos distanceFromRoot:cop.pos];
		NSLog(@"last seen %i seconds ago",(int)timesince);
		if (myradius > 2.0*timesince){ //move into the radius of possible movement
			newpos = [lastseen_pos move:cop.pos towardRootWithDelta:2.0];
			cop.subtitle = @"chasing";
		} else {//otherwise, search randomly
			cop.subtitle = @"searching";
			newpos = [themap move:cop.pos forwardRandomly:1.0];
		}
		
		
		//somehow sort the cops by their distances and announce them
		cop.pos = newpos;
		
	}
	
	int timeleft = (int)[deadline timeIntervalSinceNow];
	switch (timeleft) {
		case 120:
			[self speak:@"two minutes"];
			break;
		case 60:
			[self speak:@"one minute"];
			break;
		case 30:
			[self speak:@"thirty seconds left. move it!"];
			break;
		case 15:
			[self speak:@"fifteen seconds"];
			break;
		case 10:
			[self speak:@"ten"];
			break;
		case 7:
			[self speak:@"you're not gonna make it"];
			break;
		default:
			if (timeleft<6){
				[self speak:[NSString stringWithFormat:@"%i",timeleft]];
			}
			break;
	}
	float goal = [extraction distanceFromRoot:player.pos];
	
	if (goal < 30){
		[self speak:@"you made it. mission complete"];
	} else {
		NSString * direction = [extraction directionToRoot:player.pos];
		NSLog(@"direct = %@",direction);
		[self speak:direction];
	}
	//[self speak:[extraction directionToRoot:player.pos]];
	NSLog(@"you are %i meters from the extraction point",(int)goal);
	[super ticktock];
	
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
	
	FRPoint * extraction_point = [[[FRPoint alloc] initWithName:@"extraction point"] autorelease];
	[extraction_point setCoordinate:[themap coordinateFromEdgePosition:player.pos]];
	
	LocationPicker * lp = 
	[[[LocationPicker alloc] initWithAnnotation:extraction_point delegate:self] autorelease];
	[self.viewControl.navigationController pushViewController:lp animated:YES];
}
- (void) pickedLocation:(CLLocationCoordinate2D)location {
	//the location picker has returned a lat-lon for the destination coordinate.
	//use it to finish building the mission map.
	//make it so that cops are positioned along the way.
	
	
	NSLog(@"location has been picked");
	//[self.viewControl.navigationController popViewControllerAnimated:YES];
	CLLocation * l = [[[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude] autorelease];
	FRPoint * extraction_point = [[[FRPoint alloc] initWithName:@"extraction point"] autorelease];
	extraction_point.pos = [themap edgePosFromPoint:l];
	extraction = [themap createPathSearchAt:extraction_point.pos withMaxDistance:[NSNumber numberWithFloat:1450.0]];
	[points addObject:extraction_point];
	
	enemies = [[NSMutableArray alloc] init];
	for (int i=0;i<4;i++){
		FRPoint * cop = [[FRPoint alloc] initWithName:@"cop"];
		cop.pos = [themap move:player.pos forwardRandomly:1000.0];
		[self speak:[NSString stringWithFormat:@"one is on %@",[themap roadNameFromEdgePos:cop.pos]]];
		[enemies addObject:cop];
		[points addObject:cop]; //display the on the map
		[cop release];
	}
	for (FRPoint * pt in points){
		[pt setCoordinate:[themap coordinateFromEdgePosition:pt.pos]];
	}
	
	[self.viewControl setDest:[themap roadNameFromEdgePos:extraction_point.pos]];
	[self.viewControl initializedMission:self];
}
- (void) startup {
	[self speak:@"the cops have been alerted of your location"];
	[latestsearch retain];
	lastseen_pos = latestsearch;
	lastseen_date = [[NSDate alloc] init];
	deadline = [[NSDate alloc] initWithTimeIntervalSinceNow:360.0];
	[self speak:[NSString stringWithFormat:@"You have 6 minutes to get to the extraction point on %@",[themap descriptionOfEdgePos:extraction.root]]];
	[self speak:@"good luck and get moving"];
	
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
- (void) dealloc {
	[enemies release];
	[lastseen_pos release];
	[lastseen_date release];
	[deadline release];
	[extraction release];
	NSLog(@"mission dealloc'd");
	[super dealloc];
}
@end