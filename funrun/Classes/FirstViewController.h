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
	CLLocation * spot;
	CLLocation * currentPos;
	NSMutableArray * pedometer;
	NSMutableArray * locations;
	int toqbotrev;
}
- (float) distanceBetweenLocation:(CLLocation *)pos1 AndLocation:(CLLocation *)pos2;
@end
