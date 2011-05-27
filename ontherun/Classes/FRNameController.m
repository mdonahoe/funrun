//
//  FRNameController.m
//  ontherun
//
//  Created by Matt Donahoe on 5/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FRNameController.h"


@implementation FRNameController
@synthesize namefield;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
    return self;
}

- (void)dealloc
{
    [namefield release];
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
    // Do any additional setup after loading the view from its nib.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    namefield.text = [defaults objectForKey:@"username"];
}

- (void)viewDidUnload
{
    [self setNamefield:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)selectName:(id)sender {
    
    NSString * username = namefield.text;
    NSLog(@"username = %@",username);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:username forKey:@"username"];
    [defaults synchronize];
    
    FRMissionList * ml = [[FRMissionList alloc] initWithUsername:username];
    [self.navigationController pushViewController:ml animated:YES];
    [ml release];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
	return YES;
    
}
@end
