//
//  FirstViewController.h
//  funrun
//
//  Created by Matt Donahoe on 9/30/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface FirstViewController : UIViewController <CLLocationManagerDelegate,UIAccelerometerDelegate>{
	NSObject * bot;
	CLLocationManager * locationManager;
	CLLocation * goal;
	CLLocation * current;
	NSDate * deadline;
	int toqbotrev;
}
-(void) status;
-(void) speak:(NSString *)message;
-(void) startStandardUpdates;
-(void) gettoqbot;
@end
