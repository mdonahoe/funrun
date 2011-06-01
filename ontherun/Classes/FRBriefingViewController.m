//
//  BriefingViewController.m
//  ontherun
//
//  Created by Matt Donahoe on 3/25/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "FRBriefingViewController.h"
#import "StartViewController.h"

#define FONT_SIZE 15.0
#define CELL_CONTENT_WIDTH 300.0
#define CELL_CONTENT_MARGIN 10.0


#define kSection_Objective 0
#define kSection_Destination 1

@implementation FRBriefingViewController
@synthesize desttext;
#pragma mark -
#pragma mark View lifecycle

- (id) initWithMissionData:(NSDictionary*)md {
    self = [self initWithNibName:@"FRBriefingViewController" bundle:nil];
    if (!self) return nil;
    [md retain];
    missionData = md;
    [self setText:[missionData objectForKey:@"description"]];
    return self;
}

//maybe do init instead
- (void)viewDidLoad {
    [super viewDidLoad];
	
	//objective
	if (nil==objective) objective = [[UITableViewCell alloc] initWithFrame:CGRectZero];
	objective.selectionStyle = UITableViewCellSelectionStyleNone;
	[self setText:missionText];
	
	
	//destination
	//if (nil==destination) destination = [[UITableViewCell alloc] initWithFrame:CGRectZero];
	//destination.textLabel.text = desttext;
	//destination.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	
	//footerView
	//the button could disappear. though we want it to anyway after the mission has been started.
	if (nil==footerView) {
        NSLog(@"nil footer");
        footerView  = [[UIView alloc] init];
        [self makeButton];
    }
	
	
}

#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
	if (indexPath.section==kSection_Destination) return 50.0;
	NSString *text = missionText;
	
	CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
	
	CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
	
	CGFloat height = MAX(size.height, 44.0f);
	
	return height + (CELL_CONTENT_MARGIN * 2);
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case kSection_Objective:
			return [NSString stringWithFormat:@"%@ Mission",[missionData objectForKey:@"name"]];
		default:
			break;
	}
	return nil;
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
	return nil;
	
}
- (void) makeButton {
	//we would like to show a glossy green button, so get the image first
	UIImage *image = [[UIImage imageNamed:@"button_green.png"]
					  stretchableImageWithLeftCapWidth:8 topCapHeight:8];
	
	//create the button
	UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[button setBackgroundImage:image forState:UIControlStateNormal];
	
	//the button should be as big as a table view cell
	[button setFrame:CGRectMake(10, 3, 300, 44)];
	
	//set title, font size and font color
	[button setTitle:@"Start Mission" forState:UIControlStateNormal];
	[button.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	
	//set action of the button
	[button addTarget:self action:@selector(startup)
	 forControlEvents:UIControlEventTouchUpInside];
	
	//add the button to the view
	[footerView addSubview:button];
}
- (void) startup {
    NSLog(@"pressed");
    StartViewController * sv = [[[StartViewController alloc] initWithMissionData:missionData] autorelease];
    [self.navigationController pushViewController:sv animated:YES];
}
// specify the height of your footer section
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    //differ between your sections or if you
    //have only on section return a static value
    return 50;
}

// custom view for footer. will be adjusted to default or specified footer height
// Notice: this will work only for one section within the table view
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	
    //return the view for the footer
    return footerView;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	if (indexPath.section==kSection_Objective){
		return objective;
	} else if (indexPath.section==kSection_Destination){
		return destination;
	}
	return nil;
}

#pragma mark -
#pragma mark MissionInteraction
- (void) setDest:(NSString *)name {
	self.desttext = name;
	if (destination) destination.textLabel.text = desttext;
}
- (void) setText:(NSString *)text{
	[text retain];
	[missionText release];
	missionText = text;
	//reload data?
	UILabel * label = (UILabel*)[[objective contentView] viewWithTag:1];
	if (nil==label){
		label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
		[label setLineBreakMode:UILineBreakModeWordWrap];
		[label setMinimumFontSize:FONT_SIZE];
		[label setNumberOfLines:0];
		[label setFont:[UIFont systemFontOfSize:FONT_SIZE]];
		[label setTag:1];
    }
	CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
	CGSize size = [missionText sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
	[label setText:missionText];
	[label setFrame:CGRectMake(CELL_CONTENT_MARGIN, CELL_CONTENT_MARGIN, CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), MAX(size.height, 44.0f))];			
	[[objective contentView] addSubview:label];
}

#pragma mark -
#pragma mark Table view delegate
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	//create the location picker view thing
	//when it returns, send a pickedLocation: to the missionView
	return;
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
	[destination release];
	destination=nil;
	[footerView release];
	footerView = nil;
	[objective release];
	objective=nil;
}


- (void)dealloc {
	[destination release];
	[objective release];
	[footerView release];
	[missionText release];
    [missionData release];
    [super dealloc];
}


@end

