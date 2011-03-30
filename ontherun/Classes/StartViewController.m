    //
//  StartViewController.m
//  ontherun
//
//  Created by Matt Donahoe on 3/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StartViewController.h"
#import "FRBriefingViewController.h"
#import "FRMissionChase.h"
#import "FRMissionOne.h"
#import "FRMissionTwo.h"
#import "LocationPicker.h"

@implementation StartViewController
@synthesize gps,missionLabel;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
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
	NSLog(@"first view loaded");
	[mission release];
	mission = nil;
	
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
- (void)dealloc {
	[missionLabel release];
    [super dealloc];
}
- (IBAction)loadMissionTwo:(id)sender{
	//have different nibs for different missions?
	//or download from the interwebs?
	if (mission) [mission release];
	mission = [[FRMissionTwo alloc] initWithGPS:gps.on viewControl:self];
}
- (IBAction)loadMissionOne:(id)sender{
	//have different nibs for different missions?
	//or download from the interwebs?
	if (mission) [mission release];
	NSLog(@"gps state = %@",gps);
	mission = [[FRMissionOne alloc] initWithGPS:gps.on viewControl:self];
}
@end
