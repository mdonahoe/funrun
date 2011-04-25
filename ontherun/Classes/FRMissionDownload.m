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

#import "FRMissionDownload.h"
#import "FRMapViewController.h"

@implementation FRMissionDownload

- (id)initWithLocation:(CLLocation *)l viewControl:(UIViewController *)vc{
	self = [super initWithLocation:l viewControl:vc];
	if (!self) return nil;
	[self.viewControl setText:@"Get to the thief's hideout and return safely."];
    current_state = 0;
    intro_state = -1;
    cop_spotted = NO;
    [self playSong:@"chase_normal"];
    
    //create the safehouse (default to current position)
    safehouse = [[FRPoint alloc] initWithName:@"safehouse"];
    safehouse.pos = player.pos;
    
    
    //create the destination
    hideout = [[FRPoint alloc] initWithName:@"hideout"];
    hideout.pos = player.pos;
    float dist = 0.0;
    while (dist < 500){
        hideout.pos = [latestsearch move:player.pos awayFromRootWithDelta:600];
        dist = [latestsearch distanceFromRoot:hideout.pos];
        NSLog(@"hideout.pos = %@, dist = %f",hideout.pos,dist);
    }
    
    destination = [themap createPathSearchAt:hideout.pos withMaxDistance:[NSNumber numberWithFloat:(2000.0)]];
    
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
    NSLog(@"directions = %@",[destination directionsToRoot:player.pos]);
    switch (current_state){
        case 0:
            [self the_intro];
            break;
        case 1:
            dist = [latestsearch distanceFromRoot:hideout.pos];
            [self the_cop]; //integrate the rest of this case into the_cop
            [self speakIfEmpty:[destination directionToRoot:player.pos]];
            if (dist < 30) {
                if (cop_state){
                    [self speak:@"we cant do the download if you are being chased. failed"];
                    current_state = 5;
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
                current_state++;
                //you win!
            }
            [self speakIfEmpty:[destination directionToRoot:player.pos]];
            break;
        default:
            NSLog(@"current_state invalid");
    }
    [super ticktock];
}
- (void) the_cop {
    //cop in sight.
    float dist = [latestsearch distanceFromRoot:cop.pos];
    NSLog(@"copdist = %f, cop_state = %i, uyl = %i",dist,cop_state,ulysses.playing);
    if (!cop_spotted){
        cop.pos = [latestsearch move:cop.pos towardRootWithDelta:10.0];
    } else {
        cop.pos = [themap move:cop.pos forwardRandomly:1.0];
    }
    if (dist > 100 && cop_state==0) return;
    
    cop_spotted = YES;
    
    if (!ulysses.playing && ![voicebot isSpeaking]){
        switch (cop_state){
            case 0:
                [self ulyssesSpeak:@"6copahead"];
                cop_state++;
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
                
                destination = [themap createPathSearchAt:hideout.pos withMaxDistance:[NSNumber numberWithInt:1000] avoidingEdges:cops];
                break;
            case 2:
                if (dist < 50) {
                    cop_state++;
                    [self playSong:@"chase_elevated"];
                    [self startSiren];
                } else {
                    [self speakIfEmpty:[destination directionToRoot:player.pos]];
                }
                if (dist > 120){
                    cop_state = 0;
                    [self playSong:@"chase_normal"];
                    [self ulyssesSpeak:@"16nicework"];
                }
                [self speakIfEmpty:[NSString stringWithFormat:@"%i meters",(int)dist]];
                break;
            case 3:
                siren.volume = 10.0 / MAX(10.0,dist);//(100.0 - dist / 2.0) / 100.0;
                if (dist < 30){
                    [self ulyssesSpeak:@"12stoppolice-2"];
                    cop_state++;
                }
                if (dist > 100){
                    [self playSong:@"chase_normal"];
                    [self ulyssesSpeak:@"16nicework"];
                    cop_state = 0;
                    [self stopSiren];
                }
                [self speakIfEmpty:[NSString stringWithFormat:@"%i",(int)dist]];
                cop.pos = [latestsearch move:cop.pos towardRootWithDelta:2.0];
                break;
            default:
                siren.volume = (100.0 - dist / 2.0) / 100.0;
                if (dist < 10){
                    cop_state++;
                    if (cop_state==20) [self ulyssesSpeak:@"12holdit-2"];
                }
                if (dist > 40){
                    cop_state = 3;
                }
                cop.pos = [latestsearch move:cop.pos towardRootWithDelta:2.0];
                break;
        }
    }
}
- (void) the_chase {
    //you are being chased by the cop
    float dist = [latestsearch distanceFromRoot:cop.pos];
    NSLog(@"dist = %f, chase_state = %i, uyl = %i",dist,chase_state,ulysses.playing);
    
    [self speakIfEmpty:[destination directionToRoot:player.pos]];
    
    if (!ulysses.playing && ![voicebot isSpeaking]){
        switch (chase_state){
            case 0:
                [self ulyssesSpeak:@"11copsaround"];
                chase_state++;
                break;
            case 1:
                [self speak:[NSString stringWithFormat:@"threat detected %@ you on %@",[latestsearch directionFromRoot:cop.pos],[themap roadNameFromEdgePos:cop.pos]]];
                [self playSong:@"chase_elevated"];
                chase_state++;
                
                break;
            case 2:
                siren.volume = 10.0 / MAX(10.0,dist);//(100.0 - dist / 2.0) / 100.0;
                if (dist < 30){
                    [self ulyssesSpeak:@"12stoppolice-2"];
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
                siren.volume = (100.0 - dist / 2.0) / 100.0;
                if (dist < 10){
                    chase_state++;
                    if (chase_state==20) [self ulyssesSpeak:@"12holdit-2"];
                }
                if (dist > 40){
                    chase_state = 3;
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
    
    if (!ulysses.playing && ![voicebot isSpeaking]){
        switch (download_state){
            case 0:
                [self ulyssesSpeak:@"7inrange"];
                download_state++;
                break;
            case 1:
                if (timediff > 20) download_state++;
                break;
            case 2:
                [self ulyssesSpeak:@"9headhome"];
                [destination release];
                destination = [themap createPathSearchAt:safehouse.pos withMaxDistance:[NSNumber numberWithInt:2000]];
                cop.pos = [destination move:player.pos awayFromRootWithDelta:50.0];
                
                current_state++;
                break;
            default:
                break;
        }
    }    
}
- (void) the_intro {
    //play ulysses' sound files one after another.
    NSTimeInterval timediff = ABS([start_date timeIntervalSinceNow]);
    NSLog(@" timediff = %f, intro_state = %i, players =  %i, %i",timediff,intro_state, ulysses.playing,[voicebot isSpeaking]);
    if (!ulysses.playing && ![voicebot isSpeaking]){
        switch (intro_state) {
            case -1:
                [self ulyssesSpeak:@"1phonehack"];
                intro_state++;
                break;
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
                [self ulyssesSpeak:@"2frameyou"];
                intro_state++;
                break;
            case 3:
                if (timediff > 20) intro_state++; break;
            case 4:
                [self ulyssesSpeak:@"4cops"];
                current_state++;
                break;
            default:
                [self speakNow:@"unsupported intro state"];
                break;
        }
    }
}
#pragma mark -


- (void) speakIfEmpty:(NSString *)text{
    if (ulysses.playing) return;
    [super speakIfEmpty:text];
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
        NSLog(@"finished");
        //we probably dont need to do anything here.
    }
}

@end
