//
//  FRMissionList.m
//  ontherun
//
//  Created by Matt Donahoe on 5/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FRMissionList.h"
#import "StartViewController.h"
@implementation FRMissionList


- (id)initWithUsername:(NSString *)username {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (!self) return nil;
    
    m2 = [[toqbot alloc] init];
    
    userkey = [[NSString alloc] initWithFormat:@"ontherun_%@",username];
    
    
    return self;
}

- (void) userData:(id)obj{
    //no one on /b/
    
    
    NSArray * mission_ids = [obj objectForKey:@"missions"];
    [mission_ids retain];
    [missions release];
    missions = mission_ids;
    
    NSArray * ev_ids = [obj objectForKey:@"evidence"];
    [ev_ids retain];
    [evidence release];
    evidence = ev_ids;
    
    [self.tableView reloadData];
    
    
    
}



- (void)dealloc
{
    [m2 cancel];
    [m2 release];
    [missions release];
    [evidence release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"mission list appeared");
    [m2 loadObjectForKey:userkey toDelegate:self usingSelector:@selector(userData:)];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"mission list will disappear");
    
    [m2 cancel];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    int unlocked=0;
	switch (section) {
		case 0:
            for (NSDictionary * mission in missions){
                if ([mission objectForKey:@"locked"]==nil) unlocked++;
            }
			return [NSString stringWithFormat:@"Missions (%i/%i)",unlocked,[missions count]];
		case 1:
            for (NSDictionary * ev in evidence){
                if ([ev objectForKey:@"locked"]==nil) unlocked++;
            }
			return [NSString stringWithFormat:@"Evidence (%i/%i)",unlocked,[evidence count]];
		default:
			break;
	}
	return nil;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section==0) return [missions count];
    return [evidence count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    NSString * name;
    NSDictionary * obj = [self objFromIndexPath:indexPath];
    
    name = [obj objectForKey:@"name"];
    if ([obj objectForKey:@"locked"]){
        name = [NSString stringWithFormat:@"%@ (locked)",name];
    }
    cell.textLabel.text = name;
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary * obj = [self objFromIndexPath:indexPath];    
    if ([obj objectForKey:@"locked"]) return nil;
	return indexPath;
}
- (NSDictionary*)objFromIndexPath:(NSIndexPath*)indexPath {
    NSDictionary * obj;
    if (indexPath.section==0){
        //mission
        obj = [missions objectAtIndex:indexPath.row];
    } else {
        //evidence;
        obj = [evidence objectAtIndex:indexPath.row];
    }
    return obj;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * obj = [self objFromIndexPath:indexPath];    
    if (indexPath.section==0){
        //mission: load the starview
        
        StartViewController * sv = [[[StartViewController alloc] initWithMissionData:obj] autorelease];
        [self.navigationController pushViewController:sv animated:YES];
                                 
        
    } else {
        //evidence: load the url
        NSURL * url = [NSURL URLWithString:[obj objectForKey:@"url"]];
        UIViewController *webViewController = [[[UIViewController alloc] init] autorelease];
        UIWebView *uiWebView = [[[UIWebView alloc] initWithFrame: CGRectMake(0,0,320,480)] autorelease];
        [uiWebView loadRequest:[NSURLRequest requestWithURL:url]];
        uiWebView.scalesPageToFit=YES;
        webViewController.view = uiWebView;
        [self.navigationController pushViewController: webViewController animated:YES];
    }
}

@end
