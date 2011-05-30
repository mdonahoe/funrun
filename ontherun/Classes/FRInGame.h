//
//  FRInGame.h
//  ontherun
//
//  Created by Matt Donahoe on 5/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MagicButton <NSObject>

- (void) magicbutton;

@end

@interface FRInGame : UIViewController {
    id delegate;
}

@property(nonatomic,assign) id delegate;

- (IBAction)magicbutton:(id)sender;

@end
