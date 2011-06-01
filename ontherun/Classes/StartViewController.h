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
    UIButton *DestinationButton;
    UIButton *StartButton;
    UILabel *centerLabel;
    UILabel * distanceLabel;
    UISlider * distanceSlider;
    CLLocation * destination;
    NSDictionary * missionData;
	
}
@property(nonatomic,retain) IBOutlet UILabel * missionLabel;
@property(nonatomic,retain) IBOutlet UISwitch * gps;
@property(nonatomic,retain) IBOutlet UILabel * distanceLabel;
@property(nonatomic,retain) IBOutlet UISlider * distanceSlider;
@property(nonatomic,retain) CLLocation * latest_point;
@property (nonatomic, retain) IBOutlet UIButton *DestinationButton;
@property (nonatomic, retain) IBOutlet UIButton *StartButton;
@property (nonatomic, retain) IBOutlet UILabel *centerLabel;

- (id) initWithMissionData:(NSDictionary *)obj;
- (IBAction)pickDestination:(id)sender;
- (IBAction)startMission:(id)sender;
- (void) updatePosition:(id)obj;
- (void) startStandardUpdates;
- (IBAction) statechange:(id)sender;
- (IBAction) sliderchange:(id)sender;
- (void) updateLocation:(CLLocation *)location;
@end