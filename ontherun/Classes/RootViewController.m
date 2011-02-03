//
//  RootViewController.m
//  ontherun
//
//  Created by Matt Donahoe on 1/5/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "RootViewController.h"
#import "ASIFormDataRequest.h"
#import "JSON.h"
#import "SoundEffect.h"
#import "FRTrigger.h"
#import "MapViewController.h"

#define ARC4RANDOM_MAX      0x100000000
@implementation RootViewController

#pragma mark -
#pragma mark stuff that shouldnt be here
- (void) ticktock {
	if (latestsearch==nil) NSLog(@"nilnil");
	
	NSMutableDictionary * positions = [NSMutableDictionary dictionary];
	
	for (FRPoint * pt in points){
		
		NSString * status = @"chillin";
		
		if ([pt.name isEqualToString:@"user"]==nil){
			if (latestsearch!=nil && [latestsearch containsPoint:pt.pos] && [latestsearch distanceFromRoot:pt.pos]<300) {
				pt.pos = [latestsearch move:pt.pos towardRootWithDelta:20.0];
				status = @"following";
			} else {
				pt.pos = [themap move:pt.pos forwardRandomly:10.0];
				status = @"random";				
			}
		}
		NSArray * ep = [NSArray arrayWithObjects:
						[NSNumber numberWithInt:pt.pos.start],
						[NSNumber numberWithInt:pt.pos.end],
						[NSNumber numberWithFloat:pt.pos.position],
						status,
						nil];
		
		[positions setObject:ep forKey:[NSString stringWithFormat:@"%@_pos",pt.name]];
		
	}
	
	//send the current position of each item to the server
	[m2 sendDictionary:positions];
	
	for (FRTrigger * trig in triggers){
		//[trig ticktock];
	}
	
	[self performSelector:@selector(ticktock) withObject:nil afterDelay:1.0];
	[self.tableView reloadData];
};
- (void)updatePosition:(id)obj {
	
	float lat = [[obj objectForKey:@"lat"] floatValue];
	float lon = [[obj objectForKey:@"lon"] floatValue];
	
	CLLocation * ll = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
	[self newUserLocation:ll];
	[ll release];
	
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
	[self newUserLocation:newLocation];
	
}
- (void) newUserLocation:(CLLocation *)location {
	NSLog(@"newUserLocation: %@",location);
	user.pos = [themap edgePosFromPoint:location];
	latestsearch = [themap createPathSearchAt:user.pos];
	
	for (FRPoint * pt in points){
		//pt.pos = [latestsearch move:pt.pos toward]
	}
	
	for (FRTrigger * trig in triggers){
		//[trig checkdistancefrom:location];
	}
}
- (void) triggered {
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark View lifecycle



- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"On The Run";
	healthbar = 100;
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	//link to /Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS4.2.sdk/System/Library/PrivateFrameworks/VoiceServices.framework
	//voicebot = [[NSClassFromString(@"VSSpeechSynthesizer") alloc] init];
	//[voicebot startSpeakingString:@"I have loaded"];
	
	
	//communication with server
	m2 = [[toqbot alloc] init];
	
	triggers = nil;
	points = nil;
	user = [[FRPoint alloc] initWithDict:[NSDictionary dictionaryWithObject:@"user" forKey:@"name"]];
	
	NSURL * url = [NSURL URLWithString:@"http://toqbot.com/otr/pacman/mission.js"];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request startSynchronous];
	NSError *error = [request error];
	if (!error) {
		NSString * response = [request responseString];
		NSDictionary * data = [response JSONValue];
		
		//create trigger list
		NSMutableArray * temp = [NSMutableArray arrayWithCapacity:10];
		for (NSDictionary * dict in [data valueForKey:@"triggers"]){
			FRTrigger * trig = [[FRTrigger alloc] initWithDict:dict];
			[temp addObject:trig];
		}
		
		triggers = [[NSArray alloc] initWithArray:temp];
		
		[temp removeAllObjects];
		[temp addObject:user];
		for (NSDictionary * dict in [data valueForKey:@"points"]){
			FRPoint * pt = [[FRPoint alloc] initWithDict:dict];
			[temp addObject:pt];
		}
		points = [[NSArray alloc] initWithArray:temp];
		
		//linkup triggers and points
		for (FRTrigger * trig in triggers){
			[trig finishByUsingTriggerList:triggers andPointList:points];
			[trig setDelegate:self];
		}
		[self.tableView reloadData];
	}
	
	url = [NSURL URLWithString:@"http://toqbot.com/otr/mapdata.json"];
	request = [ASIHTTPRequest requestWithURL:url];
	[request startSynchronous];
	error = [request error];
	if (!error) {
		NSString * response = [request responseString];
		NSDictionary * data = [response JSONValue];
		themap = [[FRMap alloc] initWithNodes:[data objectForKey:@"nodes"] andRoads:[data objectForKey:@"roads"]];
	}
	
	
	//set the EdgePos for every point (given its latlon)
	for (FRPoint * pt in points){
		NSArray * latlon = [pt.dictme objectForKey:@"pos"];
		if (latlon==nil) continue;
		CLLocation * p = [[CLLocation alloc] initWithLatitude:[[latlon objectAtIndex:0] floatValue]
													longitude:[[latlon objectAtIndex:1] floatValue]];
		pt.pos = [themap edgePosFromPoint:p];
		NSLog(@"%@ %@, %i, %i, %f",latlon,[themap closestEdgeToPoint:p],pt.pos.start,pt.pos.end,pt.pos.position);
		[p release];
	}
	
	
	[self startStandardUpdates];
	[self ticktock];
	[m2 loadObjectForKey:@"userpos" toDelegate:self usingSelector:@selector(updatePosition:)];

}
/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */

#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}
// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section==0){
		return [triggers count];
	} else {
		return [points count];
	}
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	if(section == 0)
		return @"Triggers";
	else
		return @"Points";
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    if ([indexPath section]==0) {
		FRTrigger * trig = [triggers objectAtIndex:[indexPath row]];
		if (trig.active) cell.textLabel.textColor = [UIColor redColor];
		else cell.textLabel.textColor = [UIColor blackColor];
		cell.textLabel.text = [trig displayname];
	} else {
		cell.textLabel.textColor = [UIColor blackColor];
		FRPoint * pt = [points objectAtIndex:[indexPath row]];
		cell.textLabel.text = [NSString stringWithFormat:@"%@",pt.name];
	}
	return cell;
	
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	
	MapViewController * detailViewController = [[MapViewController alloc] initWithNibName:nil bundle:nil];
	[detailViewController.view setEdges:[themap getEdges]];

	[self.navigationController pushViewController:detailViewController animated:YES];
	[detailViewController release];
	
	//[self.navigationController setNavigationBarHidden:NO];
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
}


- (void)dealloc {
    [super dealloc];
}




@end

