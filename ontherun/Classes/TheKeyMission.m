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
 
 1. how many places? more places means more pathsearchs to place the points
 2. the final chase needs to be of a certain length
 3. the chase needs to be interesting
 4. James Bond!
 5. 
 
 
 
 A B and C
 
 B needs to be dist/2 from start
 C needs to be dist/2 from A
 A and B are dist/4
 C and B are dist/4
 A and start are dist/4
 
 
 
 */

@implementation TheKeyMission

- (id) initWithLocation:(CLLocation *)l distance:(float)dist destination:(CLLocation *)dest viewControl:(UIViewController *)vc{
    self = [super initWithLocation:l distance:dist destination:dest viewControl:vc];
    if (!self) return nil;
    
    
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
    while (dist1+dist2 < player_max_distance*.95 || dist2 > player_max_distance/1.8){
        pointC.pos = [latestsearch move:player.pos awayFromRootWithDelta:player_max_distance/1.9];
        dist1 = [latestsearch distanceFromRoot:pointC.pos];
        dist2 = [endmap distanceFromRoot:pointC.pos];
        NSLog(@"pos = %@, dist1 = %f, dist2 = %f",pointC.pos,dist1,dist2);
    }
    [endmap release];
    
    pointA.pos = [latestsearch move:pointC.pos towardRootWithDelta:player_max_distance/4.0];
    pointB.pos = [latestsearch move:pointC.pos towardRootWithDelta:player_max_distance/2.0];
    
    
    destination = [themap createPathSearchAt:pointA.pos withMaxDistance:[NSNumber numberWithFloat:player_max_distance]];
    
    safehouse = [[FRPoint alloc] initWithName:@"safehouse"];
    safehouse.pos = endPoint.pos;
    
    dude = [[FRPoint alloc] initWithName:@"dude"];
    dude.pos = pointC.pos;
    
    
    //position these points such that the total distance is correct
    //th final run should be the longest part. that chase sequence needs to last awhile.
    
    //have this done on the server, since i dont feel like programming constraints in objC
    
    
    
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
    
    [super ticktock];
}
#pragma mark -
- (void) the_first {
    float dist;
    //if (![self readyToSpeak]) return;
    switch (sub_state){
        case 0:
            //say some shit
            NSLog(@"ok, got some points. go get them");
            sub_state++;
            break;
        case 1:
            NSLog(@"your destination is %@",[themap roadNameFromEdgePos:pointA.pos]);
            
            sub_state++;
            break;
        case 2:
            dist = [destination distanceFromRoot:player.pos];
            NSLog(@"dist = %f",dist);
            if (dist < 30) {
                NSLog(@"thats the place. try the key. Click. Fuck, next place");
                
                sub_state=0;
                [destination release];
                destination = [themap createPathSearchAt:pointB.pos withMaxDistance:[NSNumber numberWithFloat:player_max_distance]];
                main_state++;
            }
            //say some shit
            break;
        default:
            break;
    }
}
- (void) the_second {
    float dist;
    //if (![self readyToSpeak]) return;
    switch (sub_state){
        case 0:
            NSLog(@"your destination is %@",[themap roadNameFromEdgePos:pointB.pos]);
            
            sub_state++;
            break;
        case 1:
            dist = [destination distanceFromRoot:player.pos];
            NSLog(@"dist = %f",dist);
            
            if (dist < 30) {
                NSLog(@"this is it. Cant you unlock it? Click. Crap, move on");
                
                sub_state=0;
                [destination release];
                destination = [themap createPathSearchAt:pointC.pos withMaxDistance:[NSNumber numberWithFloat:player_max_distance]];
                main_state++;
            }
            break;
        default:
            break;
    }   
}
- (void) the_third {
    float dist;
    //if (![self readyToSpeak]) return;
    switch (sub_state){
        case 0:
            //say some shit
            NSLog(@"Alright there are two more.");
            sub_state++;
            break;
        case 1:
            NSLog(@"your destination is %@",[themap roadNameFromEdgePos:pointC.pos]);
            sub_state++;
            break;
        case 2:
            dist = [destination distanceFromRoot:player.pos];
            NSLog(@"dist = %f",dist);
            
            if (dist < 30) {
                NSLog(@"here we are. give it a shot. cha-cha. Interesting...");
                
                sub_state=0;
                [destination release];
                destination = [themap createPathSearchAt:safehouse.pos withMaxDistance:[NSNumber numberWithFloat:player_max_distance]];
                dude.pos = [destination move:player.pos awayFromRootWithDelta:30.0];
                dude_speed = 4.0;
                xdist = 30.0;
                //[self playSong:@"scaryshit"];
                main_state++;
            }
            //say some shit
            break;
        default:
            break;
    }   
}
- (void) the_chase {
    float dist;
    float dist_dude_to_safehouse;
    switch (sub_state){
        case 0:
            NSLog(@"WHO THE FUCK ARE YOU!");
            sub_state++;
            break;
        case 1:
            NSLog(@"oh shiiit, get out of there!");
            sub_state++;
            break;
        case 2:
            dude.pos = [latestsearch move:dude.pos towardRootWithDelta:dude_speed];
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
            if (dist < 10){
                
                NSLog(@"I GOT YOU FUCKER!");
                main_state=5;
                return;
            }
            if (dist < .75 * xdist){
                 NSLog(@"he is gaining on you.");
                 xdist = dist;
            } else if (xdist < .75 * dist){
                 NSLog(@"you are losing him");
                 xdist = dist;
            }
            
            if (dist > 150){
                NSLog(@"you lost him");
                sub_state++;
            }
        
            
            dist_dude_to_safehouse = [destination distanceFromRoot:dude.pos];
            if (dist_dude_to_safehouse<100 && dude_speed>1.1){
                dude_speed=1.0;
                NSLog(@"he is slowing down");
            } 
            
            if (dist_dude_to_safehouse<50 && dude_speed>0){
                dude_speed =0;
                NSLog(@"he stopped. weird.");
                sub_state++;
            }
             
             
            
            break;
        case 3:
            NSLog(@"keep going to the safehouse");
            sub_state++;
            break;
        case 4:
            dist = [destination distanceFromRoot:player.pos];
            NSLog(@"dist = %f",dist);
            
            if (dist < 30){
                NSLog(@"you made it. ima look at the data");
                main_state++;
                sub_state=0;
            }
        default:
            break;
    }    
}
@end
