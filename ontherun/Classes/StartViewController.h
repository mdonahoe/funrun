//
//  StartViewController.h
//  ontherun
//
//  Created by Matt Donahoe on 3/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRMission.h"

@interface StartViewController : UIViewController {
	FRMission * themission;
	NSString * missionid;
	IBOutlet UILabel * missionLabel;
}
- (IBAction)doAction:(id)sender;

@end
