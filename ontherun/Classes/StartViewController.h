//
//  StartViewController.h
//  ontherun
//
//  Created by Matt Donahoe on 3/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "toqbot.h"
#import "FRMissionTemplate.h"

@interface StartViewController : UIViewController <CLLocationManagerDelegate> {
	UILabel * missionLabel;
	FRMissionTemplate * mission;
	UISwitch * gps;
	CLLocationManager * locationManager;
	toqbot * m2;
	CLLocation * latest_point;
	
}
@property(nonatomic,retain) IBOutlet UILabel * missionLabel;
@property(nonatomic,retain) IBOutlet UISwitch * gps;
@property(nonatomic,retain) CLLocation * latest_point;

- (IBAction)loadMissionOne:(id)sender;
- (IBAction)loadMissionTwo:(id)sender;
- (void) updatePosition:(id)obj;
- (void) startStandardUpdates;
- (IBAction) statechange:(id)sender;


@end


/*
 is there any way to tell if this view has control again?
*/