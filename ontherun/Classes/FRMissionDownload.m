//
//  FRMissionDownload.m
//  ontherun
//
//  Created by Matt Donahoe on 4/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FRMissionDownload.h"


@implementation FRMissionDownload

- (id)initWithLocation:(CLLocation *)l viewControl:(UIViewController *)vc{
	self = [super initWithLocation:l viewControl:vc];
	if (!self) return nil;
	[self.viewControl setText:@"Get to the theif's hideout and return safely."];
    current_state = 0;
    intro_state = -1;
    [self playSong:@"chase1"];
    
    //create the destination
    hideout = [[FRPoint alloc] initWithName:@"hideout"];
    hideout.pos = [themap move:player.pos forwardRandomly:500];
    //hideout.pos.position = 5; //make it at a corner.
    start_date = [[NSDate alloc] init];
    
    
    
    
    [self ticktock];
	return self;
}

- (void) ticktock {
    float dist = [latestsearch distanceFromRoot:hideout.pos];
    switch (current_state){
        case 0:
            [self the_intro];
            break;
        case 1:
            if (dist < 100){
                [self speakIfEmpty:[NSString stringWithFormat:@"The target is %i meters %@ you",(int)dist,[latestsearch directionFromRoot:hideout.pos]]];
            }
            if (dist < 30) {
                current_state++;
                hideout_date = [[NSDate alloc] init];
            }
            break;
        case 2:
            [self the_download];
            break;
    }
    [super ticktock];
}
- (void) the_download {
    NSTimeInterval timediff = ABS([hideout_date timeIntervalSinceNow]);
    NSLog(@" timediff = %f, download_state = %i, players =  %i, %i",timediff,download_state, ulysses.playing,[voicebot isSpeaking]);
    if (!ulysses.playing && ![voicebot isSpeaking]){
        switch (download_state){
            case 0:
                [self ulyssesSpeak:@"7inrange"];
                download_state++;
                break;
            case 1:
                if (timediff > 20) download_state++;
                break;
            case 2:
                [self ulyssesSpeak:@"9headhome"];
                current_state++;
                break;
            default:
                break;
        }
    }    
}

- (void) the_intro {
    //play ulysses' sound files one after another.
    NSTimeInterval timediff = ABS([start_date timeIntervalSinceNow]);
    NSLog(@" timediff = %f, intro_state = %i, players =  %i, %i",timediff,intro_state, ulysses.playing,[voicebot isSpeaking]);
    if (!ulysses.playing && ![voicebot isSpeaking]){
        switch (intro_state) {
            case -1:
                [self ulyssesSpeak:@"1phonehack"];
                intro_state++;
                break;
            case 0:
                [self ulyssesSpeak:@"3coordinates"];
                intro_state++;
                break;
            case 1:
                //speak the location
                [self speak:@"target acquired"];
                [self speak:[NSString stringWithFormat:@"head over to %@",[themap roadNameFromEdgePos:hideout.pos]]];
                //[self speakNow:@"target acquired. head to the corner of broadway and moore street"];
                intro_state++;
                break;
            case 2:
                [self ulyssesSpeak:@"2frameyou"];
                intro_state++;
                break;
            case 3:
                if (timediff > 20) intro_state++; break;
            case 4:
                [self ulyssesSpeak:@"4cops"];
                current_state++;
                break;
            default:
                [self speakNow:@"unsupported intro state"];
                break;
        }
        
    }
}
- (void) ulyssesSpeak:(NSString *)filename{
    [ulysses release];
    NSError *error;
    NSString * s = [[NSBundle mainBundle] pathForResource:filename ofType:@"mp3"];
    NSURL * x = [NSURL fileURLWithPath:s];
    ulysses = [[AVAudioPlayer alloc]
                              initWithContentsOfURL:x error:&error];
    ulysses.volume = 0.5;
    [ulysses prepareToPlay];
    [ulysses play];
}
- (void) playSong:(NSString *)filename{
    [_music release];
    NSError *error;
    NSString * s = [[NSBundle mainBundle] pathForResource:filename ofType:@"mp3"];
    NSURL * x = [NSURL fileURLWithPath:s];
    _music = [[AVAudioPlayer alloc]
                              initWithContentsOfURL:x error:&error];
    _music.volume = 0.5;
    [_music prepareToPlay];
    [_music play];
}
- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)audioplayer successfully:(BOOL)flag{
    //a player finished, do something depending on which one.
    if (audioplayer==ulysses){
        //we probably dont need to do anything here.
    }
}

@end
