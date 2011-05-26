//
//  FRMissionList.h
//  ontherun
//
//  Created by Matt Donahoe on 5/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "toqbot.h"

@interface FRMissionList : UITableViewController {
    toqbot * m2;
    NSArray * missions;
    NSArray * evidence;
    NSString * userkey;
}
- (NSDictionary*)objFromIndexPath:(NSIndexPath*)indexPath;
- (id)initWithUsername:(NSString *)username;
@end
