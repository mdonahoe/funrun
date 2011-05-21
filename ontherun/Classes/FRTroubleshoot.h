//
//  FRTroubleshoot.h
//  ontherun
//
//  Created by Matt Donahoe on 5/21/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FRTroubleshoot : UIViewController {
    UISlider *e_slider;
    UISlider *t_slider;
    UISlider *r_slider;
    UISlider *f_slider;
}

@property (nonatomic, retain) IBOutlet UISlider *e_slider;
@property (nonatomic, retain) IBOutlet UISlider *t_slider;
@property (nonatomic, retain) IBOutlet UISlider *r_slider;
@property (nonatomic, retain) IBOutlet UISlider *f_slider;

@end
