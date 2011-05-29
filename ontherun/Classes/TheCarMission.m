//
//  TheCarMission.m
//  ontherun
//
//  Created by Matt Donahoe on 5/11/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "TheCarMission.h"
/*
 
 notes:
X1. how far am i from the destination
X2. where is the destination
X3. alarm starts too early.
X5. alarm is LOUD, ulysses is quiet.
X6. the cops come really quickly. i need a chance to escape.
X7. directions on where to go to avoid the cop?
X8. if you manage to completely avoid the cop, the game fails.
X10. there is some infinite loop bug in the directionsToRoot code.

 9. where is the cop? (how far away, etc)
 4. no glass breaking sound effects
 - the alarm gets louder sometimes.
 
 A. if the gps isnt accurate, it fails completely.
 B. Toqbot slow over 3G
 
 */
@implementation TheCarMission
- (id) initWithLocation:(CLLocation *)l distance:(float)dist destination:(CLLocation *)dest viewControl:(UIViewController *)vc{
    self = [super initWithLocation:l distance:dist destination:dest viewControl:vc];
    if (!self) return nil;
    last_played_sound = nil;
    unsafe_spot = nil; //used in the_cop
    direct = NO;
    current_state = 0;
    car_state = 13; //countsdown, not up.
    alarm_state = 0;
    cop_state = 0;
    safehouse_state = 0;
    mission_name = @"The Car";
    
    [self playSong:@"chase_normal"];
    
    //create the safehouse
    safehouse = [[FRPoint alloc] initWithName:@"safehouse"];
    safehouse.pos = endPoint.pos;
    
    
    //pathsearch from the endpoint. used for positioning the car
    FRPathSearch * endmap = [themap createPathSearchAt:endPoint.pos withMaxDistance:nil];
    float dist_to_player = [endmap distanceFromRoot:player.pos];
    NSLog(@"max %f, dest = %f",player_max_distance,dist_to_player);
    
    
    //create the car
    car = [[FRPoint alloc] initWithName:@"car"];
    car.pos = player.pos;
    
    
    
    //randomly move the car until it is properly placed in the map
    //such that it is equally placed from start and end points.
    float dist2 = 0.0;
    float dist1 = 0.0;
    while (dist1+dist2 < player_max_distance*.95 || dist2 > player_max_distance/1.8){
        car.pos = [latestsearch move:player.pos awayFromRootWithDelta:player_max_distance/1.9];
        dist1 = [latestsearch distanceFromRoot:car.pos];
        dist2 = [endmap distanceFromRoot:car.pos];
        NSLog(@"car.pos = %@, dist1 = %f, dist2 = %f",car.pos,dist1,dist2);
    }
    [endmap release];
    
    
    //now create the destination pathsearch.
    destination = [themap createPathSearchAt:car.pos withMaxDistance:[NSNumber numberWithFloat:player_max_distance]];
    
    
    //setup the progress meter
    prog = [[FRProgress alloc] initWithStart:[destination distanceFromRoot:player.pos] delegate:self];
    
    
    //The cop starts at the player's location, but doesnt interact until later.
    cop = [[FRPoint alloc] initWithName:@"cop"];
    cop.pos = player.pos;
    
    //add to the points list for display.
    [points addObject:cop];
    [points addObject:car];
    [points addObject:safehouse];
    
    
    
    NSError * error;
    
    //load the siren
    NSString * p = [[NSBundle mainBundle] pathForResource:@"woowoo" ofType:@"mp3"];
    NSURL * u = [NSURL URLWithString:p];
    siren = [[AVAudioPlayer alloc] initWithContentsOfURL:u error:&error];
    if (error){
        NSLog(@"siren error");
    }
    siren.numberOfLoops = -1;
    [siren prepareToPlay];
    
    //load the alarm
    p = [[NSBundle mainBundle] pathForResource:@"woop" ofType:@"mp3"];
    u = [NSURL URLWithString:p];
    alarm = [[AVAudioPlayer alloc] initWithContentsOfURL:u error:&error];
    if (error){
        NSLog(@"alarm error");
    }
    alarm.numberOfLoops=-1;
    [alarm prepareToPlay];
    
    
    car_time_left = 300; //default to 5 minutes, but this should be depending on difficulty.
    
    
    for (FRPoint * pt in points){
        [pt setCoordinate:[themap coordinateFromEdgePosition:pt.pos]];
    }
    
    [self.viewControl.mapView addAnnotations:points];
    
    
    
    //start working.
    [self ticktock];

    return self;
}
- (void) finishWithText:(NSString*)t{
    //display something. or restart the mission. idk.
}
- (void) ticktock {
    NSLog(@"tick tock");
    NSArray * directions = [destination directionsToRoot:player.pos];
    NSString * direction = [directions objectAtIndex:0];
    if ([direction isEqualToString:@"turn around"]){
        direction = [NSString stringWithFormat:@"turn around and %@",[directions objectAtIndex:1]];
    }
    
    
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
            if (![self readyToSpeak]) break;
            [self speak:@"You failed the mission"];
            [self finishWithText:@"Mission Failed"];
            current_state=10;
            break;
        default:
            [self stopSiren];
            [self playSong:nil];
            NSLog(@"current_state invalid, stopping ticktock");
            return;
    }
    if (direct && [self readyToSpeak]) [self speakIfEmpty:direction];
    
    [super ticktock];
    
}
#pragma mark -

