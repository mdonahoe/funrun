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
#import "FRMapViewController.h"
#import "FRInGame.h"

#import <AVFoundation/AVFoundation.h>



@interface FRMissionTemplate : NSObject <FRSoundFilePlayer,MagicButton>{
	NSString * previously_said;
    NSString * last_played_sound;
	NSString * current_road;
    NSString * next_road;
    NSString * mission_name;
    FRPathSearch * latestsearch;
    FRPathSearch * destination;
	FRMap * themap;
	FRPoint * player;
    FRPoint * endPoint;
    NSDate * last_location_received_date;
    float average_player_speed;
    float player_max_distance;
    BOOL saved;
    float total_player_distance;
    NSDate * missionStart;
    
    VSSpeechSynthesizer * voicebot;
	NSMutableArray * toBeSpoken;
	NSMutableArray * points;
	FRInGame * viewControl;
    AVAudioPlayer * backgroundMusic;
    AVAudioPlayer * soundfx;
    CLLocation * last_location;
    BOOL magic;
}
@property(nonatomic,retain) NSMutableArray * points;
@property(nonatomic,assign) FRInGame * viewControl;

- (id) initWithLocation:(CLLocation*)l distance:(float)dist destination:(CLLocation*)dest viewControl:(UIViewController*)vc;
- (void) abort;
- (void) ticktock;
- (void) magicbutton;
- (void) speak:(NSString *)text;
- (void) speakIfEmpty:(NSString *)text;
- (void) speakNow:(NSString *)text;
- (void) newPlayerLocation:(CLLocation *)location;
- (void) playSong:(NSString*)name;
- (BOOL) playSoundFile:(NSString *)filename;
- (void) soundfile:(NSString*)filename;
- (BOOL) readyToSpeak;
- (void) updateDirections;
- (void) saveMissionStats:(NSString*)status;
@end
