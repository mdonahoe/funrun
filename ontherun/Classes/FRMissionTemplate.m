//
//  FRMissionTemplate.m
//  ontherun
//
//  Created by Matt Donahoe on 3/14/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "FRMissionTemplate.h"
#import "JSON.h"
#import "FRFileLoader.h"

@implementation FRMissionTemplate
@synthesize points;

- (id) init {
	self = [super init];
	if (!self) return nil;
	
	//Voice Communication
	//link to /Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS4.2.sdk/System/Library/PrivateFrameworks/VoiceServices.framework
	voicebot = [[NSClassFromString(@"VSSpeechSynthesizer") alloc] init];
	[voicebot setDelegate:self];
	toBeSpoken = [[NSMutableArray alloc] initWithObjects:@"and load",nil];
	previously_said = nil;
	
	//communication with server
	m2 = [[toqbot alloc] init];
	
	
	//init the fileloader so we can skip network downloads if already cached
	NSAutoreleasePool * thepool = [[NSAutoreleasePool alloc] init];
	FRFileLoader * loader = [[FRFileLoader alloc] initWithBaseURLString:@"http://toqbot.com/otr/test1/"];
	
	//load the map
	
	//[loader deleteCacheForFile:filename];
	NSDictionary * mapdata = [[NSString stringWithContentsOfFile:[loader pathForFile:@"mapdata_nullfree.json"]
														encoding:NSUTF8StringEncoding
														   error:NULL] JSONValue];
	themap = [[FRMap alloc] initWithNodes:[mapdata objectForKey:@"nodes"] andRoads:[mapdata objectForKey:@"roads"]];
	
	[loader release];
	[thepool release];
	
	player = [[FRPoint alloc] initWithDict:[NSDictionary dictionaryWithObject:@"player" forKey:@"name"] onMap:themap];
	
	[player setCoordinate:[themap coordinateFromEdgePosition:player.pos]];
	points = [[NSMutableArray alloc] initWithObjects:player,nil];
	
	//use toqbot for gps position updates
	if (1){
		[m2 loadObjectForKey:@"userpos" toDelegate:self usingSelector:@selector(updatePosition:)];
	} else {
		[self startStandardUpdates];
	}
	[self speakNow:@"Lock"];
	
	[voicebot setRate:(float)1.3];
	[voicebot setPitch:.35];
	
	return self;
}
- (void) speak:(NSString *)text {
	if ([voicebot isSpeaking] || [toBeSpoken count]){
		[toBeSpoken addObject:text];
	} else {
		[self speakNow:text];
	}
}
- (void) speakNow:(NSString *)text{
	if ([text isEqualToString:previously_said]) return;
	[voicebot startSpeakingString:text];
	[text retain];
	[previously_said release];
	previously_said = text;
}
- (void) speakIfEmpty:(NSString *) text {
	if (![voicebot isSpeaking] && [toBeSpoken count]==0)
		[self speakNow:text];
}
- (void) speechSynthesizer:(NSObject *) synth didFinishSpeaking:(BOOL)didFinish withError:(NSError *) error { 
	// Handle the end of speech here 
	if ([toBeSpoken count]){
		[self speakNow:[toBeSpoken objectAtIndex:0]];
		[toBeSpoken removeObjectAtIndex:0];
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
	
	[self performSelector:@selector(ticktock) withObject:nil afterDelay:1.0];
};
- (void) updatePosition:(id)obj {
	
	float lat = [[obj objectForKey:@"lat"] floatValue];
	float lon = [[obj objectForKey:@"lon"] floatValue];
	
	CLLocation * ll = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
	[self newPlayerLocation:ll];
	[ll release];
	
}
- (void) startStandardUpdates{
    // Create the location manager if this object does not
    // already have one.
    if (nil == locationManager) 
		locationManager = [[CLLocationManager alloc] init];
	
	locationManager.delegate = self;
	locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	
	// Set a movement threshold for new events.
	locationManager.distanceFilter = 1.0;
	
	[locationManager startUpdatingLocation];
}
// Delegate method from the CLLocationManagerDelegate protocol.
- (void) locationManager:(CLLocationManager *)manager
	 didUpdateToLocation:(CLLocation *)newLocation
			fromLocation:(CLLocation *)oldLocation
{
	if (newLocation.horizontalAccuracy>100) return;
	if (newLocation.coordinate.latitude==oldLocation.coordinate.latitude && newLocation.coordinate.longitude==oldLocation.coordinate.longitude){
		NSLog(@"gps update is identical, skipping recalculations");
		return;
	}
	
	[self newPlayerLocation:newLocation];
	
}
- (void) newPlayerLocation:(CLLocation *)location {
	/*
	 This method is called whenever a new player location
	 update is available.
	 
	 a new point comes from the network
	 or the gps
	 */
	
	
	NSLog(@"newPlayerLocation: %@",location);
	
	//convert to map coordinates
	FREdgePos * ep = [themap edgePosFromPoint:location];
	
	//say something. helps with gps debugging
	if (arc4random()%10==0) [self speakIfEmpty:@"click"];
	
	//speak the current road, if it changed
	NSString * roadname = [themap roadNameFromEdgePos:ep];
	if ([roadname isEqualToString:current_road]==NO && roadname){
		[roadname retain];
		[current_road release];
		current_road = roadname;
		[self speak:current_road];
	}
	
	if (latestsearch) {
		//we already have a position
		//ensure that the direction of our new point is facing away from the old one.
		player.pos = [latestsearch move:ep awayFromRootWithDelta:0];
	} else {
		player.pos = ep;
		//start the updates
		[self performSelector:@selector(ticktock) withObject:nil afterDelay:1.0]; 
	}
	
	[latestsearch release];
	latestsearch = [themap createPathSearchAt:player.pos withMaxDistance:[NSNumber numberWithFloat:1000.0]];
}

/*
- (void) playsounds {
	 
	//Be able to play random sound effects.
	//Initially used to prevent deep sleep
	 
	//Code from this blog:
	//http://blog.marcopeluso.com/2009/08/23/how-to-prevent-iphone-from-deep-sleeping/
	 
	 
	// Activate audio session
	AudioSessionSetActive(true);
	// Set up audio session, to prevent iPhone from deep sleeping, while playing sounds
	UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
	AudioSessionSetProperty (
							 kAudioSessionProperty_AudioCategory,
							 sizeof (sessionCategory),
							 &sessionCategory
							 );
	
	// Set up sound file
	NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"lion1"
															  ofType:@"wav"];
	NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:soundFilePath];
	NSError *audioerror = nil;
	// Set up audio player with sound file
	audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&audioerror];
	[audioPlayer prepareToPlay];
	
	// You may want to set this to 0.0 even if your sound file is silent.
	[audioPlayer setVolume:1.0];
	
}
*/

/*
- (void) music {
	 //Basic music player setup.
	 //from http://discussions.apple.com/thread.jspa?threadID=2084104&tstart=0&messageID=9838244
	 
	 //need to figure out interruption stuff. Sound can stop playing for some reasons
	 
	musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
	[musicPlayer setQueueWithQuery: [MPMediaQuery songsQuery]];
	[musicPlayer setShuffleMode:MPMusicShuffleModeSongs];
	[musicPlayer setRepeatMode:MPMusicRepeatModeAll];
	[musicPlayer setVolume:0.5]; //the volume for the two audio players is shared, and that sucks
	//[musicPlayer play];
}
*/

- (void) dealloc {
	[player release];
	[points release];
	[themap release];
	[latestsearch release];
	[toBeSpoken release];
	[previously_said release];
	[current_road release];
	[m2 release];
	[locationManager release];
	[super dealloc];
}
@end
