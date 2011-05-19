//
//  TheKeyMission.h
//  ontherun
//
//  Created by Matt Donahoe on 5/13/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FRMissionTemplate.h"
#import "FRProgress.h"

@interface TheKeyMission : FRMissionTemplate <FRSoundFilePlayer>{
    FRPoint * pointA;
    FRPoint * pointB;
    FRPoint * pointC;
    FRPoint * dude;
    FRPoint * safehouse;
    int main_state;
    int sub_state;
    FRPathSearch * destination;
    float xdist;
    float dude_speed;
    AVAudioPlayer * soundfx;
    AVAudioPlayer * _music;
    FRProgress * prog;
}
- (BOOL) playSoundFile:(NSString *)filename;
- (void) the_first;
- (void) the_second;
- (void) the_third;
- (void) the_chase;
- (void) soundfile:(NSString *)filename;
- (BOOL) readyToSpeak;
- (void) playSong:(NSString *)name;
@end
