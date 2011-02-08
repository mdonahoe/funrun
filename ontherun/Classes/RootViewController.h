//
//  RootViewController.h
//  ontherun
//
//  Created by Matt Donahoe on 1/5/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRMission.h"

@interface RootViewController : UITableViewController {
	NSArray * triggers;
	NSArray * messages;
	FRMission * themission;
}
@end
