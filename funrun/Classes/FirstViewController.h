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
	NSMutableArray * points;
	NSDate * deadline;
	NSMutableDictionary * toqbotkeys;
	NSMutableDictionary * sounds;
	bool mute;
	bool sending;
}
-(void) status;
-(void) speak:(NSString *)message;
-(void) startStandardUpdates;
-(void) gettoqbot;
-(IBAction) clickmute:(id)sender;
-(void) sendGPSCoordToServer:(CLLocation*)coord;
-(void) sentGPS:request;
-(void) loadsounds;
@end
