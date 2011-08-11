//
//  FRMapViewController.h
//  ontherun
//
//  Created by Matt Donahoe on 2/7/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "FRMissionTemplate.h"

@class FRMissionTemplate;

@interface FRMapViewController : UIViewController <MKMapViewDelegate>{
	FRMissionTemplate * mission;
    NSString * missionclassname;
    CLLocation * latest_point;
}
@property (nonatomic, retain) CLLocation * latest_point;

- (id) initWithMission:(NSString *)missionclass;
- (void) didTapMap:(UIGestureRecognizer *) sender;
@end
