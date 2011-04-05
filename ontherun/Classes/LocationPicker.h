//
//  LocationPicker.h
//  ontherun
//
//  Created by Matt Donahoe on 3/24/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@protocol LocationPickerDelegate <NSObject>

- (void)pickedLocation:(CLLocationCoordinate2D)location;

@end

@interface LocationPicker : UIViewController <MKMapViewDelegate> {
	IBOutlet MKMapView * mapView;
	id <MKAnnotation> pt;
	id <LocationPickerDelegate> delegate;
}
@property(nonatomic,retain) IBOutlet MKMapView * mapView;
- (id) initWithAnnotation:(id <MKAnnotation>)center delegate:(id)d;
@end


/*
 todo:
 save locations for use later
 add a listview with editable destinations
 
*/