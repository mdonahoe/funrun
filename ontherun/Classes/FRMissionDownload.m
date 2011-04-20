//
//  FRMissionDownload.m
//  ontherun
//
//  Created by Matt Donahoe on 4/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FRMissionDownload.h"
#import "FRMapViewController.h"

@implementation FRMissionDownload

- (id)initWithLocation:(CLLocation *)l viewControl:(UIViewController *)vc{
	self = [super initWithLocation:l viewControl:vc];
	if (!self) return nil;
	[self.viewControl setText:@"Get to the thief's hideout and return safely."];
    current_state = 0;
    intro_state = -1;
    
    [self playSong:@"chase_normal"];
    
    //create the destination
    hideout = [[FRPoint alloc] initWithName:@"hideout"];
    hideout.pos = player.pos;
    float dist = 0.0;
    while (dist < 500){
        hideout.pos = [latestsearch move:hideout.pos awayFromRootWithDelta:100];
        dist = [latestsearch distanceFromRoot:hideout.pos];
    }
    hideout.pos.position = 5; //make it at a corner.
    
    destination = [themap createPathSearchAt:hideout.pos withMaxDistance:[NSNumber numberWithFloat:(dist+200.0)]];
    
    start_date = [[NSDate alloc] init];
    cop = [[FRPoint alloc] initWithName:@"cop"];
    cop.pos = [latestsearch move:hideout.pos towardRootWithDelta:400.0];
    [points addObject:cop];
    [points addObject:hideout];
    
    NSError *error;
    NSString * p = [[NSBundle mainBundle] pathForResource:@"woowoo" ofType:@"mp3"];
    NSURL * u = [NSURL URLWithString:p];
    siren = [[AVAudioPlayer alloc] initWithContentsOfURL:u error:&error];
    NSLog(@"siren loaded with error %@",error);
    siren.numberOfLoops = -1;
    [siren prepareToPlay];
    
    /*
    
    FRMapViewController * mv = 
	[[[FRMapViewController alloc] initWithNibName:@"FRMapViewController" bundle:nil] autorelease];
	
	
	[self.viewControl.navigationController pushViewController:mv animated:YES];
	self.viewControl = mv;
	self.viewControl.navigationItem.rightBarButtonItem = 
	[[[UIBarButtonItem alloc] initWithTitle:@"Abort"
									  style:UIBarButtonItemStylePlain
									 target:self
									 action:@selector(abort)] autorelease];
	
	[mv.mapView addAnnotations:points];
    */
    
    
    [self ticktock];
    
	return self;
}

- (void) ticktock {
    [self the_cop];
    
    if (cop_state==0) {
        float dist = [latestsearch distanceFromRoot:hideout.pos];
        switch (current_state){
            case 0:
                [self the_intro];
                break;
            case 1:
                [self speakIfEmpty:[destination directionToRoot:player.pos]];
                if (dist < 100){
                    [self speak:[NSString stringWithFormat:@"The target is %i meters %@ you",(int)dist,[latestsearch directionFromRoot:hideout.pos]]];
                    current_state++;
                }
                break;
            case 2:
                [self speakIfEmpty:[destination directionToRoot:player.pos]];
                if (dist < 30) {
                    current_state++;
                    hideout_date = [[NSDate alloc] init];
                }
                break;
            case 3:
                [self the_download];
                break;
        }
    }
    [super ticktock];
}
- (void) speakIfEmpty:(NSString *)text{
    if (ulysses.playing) return;
    [super speakIfEmpty:text];
}
- (void) the_cop {
    //cop in sight.
    float dist = [latestsearch distanceFromRoot:cop.pos];
    NSLog(@"dist = %f, cop_state = %i, uyl = %i",dist,cop_state,ulysses.playing);
    if (dist > 100 && cop_state==0) return;
    
    if (!ulysses.playing && ![voicebot isSpeaking]){
        switch (cop_state){
            case 0:
                [self ulyssesSpeak:@"6copahead"];
                cop_state++;
                break;
            case 1:
                [self speak:[NSString stringWithFormat:@"threat detected %@ you on %@",[latestsearch directionFromRoot:cop.pos],[themap roadNameFromEdgePos:cop.pos]]];
                [self playSong:@"chase_elevated"];
                cop_state++;
                break;
            case 2:
                if (dist < 50) {
                    cop_state++;
                    [self startSiren];
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


- (void) startSiren {
    siren.volume = 0.1;
    [siren prepareToPlay];
    [siren play];
}
- (void) stopSiren {
    [siren pause];
}
- (void) the_download {
    NSTimeInterval timediff = ABS([hideout_date timeIntervalSinceNow]);
    NSLog(@" timediff = %f, download_state = %i, players =  %i, %i",timediff,download_state, ulysses.playing,[voicebot isSpeaking]);
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
