//
//  RootViewController.m
//  ontherun
//
//  Created by Matt Donahoe on 1/5/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "RootViewController.h"
#import "FRMapViewController.h"
#import "FRPoint.h"
#import "FRTrigger.h"

#define ARC4RANDOM_MAX      0x100000000
@implementation RootViewController

#pragma mark -
#pragma mark View lifecycle

- (void) viewDidLoad {
    [super viewDidLoad];
	self.title = @"On The Run";
	// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	//give the mission object to the view. the view looks at the contents of the mission object.
	if (!themission) themission = [[FRMission alloc] init];
	if (!triggers) triggers = [[NSArray alloc] init];
	if (!messages) messages = [[NSArray alloc] init];
	
}



#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}
// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return [triggers count];
		case 1:
			return [themission.points count];
		case 2:
			return [messages count];
	}
	return 0;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	switch (section) {
		case 0:
			return @"Triggers";
		case 1:
			return @"Points";
		case 2:
			return @"Messages";
	}
	
	return @"default";
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	FRTrigger * trig;
	FRPoint * pt;
	switch ([indexPath section]){
		case 0:
			trig = [triggers objectAtIndex:[indexPath row]];
			if (trig.active) cell.textLabel.textColor = [UIColor redColor];
			else cell.textLabel.textColor = [UIColor blackColor];
			cell.textLabel.text = [trig displayname];
			break;
		case 1:
			cell.textLabel.textColor = [UIColor blackColor];
			pt = [themission.points objectAtIndex:[indexPath row]];
			cell.textLabel.text = [NSString stringWithFormat:@"%@",pt.title];
			break;
		case 2:
			cell.textLabel.textColor = [UIColor blackColor];
			cell.textLabel.text = [NSString stringWithFormat:@"%@",[messages objectAtIndex:[indexPath row]]];
			break;
	}

	return cell;
	
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	
	FRMapViewController * detailViewController = [[FRMapViewController alloc] initWithNibName:@"FRMapViewController" bundle:nil];
	[self.navigationController pushViewController:detailViewController animated:YES];
	[detailViewController.mapView addAnnotations:themission.points];
	[detailViewController release];	
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	NSLog(@"rootviewcontroller unloaded");
}


- (void)dealloc {
	[triggers release];
	[themission release];
	[messages release];
    [super dealloc];
}




@end

