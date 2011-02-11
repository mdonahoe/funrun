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
 
 1. better descriptions of what is moving
 1. cache the mission and map scripts.
 1. record some gps data for offline playback.
 1. pins are not unique looking
 1. have songs that play in the background, somehow. (perhaps by using the iPod?)
 1. the user can select songs that they want to play during the game.
 1. save everything that happens during a run so that the player can watch it later.
 1. gps that works while the screen is off.
 1. 
 
 
 
 
 Questions:
 
 How do you describe a point to someone that is running?
 
 If you arent sure of their location relative to the user, announce it generally (frank is following you)
 
 Once they are in line with you, then give a better description. (He is 30 meters behind you)
 
 punch the enemies if they are infront of you and you are going fast enough?
 
 detect that you are off grid.
 
 group enemies together and announce their distances together.
 
 are meters important? all i gain from that is:
 
 1. am i losing them, or are they catching me?
 2. what state are they in
 3. is the gps still working.


 
 
 what should i be doing now?
 
 
 ugh i hate not knowing what the plan should be, or losing focus.
 
 - group enemies together
 - attack enemies if moving fast enough
 - better location model (predicted position? particles?)
 - confirm that deep sleep prevention is working
 - subclass FRPoint to create good items and people to chase
 - music that changes
 - more talking (there are dull moments)
 - sound effects instead of just txt-to-speech
 - test with iPhone 3GS
 
 
 
 
*/