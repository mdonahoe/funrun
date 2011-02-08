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
 3. Create a game object that has the logic currently inside root view controller.(when the view unloads, it causes problems)
 4. cache the mission and map scripts.
 5. 
 
 


*/