//
//  TheCarMission.m
//  ontherun
//
//  Created by Matt Donahoe on 5/11/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "TheCarMission.h"


@implementation TheCarMission
- (id) initWithLocation:(CLLocation *)l distance:(float)dist destination:(CLLocation *)dest viewControl:(UIViewController *)vc{
    self = [super initWithLocation:l distance:dist destination:dest viewControl:vc];
    if (!self) return nil;
    unsafe_spot = nil;
    car_state=13; //unlike other states, this one counts down.
    
    current_state = 0;
    cop_state = 0;
    
    [self playSong:@"chase_normal"];
    
    //create the safehouse
    safehouse = [[FRPoint alloc] initWithName:@"safehouse"];
    safehouse.pos = endPoint.pos;
    
    
    
    FRPathSearch * endmap = [themap createPathSearchAt:endPoint.pos withMaxDistance:nil];
    float dist_to_player = [endmap distanceFromRoot:player.pos];
    NSLog(@"max %f, dest = %f",player_max_distance,dist_to_player);
    
    
    //create the destination
    car = [[FRPoint alloc] initWithName:@"car"];
    car.pos = player.pos;
    
    float dist2 = 0.0;
    float dist1 = 0.0;
    while (dist1+dist2 < player_max_distance*.95 || dist2 > player_max_distance/1.9){
        car.pos = [latestsearch move:player.pos awayFromRootWithDelta:player_max_distance/1.9];
        dist1 = [latestsearch distanceFromRoot:car.pos];
        dist2 = [endmap distanceFromRoot:car.pos];
        NSLog(@"hideout.pos = %@, dist1 = %f, dist2 = %f",car.pos,dist1,dist2);
    }
    [endmap release];
    destination = [themap createPathSearchAt:car.pos withMaxDistance:[NSNumber numberWithFloat:player_max_distance]];
    
    cop = [[FRPoint alloc] initWithName:@"cop"];
    
    //maybe make the cop position random?
    cop.pos = player.pos;
    
    [points addObject:cop];
    [points addObject:car];
    [points addObject:safehouse];
    
    NSError * error;
    NSString * p = [[NSBundle mainBundle] pathForResource:@"woowoo" ofType:@"mp3"];
    NSURL * u = [NSURL URLWithString:p];
    siren = [[AVAudioPlayer alloc] initWithContentsOfURL:u error:&error];
    if (error){
        NSLog(@"siren error");
    }
    siren.numberOfLoops = -1;
    [siren prepareToPlay];
        
    [self ticktock];

    return self;
}
- (void) ticktock {
    //NSDate * ticktime = [NSDate date];
    NSArray * directions = [destination directionsToRoot:player.pos];
    NSString * direction = [directions objectAtIndex:0];
    if ([direction isEqualToString:@"turn around"]){
        //direction = [NSString stringWithFormat:@"%@ and %@", direction, [directions objectAtIndex:1]];
        direction = [directions objectAtIndex:1];
        //ulysses needs to say that you are going the wrong way.
    }
    
    if (current_state!=2) [self speakIfEmpty:direction];
    
    switch (current_state){
        case 0:
            [self the_car];
            break;
        case 1:
            [self the_alarm];
            break;
        case 2:
            [self the_cop];
            break;
        case 3:
            [self the_safehouse];
            break;
        case 4:
            //you lost the mission
            [self speak:@"You failed the mission"];
            [self finishWithText:@"Mission Failed"];
            current_state=10;
            break;
        default:
            [self stopSiren];
            [_music release];
            _music = nil;
            NSLog(@"current_state invalid, stopping ticktock");
            return;
    }
    
    [super ticktock];
    
}
- (void) the_car {
    // start with the introduction.
    
    
    float dist = [destination distanceFromRoot:player.pos];
    float progress = dist / player_max_distance / 2.0;
    car_time_left--;
    int timer = car_time_left/60;
    if (![self readyToSpeak]) return;
    switch (car_state) {
        case 13:
            [self ulyssesSpeak:@"A01_car_nearby"];
            car_state--;
            break;
        case 12:
            [self speak:@"your destination is blah"];
            car_state--;
            break;
        case 11:
            [self ulyssesSpeak:@"A02_back_soon"];
            car_state--;
            car_state = timer;
            break;
        default:
            //speak the time.
            if (timer < car_state) {
                car_state--;
                if (car_state>0){
                    [self speaktime:timer];
                } else {
                    current_state=4;
                    [self ulyssesSpeak:@"A17_too_late"];
                }
            }
            break;
    }
    
    if (dist < 30){
        //you made it
        current_state++;
        cop_goal = destination;//[destination release];
        destination = [themap createPathSearchAt:safehouse.pos withMaxDistance:[NSNumber numberWithFloat:player_max_distance]];
    }
    
}
- (void) the_alarm {
    float alarmdist = [latestsearch distanceFromRoot:car.pos];
    if (![self readyToSpeak]) return;
    switch (alarm_state){
        case 0:
            [self ulyssesSpeak:@"A18_elaborate_plan"];
            alarm_state++;
            [self startAlarm];
            break;
        case 1:
            [self ulyssesSpeak:@"A19_get_out_of_there"];
            alarm_state++;
            break;
        case 2:
            // adjust the sound of the alarm with the distance
            // once the distance exceeds 200m, kill, cue the cop.
            alarm.volume = (150.0 - alarmdist) / 100.0;
            if (alarmdist > 200) current_state++;
            break;
        default:
            break;
    }
    
}
- (void) the_cop {
    cop.pos = [cop_goal move:cop.pos towardRootWithDelta:10.0]; //moving at 10m/s
    float dist = [latestsearch distanceFromRoot:cop.pos];
    
    BOOL onpath = [cop_goal edgepos:player.pos isOnPathFromRootTo:cop.pos];
    if (onpath) {
        [unsafe_spot release];
        unsafe_spot = player.pos;
        [unsafe_spot retain];
    }
    switch (cop_state){
        case 0:
            [self ulyssesSpeak:@"A20_watch_out_police"];
            cop_state++;
            break;
        case 1:
            if (dist < 100) cop_state++;
            break;
            
        case 2:
            [self ulyssesSpeak:@"A21_cop_ahead"];
            [self startSiren];
            cop_state++;
            break;
        default:
            siren.volume = (100-dist)/100.0;
            //if the cop is closer to the car than the player is, then the player is off the track
            //if the cop gets too close, you lose.
            
            //how does the player know where to go?
            //other than that the cop is in front of you, they dont know where.
            //
            
            if (dist < 30){
                //cop see you.
                [self ulyssesSpeak:@"12stoppolice-2"];
                current_state = 4;
            } else if (dist > 120) {
                //you are clear
                [self ulyssesSpeak:@"A22_coast_clear"];
                current_state++;
            } else if (cop_state==3 && dist < 60 && onpath) {
                
                [self speak:@"You are gonna get caught. get off this road"];
                cop_state=4;
                //the cop is going to see you any second now. get off his path.
            
            } else if (cop_state==3 && !onpath){
                if ([latestsearch distanceFromRoot:unsafe_spot]>40){
                    cop_state = 5;
                    [self speak:@"You should be safe here"];
                }
            }
            break;
    }
}
- (void) the_safehouse {
    float dist = [destination distanceFromRoot:player.pos];
    if (dist < 30) {
        [self ulyssesSpeak:@"A23_successful_mission"];
        //what should actually happen when the mission ends successfully?
        current_state=5;
    }
}
- (BOOL) readyToSpeak {
    return (!ulysses.playing && ![voicebot isSpeaking]);
}
- (void) speaktime:(int)t{
    switch(t){
        case 10:
            [self ulyssesSpeak:@"A07_ten_minutes"];
            break;
        case 9:
            [self ulyssesSpeak:@"A08_nine_minutes"];
            break;
        case 8:
            [self ulyssesSpeak:@"A09_eight_minutes"];
            break;
        case 7:
            [self ulyssesSpeak:@"A10_seven_minutes"];
            break;
        case 6:
            [self ulyssesSpeak:@"A11_six_minutes"];
            break;
        case 5:
            [self ulyssesSpeak:@"A12_five_minutes"];
            break;
        case 4:
            [self ulyssesSpeak:@"A13_four_minutes"];
            break;
        case 3:
            [self ulyssesSpeak:@"A14_three_minutes"];
            break;
        case 2:
            [self ulyssesSpeak:@"A15_two_minutes"];
            break;
        case 1:
            [self ulyssesSpeak:@"A16_one_minute"];
            break;
        default:
            break;
    }
}
- (void) ulyssesSpeak:(NSString *)filename{
    [ulysses release];
    NSError *error;
    NSString * s = [[NSBundle mainBundle] pathForResource:filename ofType:@"mp3"];
    NSURL * x = [NSURL fileURLWithPath:s];
    ulysses = [[AVAudioPlayer alloc] initWithContentsOfURL:x error:&error];
    ulysses.volume = 0.5;
    [ulysses prepareToPlay];
    [ulysses play];
}
@end
