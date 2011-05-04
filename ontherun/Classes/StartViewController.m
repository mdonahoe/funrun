//
//  StartViewController.m
//  ontherun
//
//  Created by Matt Donahoe on 3/14/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "StartViewController.h"
#import "FRBriefingViewController.h"
#import "FRMissionChase.h"
#import "FRMissionOne.h"
#import "FRMissionTwo.h"
#import "FRMissionDownload.h"
#import "LocationPicker.h"

@implementation StartViewController
@synthesize gps,missionLabel,latest_point,distanceLabel,distanceSlider;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		//use toqbot for gps position updates
		m2 = [[toqbot alloc] init];
		[self startStandardUpdates];
		NSLog(@"created!");
	}
    return self;
}
*/
- (IBAction) statechange:(id)sender {
	//when the view gets unloaded and reloaded, gps.on defaults to YES. might want to save it seperately.
	if (gps.on){
		NSLog(@"turning gps on");
		[m2 cancel];
		[self startStandardUpdates];
	} else {
		NSLog(@"GPS OFF");
		[m2 loadObjectForKey:@"userpos" toDelegate:self usingSelector:@selector(updatePosition:)];
		[locationManager stopUpdatingLocation];
	}
}

- (IBAction) sliderchange:(id)sender {
	//update the label according to the slider
    distanceLabel.text = [NSString stringWithFormat:@"%f miles",(int)(distanceSlider.value*10)/10.0];
}
- (void) pickedLocation:(CLLocationCoordinate2D)location{
    [destination release];
    destination = [[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude];
    //destinationLabel.text = 
}
/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	NSLog(@"first view loaded");
	if (nil==m2) m2 = [[toqbot alloc] init];
	[self statechange:self]; //what happens if this gets called twice in a row?
	
    
	[mission release];
	mission = nil;
    
    //do we need to initialize destination to nil?
    //[destination release];
	//destination = nil;
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	NSLog(@"first view unloaded");
}
- (IBAction)loadMissionTwo:(id)sender{
	//have different nibs for different missions?
	//or download from the interwebs?
	if (mission) [mission release];
	mission = [[FRMissionTwo alloc] initWithLocation:self.latest_point viewControl:self];
}
- (IBAction)loadMissionOne:(id)sender{
	//have different nibs for different missions?
	//or download from the interwebs?
	if (mission) [mission release];
	mission = [[FRMissionDownload alloc] initWithLocation:self.latest_point distance:distanceSlider.value destination:destination viewControl:self];
}
- (IBAction) pickDestination:(id)sender{
    FRPoint * extraction_point = [[[FRPoint alloc] initWithName:@"extraction point"] autorelease];
	[extraction_point setCoordinate:latest_point.coordinate];
	
	LocationPicker * lp = 
	[[[LocationPicker alloc] initWithAnnotation:extraction_point delegate:self] autorelease];
	[self.navigationController pushViewController:lp animated:YES];
}
- (void) updatePosition:(id)obj {
	float lat = [[obj objectForKey:@"lat"] floatValue];
	float lon = [[obj objectForKey:@"lon"] floatValue];
	
	self.latest_point = [[[CLLocation alloc] initWithLatitude:lat longitude:lon] autorelease];
	if (mission) [mission newPlayerLocation:self.latest_point];
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
	NSLog(@"recieved timestamp: %f",[newLocation.timestamp timeIntervalSinceNow]);
	if (newLocation.horizontalAccuracy>100.0 || [newLocation.timestamp timeIntervalSinceNow] < -30.0) return;
	if (newLocation.coordinate.latitude==oldLocation.coordinate.latitude && newLocation.coordinate.longitude==oldLocation.coordinate.longitude){
		return;
	}
	
	self.latest_point = newLocation;
	if (mission) [mission newPlayerLocation:self.latest_point];
	
}
- (void)dealloc {
	[missionLabel release];
	self.latest_point = nil;
	if (m2) [m2 cancel];
	[m2 release];
	[locationManager release];
	[mission release];
	[super dealloc];
}
@end
