//
//  FRMission.h
//  ontherun
//
//  Created by Matt Donahoe on 2/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
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
	int healthbar;
	NSMutableArray * toBeSpoken;
	AVAudioPlayer * audioPlayer;
	int ticks;
	
}

@property(nonatomic,retain) NSArray * points;

- (void) updatePosition:(id)obj;
- (void) ticktock;
- (void) startStandardUpdates;
- (void) newUserLocation:(CLLocation *)location;
- (void) speakString:(NSString *)text;
- (FRPathSearch *) getPlayerView;
- (FRMap *) getMap;
- (void) speakIfYouCan:(NSString *)text;
- (void) speakEventually:(NSString *)text;
@end
