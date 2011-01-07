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
#define ARC4RANDOM_MAX      0x100000000
@implementation RootViewController


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	triggers = nil;
	points = nil;
	
	user = [[FRPoint alloc] initWithDict:[NSDictionary dictionaryWithObject:@"user" forKey:@"name"]];
	
	NSLog(@"my table view %@",self.view);
	toqbotkeys = [[NSMutableDictionary alloc] init];
	[toqbotkeys setObject:[NSNumber numberWithInt:-1] forKey:@"triggers"];
	[toqbotkeys setObject:[NSNumber numberWithInt:-1] forKey:@"points"];
	[toqbotkeys setObject:[NSNumber numberWithInt:-1] forKey:@"userpos"];
	[ASIHTTPRequest setDefaultTimeOutSeconds:50];
	[self gettoqbot];
}

- (void) checkTriggers:(NSTimer *)theTimer {
	for (NSDictionary * trig in triggers){
		if ([[trig objectForKey:@"active"] boolValue]==NO) continue;
		
	}
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
#pragma mark toqbot

- (void) gettoqbot {
	//get the path we are going to run
	NSMutableString *resultString = [NSMutableString string];
	for (NSString* key in [toqbotkeys allKeys]){
		if ([resultString length]>0)
			[resultString appendString:@"&"];
		[resultString appendFormat:@"%@=%@", key, [toqbotkeys objectForKey:key]];
	}
	NSString * url = [NSString stringWithFormat:@"http://toqbot.com/db/?%@",resultString];
	ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
	[request setDelegate:self];
	[request startAsynchronous];
}
- (void) requestFinished:(ASIHTTPRequest *) request {
	BOOL dirty = NO;
	NSArray * docs = [[request responseString] JSONValue];
	for (NSDictionary * doc in docs){
		int rev = [[doc valueForKey:@"rev"] intValue]+1;
		NSString * key = [doc valueForKey:@"key"];
		[toqbotkeys
		 setObject:[NSNumber numberWithInt:rev]
		 forKey:key];
		id data = [[doc objectForKey:@"data"] JSONValue];
		if (data==nil) continue;
		if ([data respondsToSelector:@selector(objectAtIndex:)]){
			if ([key isEqualToString:@"triggers"]){
				[triggers release];
				NSMutableArray * temp = [NSMutableArray arrayWithCapacity:10];
				for (NSDictionary * dict in data){
					FRTrigger * trig = [[FRTrigger alloc] initWithDict:dict];
					[temp addObject:trig];
				}
				triggers = [[NSArray alloc] initWithArray:temp];
				dirty = YES;
			} else if ([key isEqualToString:@"points"]) {
				[points release];
				NSMutableArray * temp = [NSMutableArray arrayWithCapacity:10];
				[temp addObject:user];
				for (NSDictionary * dict in data){
					FRPoint * pt = [[FRPoint alloc] initWithDict:dict];
					[temp addObject:pt];
				}
				points = [[NSArray alloc] initWithArray:temp];
				dirty = YES;
			} else {
				NSLog(@"key = %@",key);
			}
		}  else if ([key isEqualToString:@"userpos"]) {
			float lat = [[data objectForKey:@"lat"] floatValue];
			float lon = [[data objectForKey:@"lon"] floatValue];
			user.pos = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
			NSLog(@"new pos");
			for (FRTrigger * trig in triggers){
				NSLog(@" trig %@ is %f meters away",trig.name,[trig checkdistancefrom:user.pos]);
			}
		}
	}
	if (dirty){
		//recreate triggers and points
		for (FRTrigger * trig in triggers){
			[trig finishByUsingTriggerList:triggers andPointList:points];
			[trig setDelegate:self];
		}
		[self.tableView reloadData];
	}
	
	
	[self gettoqbot];
}
- (void) requestFailed:(ASIHTTPRequest *) request {
	//NSLog(@"request error %@",[request error]);
	[self gettoqbot];
}

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
    if ([indexPath section]==0){
	// Configure the cell.
		FRTrigger * trig = [triggers objectAtIndex:[indexPath row]];
		if (trig.active) cell.textLabel.textColor = [UIColor redColor];
		else cell.textLabel.textColor = [UIColor blackColor];
		cell.textLabel.text = trig.name;
	} else {
		FRPoint * pt = [points objectAtIndex:[indexPath row]];
		cell.textLabel.text = [NSString stringWithFormat:@"%@:%@",pt.name,pt.pos];
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
    
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
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

- (void) triggered {
	[self.tableView reloadData];
}


@end

