//
//  TheCarMission.h
//  ontherun
//
//  Created by Matt Donahoe on 5/11/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FRMissionTemplate.h"

@interface TheCarMission : FRMissionTemplate {
    //states
    int car_state;
    int alarm_state;
    int cop_state;
    int safehouse_state;
    int current_state;
    
    //audio
    AVAudioPlayer * ulysses;
    AVAudioPlayer * _music;
    AVAudioPlayer * siren;
    AVAudioPlayer * alarm;
    
    //points
    FRPoint * car;
    FRPoint * cop;
    FRPoint * safehouse;
    
    int car_time_left;
    int car_times_spoken;
    
    FRPathSearch * destination;
    FRPathSearch * cop_goal;
}

- (void) the_car;
- (void) the_alarm;
- (void) the_cop;
- (void) the_safehouse;
- (void) ulyssesSpeak:(NSString *)filename;


@end
