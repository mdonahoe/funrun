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
#import "FRPathSearch.h"
#import "toqbot.h"

@interface RootViewController : UITableViewController <CLLocationManagerDelegate> {
	NSArray * triggers;
	NSArray * points;
	FRPoint * user;
	FRPathSearch * latestsearch;
	NSString * myroad;
	FRMap * themap;
	CLLocationManager * locationManager;
	NSObject * voicebot;
	toqbot * m2;
	int healthbar;
}
- (void) triggered;
- (void) startStandardUpdates;
- (void) newUserLocation:(CLLocation *)location;

@end
