//
//  FRBriefingViewController.h
//  ontherun
//
//  Created by Matt Donahoe on 3/24/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRMissionTemplate.h"
// http://developer.apple.com/library/ios/#documentation/uikit/reference/UITableViewDelegate_Protocol/Reference/Reference.html

//
@interface FRBriefingViewController : UITableViewController <UITableViewDelegate,UITableViewDataSource>{
	UITableViewCell * objective;
	UITableViewCell * destination;
	UITableViewCell * footerView;
	NSString * missionText;
	NSString * desttext;
	FRMissionTemplate * mission;
}
@property(nonatomic,retain) NSString * desttext;
@property(nonatomic,assign) FRMissionTemplate * mission; //retain?
- (void) setDest:(NSString *)name;
- (void) setText:(NSString *)text;
@end
