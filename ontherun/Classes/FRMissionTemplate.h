//
//  FRMissionTemplate.h
//  ontherun
//
//  Created by Matt Donahoe on 3/14/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "FRMap.h"
#import "FRPathSearch.h"
#import "toqbot.h"
#import "VSSpeechSynthesizer.h"
#import "FRPoint.h"



//sounds TODO
//#import <AudioToolbox/AudioToolbox.h>
//#import <AVFoundation/AVFoundation.h>
//#import <MediaPlayer/MediaPlayer.h>



@interface FRMissionTemplate : NSObject <CLLocationManagerDelegate> {
	NSString * previously_said;
	FRPathSearch * latestsearch;
	FRMap * themap;
	FRPoint * player;
	CLLocationManager * locationManager;
	VSSpeechSynthesizer * voicebot;
	toqbot * m2;
	NSMutableArray * toBeSpoken;
	NSMutableArray * points;
	NSString * current_road;
	BOOL setup_complete;
	UIViewController * viewControl;
	
}
@property(nonatomic,retain) NSMutableArray * points;
@property(nonatomic,assign) UIViewController * viewControl;

- (void) updatePosition:(id)obj;
- (void) ticktock;
- (void) startStandardUpdates;
- (void) newPlayerLocation:(CLLocation *)location;
- (void) speak:(NSString *)text;
- (void) speakIfEmpty:(NSString *)text;
- (void) speakNow:(NSString *)text;
- (void) initWithStart:(FREdgePos *)start;
@end
