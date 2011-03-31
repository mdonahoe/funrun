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



//sounds TODO
//#import <AudioToolbox/AudioToolbox.h>
//#import <AVFoundation/AVFoundation.h>
//#import <MediaPlayer/MediaPlayer.h>



@interface FRMissionTemplate : NSObject {
	NSString * previously_said;
	FRPathSearch * latestsearch;
	FRMap * themap;
	FRPoint * player;
	VSSpeechSynthesizer * voicebot;
	NSMutableArray * toBeSpoken;
	NSMutableArray * points;
	NSString * current_road;
	UIViewController * viewControl;
	
}
@property(nonatomic,retain) NSMutableArray * points;
@property(nonatomic,assign) UIViewController * viewControl;
- (id) initWithMap:(FRMap *)m andPlayer:(FRPoint*)p;
- (id) initWithLocation:(CLLocation*)l viewControl:(UIViewController*)vc;
- (void) abort;
- (void) ticktock;
- (void) speak:(NSString *)text;
- (void) speakIfEmpty:(NSString *)text;
- (void) speakNow:(NSString *)text;
- (void) newPlayerLocation:(CLLocation *)location;
@end
