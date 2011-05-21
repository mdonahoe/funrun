//
//  FRMissionDownload.h
//  ontherun
//
//  Created by Matt Donahoe on 4/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FRMissionTemplate.h"

/*
 This is the mission that was seen in the trailer.
 
 
 Ulysses has tracked down the thief who framed you.
 
 The man has a hideout nearby. You need to get there and download data using Wifi.
 
 Be careful of police.
 
 
 
 
 states:
    intro - ulysses talks about the mission
    halfway - a cop is nearby, and you need to route around him.
    download - you arrived at the location. wait for ulyses to hack the network and get the data.
    done - download complete. head to a safehouse
    cops - you've been spotted and the cops are heading to your location. get moving.
    chase - you are being followed! outrun them.
    home - great work, you lost them. uly will analyze the data and get back to you.
 
 
 
 
 sound:
    navigation data
    ulysses talk
    music
    siren (with volume adjustment)
    police yelling
    
 */



@interface FRMissionDownload : FRMissionTemplate {
    FRPoint * hideout;
    AVAudioPlayer * ulysses;
    AVAudioPlayer * _music;
    AVAudioPlayer * siren;
    int current_state;
    int download_state;
    int intro_state;
    int cop_state;
    int chase_state;
    NSDate * hideout_date;
    NSDate * start_date;
    FRPoint * cop;
    FRPoint * safehouse;
    BOOL cop_spotted;
    NSDate * progress_date;
    float progress_dist;
    float player_speed;
    
}
- (void) finishWithText:(NSString *)text;
- (void) ulyssesSpeak:(NSString *)filename;
- (void) stopSiren;
- (void) startSiren;
- (void) the_cop;
- (void) the_download;
- (void) the_intro;
- (void) the_chase;
- (void) playSong:(NSString *)name;
- (BOOL) readyToSpeak;

@end
