//
//  FRMission.m
//  ontherun
//
//  Created by Matt Donahoe on 2/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FRMission.h"
#import "ASIFormDataRequest.h"
#import "JSON.h"
#import "FRFileLoader.h"

@implementation FRMission



@synthesize points;
- (id) initWithMissionName:(NSString*)missionname {
	NSLog(@"mission name = %@",missionname);
	self = [super init];
	if (!self) return nil;
	
	
	/*
	 
	 Be able to play random sound effects.
	 Initially used to prevent deep sleep
	 
	 Code from this blog:
	 http://blog.marcopeluso.com/2009/08/23/how-to-prevent-iphone-from-deep-sleeping/
	 
	 */
	
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
	
	
	
	ticks = 0;
	healthbar = 100;
	toBeSpoken = [[NSMutableArray alloc] initWithObjects:@"and load",nil];
	
	
	/*
	 Basic music player setup.
	 from http://discussions.apple.com/thread.jspa?threadID=2084104&tstart=0&messageID=9838244
	 
	 need to figure out interruption stuff. Sound can stop playing for some reasons
	 
	 */
	musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
	[musicPlayer setQueueWithQuery: [MPMediaQuery songsQuery]];
	[musicPlayer setShuffleMode:MPMusicShuffleModeSongs];
	[musicPlayer setRepeatMode:MPMusicRepeatModeAll];
	[musicPlayer setVolume:0.5]; //the volume for the two audio players is shared, and that sucks
	//[musicPlayer play];
	
	
	
	//link to /Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS4.2.sdk/System/Library/PrivateFrameworks/VoiceServices.framework
	voicebot = [[NSClassFromString(@"VSSpeechSynthesizer") alloc] init];
	[voicebot setDelegate:self];
	
	//communication with server
	m2 = [[toqbot alloc] init];

	//init the fileloader so we can skip network downloads if already cached
	NSAutoreleasePool * thepool = [[NSAutoreleasePool alloc] init];
	FRFileLoader * loader = [[FRFileLoader alloc] initWithBaseURLString:@"http://toqbot.com/otr/test1/"];
	
	//load the map
	NSDictionary * mapdata = [[NSString stringWithContentsOfFile:[loader pathForFile:@"mapdata.json"]
														encoding:NSUTF8StringEncoding
														   error:NULL] JSONValue];
	themap = [[FRMap alloc] initWithNodes:[mapdata objectForKey:@"nodes"] andRoads:[mapdata objectForKey:@"roads"]];
	
	//create the special user point
	user = [[FRPoint alloc] initWithDict:[NSDictionary dictionaryWithObject:@"user" forKey:@"name"] onMap:themap];
	
	//load the mission(s)
	NSString * missionstring = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:[loader pathForFile:missionname]] encoding:NSUTF8StringEncoding];
	NSDictionary * missiondata = [missionstring JSONValue];
	[missionstring release];
	
	NSMutableArray * temp = [NSMutableArray arrayWithCapacity:10];
	[temp addObject:user];
	for (NSDictionary * dict in [missiondata valueForKey:@"points"]){
		NSString * pointclass = [dict objectForKey:@"class"];
		FRPoint * pt;
		if (pointclass){
			pt = [[NSClassFromString([NSString stringWithFormat:@"FRPoint%@",pointclass]) alloc] initWithDict:dict onMap:themap];
		} else {
			pt = [[FRPoint alloc] initWithDict:dict onMap:themap];
		}
		[temp addObject:pt];
	}
	points = [[NSArray alloc] initWithArray:temp];
	
	
	//we dont need the file loader anymore
	[loader release];
	
	//release the pool, which also drain it... i think
	[thepool release];
	
	
	//[self startStandardUpdates];
	[self ticktock];
	
	//use toqbot for gps position updates
	if (0){
		[m2 loadObjectForKey:@"userpos" toDelegate:self usingSelector:@selector(updatePosition:)];
	} else {
		[self startStandardUpdates];
	}
	[self speakString:@"Lock"];
	NSString * name;
	id avsc = [objc_getClass("AVSystemController") sharedAVSystemController];
	[avsc getActiveCategoryVolume:&last_volume andName:&name];
	
	current_road = @"start";
	[current_road retain];
	
	return self;
}

- (void) saveRunDataForLater {
	//get the documents directory:
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	//make a file name to write the data to using the documents directory:
	NSString *fullFileName = [NSString stringWithFormat:@"%@/arraySaveFile", documentsDirectory];
	
	//this statement is what actually writes out the array
	//to the file system:
	[logarray writeToFile:fullFileName atomically:NO];
	
}
- (NSArray *) loadRunData {
	/* 
	 Now, your information has been saved to the iPhone’s file system in the documents directory of your app.
	 Here is how you would retrieve the information that you saved:
	 */
	
	
	//get the documents directory:
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	//make a file name to read the data from using the documents directory:
	NSString *fullFileName = [NSString stringWithFormat:@"%@/arraySaveFile", documentsDirectory];
	
	//retrieve your array by using initWithContentsOfFile while passing
	//the name of the file where you saved the array contents.
	NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:fullFileName];
	
	//use an alert to display the first value in the array to prove
	//that you were able to save and retrieve the information.
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
													message:[array objectAtIndex:0]
												   delegate:self
										  cancelButtonTitle:@"OK"
										  otherButtonTitles: nil];
	[alert show];
	[alert release];
	
	
	return array;
}

