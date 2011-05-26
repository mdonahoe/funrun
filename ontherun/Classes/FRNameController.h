//
//  FRNameController.h
//  ontherun
//
//  Created by Matt Donahoe on 5/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRMissionList.h"

@interface FRNameController : UIViewController {
    UITextField *namefield;
}
@property (nonatomic, retain) IBOutlet UITextField *namefield;
- (IBAction)selectName:(id)sender;

@end
