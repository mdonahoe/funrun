//
//  FRTroubleshoot.m
//  ontherun
//
//  Created by Matt Donahoe on 5/21/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "FRTroubleshoot.h"


@implementation FRTroubleshoot
@synthesize e_slider;
@synthesize t_slider;
@synthesize r_slider;
@synthesize f_slider;

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
    [t_slider release];
    [r_slider release];
    [e_slider release];
    [f_slider release];
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
}

- (void)viewDidUnload
{
    [self setT_slider:nil];
    [self setR_slider:nil];
    [self setE_slider:nil];
    [self setF_slider:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
