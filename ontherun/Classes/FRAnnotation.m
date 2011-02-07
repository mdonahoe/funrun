//
//  FRAnnotation.m
//  ontherun
//
//  Created by Matt Donahoe on 2/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FRAnnotation.h"


@implementation FRAnnotation
- (CLLocationCoordinate2D)coordinate;
{
    return mycoordinate;
}
- (void) setCoordinate:(CLLocationCoordinate2D)newCoordinate {
	mycoordinate = newCoordinate;
}
// required if you set the MKPinAnnotationView's "canShowCallout" property to YES
- (NSString *)title
{
    return @"Golden Gate Bridge";
}

// optional
- (NSString *)subtitle
{
    return @"Opened: May 27, 1937";
}

- (void)dealloc
{
    [super dealloc];
}
@end
