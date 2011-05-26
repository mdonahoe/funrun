//
//  FRMissionTemplate.m
//  ontherun
//
//  Created by Matt Donahoe on 3/14/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "FRMissionTemplate.h"
#import "FRBriefingViewController.h"
#import "JSON.h"
#import "ASIHTTPRequest.h"
#import "FRTroubleshoot.h"


@implementation FRMissionTemplate
@synthesize points,viewControl;

- (id) initWithLocation:(CLLocation*)l distance:(float)dist destination:dest viewControl:(UIViewController*)vc {
	self = [super init];
	if (!self) return nil;
	
    player_max_distance = dist*1000; //convert to meters
    last_location_received_date = nil;
    average_player_speed = 0.0;
    

    
    //Voice Communication
	//link to /Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS4.2.sdk/System/Library/PrivateFrameworks/VoiceServices.framework
	voicebot = [[NSClassFromString(@"VSSpeechSynthesizer") alloc] init];
	[voicebot setDelegate:self];
	toBeSpoken = [[NSMutableArray alloc] init];
	previously_said = nil;
	last_played_sound = nil;
	//communication with server
	
	
    endPoint = [[FRPoint alloc] initWithName:@"end point"];
    if (dest==nil) {
        endPoint.pos = player.pos;
    } else {
        endPoint.pos = [themap edgePosFromPoint:dest];
    }	
	//init the pool
	NSAutoreleasePool * thepool = [[NSAutoreleasePool alloc] init];
	
	//load the map
    NSString * mapurl = [NSString stringWithFormat:@"http://toqbot.com/map/download?lat=%f&lng=%f&dist=%f",l.coordinate.latitude,l.coordinate.longitude,player_max_distance];
    NSURL *url = [NSURL URLWithString:mapurl];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request startSynchronous];
    NSError *error = [request error];
    
    NSString * mapstring;
    if (!error) {
        mapstring = [request responseString];
    } else {
        NSLog(@"there was a download error %@",error);
        [self dealloc];
        return nil;
    }
    //dict of nodes and roads
    NSDictionary * mapdata = [mapstring JSONValue];
	
    themap = [[FRMap alloc] initWithNodes:[mapdata objectForKey:@"nodes"] andRoads:[mapdata objectForKey:@"roads"]];
	
	[thepool release];
	
	player = [[FRPoint alloc] initWithDict:[NSDictionary dictionaryWithObject:@"player" forKey:@"name"] onMap:themap];
	[self newPlayerLocation:l];
	player.pos = [themap edgePosFromPoint:l];
	[player setCoordinate:[themap coordinateFromEdgePosition:player.pos]];
	
    
    endPoint = [[FRPoint alloc] initWithName:@"end point"];
    if (dest==nil) {
        endPoint.pos = player.pos;
    } else {
        endPoint.pos = [themap edgePosFromPoint:dest];
    }
    
    
    points = [[NSMutableArray alloc] initWithObjects:player,nil];
	

	[voicebot setRate:1.3];
	[voicebot setPitch:0.25];
	
	/*FRBriefingViewController * brief = 
	[[[FRBriefingViewController alloc] initWithNibName:@"FRBriefingViewController"
												bundle:nil] autorelease];
	[brief setText:@"nothing to see here"];
	brief.mission = self;
	
    [vc.navigationController pushViewController:brief animated:YES];
	self.viewControl = brief;
     */
    
    FRTroubleshoot * trouble = [[[FRTroubleshoot alloc] initWithNibName:@"FRTroubleshoot" bundle:nil] autorelease];
    [vc.navigationController pushViewController:trouble animated:YES];
    self.viewControl = trouble;
	return self;
}

