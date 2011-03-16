    //
//  StartViewController.m
//  ontherun
//
//  Created by Matt Donahoe on 3/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StartViewController.h"
#import "FRMapViewController.h"

@implementation StartViewController

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
	if (!missionid){
		missionLabel.text = @"Mission One";
		[self setMission:@"mission_one2.js"];
	} else {
		missionLabel.text = [NSString stringWithFormat:@"mission = %@",missionid];
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}
- (IBAction)doAction:(id)sender{
	NSLog(@"clicked");
	if (!missionid) return;
	themission = [[FRMissionOne alloc] initWithFilename:missionid];
	NSLog(@"points = %i",[themission.points count]);
	FRMapViewController * detailViewController = [[FRMapViewController alloc] initWithNibName:@"FRMapViewController" bundle:nil];
	[self.navigationController pushViewController:detailViewController animated:YES];
	NSLog(@"map view = %@",detailViewController.mapView);
	[detailViewController.mapView addAnnotations:themission.points];
	[detailViewController release];	
	
}
- (void) setMission:(NSString *)m {
	[m retain];
	[missionid release];
	missionid = m;
	
}
@end
