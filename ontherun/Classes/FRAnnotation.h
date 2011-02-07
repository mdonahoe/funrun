//
//  FRAnnotation.h
//  ontherun
//
//  Created by Matt Donahoe on 2/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface FRAnnotation : NSObject <MKAnnotation>{
	CLLocationCoordinate2D mycoordinate;
}

@end