- (void) speak:(NSString *)text {
	if ([voicebot isSpeaking] || [toBeSpoken count]){
		[toBeSpoken addObject:text];
	} else {
		if ([text isEqualToString:previously_said]) return;
		[self speakNow:text];
	}
}
- (void) speakNow:(NSString *)text{
	[voicebot startSpeakingString:text];
	[text retain];
	[previously_said release];
	previously_said = text;
}
- (void) speakIfEmpty:(NSString *) text {
	if (![voicebot isSpeaking] && [toBeSpoken count]==0 && [text isEqualToString:previously_said]==NO)
		[self speakNow:text];
}
- (void) speechSynthesizer:(NSObject *) synth didFinishSpeaking:(BOOL)didFinish withError:(NSError *) error { 
	// Handle the end of speech here
	//perhaps ditch this method and instead do a call in ticktock
	while ([toBeSpoken count]){
		NSString * text = [toBeSpoken objectAtIndex:0];
		[text retain];
		[toBeSpoken removeObjectAtIndex:0];
		if (![text isEqualToString:previously_said]){
			[self speakNow:text];
			[text release];
			break;
		} else {
			[text release];
		}
	}
}
- (void) ticktock {
	/*
	 This method is called once a second
	 
	 todo: it could be possible to call this more than once a second, dual threading. that would be bad
	 */
	
	//update map positions
	for (FRPoint * pt in points){
		[pt setCoordinate:[themap coordinateFromEdgePosition:pt.pos]];
	}
    [self updateDirections];
	[self performSelector:@selector(ticktock) withObject:nil afterDelay:1.0];
};
- (void) newPlayerLocation:(CLLocation *)location {
	/*
	 This method is called whenever a new player location
	 update is available.
	 
	 a new point comes from the network
	 or the gps
	 */
	
	NSDate * current_date = [[NSDate alloc] init];
	NSLog(@"newPlayerLocation: %@",location);
	
	
	if (latestsearch) {

        
        double min_score = 100000000000000000000000000.0; //giant number
        FREdgePos * best = nil;
        
        NSArray * ten_closest = [themap closest:10 edgesToPoint:location];
        
        float a,b,c,d;
        a = ((FRTroubleshoot*)viewControl).e_slider.value;
        b = ((FRTroubleshoot*)viewControl).t_slider.value;
        c = ((FRTroubleshoot*)viewControl).r_slider.value;
        d = ((FRTroubleshoot*)viewControl).f_slider.value;
        //NSLog(@"a=%f,b=%f,c=%f,d=%f",a,b,c,d);
        
        for (NSArray * edge in ten_closest){
            
            
            //edge error penalty
            float E = [themap distanceFromEdge:edge toPoint:location];
            
            //total distance moved penalty
            FREdgePos * ep = [themap edgePosFromPoint:location usingEdge:edge];
            ep = [latestsearch move:ep awayFromRootWithDelta:0.0]; //face away.
            float T = [latestsearch distanceFromRoot:ep];
            
            //road switch penalty
            NSString * road = [themap roadNameFromEdgePos:ep];
            float R = ([road isEqualToString:current_road]||[road isEqualToString:next_road])?0.0f:1.0f;
            
            //turn around penalty
            float F = [latestsearch rootIsFacing:ep]?0.0f:1.0f;
            
            //ideally these would be manually controlled.
            double score = a*E+b*T+c*R+d*F;
            
            //NSLog(@"score = %f, %@",score,road);
            if (score < min_score){
                min_score = score;
                best = ep;
            }
            
            //calculate the ep, and the travel distance
        }
        //NSLog(@"best score = %f, %@",min_score,[themap roadNameFromEdgePos:best]);
        
        float new_dist = [latestsearch distanceFromRoot:best];
#define SPEED_ALPHA 0.5
        average_player_speed = SPEED_ALPHA*(new_dist / [current_date timeIntervalSinceDate:last_location_received_date]) + (1.0-SPEED_ALPHA)*(average_player_speed);
        if (arc4random()%30==0) [self speakIfEmpty:[NSString stringWithFormat:@"%i meters per second",(int)average_player_speed]];
		player.pos = [latestsearch move:best awayFromRootWithDelta:0];
        //[best release];
	} else {
		player.pos = [themap edgePosFromPoint:location];
        
	}
	
    [last_location_received_date release];
    last_location_received_date = current_date;
	
    [latestsearch release];
	latestsearch = [themap createPathSearchAt:player.pos withMaxDistance:[NSNumber numberWithFloat:player_max_distance/1.8]];
    
    
    //speak the current road, if it changed
	NSString * roadname = [themap roadNameFromEdgePos:player.pos];
	if ([roadname isEqualToString:current_road]==NO && roadname){
		[roadname retain];
		[current_road release];
		current_road = roadname;
		[self speak:current_road];
	}
	
}

- (void) abort {
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[toBeSpoken removeAllObjects];
	[self speak:@"Mission Aborted"];
}
- (void) playSong:(NSString *)name {
    [backgroundMusic release];
    if (name==nil) return;
    
    NSString * path = [[NSBundle mainBundle] pathForResource:name ofType:@"mp3"];
    NSURL * url = [NSURL fileURLWithPath:path];
    NSError * error;
    backgroundMusic = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    [backgroundMusic prepareToPlay];
    backgroundMusic.numberOfLoops = -1;
    backgroundMusic.volume = 0.5;
    [backgroundMusic play];
}
- (void) updateDirections {
    //goal road needs to update everytime.
    //how do we know if we can speak?
    //voicebot and soundfx
    if (destination==nil) return;
    
    NSString * road = [destination nextRoad:player.pos];
    [road retain];
    [next_road release];
    next_road = road;
}
- (void) soundfile:(NSString*)filename{
    [soundfx release];
    NSError *error;
    NSString * s = [[NSBundle mainBundle] pathForResource:filename ofType:@"mp3"];
    NSURL * x = [NSURL fileURLWithPath:s];
    soundfx = [[AVAudioPlayer alloc] initWithContentsOfURL:x error:&error];
    soundfx.volume = 1.0;
    [soundfx prepareToPlay];
    [soundfx play];
}
- (BOOL) playSoundFile:(NSString*)filename {
    //dont play if something else is playing
    if (![self readyToSpeak]) return NO;
    
    //dont play the same sound twice.
    if ([last_played_sound isEqualToString:filename]) return NO;
    [filename retain];
    [last_played_sound release];
    last_played_sound = filename;
    
    [self soundfile:filename];
    return YES;
}
- (BOOL) readyToSpeak {
    //no sound fx or voice playing
    return !(soundfx.playing || [voicebot isSpeaking]);
}
- (id) retain
{
    // Break here to see who is retaining me.
    NSLog(@"about to retain. current count is =%i",[self retainCount]);
    return [super retain];
}
- (void) dealloc {
    //stop the ticktocks
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
	
    [player release];
	[points release];
	[themap release];
    [soundfx release];
    [voicebot release];
	[next_road release];
    [toBeSpoken release];
    [destination release];
    [latestsearch release];
    [current_road release];
    [previously_said release];
    [backgroundMusic release];
    [last_played_sound release];
	[last_location_received_date release];
	self.viewControl = nil;
    [super dealloc];
	NSLog(@"mission is dead");
}
@end
