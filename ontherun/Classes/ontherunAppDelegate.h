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
 1. this is increasingly important because the application is failing to launch in time. and errors
 
 #better debugging
 1. record some gps data for offline playback.
 1. save everything that happens during a run so that the player can watch it later.
 
 
 #game variety
 1. Add information to the mission.js
 1. Add methods to FRPoint and subclasses for determining Pin color
 1. Add more points to the game to decrease long gaps of silence
 1. Have player speed be a factor, like for attacking enemies
 
 #player position model
 1. use accuracy
 1. make predictions of location based on speed
 1. use a particle filter
 
 #better audio descriptions
 1. run a live test to see what a human would do
 1. agreggate points that are close together
 1. points emit sound effects
 
 #music
 1. put dramatic theme songs on iPhone
 1. the user can select songs that they want to play during the game.
 1. make the music volume seperate from the sound effect volume.
 
 #GPS reciever questions
 1. gps that works while the screen is off.
 1. fix the deep sleep module (i think the gps will shutoff after awhile)
 1. test on iPhone 3GS
 
 #offline play mode.
 1. web or iphone based?
 1. how should it look?
 1. see pictures of items collected
 1. view replay of previous missions
 1. perform actions/choices?
 
 #testers
 1. patsy ?
 1. jessie ?
 1. dad
 1. drew
 1. andrea
 1. gabe ?
 1. matt hirsch ?
 
 
 #thesis
 1. start making notes on what i've done so far
 1. whenever i am too brain dead to code, write notes.
 
 
 #map generation
 1. create constraint based map descriptions that can be fit to whever the user lives
 1. have the user input their home, running speed, and running goals, and let the generator configure a map for them
 
 
 #interface
 1. menu screen
 1. level select
 1. 
 
*/