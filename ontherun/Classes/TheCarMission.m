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
    cop_speed = -1.0; //negative speed means the cop is inactive. used for state
    [self playSong:@"chase_normal"];
    
    //create the safehouse
    safehouse = [[FRPoint alloc] initWithName:@"safehouse"];
    safehouse.pos = [endPoint.pos copy];
    safehouse.pos.position = MIN(safehouse.pos.position+10,[themap maxPosition:safehouse.pos]);
    player.subtitle = @"Tap to move";
    
    //pathsearch from the endpoint. used for positioning the car
    FRPathSearch * endmap = [themap createPathSearchAt:endPoint.pos withMaxDistance:nil];
    float dist_to_player = [endmap distanceFromRoot:player.pos];
    NSLog(@"max %f, dest = %f",player_max_distance,dist_to_player);
    
    
    //create the car
    car = [[FRPoint alloc] initWithName:@"car"];
    car.pos = player.pos;
    
    
    
    //randomly move the car until it is properly placed in the map
    //such that it is equally placed from start and end points.
    /*
    float dist2 = 0.0;
    float dist1 = 0.0;
    int i=0;
    while ((dist1+dist2 < player_max_distance*.95 || dist2 > player_max_distance/1.8) && i++<100){
        car.pos = [latestsearch move:player.pos awayFromRootWithDelta:player_max_distance/1.9];
        dist1 = [latestsearch distanceFromRoot:car.pos];
        dist2 = [endmap distanceFromRoot:car.pos];
        NSLog(@"car.pos = %@, dist1 = %f, dist2 = %f",car.pos,dist1,dist2);
    }
    
    */
    car.pos = [latestsearch edgePosHalfwayBetweenRootAndOther:endmap withDistance:player_max_distance];
    car.subtitle = @"Plate number 2H4-BGQ";
    [endmap release];
    
    
    //now create the destination pathsearch.
    destination = [themap createPathSearchAt:car.pos withMaxDistance:[NSNumber numberWithFloat:player_max_distance]];
    
    
    //setup the progress meter
    prog = [[FRProgress alloc] initWithStart:[destination distanceFromRoot:player.pos] delegate:self];
    
    
    //The cop starts at the player's location, but doesnt interact until later.
    cop = [[FRPoint alloc] initWithName:@"cop"];
    cop.pos = [endPoint.pos copy];
    cop.pinColor = @"red";
    cop_goal = nil;
    
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
    
    float dist1 = [latestsearch distanceFromRoot:car.pos];
    car_time_left = MAX(300,(int)(dist1/2.5)); //min is 5 minutes
    
    NSLog(@"time to car = %i",car_time_left);
    for (FRPoint * pt in points){
        [pt setCoordinate:[themap coordinateFromEdgePosition:pt.pos]];
    }
    
    //[self.viewControl.mapView addAnnotations:points];
    
    
    
    //start working.
    [self ticktock];

    return self;
}
- (void) finishWithText:(NSString*)t{
    //display something. or restart the mission. idk.
}
- (void) ticktock {
    NSString * direction = [destination whereShouldIGo:player.pos];
    NSLog(@"direction = %@",direction);
    
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
    //if (direct && [self readyToSpeak]) [self speakIfEmpty:direction];
    [self speakDirections];
    if (prog && destination) [prog update:[destination distanceFromRoot:player.pos]];
    [super ticktock];
    
}
#pragma mark -