- (void) the_car {
    // start with the introduction.
    
    BOOL bingo = ([destination rootDistanceToLatLng:last_location] < 30 && [current_road isEqualToString:[themap roadNameFromEdgePos:car.pos]]);
    if (bingo) [self speakIfEmpty:@"bingo!"];
    
    float dist = [destination distanceFromRoot:player.pos];
    float progress = dist / player_max_distance / 2.0;
    car_time_left--;
    int timer = car_time_left/60;
    if (![self readyToSpeak]) return;
    switch (car_state) {
        case 13:
            [self playSoundFile:@"A01_car_nearby"];
            car_state--;
            break;
        case 12:
            [self speak:[NSString stringWithFormat:@"your destination is %@. %@",[themap roadNameFromEdgePos:car.pos],[themap descriptionOfEdgePos:car.pos]]];
            car_state--;
            break;
        case 11:
            [self playSoundFile:@"A02_back_soon"];
            car_state--;
            car_state = timer;
            direct = YES;
            break;
        default:
            //speak the time.
            if (timer < car_state) {
                car_state--;
                if (car_state>=0){
                    [self speaktime:timer];
                } else {
                    current_state=4;
                    [self saveMissionStats:@"Did not get to the car in time"];
                    [self playSoundFile:@"A17_too_late"];
                }
            } else {
                [prog update:dist];
            }
            break;
    }
    
    if (dist < 30 || bingo){
        //you made it
        current_state++;
        [destination release];
        destination = [themap createPathSearchAt:safehouse.pos withMaxDistance:[NSNumber numberWithFloat:player_max_distance]];
        [prog release];
        prog = nil;
        direct = NO;
    }
    
}
- (void) the_alarm {
    float alarmdist = [latestsearch distanceFromRoot:car.pos];
    if (![self readyToSpeak]) return;
    switch (alarm_state){
        case 0:
            [self playSoundFile:@"A18_elaborate_plan"];
            alarm_state++;
            break;
        case 1:
            [self startAlarm];
            [self playSoundFile:@"A19_get_out_of_there"];
            alarm_state++;
            direct = YES;
            break;
        case 2:
            // adjust the sound of the alarm with the distance
            // once the distance exceeds 100m, kill, cue the cop.
            alarm.volume = (100.0 - alarmdist) / 100.0;
            if (alarmdist > 100) {
                [self stopAlarm];
                current_state++;
            }
            break;
        default:
            break;
    }
}
- (void) the_cop {
    /*
     
     sometimes it still totally fails and i dont know why.
     
     cop needs to move faster when you are "safe"
     
     
     "stop running so you dont draw attention" "dont move"
     */
    
    
    //if (cop_state>2){
        
    //}
    
    BOOL onpath = [cop_goal edgepos:player.pos isOnPathFromRootTo:cop.pos];
    if (onpath) {
        [unsafe_spot release];
        unsafe_spot = player.pos;
        [unsafe_spot retain];
    }
    NSString * speakstring = nil;
    
    float dist_cop_to_car = [cop_goal distanceFromRoot:cop.pos];
    
    
    
    float dist_cop_to_player = [latestsearch distanceFromRoot:cop.pos];
    float dist_player_to_car = [cop_goal distanceFromRoot:player.pos];
    float dist_player_to_spot = [destination distanceFromRoot:player.pos];
    
    
    switch (cop_state){
        case 0:
            if ([self playSoundFile:@"A20_watch_out_police"]){
                cop_state++;
            }
            break;
            
        case 1:
            if ([self playSoundFile:@"6copahead"]){
                [self startSiren];
                siren.volume = 0.01;
                cop_state++;
            
            
                //the cop is now going to move toward your current location (as of right now)
                if ([latestsearch containsPoint:cop.pos]){
                    cop_goal=latestsearch;
                    [latestsearch retain];
                } else {
                    [self speak:@"COP OUTSIDE SEARCH AREA"];
                    current_state = 4;
                }
                prog=[[FRProgress alloc] initWithStart:dist_cop_to_player delegate:self];
                direct = NO; //stop giving directions
                [destination release];
                destination=nil;
                cop_speed = 10.0;
            }
            break;
        case 2:
            if ([self readyToSpeak]){
                cop_state++;
                [self speak:[NSString stringWithFormat:@"Police activity on %@",[themap roadNameFromEdgePos:cop.pos]]];
            }
            break;
            
        default:

            
            
            NSLog(@"d1 = %f,d2 = %f, d3 = %f",dist_cop_to_player,dist_cop_to_car,dist_player_to_car);
            NSLog(@"You are onpath? %i",onpath);
            NSLog(@"cop is on %@",[themap roadNameFromEdgePos:cop.pos]);
            siren.volume = MAX(0.01,(100-dist_cop_to_player)/100.0);
            
            
            
            
            
            
            if (onpath && dist_cop_to_player < 20 && [self playSoundFile:@"12stoppolice-2"]){
                //cop see you.
                current_state = 4;
                [self saveMissionStats:@"spotted by police"];
                
            } else if (!onpath && dist_cop_to_player > 100 && dist_cop_to_car < dist_player_to_car && [self playSoundFile:@"A22_coast_clear"]) {
                //you are clear
                [self stopSiren];
                current_state++;
                //[destination release];
                destination = [themap createPathSearchAt:safehouse.pos withMaxDistance:[NSNumber numberWithFloat:player_max_distance]];
                direct = YES;
                
            } else if (cop_state==3 && dist_cop_to_player < 100 && onpath && [self readyToSpeak]) {
                
                [self speak:@"You are gonna get caught. get off this road"];
                cop_state = 4;
                cop_speed = 2.0;
                //the cop is going to see you any second now. get off his path.
            
            } else if (cop_state==3 && !onpath && [self readyToSpeak]){
                if ([latestsearch distanceFromRoot:unsafe_spot]>40){
                    cop_state = 5;
                    [self speak:@"You should be safe here"];
                    direct = NO;
                }
            } else {
                
            }
            
            if (dist_cop_to_car > 25){
                FREdgePos * newpos = [cop_goal move:cop.pos towardRootWithDelta:(onpath?cop_speed:20.0)];
                
                
                if (![[themap roadNameFromEdgePos:newpos] isEqualToString:[themap roadNameFromEdgePos:cop.pos]]){
                    
                    [self speak:[NSString stringWithFormat:@"He just turned onto %@",[themap roadNameFromEdgePos:newpos]]];
                    
                    
                } else {
                    NSString * textualchange = [themap descriptionFromEdgePos:cop.pos toEdgePos:newpos];
                    if (textualchange) {
                        [self speak:[NSString stringWithFormat:@"He just went %@",textualchange]];
                    }
                }
                
                cop.pos = newpos;
            }
            
            
            [prog update:dist_cop_to_player];
            break;
    }
}
- (void) the_safehouse {
    float dist = [destination distanceFromRoot:player.pos];
    if (dist < 30) {
        if ([self playSoundFile:@"A23_successful_mission"]) {
            [self saveMissionStats:@"success"];
            current_state=5;
        }
            //what should actually happen when the mission ends successfully?
    }
}