- (void) speakString:(NSString *)text {
	[voicebot startSpeakingString:text];
	//NSLog(@"%@",text);
	//[m2 sendObject:text forKey:@"voicebot"];
}
- (void) speechSynthesizer:(NSObject *) synth didFinishSpeaking:(BOOL)didFinish withError:(NSError *) error { 
	// Handle the end of speech here 
	if ([toBeSpoken count]){
		[self speakString:[toBeSpoken objectAtIndex:0]];
		[toBeSpoken removeObjectAtIndex:0];
	}
	//[self performSelector:@selector(speakStatus) withObject:nil afterDelay:1.0];
}
- (void)speakIfYouCan:(NSString*)text {
	if ([voicebot isSpeaking]) return;
	[self speakString:text];
}
- (void)speakEventually:(NSString *)text{
	if ([voicebot isSpeaking]){
		[toBeSpoken addObject:text];
	} else {
		[self speakString:text];
	}
}

//getters used by the FRPoint subclasses
- (FRMap*) getMap { return themap;}
- (FRPathSearch *) getPlayerView { return latestsearch;}

- (void) ticktock {
	//quick hack for detecting remote control presses
	// do this instead http://www.iphonedevsdk.com/forum/iphone-sdk-development/44433-there-way-respond-clicks-headphone-buttons.html
	id avsc = [objc_getClass("AVSystemController") sharedAVSystemController];
	float thevolume;
	NSString * name;
	[avsc getActiveCategoryVolume:&thevolume andName:&name];
	if (thevolume!=last_volume) [self speakEventually:@"PUNCH"];
	last_volume = thevolume;
	
	//NSLog(@"volume %f for %@",thevolume,name);
	if (ticks++>10){
		ticks = 0;
		//NSLog(@"play the fucking sound");
		//[audioPlayer play];
	}
	
	if (latestsearch==nil) NSLog(@"nilnil");
	
	
	for (FRPoint * pt in points){
		
		if ([pt.title isEqualToString:@"user"]==NO){
			
			/*
			 
			 Thinking about making conveinence functions here, but i can write the method names
			 
			if (latestsearch && [latestsearch containsPoint:pt.pos]){
				[pt updateForMissionInSight:self];
			} else {
				[pt updateForMissionOutOfSight:self];
			}
			 */
			//NSLog(@"updating:%@",pt.title);
			[pt updateForMission:self];
			
			
			/*
			 
			 ideally the points would return something that makes them aggregateable.??
			 I should instead work on something that will let me do a live test with someone
			 so they can describe the world to me in realtime, and I can record what they say
			 
			 That experience will give me a better sense of how to do the descriptions.
			 
			 Perhaps I can do it over text-to-speech using toqbot?
			 */
			
			
		}
		
		//update 2d coordinate (so the map updates live)
		[pt setCoordinate:[themap coordinateFromEdgePosition:pt.pos]];
		
	}
	
	[self performSelector:@selector(ticktock) withObject:nil afterDelay:1.0];
};
- (void) updatePosition:(id)obj {
	
	float lat = [[obj objectForKey:@"lat"] floatValue];
	float lon = [[obj objectForKey:@"lon"] floatValue];
	
	CLLocation * ll = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
	[self newUserLocation:ll];
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

	[self newUserLocation:newLocation];
	
}
- (void) newUserLocation:(CLLocation *)location {
	NSLog(@"newUserLocation: %@",location);
	FREdgePos * ep = [themap edgePosFromPoint:location];
	if (arc4random()%10==0) [self speakIfYouCan:@"click"];
	NSString * roadname = [themap roadNameFromEdgePos:ep];
	if ([roadname isEqualToString:current_road]==NO && roadname){
		[roadname retain];
		[current_road release];
		current_road = roadname;
		[self speakEventually:current_road];
	}
	
	if (latestsearch) {
		//we already have a position
		//ensure that the direction of our new point is facing away from the old one.
		user.pos = [latestsearch move:ep awayFromRootWithDelta:0];
	} else {
		user.pos = ep;
	}
	
	[latestsearch release];
	latestsearch = [themap createPathSearchAt:user.pos withMaxDistance:[NSNumber numberWithFloat:200.0]];
}

- (void) dealloc {
	[points release];
	[user release];
	[locationManager stopUpdatingLocation];
	[locationManager release];
	[m2 release];
	[themap release];
	[latestsearch release];
	[voicebot release];
	[super dealloc];
}
@end
