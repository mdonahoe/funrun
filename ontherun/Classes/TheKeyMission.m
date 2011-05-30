//
//  TheKeyMission.m
//  ontherun
//
//  Created by Matt Donahoe on 5/13/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "TheKeyMission.h"


/*
 what happens in this mission?
 
 check out a number of locations.
 then get chased.
 outrun that person
 go home.
 
 */

@implementation TheKeyMission

- (id) initWithLocation:(CLLocation *)l distance:(float)dist destination:(CLLocation *)dest viewControl:(UIViewController *)vc{
    self = [super initWithLocation:l distance:dist destination:dest viewControl:vc];
    if (!self) return nil;
    
    mission_name = @"The Key";
    
    pointA = [[FRPoint alloc] initWithName:@"first"];
    pointB = [[FRPoint alloc] initWithName:@"second"];
    pointC = [[FRPoint alloc] initWithName:@"third"];
    
    
    //pathsearch from the endpoint. used for positioning the car
    FRPathSearch * endmap = [themap createPathSearchAt:endPoint.pos withMaxDistance:nil];
    float dist_to_player = [endmap distanceFromRoot:player.pos];
    NSLog(@"max %f, dest = %f",player_max_distance,dist_to_player);
    
    //randomly move the last point until it is properly placed in the map
    //such that it is equally placed from start and end points.
    float dist2 = 0.0;
    float dist1 = 0.0;
    FREdgePos * start = [themap flipEdgePos:player.pos];
    while (dist1+dist2 < player_max_distance*.95 || dist2 > player_max_distance/1.8){
        start = [themap flipEdgePos:start];
        pointC.pos = [latestsearch move:start awayFromRootWithDelta:player_max_distance/1.9];
        dist1 = [latestsearch distanceFromRoot:pointC.pos];
        dist2 = [endmap distanceFromRoot:pointC.pos];
        NSLog(@"pos = %@, dist1 = %f, dist2 = %f",pointC.pos,dist1,dist2);
    }
    [endmap release];
    
    float rundist = [latestsearch distanceFromRoot:pointC.pos];
    
    pointA.pos = [latestsearch move:pointC.pos towardRootWithDelta:2*rundist/3.0];
    pointB.pos = [latestsearch move:pointC.pos towardRootWithDelta:1*rundist/3.0];
    
    
    destination = [themap createPathSearchAt:pointA.pos withMaxDistance:[NSNumber numberWithFloat:player_max_distance]];
    
    safehouse = [[FRPoint alloc] initWithName:@"safehouse"];
    safehouse.pos = endPoint.pos;
    
    dude = [[FRPoint alloc] initWithName:@"dude"];
    dude.pos = pointC.pos;
    
    prog = [[FRProgress alloc] initWithStart:[destination distanceFromRoot:player.pos] delegate:self];
    
    //position these points such that the total distance is correct
    //the final run should be the longest part. that chase sequence needs to last awhile.
    
    //add dude to map
    [dude setCoordinate:[themap coordinateFromEdgePosition:dude.pos]];
    [points addObject:dude];
    [self.viewControl.mapView addAnnotations:points];
    
    
    [self ticktock];
    return self;
}
- (void) ticktock {
    switch (main_state){
        case 0:
            [self the_first];
            break;
        case 1:
            [self the_second];
            break;
        case 2:
            [self the_third];
            break;
        case 3:
            [self the_chase];
            break;
        default:
            NSLog(@"its over!");
            return;
            break;
    }
    if ([self readyToSpeak]){
        
        NSArray * directions = [destination directionsToRoot:player.pos];
        NSString * direction = [directions objectAtIndex:0];
        if ([direction isEqualToString:@"turn around"]){
            direction = [NSString stringWithFormat:@"turn around and %@",[directions objectAtIndex:1]];
        }
        [self speakIfEmpty:direction];
    }
    [super ticktock];
}
#pragma mark -
- (void) the_first {
    float dist;
    if (![self readyToSpeak]) return;
    switch (sub_state){
        case 0:
            //intro
            [self soundfile:@"B01"];
            [self playSong:@"chase_normal"];
            sub_state++;
            break;
        case 1:
            [self speak:[NSString stringWithFormat:@"your destination is %@",[themap roadNameFromEdgePos:pointA.pos]]];
            
            sub_state++;
            break;
        case 2:
            dist = [destination distanceFromRoot:player.pos];
            [prog update:dist];
            NSLog(@"dist = %f",dist);
            if ((dist < 30) && [self playSoundFile:@"B06"]) sub_state++;
            break;
        case 3:
            [self soundfile:@"B10"];
            sub_state=0;
            [destination release];
            destination = [themap createPathSearchAt:pointB.pos withMaxDistance:[NSNumber numberWithFloat:player_max_distance]];
            main_state++;
            [prog release];
            prog = [[FRProgress alloc] initWithStart:[destination distanceFromRoot:player.pos] delegate:self];
            break;
        default:
            break;
    }
}
- (void) the_second {
    float dist;
    if (![self readyToSpeak]) return;
    
    switch (sub_state){
        case 0:
            NSLog(@"your destination is %@",[themap roadNameFromEdgePos:pointB.pos]);
            [self speak:[NSString stringWithFormat:@"your destination is %@",[themap roadNameFromEdgePos:pointB.pos]]]; 
            
            sub_state++;
            break;
        case 1:
            dist = [destination distanceFromRoot:player.pos];
            NSLog(@"dist = %f",dist);
            [prog update:dist];
            
            if (dist < 30) {
                NSLog(@"this is it. Cant you unlock it? Click. Crap, move on");
                [self soundfile:@"B07"];
                sub_state=0;
                [destination release];
                destination = [themap createPathSearchAt:pointC.pos withMaxDistance:[NSNumber numberWithFloat:player_max_distance]];
                main_state++;
                [prog release];
                prog = [[FRProgress alloc] initWithStart:[destination distanceFromRoot:player.pos] delegate:self];
                
            }
            break;
        default:
            break;
    }   
}
- (void) the_third {
    float dist;
    if (![self readyToSpeak]) return;
    
    switch (sub_state){
        case 0:
            NSLog(@"Alright there are two more.");
            [self soundfile:@"B11"];
            sub_state++;
            break;
        case 1:
            NSLog(@"your destination is %@",[themap roadNameFromEdgePos:pointC.pos]);
            [self speak:[NSString stringWithFormat:@"your destination is %@",[themap roadNameFromEdgePos:pointC.pos]]]; 
            sub_state++;
            break;
        case 2:
            dist = [destination distanceFromRoot:player.pos];
            NSLog(@"dist = %f",dist);
            
            [prog update:dist];
            
            if (dist < 30) {
                NSLog(@"here we are. give it a shot. cha-cha. Interesting...");
                [self soundfile:@"B08"];
                [self playSong:@"chase_elevated"];
                sub_state++;
            } else if (dist < 100){
                //[self speak:@"getting close"];
            }
            break;
        case 3:
            [self soundfile:@"B12"];
            sub_state=0;
            [destination release];
            destination = [themap createPathSearchAt:safehouse.pos withMaxDistance:[NSNumber numberWithFloat:player_max_distance]];
            dude.pos = player.pos;
            dude_speed = 4.0;
            xdist = 30.0;
            main_state++;
            chase_ticks=0;
            [prog release];
            prog = [[FRProgress alloc] initWithStart:[destination distanceFromRoot:player.pos] delegate:self];
            
            break;
            
        default:
            break;
    }   
}
- (void) the_chase {
    float dist;
    float dist_dude_to_safehouse;
    float dist_player_to_safehouse;
    FREdgePos * newpos;
    NSString * textualchange;
    switch (sub_state){
        case 0:
            if ([self playSoundFile:@"E01"]) {
                [self playSong:@"chase_scary"];
                sub_state++;
            }
            break;
        case 1:
            NSLog(@"oh shiiit, get out of there!");
            if ([self playSoundFile:@"B13"]) sub_state++;
            break;
        case 2:
            dist = [latestsearch distanceFromRoot:dude.pos];
            if (dist > 30) sub_state++;
            
            if (![self readyToSpeak]) return;
            
            if (chase_ticks++ > 10){
                [self speak:@"YOU LOSE"];
                [self saveMissionStats:@"Caught by the guard"];
                
                main_state=5;
            } else if (chase_ticks>5){
                [self speak:@"run run run"];
            }
            break;
        case 3:
            
            newpos = [latestsearch move:dude.pos towardRootWithDelta:dude_speed];
            dist = [latestsearch distanceFromRoot:dude.pos];
            /*
             
             types of things to say:
                if he is gaining on you
                if you are losing him
                if you get close to you house, he slows down.
                
             
                if he catches you, you lose
                if you get away, he stops
                if he gets too close to the safehouse he slows down or stops
             */
            
            if (![[themap roadNameFromEdgePos:newpos] isEqualToString:[themap roadNameFromEdgePos:dude.pos]]){
                
                [self speak:[NSString stringWithFormat:@"He just turned onto %@",[themap roadNameFromEdgePos:newpos]]];
                
                
            } else {
                textualchange = [themap descriptionFromEdgePos:dude.pos toEdgePos:newpos];
                if (textualchange) {
                    [self speak:[NSString stringWithFormat:@"He just went %@",textualchange]];
                }
            }
            
            dude.pos = newpos;
            
            if (![self readyToSpeak]) return;
            
            if (dist < 10){
                
                NSLog(@"I GOT YOU FUCKER!");
                [self soundfile:@"E06"];
                [self saveMissionStats:@"The guard caught up to you"];
                
                main_state=5;
                return;
            } else if (dist < 20){
                dude_speed = 2.0;
                [self soundfile:@"E03"]; //"you cant outrun me"
            }
            
            
            
            //gaining/losing him. might want to randomize the sound files
            if (dist < .75 * xdist){
                 NSLog(@"he is gaining on you.");
                [self soundfile:@"B16"]; 
                xdist = dist;
            } else if (xdist < .75 * dist){
                 NSLog(@"you are losing him");
                [self soundfile:@"B23"];
                 xdist = dist;
                dude_speed = 4.0;
            }
            
            if (dist > 150){
                NSLog(@"you lost him");
                [self soundfile:@"B24"];
                [self playSong:@"chase_elevated"];
                sub_state++;
            }
        
            
            dist_dude_to_safehouse = [destination distanceFromRoot:dude.pos];
            if (dist_dude_to_safehouse<100 && dude_speed>1.1){
                dude_speed=1.0;
                [self soundfile:@"B19"];
                NSLog(@"he is slowing down");
            } 
            
            if (dist_dude_to_safehouse<50 && dude_speed>0){
                dude_speed = 0;
                NSLog(@"You lost him.");
                [self soundfile:@"B24"];
                sub_state++;
                [self playSong:@"chase_elevated"];
            }
            
            
            dist_player_to_safehouse = [destination distanceFromRoot:player.pos];
            [prog update:dist_player_to_safehouse];
            if (dist_player_to_safehouse < 30){
                sub_state=5;
            }
            
            break;
        case 4:
            NSLog(@"keep going to the safehouse");
            [self soundfile:@"B27"];
            
            sub_state++;
            break;
        case 5:
            dist = [destination distanceFromRoot:player.pos];
            NSLog(@"dist = %f",dist);
            [prog update:dist];
            if (dist < 30){
                [self soundfile:@"B28"];
                [self playSong:@"chase_normal"];
                NSLog(@"you made it. ima look at the data");
                [self saveMissionStats:@"success"];
                
                main_state++;
                sub_state=0;
            }
        default:
            break;
    }    
}


#pragma mark -
- (void) soundfile:(NSString*)filename{
    [soundfx release];
    NSError *error;
    NSString * s = [[NSBundle mainBundle] pathForResource:filename ofType:@"aiff"];
    NSURL * x = [NSURL fileURLWithPath:s];
    soundfx = [[AVAudioPlayer alloc] initWithContentsOfURL:x error:&error];
    soundfx.volume = 1.0;
    [soundfx prepareToPlay];
    [soundfx play];
}
- (void) dealloc {
    [pointA release];
    [pointB release];
    [pointC release];
    [safehouse release];
    [dude release];
    [prog release];
    [super dealloc];
}
@end
