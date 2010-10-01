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
#define ARC4RANDOM_MAX      0x100000000
@implementation FirstViewController


/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	bot = [[NSClassFromString(@"VSSpeechSynthesizer") alloc] init];
	[self speak:@"Fun run activated."];
	
	toqbotrev=-1;
	goal = nil;
	current = nil;
	deadline = nil;
	[self startStandardUpdates];
	[ASIHTTPRequest setDefaultTimeOutSeconds:50];
	[self gettoqbot];
	[self status];
}
- (void)gettoqbot {
	NSString * url = [NSString stringWithFormat:@"http://toqbot.com/db/?voicetest=%i",toqbotrev];
	ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
	[request setDelegate:self];
	[request startAsynchronous];
}
- (void) requestFinished:(ASIHTTPRequest *) request {
	NSDictionary * data = [[[request responseString] JSONValue] objectAtIndex:0];
	toqbotrev = [(NSInteger)[data valueForKey:@"rev"] intValue]+1;
	[self speak:[data valueForKey:@"data"]];
	[self gettoqbot];
	//NSLog(@"request success %@",[[request responseString] JSONValue]);
	
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
}
- (void) newGoal {
	[goal release];
	[deadline release];
	double x = (double)arc4random() / ARC4RANDOM_MAX - 0.5;
	double y = (double)arc4random() / ARC4RANDOM_MAX - 0.5;
	double m = sqrt(x*x+y*y+.000001);
	goal = [[CLLocation alloc] initWithLatitude:(current.coordinate.latitude+.001*x/m) longitude:(current.coordinate.longitude+.001*y/m)];
	deadline = [[NSDate alloc] initWithTimeIntervalSinceNow:60];
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
		//NSLog(@"distance: %@ and %@",goal,current);
		if (dist<10){
			[self speak:@"Success."];
			[self newGoal];
		} else if (timeleft<=0) {
			[self speak:@"Failure"];
			[self newGoal];
		} else if (dist>100) {
			[self speak:@"Out of range"];
			[self newGoal];
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

@end