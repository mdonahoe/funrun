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
#import "FRProgress.h"



#import <AVFoundation/AVFoundation.h>



@interface FRMissionTemplate : NSObject <FRSoundFilePlayer>{
	NSString * previously_said;
    NSString * last_played_sound;
	NSString * current_road;
    NSString * next_road;
    FRPathSearch * latestsearch;
    FRPathSearch * destination;
	FRMap * themap;
	FRPoint * player;
    FRPoint * endPoint;
    NSDate * last_location_received_date;
    float average_player_speed;
    float player_max_distance;
	VSSpeechSynthesizer * voicebot;
	NSMutableArray * toBeSpoken;
	NSMutableArray * points;
	UIViewController * viewControl;
    AVAudioPlayer * backgroundMusic;
    AVAudioPlayer * soundfx;
}
@property(nonatomic,retain) NSMutableArray * points;
@property(nonatomic,assign) UIViewController * viewControl;

- (id) initWithLocation:(CLLocation*)l distance:(float)dist destination:(CLLocation*)dest viewControl:(UIViewController*)vc;
- (void) abort;
- (void) ticktock;
- (void) speak:(NSString *)text;
- (void) speakIfEmpty:(NSString *)text;
- (void) speakNow:(NSString *)text;
- (void) newPlayerLocation:(CLLocation *)location;
- (void) playSong:(NSString*)name;
- (BOOL) playSoundFile:(NSString *)filename;
- (void) soundfile:(NSString*)filename;
- (BOOL) readyToSpeak;
- (void) updateDirections;

@end
