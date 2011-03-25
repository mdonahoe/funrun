//
//  LocationPicker.m
//  ontherun
//
//  Created by Matt Donahoe on 3/24/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "LocationPicker.h"


@implementation LocationPicker
@synthesize mapView;
- (id) initWithAnnotation:(id <MKAnnotation>)center delegate:(id)d{
	self = [super initWithNibName:@"LocationPicker" bundle:nil];
	if (!self) return nil;
	[center retain];
	pt = center;
	//pt.subtitle = @"Drag to new location";
	self.navigationItem.rightBarButtonItem =
	[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(donePicking)] autorelease];
	
	delegate = d;
	return self;
	
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	MKCoordinateRegion newRegion;
    newRegion.center.latitude = pt.coordinate.latitude;
    newRegion.center.longitude = pt.coordinate.longitude;
    newRegion.span.latitudeDelta = 0.05;
    newRegion.span.longitudeDelta = 0.05;
    [mapView setRegion:newRegion animated:YES];
	[mapView addAnnotation:pt];
}
- (void) donePicking {
	NSLog(@"done picking");
	[self.navigationController popViewControllerAnimated:NO];
	[delegate pickedLocation:pt.coordinate];
	
}
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/
- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation{
	static NSString* pinIdentifier = @"I love pins!";
	NSLog(@"annotation view");
	MKPinAnnotationView* pinView = (MKPinAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:pinIdentifier];
	
	if (!pinView){
		
		MKPinAnnotationView * myPinView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pinIdentifier] autorelease];
		myPinView.animatesDrop = YES;
		myPinView.canShowCallout = YES;
		myPinView.draggable = YES;
		myPinView.pinColor = MKPinAnnotationColorPurple;
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


- (void)dealloc {
	[mapView release];
	[pt release];
	NSLog(@"I pick my nose");
    [super dealloc];
}


@end
