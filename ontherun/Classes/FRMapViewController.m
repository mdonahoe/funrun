    //
//  FRMapViewController.m
//  ontherun
//
//  Created by Matt Donahoe on 2/7/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "FRMapViewController.h"
#import "FRPoint.h"
#import "TheCarMission.h"
#import "TheKeyMission.h"

@implementation FRMapViewController
@synthesize latest_point;

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return YES;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    return YES;
}

- (id) initWithMission:(NSString *)missionclass{
    self = [super initWithNibName:@"FRMapViewController" bundle:nil];
    if (!self) return nil;
    //42.367062, -71.09813
    self.latest_point = [[[CLLocation alloc] initWithLatitude:42.367062 longitude:-71.09813] autorelease];
    
    missionclassname = missionclass;
    
    [self gotoLocation];
    
    return self;
}
- (void) didTapMap:(UIGestureRecognizer *) sender {
    //they double tapped. Find the location
    NSLog(@"tapped");
    CGPoint loc = [sender locationInView:self.view];
    CLLocationCoordinate2D ll = [(MKMapView*)self.view convertPoint:loc toCoordinateFromView:self.view];
    self.latest_point = [[[CLLocation alloc] initWithLatitude:ll.latitude longitude:ll.longitude] autorelease];
    if (mission) [mission newPlayerLocation:self.latest_point];
    
    
}
- (void)viewDidDisappear:(BOOL)animated {
    NSLog(@"disappear");
    [NSObject cancelPreviousPerformRequestsWithTarget:mission];
    [mission release];
    mission = nil;
}
- (void)gotoLocation
{
    // start off by default in San Francisco
    MKCoordinateRegion newRegion;
    newRegion.center.latitude = self.latest_point.coordinate.latitude;
    newRegion.center.longitude = self.latest_point.coordinate.longitude;
    newRegion.span.latitudeDelta = 0.05;
    newRegion.span.longitudeDelta = 0.05;
	
    [(MKMapView*)self.view setRegion:newRegion animated:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	NSLog(@"map loaded");
	[super viewDidLoad];
	((MKMapView*)self.view).mapType = MKMapTypeStandard;
	[self gotoLocation];
    
    
    UITapGestureRecognizer* tapRec = [[UITapGestureRecognizer alloc] 
                                      initWithTarget:self action:@selector(didTapMap:)];
    
    
    [(MKMapView*)self.view addGestureRecognizer:tapRec];
    [tapRec release];
    
    
    mission = [[NSClassFromString(missionclassname) alloc] initWithLocation:self.latest_point
                                                                         distance:1000
                                                                      destination:nil
                                                                      viewControl:self];
    
    
    [(MKMapView*)self.view addAnnotations:mission.points];
}
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return YES;
}
- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation{
	NSString * pinIdentifier = ((FRPoint *) annotation).pinColor;
	
    
    MKPinAnnotationView * pinView = (MKPinAnnotationView *) [theMapView dequeueReusableAnnotationViewWithIdentifier:pinIdentifier];
	
	if (!pinView){
		MKPinAnnotationView * myPinView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pinIdentifier] autorelease];
		myPinView.animatesDrop = YES;
		myPinView.canShowCallout = YES;
		
        if ([pinIdentifier isEqualToString:@"green"]) myPinView.pinColor = MKPinAnnotationColorGreen;
        if ([pinIdentifier isEqualToString:@"purple"]) myPinView.pinColor = MKPinAnnotationColorPurple;
        
        
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
	self.latest_point = nil;
    [mission release];
	[super dealloc];
}
@end
