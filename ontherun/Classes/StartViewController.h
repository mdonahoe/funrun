//
//  StartViewController.h
//  ontherun
//
//  Created by Matt Donahoe on 3/14/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "toqbot.h"
#import "FRMissionTemplate.h"
#import "LocationPicker.h"

@interface StartViewController : UIViewController <CLLocationManagerDelegate,LocationPickerDelegate> {
	UILabel * missionLabel;
	FRMissionTemplate * mission;
	UISwitch * gps;
	CLLocationManager * locationManager;
	toqbot * m2;
	CLLocation * latest_point;
    UILabel * distanceLabel;
    UISlider * distanceSlider;
    CLLocation * destination;
	
}
@property(nonatomic,retain) IBOutlet UILabel * missionLabel;
@property(nonatomic,retain) IBOutlet UISwitch * gps;
@property(nonatomic,retain) IBOutlet UILabel * distanceLabel;
@property(nonatomic,retain) IBOutlet UISlider * distanceSlider;
@property(nonatomic,retain) CLLocation * latest_point;

- (IBAction)pickDestination:(id)sender;
- (IBAction)loadMissionOne:(id)sender;
- (IBAction)loadMissionTwo:(id)sender;
- (void) updatePosition:(id)obj;
- (void) startStandardUpdates;
- (IBAction) statechange:(id)sender;
- (IBAction) sliderchange:(id)sender;

@end