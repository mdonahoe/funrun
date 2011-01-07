//
//  FirstViewController.m
//  funrun
//
//  Created by Matt Donahoe on 9/30/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "FirstViewController.h"
#import "ASIFormDataRequest.h"
#import "JSON.h"
#import "SoundEffect.h"
#define ARC4RANDOM_MAX      0x100000000
@implementation FirstViewController


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	bot = [[NSClassFromString(@"VSSpeechSynthesizer") alloc] init];
	[self speak:@"Fun run activated."];
	toqbotkeys = [[NSMutableDictionary alloc] init];
	NSNumber * latest = [NSNumber numberWithInt:-1];
	[toqbotkeys setObject:latest forKey:@"voicetest"];
	[toqbotkeys setObject:latest forKey:@"soundfileurl"];
	goal = nil;
	current = nil;
	deadline = nil;
	mute = NO;
	sending = NO;
	[self startStandardUpdates];
	[self loadsounds];
	[ASIHTTPRequest setDefaultTimeOutSeconds:50];
	[self gettoqbot];
	
}
-(void) sendGPSCoordToServer:(CLLocation*)coord {
	//extract and prepare the data
	NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithCapacity:4];
	[dict setObject:[NSNumber numberWithFloat:coord.coordinate.latitude] forKey:@"lat"];
	[dict setObject:[NSNumber numberWithFloat:coord.coordinate.longitude] forKey:@"lon"];
	[dict setObject:[NSNumber numberWithFloat:coord.horizontalAccuracy] forKey:@"acc"];
	[dict setObject:[NSNumber numberWithDouble:[coord.timestamp timeIntervalSinceReferenceDate]] forKey:@"time"];
	
	NSString * data = [dict JSONRepresentation];
	[dict release];
	
	//create the POST request
	NSURL * url = [NSURL URLWithString:@"http://toqbot.com/db/"];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request setPostValue:data forKey:@"GPStest2"];
	
	//set the correct callback and send to server
	[request setDidFinishSelector:@selector(sentGPS:)];
	[request setDidFailSelector:@selector(sentGPS:)];
	[request setDelegate:self];
	[request startAsynchronous];
	
}
-(void) sentGPS:request {
	sending = NO;
}
-(void) loadsounds {
	NSString * sound_names[] = {
		@"DingLing",
		@"lion1",
		@"panther3",
	};
	
	SoundEffect * loaded_sound;
	sounds = [[NSMutableDictionary alloc] initWithCapacity:10];
	for (int i=0;i<3;i++){
		loaded_sound = [[SoundEffect alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:sound_names[i] ofType:@"wav"]];
		[sounds setObject:loaded_sound forKey:sound_names[i]];
		[loaded_sound release];
	}
}
- (void)gettoqbot {
	//get the path we are going to run
	NSMutableString *resultString = [NSMutableString string];
	for (NSString* key in [toqbotkeys allKeys]){
		if ([resultString length]>0)
			[resultString appendString:@"&"];
		[resultString appendFormat:@"%@=%@", key, [toqbotkeys objectForKey:key]];
	}
	NSString * url = [NSString stringWithFormat:@"http://toqbot.com/db/?%@",resultString];
	ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
	[request setDelegate:self];
	[request startAsynchronous];
}
- (void) requestFinished:(ASIHTTPRequest *) request {
	NSArray * docs = [[request responseString] JSONValue];
	for (NSDictionary * data in docs){
		int rev = [[data valueForKey:@"rev"] intValue]+1;
		NSString * key = [data valueForKey:@"key"];
		[toqbotkeys
		 setObject:[NSNumber numberWithInt:rev]
		 forKey:key];
		if (mute) continue;
		if ([data objectForKey:@"data"]==nil) continue;
		
		if ([key isEqualToString:@"voicetest"]) {
			[self speak:[data objectForKey:@"data"]];
		} else if ([key isEqualToString:@"soundfileurl"]) {
			[[sounds objectForKey:[data objectForKey:@"data"]] play];
		}
	}
	[self gettoqbot];
}
-(void) requestFailed:(ASIHTTPRequest *) request {
	//NSLog(@"request error %@",[request error]);
	[self gettoqbot];
}
- (void)startStandardUpdates
{
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
- (void)locationManager:(CLLocationManager *)manager
didUpdateToLocation:(CLLocation *)newLocation
fromLocation:(CLLocation *)oldLocation
{
	if (newLocation.horizontalAccuracy>100) return;
	[newLocation retain];
	[current release];
	current = newLocation;
	if (sending==NO) [self sendGPSCoordToServer:current];
	
}

- (void) newGoal {
	[goal release];
	[deadline release];
	NSDictionary * pt = [points objectAtIndex:0];
	goal = [[CLLocation alloc] initWithLatitude:[[pt objectForKey:@"lat"] floatValue] longitude:[[pt objectForKey:@"lon"] floatValue]];
	deadline = [[NSDate alloc] initWithTimeIntervalSinceNow:[[pt objectForKey:@"time"] intValue]];
	if ([points count]>1) [points removeObjectAtIndex:0];
	//[self speak:[NSString stringWithFormat:@"%i points left",[points count]]];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
	//error!
}

-(void) speak:(NSString*)message {
	[bot startSpeakingString:message];
}
-(void) status {
	if (current!=nil){
		if (goal==nil) [self newGoal];
		NSTimeInterval timeleft = [deadline timeIntervalSinceDate:[NSDate date]];
		float dx = goal.coordinate.longitude - current.coordinate.longitude;
		float dy = goal.coordinate.latitude - current.coordinate.latitude;
		float m = sqrt(dx*dx+dy*dy);
		NSString * direction = @"";
		if (fabs(dx)+fabs(dy)>1.25*m) {
			if (dy>0){
				if (dx>0){
					direction = @"North-east";
				} else {
					direction = @"North-west";
				}
			} else {
				if (dx>0){
					direction = @"South-east";
				} else {
					direction = @"South-west";
					
				}				
			}
		} else {
			if (fabs(dx)>fabs(dy)){
				if (dx>0){
					direction = @"East";
				} else {
					direction = @"West";
				}
			} else {
				if (dy>0){
					direction = @"North";
				} else {
					direction = @"South";
				}
			}	
		}
		CLLocationDistance dist = [current distanceFromLocation:goal];
		if (dist<10){
			[self speak:@"Success."];
			[self newGoal];
		} else if (timeleft<=0) {
			[self speak:@"Failure"];
			[self newGoal];
		//} else if (dist>100) {
		//	[self speak:@"Out of range"];
		//	[self newGoal];
		} else {
			[self speak:[NSString stringWithFormat:@"%i seconds. %i meters %@",(int)timeleft,(int)dist,direction]];
		}
	
	} else {
		[self speak:@"Acquiring your location."];
	}
	[self performSelector:@selector(status) withObject:nil afterDelay:5];
}
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}
-(IBAction)clickmute:(id)sender{
	NSLog(@"clickmute!");
	if(mute){
		mute = NO;
	} else {
		mute = YES;
	}
}
@end