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
#import "FRMapViewController.h"

#define ARC4RANDOM_MAX      0x100000000
@implementation RootViewController

#pragma mark -
#pragma mark stuff that shouldnt be here
- (void) speakString:(NSString *)text {
	//[voicebot startSpeakingString:text];
	NSLog(@"%@",text);
	//[m2 sendObject:text forKey:@"voicebot"];
}
- (void) ticktock {
	if (latestsearch==nil) NSLog(@"nilnil");
	
	
	for (FRPoint * pt in points){
		
		if ([pt.name isEqualToString:@"user"]==NO){
			
			
			if (latestsearch && [latestsearch containsPoint:pt.pos]) {
				float dist = [latestsearch distanceFromRoot:pt.pos];
				if (dist < 300) {
					pt.pos = [latestsearch move:pt.pos towardRootWithDelta:20.0];
					if ([pt.status isEqualToString:@"following"]==NO) 
						[messages insertObject:[NSString stringWithFormat:@"%@ is following",pt.name] atIndex:0];
					pt.status = @"following";
					NSString * direction = [latestsearch directionFromRoot:pt.pos];
					[self speakString:[NSString stringWithFormat:@"%@ is %i meters %@ of you",pt.name,(int)dist,direction]];
					
					
				} else {
					pt.pos = [themap move:pt.pos forwardRandomly:10.0];
					if ([pt.status isEqualToString:@"following"])
						[messages insertObject:[NSString stringWithFormat:@"You lost %@",pt.name] atIndex:0];
					pt.status = @"random";
				}
			} else {
				pt.pos = [themap move:pt.pos forwardRandomly:10.0];
				if ([pt.status isEqualToString:@"following"])
					[messages insertObject:[NSString stringWithFormat:@"You lost %@",pt.name] atIndex:0];
				pt.status = @"random";
			}

		}
		
		//update 2d coordinate (so the map updates live)
		[pt setCoordinate:[themap coordinateFromEdgePosition:pt.pos]];
		
	}
	
	
	for (FRTrigger * trig in triggers){
		//[trig ticktock];
	}

	[self performSelector:@selector(ticktock) withObject:nil afterDelay:0.5];
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
	EdgePos ep = [themap edgePosFromPoint:location];
	
	if (latestsearch) {
		//we already have a position
		//ensure that the direction of our new point is facing away from the old one.
		user.pos = [latestsearch move:ep awayFromRootWithDelta:0];
	} else {
		user.pos = ep;
	}
	
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
		//NSLog(@"%@ %@, %i, %i, %f",latlon,[themap closestEdgeToPoint:p],pt.pos.start,pt.pos.end,pt.pos.position);
		[p release];
	}
	
	
	[self startStandardUpdates];
	[self ticktock];
	[m2 loadObjectForKey:@"userpos" toDelegate:self usingSelector:@selector(updatePosition:)];

	
	//game stuff
	
	messages = [[NSMutableArray alloc] initWithCapacity:3];
	[messages addObject:@"first post"];
	
	healthbar = 100;
	
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
	return 3;
}
// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return [triggers count];
		case 1:
			return [points count];
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
			pt = [points objectAtIndex:[indexPath row]];
			cell.textLabel.text = [NSString stringWithFormat:@"%@",pt.name];
			break;
		case 2:
			cell.textLabel.textColor = [UIColor blackColor];
			cell.textLabel.text = [NSString stringWithFormat:@"%@",[messages objectAtIndex:[indexPath row]]];
			break;
	}
	/*
    if ([indexPath section]==0) {
		FRTrigger * trig = [triggers objectAtIndex:[indexPath row]];
		if (trig.active) cell.textLabel.textColor = [UIColor redColor];
		else cell.textLabel.textColor = [UIColor blackColor];
		cell.textLabel.text = [trig displayname];
	} else {
		cell.textLabel.textColor = [UIColor blackColor];
		FRPoint * pt = [points objectAtIndex:[indexPath row]];
		cell.textLabel.text = [NSString stringWithFormat:@"%@",pt.name];
	}*/
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
	
	
	FRMapViewController * detailViewController = [[FRMapViewController alloc] initWithNibName:@"FRMapViewController" bundle:nil];
	
	//EdgePos ep = ((FRPoint*)[points objectAtIndex:indexPath.row]).pos;
	//CLLocationCoordinate2D c = [themap coordinateFromEdgePosition:ep];
	
	[self.navigationController pushViewController:detailViewController animated:YES];
	[detailViewController.mapView addAnnotations:points];
	//[detailViewController addAnnotationAtCoordinate:c];
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

