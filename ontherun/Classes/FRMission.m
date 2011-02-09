//
//  FRMission.m
//  ontherun
//
//  Created by Matt Donahoe on 2/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FRMission.h"
#import "ASIFormDataRequest.h"
#import "JSON.h"

@implementation FRMission

@synthesize points;

- (id) init {
	
	self = [super init];
	if (!self) return nil;
	
	//link to /Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS4.2.sdk/System/Library/PrivateFrameworks/VoiceServices.framework
	voicebot = [[NSClassFromString(@"VSSpeechSynthesizer") alloc] init];
	[voicebot startSpeakingString:@"boop boop beep"];
	[voicebot setDelegate:self];
	
	//communication with server
	m2 = [[toqbot alloc] init];
	
	user = [[FRPoint alloc] initWithDict:[NSDictionary dictionaryWithObject:@"user" forKey:@"name"]];
	
	NSURL * url = [NSURL URLWithString:@"http://toqbot.com/otr/pacman/mission.js"];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request startSynchronous];
	NSError * error = [request error];
	if (!error) {
		NSString * response = [request responseString];
		NSDictionary * data = [response JSONValue];
		
		NSMutableArray * temp = [NSMutableArray arrayWithCapacity:10];
		
		[temp addObject:user];
		for (NSDictionary * dict in [data valueForKey:@"points"]){
			FRPoint * pt = [[FRPoint alloc] initWithDict:dict];
			[temp addObject:pt];
		}
		points = [[NSArray alloc] initWithArray:temp];
	}
	
	url = [NSURL URLWithString:@"http://toqbot.com/otr/mapdata.json"];
	request = [ASIHTTPRequest requestWithURL:url];
	[request startSynchronous];
	error = [request error];
	
	if (!error) {
		NSString * response = [request responseString];
		NSDictionary * data = [response JSONValue];
		themap = [[FRMap alloc] initWithNodes:[data objectForKey:@"nodes"] andRoads:[data objectForKey:@"roads"]];
	}
	
	
	//set the EdgePos for every point (given its latlon)
	for (FRPoint * pt in points){
		NSArray * latlon = [pt.dictme objectForKey:@"pos"];
		if (latlon==nil) continue;
		CLLocation * p = [[CLLocation alloc] initWithLatitude:[[latlon objectAtIndex:0] floatValue]
													longitude:[[latlon objectAtIndex:1] floatValue]];
		pt.pos = [themap edgePosFromPoint:p];
		[p release];
	}
	
	
	//[self startStandardUpdates];
	[self ticktock];
	[m2 loadObjectForKey:@"userpos" toDelegate:self usingSelector:@selector(updatePosition:)];
	return self;
}

- (void) speakString:(NSString *)text {
	[voicebot startSpeakingString:text];
	//NSLog(@"%@",text);
	//[m2 sendObject:text forKey:@"voicebot"];
}
- (void) speechSynthesizer:(NSObject *) synth didFinishSpeaking:(BOOL)didFinish withError:(NSError *) error { 
	// Handle the end of speech here 
	NSLog(@"done speaking");
	//[self performSelector:@selector(speakStatus) withObject:nil afterDelay:1.0];
}
- (void) speakStatus {
	if ([voicebot isSpeaking]) return;
}
- (void) ticktock {
	if (latestsearch==nil) NSLog(@"nilnil");
	
	
	for (FRPoint * pt in points){
		
		if ([pt.title isEqualToString:@"user"]==NO){
			
			//NSLog(@"pt = %@",pt.title);
			if (latestsearch && [latestsearch containsPoint:pt.pos]) {
				//NSLog(@"in path search");
				float dist = [latestsearch distanceFromRoot:pt.pos];
				if (dist < 100) {
					//NSLog(@"less than 100");
					pt.pos = [latestsearch move:pt.pos towardRootWithDelta:10.0];
					//if ([pt.subtitle isEqualToString:@"following"]==NO)
						//[self speakString:[NSString stringWithFormat:@"%@ is following %i meters %@ you",pt.title,(int)dist,[latestsearch directionFromRoot:pt.pos]]];
					pt.subtitle = [NSString stringWithFormat:@"%i m %@",(int)[latestsearch distanceFromRoot:pt.pos],[latestsearch directionFromRoot:pt.pos]];
				} else {
					//NSLog(@" > 100");
					pt.pos = [themap move:pt.pos forwardRandomly:5.0];
					if ([pt.subtitle isEqualToString:@"following"])
						[self speakString:[NSString stringWithFormat:@"You lost %@",pt.title]];
					pt.subtitle = @"random";
				}
			} else {
				//NSLog(@"not in pathsearch");
				pt.pos = [themap move:pt.pos forwardRandomly:3.0];
				if ([pt.subtitle isEqualToString:@"following"])
					[self speakString:[NSString stringWithFormat:@"You lost %@",pt.title]];
				pt.subtitle = @"random";
			}
			
		}
		
		//update 2d coordinate (so the map updates live)
		[pt setCoordinate:[themap coordinateFromEdgePosition:pt.pos]];
		
	}
	
	[self performSelector:@selector(ticktock) withObject:nil afterDelay:0.5];
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
	NSLog(@"newUserLocation: %@",location);
	EdgePos ep = [themap edgePosFromPoint:location];
	if (latestsearch) {
		//we already have a position
		//ensure that the direction of our new point is facing away from the old one.
		user.pos = [latestsearch move:ep awayFromRootWithDelta:0];
	} else {
		user.pos = ep;
	}
	
	[latestsearch release];
	latestsearch = [themap createPathSearchAt:user.pos withMaxDistance:[NSNumber numberWithFloat:200.0]];
}

- (void) dealloc {
	[points release];
	[user release];
	[locationManager stopUpdatingLocation];
	[m2 release];
	[themap release];
	[latestsearch release];
	[voicebot release];
	[super dealloc];
}
@end
