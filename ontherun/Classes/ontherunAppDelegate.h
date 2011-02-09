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

 Stuff I should be working on:
 
 1. good descriptions of what is moving
 2. testing the accuracy of the position updates
 4. cache the mission and map scripts.
 5. record some gps data for offline playback.
 1. out of view of you error
 1. points dont get closer
 1. pins are not unique looking, cant tap them
 1. test isFacingRoot code to make sure it works
 1. have songs that play in the background, somehow. (perhaps by using the iPod?)
 1. the user can select songs that they want to play during the game.
 1. add hysteresis so they dont follow and lose you at the same time.
 1. add a speech messaging queue of some sort to make all the announcments without clobbering each other
 1. save everything that happens during a run so that the player can watch it later.
 
 
 
 
 
 Questions:
 
 How do you describe a point to someone that is running?
 
 If you arent sure of their location relative to the user, announce it generally (frank is following you)
 
 Once they are in line with you, then give a better description. (He is 30 meters behind you)
 
 


*/