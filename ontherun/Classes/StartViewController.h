//
//  StartViewController.h
//  ontherun
//
//  Created by Matt Donahoe on 3/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRMissionTemplate.h"

@interface StartViewController : UIViewController {
	UILabel * missionLabel;
	FRMissionTemplate * mission;
	UISwitch * gps;
}
@property(nonatomic,retain) IBOutlet UILabel * missionLabel;
@property(nonatomic,retain) IBOutlet UISwitch * gps;
- (IBAction)loadMissionOne:(id)sender;
- (IBAction)loadMissionTwo:(id)sender;
@end
