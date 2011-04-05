//
//  FRMapViewController.h
//  ontherun
//
//  Created by Matt Donahoe on 2/7/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "FRMissionTemplate.h"

@interface FRMapViewController : UIViewController <MKMapViewDelegate>{
	MKMapView * mapView;
	UILabel * timer;
}
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UILabel * timer;
- (void) gotoLocation;

/* todo
 new colors for the pins, depending on class type (destination, bad guy etc)
 */

@end
