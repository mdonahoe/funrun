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
 

 #better debugging
 1. pipe stdout to a file and log lots of stuff.
 1. save everything that happens during a run so that the player can watch it later.
  
 #game variety
 1. Add methods to FRPoint and subclasses for determining Pin color
 1. Add more points to the game to decrease long gaps of silence
 1. Have player speed be a factor, like for attacking enemies
 1. Is it possible to lose? I can listen to STAB STAB STAB forever.
 
 #player position model
 1. use accuracy
 1. make predictions of location based on speed
 1. use a particle filter
 1. look at GPS data with Adam and design a player model, perhaps using a Kalman filter, or particle filters
 
 #better audio descriptions
 1. run a live test to see what a human would do
 1. agreggate points that are close together
 1. points emit sound effects
 1. deepsleep timer audio interferes with the speechsynth system
 1. get some audio recording samples from Charlie.
 
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
 1. confirm that i dont need COUHES
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
 1. generate a persistent map that lives ontop on the individual mission map
 1. create constraint based map descriptions that can be fit to whever the user lives
 1. have the user input their home, running speed, and running goals, and let the generator configure a map for them
 1. Game adjusts the mission based on the startup position of the user, and where they want to end up at the end of the run.
 
 #interface
 1. menu screen
 1. level select
 1. have something besides the rootviewcontroller (tableview) to start.
 
 
 #code smell
 1. learn about how #import works in objective-c.
 1. make sure we arent leaking objects
 1. use more pools to reduce memory footprint during startup?
 
 
 #persistant world
 1. missions will happen in realtime whether or not you decide to participate.
 1. get a call from someone who needs your help.
 1. schedule your run times in advance, so you know you have free time to do the run. test adherance to the schedule.
 1. objects get sent to server, where the computation continues. alerts get pushed to the phone.
 1. get notifications working on the phone.
 
 #questions?
 1. is this too large of a project?
 1. when will i finish?
 1. what should i cut?
 
 
 
 #player position prediction model
 1. gather data
 2. look at data
 3. model
 4. test
 5. port to obj-c
 6. real test
 
 
 
 
*/