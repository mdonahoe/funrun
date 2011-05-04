//
//  FRMissionDownload.m
//  ontherun
//
//  Created by Matt Donahoe on 4/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


// lead the cop away from the destination
// prevent repeat directions
// audio versions of "turn around" and distances
// fix the map
// fix the front page
// possible to lose
// he is out of sight. make another turn to lose him.
// audioroute stuff is going to fuck it up (push headphone button, starts ipod, press again... dead)
// home location, and cops that chase you.
// make audio fade before transitions
// add home.
// map dual streets? edit the map data.
// continue on whatever to your desintation. lame
// 

#import "FRMissionDownload.h"
#import "FRMapViewController.h"
#import "FRSummaryViewController.h"

@implementation FRMissionDownload

- (id)initWithLocation:(CLLocation *)l distance:(float)dist destination:(CLLocation*)dest viewControl:(UIViewController *)vc{
	self = [super initWithLocation:l distance:dist destination:dest viewControl:vc];
	if (!self) return nil;
	[self.viewControl setText:@"Get to the thief's hideout and return safely."];
    current_state = 0;
    intro_state = 0;
    cop_state = 0;
    chase_state = 0;
    
    cop_spotted = NO;
    [self playSong:@"chase_normal"];
    
    //create the safehouse
    safehouse = [[FRPoint alloc] initWithName:@"safehouse"];
    safehouse.pos = endPoint.pos;
    
    player_speed = 2.0;
    //player_distance = 2000.0; //1.25 miles
    
    
    
    //create the destination
    hideout = [[FRPoint alloc] initWithName:@"hideout"];
    hideout.pos = player.pos;
    float distance = 0.0;
    while (distance < player_max_distance/2){
        hideout.pos = [latestsearch move:player.pos awayFromRootWithDelta:player_max_distance/1.9];
        distance = [latestsearch distanceFromRoot:hideout.pos];
        NSLog(@"hideout.pos = %@, dist = %f",hideout.pos,distance);
    }
    progress_dist = distance;
    progress_date = [[NSDate alloc] init];
    destination = [themap createPathSearchAt:hideout.pos withMaxDistance:[NSNumber numberWithFloat:player_max_distance]];
    
    start_date = [[NSDate alloc] init];
    cop = [[FRPoint alloc] initWithName:@"cop"];
    
    //maybe make the cop position random?
    cop.pos = hideout.pos;
    
    [points addObject:cop];
    [points addObject:hideout];
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
    float dist;
    NSArray * directions = [destination directionsToRoot:player.pos];
    NSString * direction = [directions objectAtIndex:0];
    if ([direction isEqualToString:@"turn around"]){
        //direction = [NSString stringWithFormat:@"%@ and %@", direction, [directions objectAtIndex:1]];
        direction = [directions objectAtIndex:1];
        //ulysses needs to say that you are going the wrong way.
    }
    if (intro_state > 2) [self speakIfEmpty:direction];
    
    switch (current_state){
        case 0:
            [self the_intro];
            break;
        case 1:
            dist = [latestsearch distanceFromRoot:hideout.pos];
            NSLog(@"directions = %@, progress = %f",directions,[progress_date timeIntervalSinceNow]);
            if ([progress_date timeIntervalSinceNow] < -10){
                if (dist - progress_dist > 20){
                    //dist != weight, so they may actually be going the right way
                    [self speak:@"turn around, you idiot!"];
                }
                [progress_date release];
                progress_date = [[NSDate alloc] init];
                progress_dist = dist;
            }
            [self the_cop]; //integrate the rest of this case into the_cop
            if (dist < 30) {
                if (cop_state > 0){
                    [self speak:@"we cant do the download if you are being chased. failed"];
                    [self finishWithText:@"Mission Failed:\n cop watching the drop zone"];
                    return;
                } else {
                    current_state++;
                    hideout_date = [[NSDate alloc] init];
                }
            } else if (dist < 100){
                [self speakIfEmpty:[NSString stringWithFormat:@"The target is %i meters %@ you",(int)dist,[latestsearch directionFromRoot:hideout.pos]]];
            }
            break;
        case 2:
            [self the_download];
            break;
        case 3:
            [self the_chase];
            break;
        case 4:
            dist = [destination distanceFromRoot:player.pos];
            if (dist < 30){
                [self ulyssesSpeak:@"16greatwork"];
                current_state = 10;
                //you win!
                [self finishWithText:[NSString stringWithFormat:@"Mission Complete\nDuration:%f",[start_date timeIntervalSinceNow]]];
            }
            break;
        case 5:
            //you lost the mission
            [self speak:@"You failed the mission"];
            current_state=10;
        default:
            [self stopSiren];
            [_music release];
            _music = nil;
            NSLog(@"current_state invalid, stopping ticktock");
            return;
    }
    [super ticktock];
}
- (void) finishWithText:(NSString *)text{
    FRSummaryViewController * summary =
    [[FRSummaryViewController alloc] initWithNibName:@"FRSummaryViewController" bundle:nil];
    [self.viewControl.navigationController pushViewController:summary animated:YES];
    self.viewControl.navigationItem.rightBarButtonItem = nil;
    self.viewControl = summary;
    summary.status.text = text;
    [summary release];
    [toBeSpoken removeAllObjects];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}


