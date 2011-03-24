//
//  FRSummaryViewController.h
//  ontherun
//
//  Created by Matt Donahoe on 3/23/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FRSummaryViewController : UIViewController {
	UILabel * status;
}
@property (nonatomic, retain) IBOutlet UILabel * status;
@end
