//
//  FRPoint.h
//  ontherun
//
//  Created by Matt Donahoe on 1/5/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface FRPoint : NSObject {
	NSString * name;
	CLLocation * pos;
	FRPoint * target;
	float speed;
	NSDictionary * dictme;
}
@property(nonatomic,retain) NSString * name;
@property(nonatomic,retain) CLLocation * pos;
@property(nonatomic,retain) FRPoint * target;

- (id) initWithDict:(NSDictionary*)dict;

@end