#pragma mark -
- (void) speaktime:(int)t{
    switch(t){
        case 9:
            [self playSoundFile:@"A07_ten_minutes"];
            break;
        case 8:
            [self playSoundFile:@"A08_nine_minutes"];
            break;
        case 7:
            [self playSoundFile:@"A09_eight_minutes"];
            break;
        case 6:
            [self playSoundFile:@"A10_seven_minutes"];
            break;
        case 5:
            [self playSoundFile:@"A11_six_minutes"];
            break;
        case 4:
            [self playSoundFile:@"A12_five_minutes"];
            break;
        case 3:
            [self playSoundFile:@"A13_four_minutes"];
            break;
        case 2:
            [self playSoundFile:@"A14_three_minutes"];
            break;
        case 1:
            [self playSoundFile:@"A15_two_minutes"];
            break;
        case 0:
            [self playSoundFile:@"A16_one_minute"];
            break;
        default:
            break;
    }
}
- (void) startSiren {
    siren.volume = 0.1;
    [siren prepareToPlay];
    [siren play];
}
- (void) stopSiren {
    [siren pause];
}
- (void) startAlarm {
    alarm.volume = 1.0;
    [alarm prepareToPlay];
    [alarm play];
}
- (void) stopAlarm {
    [alarm pause];
}
- (void) dealloc {
    [alarm release];
    [cop release];
    [safehouse release];
    [siren release];
    [car release];
    [unsafe_spot release];
    [cop_goal release];
    [prog release];
    [super dealloc];
}
@end
