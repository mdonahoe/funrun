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
#import "TheCarMission.h"
#import "TheKeyMission.h"
#import "LocationPicker.h"

@implementation StartViewController
@synthesize DestinationButton;
@synthesize StartButton;
@synthesize centerLabel;
@synthesize gps,missionLabel,latest_point,distanceLabel,distanceSlider;

- (id) initWithMissionData:(NSDictionary *)obj {
    self = [super initWithNibName:@"StartView" bundle:nil];
    if (!self) return nil;
    
    [obj retain];
    missionData = obj;
    latest_point = nil;
    destination = nil;
    return self;
}
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
    distanceLabel.text = [NSString stringWithFormat:@"%f km",(int)(distanceSlider.value*10)/10.0];
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

- (void) viewWillAppear:(BOOL)animated {
    
    if (mission) {
        [NSObject cancelPreviousPerformRequestsWithTarget:mission];
        NSLog(@"mission about to be released, retains = %i",[mission retainCount]);
        [mission saveMissionStats:@"canceled"];
        [mission release];
        mission = nil;
    }
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
    [self setDestinationButton:nil];
    [self setStartButton:nil];
    [self setCenterLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	NSLog(@"first view unloaded");
}
- (IBAction)startMission:(id)sender{
	//load the custom class using the class name in missionData
    if (latest_point==nil) return;
    
    NSLog(@" latest point = %@",latest_point);
        
    if (mission) {
        [NSObject cancelPreviousPerformRequestsWithTarget:mission];
        [mission release];
        mission = nil;
    }
    mission = [[NSClassFromString([missionData objectForKey:@"class"]) alloc] initWithLocation:self.latest_point
                                                                                      distance:distanceSlider.value
                                                                                   destination:destination
                                                                                   viewControl:self];
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
	
	
    CLLocation * newLocation = [[[CLLocation alloc] initWithLatitude:lat longitude:lon] autorelease];
    [self updateLocation:newLocation];
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
	if (newLocation.horizontalAccuracy>100.0 || [newLocation.timestamp timeIntervalSinceNow] < -30.0) return;
	if (newLocation.coordinate.latitude==oldLocation.coordinate.latitude && newLocation.coordinate.longitude==oldLocation.coordinate.longitude){
		return;
	}
	NSLog(@"recieved timestamp: %f",[newLocation.timestamp timeIntervalSinceNow]);
	
    
    [self updateLocation:newLocation];
	
}
- (void) updateLocation:(CLLocation *)location {
    if (self.latest_point==nil){
        self.centerLabel.text = @"";
        self.DestinationButton.hidden=NO;
        self.StartButton.hidden=NO;
    }
    self.latest_point = location;
    if (mission) [mission newPlayerLocation:self.latest_point];
}
- (void)dealloc {
	[missionLabel release];
	self.latest_point = nil;
	if (m2) [m2 cancel];
	[m2 release];
	[locationManager release];
	[mission release];
    [DestinationButton release];
    [StartButton release];
    [centerLabel release];
	[super dealloc];
    NSLog(@"start view dead");
}
@end
