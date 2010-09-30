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
	[bot startSpeakingString:@"HELLO WORLD. I love you"];
	//[self startStandardUpdates];
	toqbotrev=-1;
	[self gettoqbot];
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
	[bot startSpeakingString:[data valueForKey:@"data"]];
	[self gettoqbot];
	//NSLog(@"request success %@",[[request responseString] JSONValue]);
	
}
-(void) requestFailed:(ASIHTTPRequest *) request {
	NSLog(@"request error %@",[request error]);
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
	int meters = (int)[self distanceBetweenLocation:newLocation AndLocation:oldLocation];
	[bot startSpeakingString:[NSString stringWithFormat:@"You went %i meters",meters]];
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
	//error!
}
- (float) distanceBetweenLocation:(CLLocation *)pos1 AndLocation:(CLLocation *)pos2{
	const float toRad = 3.14159265/180.0;
	const float R = 6371; //earth radius (km)
	
	float lat1 = pos1.coordinate.latitude*toRad;
	float lat2 = pos2.coordinate.latitude*toRad;
	float lon1 = pos1.coordinate.longitude*toRad;
	float lon2 = pos2.coordinate.longitude*toRad;
	
	float dlat = lat2-lat1;
	float dlon = lon2-lon1;
	
	float a = sin(dlat/2)*sin(dlat/2)+cos(lat1)*cos(lat2)*sin(dlon/2)*sin(dlon/2);
	float c = 2 * atan2(sqrt(a),sqrt(1-a));
	
	return R * c;
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