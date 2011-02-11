//
//  ontherunAppDelegate.h
//  ontherun
//
//  Created by Matt Donahoe on 1/5/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ontherunAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end

/*
 
 TODO!
 
 
 #speed up app launch
 1. cache the mission and map scripts.
 
 
 #better debugging
 1. record some gps data for offline playback.
 1. save everything that happens during a run so that the player can watch it later.
 
 
 #game variety
 1. Add information to the mission.js
 1. Add methods to FRPoint and subclasses for determining Pin color
 1. add more points to the game to decrease long gaps of silence
 1. have player speed be a factor, like for attacking enemies
 
 #player position model
 1. use accuracy
 1. make predictions of location based on speed
 1. use a particle filter
 
 #better audio descriptions
 1. run a live test to see what a human would do
 1. agreggate points that are close together
 1. points emit sound effects
 
 #music
 1. put songs on iPhone
 1. have songs that play in the background, somehow. (perhaps by using the iPod?)
 1. the user can select songs that they want to play during the game.
 
 #GPS reciever questions
 1. gps that works while the screen is off.
 1. fix the deep sleep module (i think the gps will shutoff after awhile)
 1. test on iPhone 3GS
 
 
 
*/