- (void) the_car {
    // start with the introduction.
    
    BOOL bingo = ([destination rootDistanceToLatLng:last_location] < 30 && [current_road isEqualToString:[themap roadNameFromEdgePos:car.pos]]);
    
    float dist = [destination distanceFromRoot:player.pos];
    float progress = dist / player_max_distance / 2.0;
    car_time_left--;
    int timer = car_time_left/60;
    if (![self readyToSpeak]) return;
    switch (car_state) {
        case 13:
            [self playSoundFile:@"TheCar - alright the car is parked nearby"];
            car_state--;
            break;
        case 12:
            [self speak:[NSString stringWithFormat:@"your destination is %@. %@",[themap roadNameFromEdgePos:car.pos],[themap descriptionOfEdgePos:car.pos]]];
            car_state--;
            break;
        case 11:
            [self playSoundFile:@"TheCar - you dont have much time back soon"];
            car_state--;
            car_state = MIN(timer,10);
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
                    [self playSoundFile:@"TheCar - driver is back forget it"];
                }
            }
            break;
    }
    
    if (dist < 30 || bingo || magic){
        //you made it
        magic = NO;
        current_state++;
        [destination release];
        destination = [themap createPathSearchAt:safehouse.pos withMaxDistance:[NSNumber numberWithFloat:player_max_distance]];
        [prog release];
        prog = [[FRProgress alloc] initWithStart:[destination distanceFromRoot:player.pos] delegate:self];
        direct = NO;
    }
    
}
- (void) the_alarm {
    float alarmdist = [latestsearch distanceFromRoot:car.pos];
    if (![self readyToSpeak]) return;
    switch (alarm_state){
        case 0:
            [self playSoundFile:@"TheCar - thats the car we have to improvise"];
            alarm_state++;
            break;
        case 1:
            [self startAlarm];
            [self playSoundFile:@"TheCar - great now youve got 30 seconds to get the hell out of there"];
            alarm_state++;
            direct = YES;
            break;
        case 2:
            [self speak:[NSString stringWithFormat:@"your destination is %@. %@",[themap roadNameFromEdgePos:destination.root],[themap descriptionOfEdgePos:destination.root]]];
            alarm_state++;
            direct = YES;
            break;
        case 3:
            // adjust the sound of the alarm with the distance
            // once the distance exceeds 100m, kill, cue the cop.
            alarm.volume = MIN(.06,10.0/alarmdist);
            if (alarmdist > 50 && [self playSoundFile:@"TheCar - the police will be checking out that alarm"]) {
                [self startSiren];
                siren.volume = 0.01;
                
                alarm_state++;
            }
            break;
        case 4:
            alarm.volume = MIN(.06,10.0/alarmdist);
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

    float dist_cop_to_car = [cop_goal distanceFromRoot:cop.pos];
    float dist_cop_to_player = [latestsearch distanceFromRoot:cop.pos];
    float dist_player_to_car = [cop_goal distanceFromRoot:player.pos];
    float dist_player_to_spot = [destination distanceFromRoot:player.pos];
    
    
    if (cop_state==0){
        //detect distance to goal. used when we never place the cop.
        if (dist_player_to_spot < 50){
            current_state++;
            return;
        }
    }
    
    
    switch (cop_state){
            
        case 0: {
            //attempt to create a safe spot and cop.
            
            
            if (![self readyToSpeak]) return;
            FREdgePos * goal = player.pos;
            float dist = 0.0;
            int i=0;
            while (goal!=nil && dist < 50 && i++<10){
                goal = [destination move:goal towardRootWithDelta:30.0];
                goal = [destination forkPoint:goal];
                dist = [latestsearch distanceFromRoot:goal];
            }
            //goal.end = fork node
            
            
            
            if (goal==nil) {
                NSLog(@"no fork point available");
                return;
            }
            if (dist > 200) {
                NSLog(@"fork point too far away");
                return;
            }
            if (dist < 50) {
                NSLog(@"fork point too close");
                return;
            }
            
            //start the cop at the same node, but facing the safehouse
            NSNumber * next = [destination closerNode:[goal endObj]];
            FREdgePos * coppos = [[[FREdgePos alloc] init] autorelease];
            coppos.end = [goal end];
            coppos.start = [next intValue];
            coppos.position = [themap maxPosition:coppos];
            
            //move inward, away from the street to ensure that the player is in the right place
            goal = [latestsearch move:goal awayFromRootWithDelta:10.0];
            CLLocationCoordinate2D x = [themap coordinateFromEdgePosition:goal];
            NSLog(@"goal = lat = %f, lon=%f",x.latitude,x.longitude);
            
            //what is the distance to the goal?
            
            
            
            
            float cop_dist = [latestsearch distanceFromRoot:coppos];
            i=0;
            while (cop_dist < 1000 && i++<10){
                coppos = [destination move:coppos towardRootWithDelta:dist*10-cop_dist];
                cop_dist = [latestsearch distanceFromRoot:coppos];
            }
            i=0;
            if (cop_dist < 1000 && i++<10){
                coppos = [latestsearch move:coppos awayFromRootWithDelta:100.0];
                cop_dist = [latestsearch distanceFromRoot:coppos];
            }
            NSLog(@"dist = %f, cop_dist = %f",dist,cop_dist);
            
            cop_speed = MIN(10.0,cop_dist / (dist / 2.0) * .75);
            cop.pos = coppos;
            
            if ([latestsearch containsPoint:cop.pos]){
                cop_goal=latestsearch;
                [latestsearch retain];
            } else {
                NSLog(@"cop outside search area");
                [self speak:@"COP OUTSIDE SEARCH AREA"];
                current_state = 4;
                return;
            }
            
            
            [destination release];
            destination = [themap createPathSearchAt:goal withMaxDistance:[NSNumber numberWithFloat:400.0]];
            [prog release];
            prog = [[FRProgress alloc] initWithStart:dist delegate:self];
            [self soundfile:@"TheCar - ive detected a police car you need to get off its course"];
            cop_state++;
            break;
        }
        case 1:
            if ([self readyToSpeak]){
                cop_state++;
                
                [self speak:[NSString stringWithFormat:@"Police activity on %@",[themap roadNameFromEdgePos:cop.pos]]];
            }
            break;
            
        case 2:
            if ([self readyToSpeak]){
                cop_state++;
                [self speak:[NSString stringWithFormat:@"your destination is %@. %@",[themap roadNameFromEdgePos:destination.root],[themap descriptionOfEdgePos:destination.root]]];
            }
        default:

            
            
            NSLog(@"cop is on %@",[themap roadNameFromEdgePos:cop.pos]);
            siren.volume = MIN(0.60,10.0/dist_cop_to_player);
            
            
            
            
            
            if (!magic && onpath && dist_cop_to_player < 10 && [self playSoundFile:@"12stoppolice-2"]){
                //cop see you.
                current_state = 4;
                [self saveMissionStats:@"spotted by police"];
                
            } else if (!onpath && dist_cop_to_player > 100 && dist_cop_to_car < dist_player_to_car && [self playSoundFile:@"TheCar - that does it - the coast is clear"]) {
                //you are clear
                [self stopSiren];
                magic = NO;
                current_state++;
                //[destination release];
                destination = [themap createPathSearchAt:safehouse.pos withMaxDistance:[NSNumber numberWithFloat:player_max_distance]];
                [prog release];
                prog = [[FRProgress alloc] initWithStart:[destination distanceFromRoot:player.pos] delegate:self];
                direct = YES;
                
            } else if (cop_state==3 && dist_cop_to_player < 100 && onpath && [self readyToSpeak]) {
                
                [self soundfile:@"TheCar - hes coming - get off this road"];
                cop_state = 4;
                cop_speed = 2.0;
                //the cop is going to see you any second now. get off his path.
            
            } else if (cop_state==3 && !onpath && [self readyToSpeak]){
                if ([latestsearch distanceFromRoot:unsafe_spot]>40){
                    cop_state = 5;
                    [self soundfile:@"TheCar - ok you should be safe here for now"];
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
            break;
    }
}
- (void) the_safehouse {
    float dist = [destination distanceFromRoot:player.pos];
    BOOL bingo = ([destination rootDistanceToLatLng:last_location] < 30 && [current_road isEqualToString:[themap roadNameFromEdgePos:car.pos]]);
    if (safehouse_state==0 && [self readyToSpeak]){
        [self speak:[NSString stringWithFormat:@"your destination is %@. %@",[themap roadNameFromEdgePos:destination.root],[themap descriptionOfEdgePos:destination.root]]];
        safehouse_state++;
    }
    if (magic || dist < 30 || bingo) {
        if ([self playSoundFile:@"TheCar - successful mission"]) {
            [self saveMissionStats:@"success"];
            current_state=5;
            magic = YES;
        }
            //what should actually happen when the mission ends successfully?
    }
}

#pragma mark -
- (void) speaktime:(int)t{
    switch(t){
        case 9:
            [self playSoundFile:@"10 minutes"];
            break;
        case 8:
            [self playSoundFile:@"9 minutes"];
            break;
        case 7:
            [self playSoundFile:@"8 minutes"];
            break;
        case 6:
            [self playSoundFile:@"7 minutes"];
            break;
        case 5:
            [self playSoundFile:@"6 minutes"];
            break;
        case 4:
            [self playSoundFile:@"5 minutes"];
            break;
        case 3:
            [self playSoundFile:@"4 minutes"];
            break;
        case 2:
            [self playSoundFile:@"3 minutes"];
            break;
        case 1:
            [self playSoundFile:@"2 minutes"];
            break;
        case 0:
            [self playSoundFile:@"1 minute"];
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
