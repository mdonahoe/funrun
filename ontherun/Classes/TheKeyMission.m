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
    int i=0;
    while ((dist1+dist2 < player_max_distance*.95 || dist2 > player_max_distance/1.8) && i++<100){
        start = [themap flipEdgePos:start];
        pointC.pos = [latestsearch move:start awayFromRootWithDelta:player_max_distance/1.9];
        dist1 = [latestsearch distanceFromRoot:pointC.pos];
        dist2 = [endmap distanceFromRoot:pointC.pos];
        NSLog(@"pos = %@, dist1 = %f, dist2 = %f",pointC.pos,dist1,dist2);
    }
    [endmap release];
    
    float rundist = [latestsearch distanceFromRoot:pointC.pos];
    
    pointA.pos = [latestsearch move:pointC.pos towardRootWithDelta:2*rundist/3.0];
    pointA.pos = [latestsearch move:pointA.pos awayFromRootWithDelta:0.0]; //face away
    
    pointB.pos = [latestsearch move:pointC.pos towardRootWithDelta:1*rundist/3.0];
    pointB.pos = [latestsearch move:pointB.pos awayFromRootWithDelta:0.0]; //face away
    
    
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
    //[self.viewControl.mapView addAnnotations:points];
    
    
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
            [self playSong:nil];
            return;
            break;
    }
    if ([self readyToSpeak]){
        
        NSArray * directions = [destination directionsToRoot:player.pos];
        NSString * direction = [directions objectAtIndex:0];
        if ([direction isEqualToString:@"turn around"]){
            direction = [NSString stringWithFormat:@"%@",[directions objectAtIndex:1]];
        }
        [self speakIfEmpty:direction];
    }
    [super ticktock];
}
#pragma mark -
- (void) the_first {
    float dist;
    BOOL bingo = ([destination rootDistanceToLatLng:last_location] < 30 && [current_road isEqualToString:[themap roadNameFromEdgePos:pointA.pos]]);
    
    if (![self readyToSpeak]) return;
    switch (sub_state){
        case 0:
            //intro
            [self soundfile:@"TheKey - from what i can tell - the first house is nearby"];
            [self playSong:@"chase_normal"];
            sub_state++;
            break;
        case 1:
            [self speak:[NSString stringWithFormat:@"your destination is %@. %@",[themap roadNameFromEdgePos:pointA.pos],[themap descriptionOfEdgePos:pointA.pos]]];
            
            sub_state++;
            break;
        case 2:
            if ([self playSoundFile:@"TheKey - i sent a location to your gps - remember to bring that key"]) sub_state++;
            break;
        case 3:
            dist = [destination distanceFromRoot:player.pos];
            [prog update:dist];
            if ((magic || (dist < 30) || bingo) && [self playSoundFile:@"TheKey - ok this is the first location - try the key"]) sub_state++;
            break;
        case 4:
            if ([self playSoundFile:@"TheKey - did that work"]) sub_state++;
            break;
        case 5:
            if ([self playSoundFile:@"TheKey - alright this place is no good"]) sub_state++;
            break;
        case 6:
            magic = NO;
            [self soundfile:@"TheKey - hmm - ok lets try the another place"];
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
    BOOL bingo = ([destination rootDistanceToLatLng:last_location] < 30 && [current_road isEqualToString:[themap roadNameFromEdgePos:pointB.pos]]);
    
    if (![self readyToSpeak]) return;
    
    switch (sub_state){
        case 0:
            [self speak:[NSString stringWithFormat:@"your destination is %@. %@",[themap roadNameFromEdgePos:pointB.pos],[themap descriptionOfEdgePos:pointB.pos]]];
            
            sub_state++;
            break;
        case 1:
            dist = [destination distanceFromRoot:player.pos];
            [prog update:dist];
            
            if (magic || dist < 30 || bingo) {
                [self soundfile:@"TheKey - there should be a storage unit i think - no keep moving2"];
                magic = NO;
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
    BOOL bingo = ([destination rootDistanceToLatLng:last_location] < 30 && [current_road isEqualToString:[themap roadNameFromEdgePos:pointC.pos]]);
    
    if (![self readyToSpeak]) return;
    
    switch (sub_state){
        case 0:
            [self speak:[NSString stringWithFormat:@"your destination is %@. %@",[themap roadNameFromEdgePos:pointC.pos],[themap descriptionOfEdgePos:pointC.pos]]];
            sub_state++;
            break;
        case 1:
            [self soundfile:@"TheKey - i always get east and west confused - keep moving"];
            
            sub_state++;
            break;
        case 2:
            dist = [destination distanceFromRoot:player.pos];
            
            [prog update:dist];
            
            if (magic || dist < 30 || bingo) {
                magic = NO;
                [self soundfile:@"TheKey - ok this is it - try the key"];
                [self playSong:@"chase_elevated"];
                sub_state++;
            } else if (dist < 100){
                //[self speak:@"getting close"];
            }
            break;
        case 3:
            [self soundfile:@"TheKey - huh thats interesting - do you see anything inside"];
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
    
    BOOL bingo = ([destination rootDistanceToLatLng:last_location] < 30 && [current_road isEqualToString:[themap roadNameFromEdgePos:safehouse.pos]]);
    
    
    switch (sub_state){
        case 0:
            if ([self playSoundFile:@"TheKey - oh shit - picking up guard radio - get to the safehouse"]) {
                //instead of playing immediately, play music after hes done speaking?
                [self playSong:@"chase_scary"];
                sub_state++;
            }
            break;
        case 1:
            if (chase_ticks++>5 && [self playSoundFile:@"BadGuy - hey you - get outta there"]){
                sub_state++;
            }
            break;
        case 2:
            dist = [latestsearch distanceFromRoot:dude.pos];
            if (dist > 30) sub_state++;
            
            if (![self readyToSpeak]) return;
            
            if (chase_ticks++ > 10){
                [self soundfile:@"BadGuy - i gotcha"];
                [self saveMissionStats:@"Caught by the guard"];
                
                main_state=5;
            } else if (chase_ticks>5){
                [self soundfile:@"TheKey - go"];
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
            
            if (dist < 4){
                
                [self soundfile:@"BadGuy - gotcha"];
                [self saveMissionStats:@"The guard caught up to you"];
                
                main_state=5;
                return;
            } else if (dist < 20){
                dude_speed = 0.1;
                [self soundfile:@"BadGuy - youre mine now"]; 
            }
            
            
            
            //gaining/losing him. might want to randomize the sound files
            if (dist < .75 * xdist){
                [self soundfile:@"TheKey - hes gaining on you"]; 
                xdist = dist;
            } else if (xdist < .75 * dist){
                [self soundfile:@"TheKey - youre losing him"];
                 xdist = dist;
                dude_speed = 4.0;
            }
            
            if (dist > 150){
                [self soundfile:@"TheKey - great - you lost him"];
                [self playSong:@"chase_elevated"];
                sub_state++;
            }
        
            
            dist_dude_to_safehouse = [destination distanceFromRoot:dude.pos];
            if (dist_dude_to_safehouse<100 && dude_speed>1.1){
                dude_speed=1.0;
                [self soundfile:@"TheKey - hes slowing down but this aint over"];
            } 
            
            if (dist_dude_to_safehouse<50 && dude_speed>0){
                dude_speed = 0;
                [self soundfile:@"TheKey - great - you lost him"];
                sub_state++;
                [self playSong:@"chase_elevated"];
            }
            
            
            dist_player_to_safehouse = [destination distanceFromRoot:player.pos];
            [prog update:dist_player_to_safehouse];
            if (magic || dist_player_to_safehouse < 30 || bingo){
                sub_state=5;
            }
            
            break;
        case 4:
            [self soundfile:@"TheKey - now get back to the safehouse"];
            
            sub_state++;
            break;
        case 5:
            dist = [destination distanceFromRoot:player.pos];
            [prog update:dist];
            BOOL bingo = ([destination rootDistanceToLatLng:last_location] < 30 && [current_road isEqualToString:[themap roadNameFromEdgePos:safehouse.pos]]);
            
            if (magic || dist < 30 || bingo){
                magic = NO;
                [self soundfile:@"TheKey - did go as planned - talk to you soon"];
                [self saveMissionStats:@"success"];
                
                main_state++;
                sub_state=0;
            }
        default:
            break;
    }    
}


#pragma mark -
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