- (void) restartMission {
    [self speak:@"the mission will restart in 10 seconds. Think about how shitty you are"];
}
# pragma mark -
# pragma mark sequences
- (void) the_intro {
    //play ulysses' sound files one after another.
    NSTimeInterval timediff = ABS([start_date timeIntervalSinceNow]);
    NSLog(@" timediff = %f, intro_state = %i, players =  %i, %i",timediff,intro_state, ulysses.playing,[voicebot isSpeaking]);
    if ([self readyToSpeak]){
        switch (intro_state) {
            case 0:
                [self ulyssesSpeak:@"3coordinates"];
                intro_state++;
                break;
            case 1:
                //speak the location
                [self speak:@"target acquired"];
                [self speak:[NSString stringWithFormat:@"head over to %@",[themap roadNameFromEdgePos:hideout.pos]]];
                intro_state++;
                break;
            case 2:
                [self ulyssesSpeak:@"1phonehack"];
                intro_state++;
                break;
            case 3:
                [self ulyssesSpeak:@"2frameyou"];
                intro_state++;
                break;
            case 4:
                if (timediff > 20) intro_state++;
                break;
            case 5:
                [self ulyssesSpeak:@"4cops"];
                current_state++;
                break;
            default:
                [self speakNow:@"unsupported intro state"];
                break;
        }
    }
}
- (void) the_cop {
    //cop in sight.
    
    
    
    
    float dist = [latestsearch distanceFromRoot:cop.pos];
    
    /*
    cop movements
     1. move toward the player from the destination, at the players speed, until dist < 100
     2. move randomly at player_speed/2
     3. if dist < 50 chase the player 
     4. if dist > 120 disappear.
     
     */
        
    //always move the cop
    switch (cop_state){
        case -1:
            //we lost the cop. he is gone forever
            break;
        case 0:
            //move to the player's location
            cop.pos = [latestsearch move:cop.pos towardRootWithDelta:10.0];
            break;
        case 1:
            //cop ahead.
            break;
        case 2:
            //player sees the cop
            cop.pos = [themap move:cop.pos forwardRandomly:player_speed/2.0];
            break;
        default:
            cop.pos = [latestsearch move:cop.pos towardRootWithDelta:player_speed];
            break;
    }
    
    
    if ([self readyToSpeak]){
        switch (cop_state){
            case -1:
                //dead
                break;
            case 0:
                if (dist < 100){
                    [self ulyssesSpeak:@"6copahead"];
                    cop_state++;
                }
                break;
            case 1:
                [self speak:[NSString stringWithFormat:@"threat detected %@ you on %@",[latestsearch directionFromRoot:cop.pos],[themap roadNameFromEdgePos:cop.pos]]];
                cop_state++;
                [self speak:@"rerouting"]; 
                NSMutableArray * cops = [NSMutableArray arrayWithCapacity:3];
                [cops addObject:cop.pos];
                [cops addObject:[latestsearch move:cop.pos towardRootWithDelta:50.0]];
                [cops addObject:[destination move:cop.pos towardRootWithDelta:50.0]];
                
                [destination release];
                
                destination = [themap createPathSearchAt:hideout.pos withMaxDistance:[NSNumber numberWithFloat:player_max_distance] avoidingEdges:cops];
                break;
            case 2:
                if (dist < 50) {
                    cop_state++;
                    [self playSong:@"chase_elevated"];
                    [self startSiren];
                }
                if (dist > 120){
                    cop_state = -1;
                    [self playSong:@"chase_normal"];
                    [self ulyssesSpeak:@"16nicework"];
                }
                [self speakIfEmpty:[NSString stringWithFormat:@"%i meters",(int)dist]];
                break;
            case 3:
                siren.volume = 10.0 / MAX(10.0,dist);//(100.0 - dist / 2.0) / 100.0;
                if (dist < 30){
                    [self ulyssesSpeak:@"12stoppolice-2"];
                    [self playSong:@"chase_scary"];
                    cop_state++;
                }
                if (dist > 100){
                    [self playSong:@"chase_normal"];
                    [self ulyssesSpeak:@"16nicework"];
                    cop_state = -1;
                    [self stopSiren];
                }
                [self speakIfEmpty:[NSString stringWithFormat:@"%i",(int)dist]];
                cop.pos = [latestsearch move:cop.pos towardRootWithDelta:2.0];
                
                if ([destination distanceFromRoot:cop.pos] < 120){
                    cop_state = -1;
                    [self speak:@"The cop stopped chasing you"];
                    [self stopSiren];
                    [self playSong:@"chase_normal"];
                
                }
                break;
            default:
                // you are about to lose the mission.
                // need to clarify how dire the situation is. the player cant see the screen also.
                // cop_state increases until the shit hits the fan.
                
                siren.volume = 1.0;
                if (dist < 20){
                    cop_state++;
                    if (cop_state==6){
                        [self ulyssesSpeak:@"woop"];
                    }
                    if (cop_state==8) {
                        [self ulyssesSpeak:@"12holdit-2"];
                        [self finishWithText:@"You were caught"];
                        current_state = 5;
                    }
                }
                if (dist > 40){
                    cop_state = 3;
                    [self playSong:@"chase_elevated"];
                }
                cop.pos = [latestsearch move:cop.pos towardRootWithDelta:2.0];
                break;
        }
    }
}
- (void) the_download {
    NSTimeInterval timediff = ABS([hideout_date timeIntervalSinceNow]);
    
    NSLog(@" timediff = %f, download_state = %i, players =  %i, %i",
          timediff,download_state, ulysses.playing,[voicebot isSpeaking]);
    
    if ([self readyToSpeak]){
        switch (download_state){
            case 0:
                [self ulyssesSpeak:@"7inrange"];
                download_state++;
                break;
            case 1:
                if (timediff > 15) download_state++;
                break;
            case 2:
                [self ulyssesSpeak:@"9headhome"];
                [destination release];
                destination = [themap createPathSearchAt:safehouse.pos withMaxDistance:[NSNumber numberWithFloat:player_max_distance]];
                cop.pos = [destination move:player.pos awayFromRootWithDelta:50.0];
                
                current_state++;
                break;
            default:
                break;
        }
    }    
}
- (void) the_chase {
    //you are being chased by the cop
    float dist = [latestsearch distanceFromRoot:cop.pos];
    NSLog(@"dist = %f, chase_state = %i, uyl = %i",dist,chase_state,ulysses.playing);
    
    [self speakIfEmpty:[destination directionToRoot:player.pos]];
    
    
    if ([self readyToSpeak]){
        switch (chase_state){
            case 0:
                [self ulyssesSpeak:@"11copsaround"];
                chase_state++;
                break;
            case 1:
                [self speak:[NSString stringWithFormat:@"threat detected %@ you on %@",[latestsearch directionFromRoot:cop.pos],[themap roadNameFromEdgePos:cop.pos]]];
                [self playSong:@"chase_elevated"];
                [self startSiren];
                chase_state++;
                
                break;
            case 2:
                siren.volume = 10.0 / MAX(10.0,dist);//(100.0 - dist / 2.0) / 100.0;
                if (dist < 30){
                    [self ulyssesSpeak:@"12stoppolice-2"];
                    [self playSong:@"chase_scary"];
                    chase_state++;
                }
                if (dist > 100){
                    [self playSong:@"chase_normal"];
                    [self ulyssesSpeak:@"16nicework"];
                    [self stopSiren];
                    current_state++;
                }
                [self speakIfEmpty:[NSString stringWithFormat:@"%i",(int)dist]];
                cop.pos = [latestsearch move:cop.pos towardRootWithDelta:2.0];
                break;
            default:
                siren.volume = 1.0;
                if (dist < 20){
                    chase_state++;
                    if (chase_state==8) {
                        [self ulyssesSpeak:@"12holdit-2"];
                        [self finishWithText:@"you lost the chase"];
                        current_state = 5;
                    }
                    if (cop_state==6){
                        [self ulyssesSpeak:@"woop"];
                    }
                }
                if (dist > 40){
                    [self playSong:@"chase_elevated"];
                    chase_state = 2;
                }
                cop.pos = [latestsearch move:cop.pos towardRootWithDelta:2.0];
                break;
        }
    }
    
    
    //always move the cop
    cop.pos = [latestsearch move:cop.pos towardRootWithDelta:2.0];
}



