    //
//  FRMapViewController.m
//  ontherun
//
//  Created by Matt Donahoe on 2/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FRMapViewController.h"
#import "FRMissionTwo.h"
#import "FRSummaryViewController.h"



@implementation FRMapViewController
@synthesize mapView,timer;

- (void)gotoLocation
{
    // start off by default in San Francisco
    MKCoordinateRegion newRegion;
    newRegion.center.latitude = 42.367179;
    newRegion.center.longitude = -71.097939;
    newRegion.span.latitudeDelta = 0.05;
    newRegion.span.longitudeDelta = 0.05;
	
    [self.mapView setRegion:newRegion animated:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	NSLog(@"map loaded");
	[super viewDidLoad];
	self.mapView.mapType = MKMapTypeStandard;
	mission = [[FRMissionTwo alloc] init];
	mission.delegate = self;
	[self gotoLocation];
}
- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation{
	static NSString* pinIdentifier = @"I love pins!";
	NSLog(@"annotation view");
	MKPinAnnotationView* pinView = (MKPinAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:pinIdentifier];
	
	if (!pinView){
		MKPinAnnotationView * myPinView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pinIdentifier] autorelease];
		myPinView.animatesDrop = YES;
		myPinView.canShowCallout = YES;
		myPinView.pinColor = MKPinAnnotationColorGreen;
		return myPinView;
	}
	
	pinView.annotation = annotation;
	return pinView;
}
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) missionInitialized {
	[self.mapView addAnnotations:mission.points];
	timer.text = @"READY";
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"start"
																			   style:UIBarButtonItemStyleDone
																			  target:self
																			  action:@selector(startButton)] autorelease];
}
- (void) startButton {
	[mission startup];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Abort"
																			   style:UIBarButtonItemStylePlain
																			  target:self
																			  action:@selector(abortButton)] autorelease];
}
- (void) abortButton {
	self.navigationItem.rightBarButtonItem = nil;
	[mission abort];
	[self missionEndedWithString:@"Aborted"];
}
- (void) missionTick {
	NSLog(@"update view");
	timer.text = @"in progress";
}
- (void) missionEndedWithString:(NSString *)status {
	[mission release];
	mission = nil;
	timer.text = status;
	FRSummaryViewController * summary =
	[[FRSummaryViewController alloc] initWithNibName:@"FRSummaryViewController" bundle:nil];
	[self.navigationController pushViewController:summary animated:YES];
	summary.status.text = status;
	[summary release];
}
- (void)dealloc {
	mapView = nil;
	timer = nil;
	[mission release];
    [super dealloc];
}
//currently unused
-(void)zoomToFitMapAnnotations {
	if([mapView.annotations count] < 2)
	return;

	CLLocationCoordinate2D topLeftCoord;
	topLeftCoord.latitude = -90;
	topLeftCoord.longitude = 180;

	CLLocationCoordinate2D bottomRightCoord;
	bottomRightCoord.latitude = 90;
	bottomRightCoord.longitude = -180;

	for(FRPoint * annotation in mapView.annotations) {
		topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
		topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);

		bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
		bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
	}

	MKCoordinateRegion region;
	region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
	region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
	region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1; // Add a little extra space on the sides
	region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1; // Add a little extra space on the sides

	region = [mapView regionThatFits:region];
	[mapView setRegion:region animated:YES];
}
@end
