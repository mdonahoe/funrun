//
//  voicetestAppDelegate.h
//  voicetest
//
//  Created by Matt Donahoe on 9/29/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

@class voicetestViewController;

@interface voicetestAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    voicetestViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet voicetestViewController *viewController;

@end

