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
    
    
    float cop_speed;
    //audio
    AVAudioPlayer * siren;
    AVAudioPlayer * alarm;
    
    //points
    FRPoint * car;
    FRPoint * cop;
    FRPoint * safehouse;
    FREdgePos * unsafe_spot; //hack for finding distance to path.
    
    int car_time_left;
    int car_times_spoken;
    BOOL direct;
    FRPathSearch * cop_goal;
    FRProgress * prog;
}

- (void) the_car;
- (void) the_alarm;
- (void) the_cop;
- (void) the_safehouse;
- (void) stopSiren;
- (void) startSiren;
- (void) stopAlarm;
- (void) startAlarm;
- (void) speaktime:(int)t;

@end
