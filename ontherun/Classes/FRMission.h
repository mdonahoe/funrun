//
//  FRMission.h
//  ontherun
//
//  Created by Matt Donahoe on 2/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FRPoint.h"
#import "FRMap.h"
#import "FRPathSearch.h"
#import "toqbot.h"

@interface FRMission : NSObject <CLLocationManagerDelegate> {
	NSArray * points;
	FRPoint * user;
	FRPathSearch * latestsearch;
	FRMap * themap;
	CLLocationManager * locationManager;
	NSObject * voicebot;
	toqbot * m2;
}

@property(nonatomic,retain) NSArray * points;

- (void) updatePosition:(id)obj;
- (void) ticktock;
- (void) startStandardUpdates;
- (void) newUserLocation:(CLLocation *)location;
- (void) speakString:(NSString *)text;


@end
