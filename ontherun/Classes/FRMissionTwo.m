//
//  FRMissionTwo.m
//  ontherun
//
//  Created by Matt Donahoe on 3/21/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "FRMissionTwo.h"
#import "FRSummaryViewController.h"

@implementation FRMissionTwo
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

- (void) initWithStart:(FREdgePos*)start{
	//called after the mission figures out the users location
	[self speak:@"the cops have been alerted of your location"];
	
	//last known position
	[latestsearch retain];
	lastseen_pos = latestsearch;
	lastseen_date = [[NSDate alloc] init];
	
	enemies = [[NSMutableArray alloc] init];
	for (int i=0;i<4;i++){
		FRPoint * cop = [[FRPoint alloc] initWithName:@"cop"];
		cop.pos = [themap move:player.pos forwardRandomly:1000.0];
		[self speak:[NSString stringWithFormat:@"one is on %@",[themap roadNameFromEdgePos:cop.pos]]];
		[enemies addObject:cop];
		[points addObject:cop]; //display the on the map
		[cop release];
	}
	
	
	FRPoint * extraction_point = [[FRPoint alloc] initWithName:@"extraction point"];
	extraction_point.pos = [latestsearch move:player.pos awayFromRootWithDelta:1450.0];
	extraction = [themap createPathSearchAt:extraction_point.pos withMaxDistance:[NSNumber numberWithFloat:1450.0]];
	[points addObject:extraction_point];
	[extraction_point release];
	
	//cops could exit buildings, or be in cars
	//the map isnt going to have a points until this is called. connect to the MKMapView somehow?
	
	//(id)initWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action

	
	[super initWithStart:start];
}
- (void) startup {
	NSLog(@"booooooom");
	deadline = [[NSDate alloc] initWithTimeIntervalSinceNow:360.0];
	[self speak:[NSString stringWithFormat:@"You have 6 minutes to get to the extraction point on %@",[themap descriptionOfEdgePos:extraction.root]]];
	[self speak:@"good luck and get moving"];
	[self ticktock];
}
- (void) abort {
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[toBeSpoken removeAllObjects];
	[voicebot setDelegate:nil];
	[self speak:@"Mission Aborted"];
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
