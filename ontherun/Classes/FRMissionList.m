//
//  FRMissionList.m
//  ontherun
//
//  Created by Matt Donahoe on 5/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FRMissionList.h"
#import "JSON.h"
#import "FRMapViewController.h"

@implementation FRMissionList

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

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return YES;
}

- (void)dealloc
{
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
    NSString * path = [[NSBundle mainBundle] pathForResource:@"missionconfig" ofType:@"json"];
    NSURL * url = [NSURL fileURLWithPath:path];
    NSError * error;
    NSString * config = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    NSLog(@"config = %@",[config substringToIndex:100]);
    
    //dict of nodes and roads
    NSDictionary * obj = [config JSONValue];
    [self userData:obj];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
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
        cell.textLabel.textColor = [UIColor grayColor];
        cell.imageView.image = [UIImage imageNamed:@"lock.png"];
    } else {
        cell.textLabel.textColor = [UIColor blackColor];
        cell.imageView.image = nil;
    }
    cell.textLabel.text = name;
    
    return cell;
}

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
        //StartViewController * sv = [[[StartViewController alloc] initWithMissionData:obj] autorelease];
        //[self.navigationController pushViewController:sv animated:YES];
        
        FRMapViewController * mv = [[[FRMapViewController alloc] initWithMission:[obj objectForKey:@"class"]] autorelease];
        [self.navigationController pushViewController:mv animated:YES];
        
        NSLog(@"starting %@",[obj objectForKey:@"class"]);
    }
}

@end
