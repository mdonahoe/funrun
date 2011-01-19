//
//  RootViewController.h
//  ontherun
//
//  Created by Matt Donahoe on 1/5/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRPoint.h"
#import "FRMap.h"
@interface RootViewController : UITableViewController <CLLocationManagerDelegate> {
	NSMutableDictionary * toqbotkeys;
	NSArray * triggers;
	NSArray * points;
	FRPoint * user;
	FRPoint * target;
	FRMap * themap;
	CLLocationManager * locationManager;
}
- (void) triggered;
- (void) startStandardUpdates;
- (void) gettoqbot;
- (void) newUserLocation:(CLLocation *)location;

@end
