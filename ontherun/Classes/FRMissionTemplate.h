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
#import "VSSpeechSynthesizer.h"
#import "FRPoint.h"
#import "LocationPicker.h"



#import <AVFoundation/AVFoundation.h>



@interface FRMissionTemplate : NSObject <LocationPickerDelegate>{
	NSString * previously_said;
	FRPathSearch * latestsearch;
	FRMap * themap;
	FRPoint * player;
    NSDate * last_location_received_date;
    float average_player_speed;
    float player_max_distance;
	VSSpeechSynthesizer * voicebot;
	NSMutableArray * toBeSpoken;
	NSMutableArray * points;
	NSString * current_road;
	UIViewController * viewControl;
    AVAudioPlayer * backgroundMusicPlayer;
}
@property(nonatomic,retain) NSMutableArray * points;
@property(nonatomic,assign) UIViewController * viewControl;
//- (id) initWithMap:(FRMap *)m andPlayer:(FRPoint*)p;
- (id) initWithLocation:(CLLocation*)l distance:(float)dist viewControl:(UIViewController*)vc;
- (void) abort;
- (void) ticktock;
- (void) speak:(NSString *)text;
- (void) speakIfEmpty:(NSString *)text;
- (void) speakNow:(NSString *)text;
- (void) newPlayerLocation:(CLLocation *)location;
- (void) playSong:(NSString*)name;
@end
