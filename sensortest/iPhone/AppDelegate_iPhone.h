//
//  AppDelegate_iPhone.h
//  sensortest
//
//  Created by Matt Donahoe on 2/17/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate_iPhone : NSObject <UIApplicationDelegate, CLLocationManagerDelegate, UIAccelerometerDelegate> {
    UIWindow *window;
	CLLocationManager * lman;
	float start;
	NSDate * startDate;
	NSObject * voicebot;
	int mode;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end

