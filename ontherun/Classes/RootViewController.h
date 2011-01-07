//
//  RootViewController.h
//  ontherun
//
//  Created by Matt Donahoe on 1/5/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRPoint.h"
@interface RootViewController : UITableViewController {
	NSMutableDictionary * toqbotkeys;
	NSArray * triggers;
	NSArray * points;
	FRPoint * user;
}

@end
