//
//  FRMissionList.h
//  ontherun
//
//  Created by Matt Donahoe on 5/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FRMissionList : UITableViewController {
    NSArray * missions;
    NSArray * evidence;
}
- (NSDictionary*)objFromIndexPath:(NSIndexPath*)indexPath;
- (id)initWithUsername:(NSString *)username;
- (void) uploadLogs;
- (void) saveFailed:(id)request;
- (void) savedALog:(id) request;
@end