#pragma mark -
#pragma mark sound stuff

- (void) speakIfEmpty:(NSString *)text{
    if (ulysses.playing) return;
    [super speakIfEmpty:text];
}
- (BOOL) readyToSpeak {
    return (!ulysses.playing && ![voicebot isSpeaking]);
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
- (void) startSiren {
    siren.volume = 0.1;
    [siren prepareToPlay];
    [siren play];
}
- (void) stopSiren {
    [siren pause];
}
- (void) playSong:(NSString *)filename{
    [_music release];
    NSError *error;
    NSString * s = [[NSBundle mainBundle] pathForResource:filename ofType:@"mp3"];
    NSURL * x = [NSURL fileURLWithPath:s];
    _music = [[AVAudioPlayer alloc] initWithContentsOfURL:x error:&error];
    _music.volume = 0.5;
    _music.numberOfLoops = -1;
    [_music prepareToPlay];
    [_music play];
}
- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)audioplayer successfully:(BOOL)flag{
    //a player finished, do something depending on which one.
    if (audioplayer==_music){
    }
}
- (void) dealloc {
    //date objects
    [start_date release];
    [progress_date release];
    [hideout_date release];
    
    //avplayers
    [siren release];
    [ulysses release];
    [_music release];
    
    //frpoints
    [hideout release];
    [safehouse release];
    [cop release];
    
    [destination release];
    
    [super dealloc];
}
@end
