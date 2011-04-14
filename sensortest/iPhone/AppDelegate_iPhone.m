//
//  AppDelegate_iPhone.m
//  sensortest
//
//  Created by Matt Donahoe on 2/17/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "AppDelegate_iPhone.h"

@implementation AppDelegate_iPhone

@synthesize window;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
    
    [window makeKeyAndVisible];
    start = CFAbsoluteTimeGetCurrent();
	//GPS updates
	lman = [[CLLocationManager alloc] init];
	lman.delegate = self;
	lman.desiredAccuracy = kCLLocationAccuracyBest;
	lman.distanceFilter = 1.0;
	[lman startUpdatingLocation];
	[lman startUpdatingHeading];
	//acceleration
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:1.0 / 30];
    [[UIAccelerometer sharedAccelerometer] setDelegate:self];
    
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *logPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%i.log",(int)CFAbsoluteTimeGetCurrent()]];
    freopen([logPath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stdout);
	
	//link to /Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS4.2.sdk/System/Library/PrivateFrameworks/VoiceServices.framework
	//voicebot = [[NSClassFromString(@"VSSpeechSynthesizer") alloc] init];
	//[voicebot setDelegate:self];
	
	startDate = [NSDate date];
	[startDate retain];
	//mode=0;
	//[self nextMode];
	
    return YES;
}
- (void) nextMode {
	//
	mode = (mode+1)%6;
	NSArray *modes = [NSArray arrayWithObjects:@"STOP", @"WALK", @"JOG", @"RUN", @"JOG", @"WALK", nil];
	NSString * x = [modes objectAtIndex:mode];
	NSString *y  = [NSString stringWithFormat:@"%@ %@ %@ %@",x,x,x,x];
	[voicebot startSpeakingString:y];
	printf("S:%s,%f\n",[x UTF8String],[[NSDate date] timeIntervalSinceDate:startDate]);
}
- (void) speechSynthesizer:(NSObject *) synth didFinishSpeaking:(BOOL)didFinish withError:(NSError *) error { 
	printf("D:%f\n",[[NSDate date] timeIntervalSinceDate:startDate]);
	[self performSelector:@selector(nextMode) withObject:nil afterDelay:10.0];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}
- (void) locationManager:(CLLocationManager *)manager
	 didUpdateToLocation:(CLLocation *)newLocation
			fromLocation:(CLLocation *)oldLocation
{
	//NSLog(@"L:%@",newLocation);
	printf("L:%f,%f,%f,%f,%f\n",newLocation.coordinate.latitude,newLocation.coordinate.longitude,newLocation.horizontalAccuracy,[newLocation.timestamp timeIntervalSinceDate:startDate],[[NSDate date] timeIntervalSinceDate:startDate]);
}

- (void) locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    //NSLog(@"heading: %@",newHeading);
    printf("M:%f,%f,%f,%f,%f\n",newHeading.trueHeading,newHeading.x,newHeading.y,newHeading.z,[[NSDate date] timeIntervalSinceDate:startDate]);
}

- (void)dealloc {
    [window release];
    [super dealloc];
}


- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
	//printf("A:%f,%f,%f,%f\n",acceleration.x,acceleration.y,acceleration.z,[[NSDate date] timeIntervalSinceDate:startDate]);
}

@end
