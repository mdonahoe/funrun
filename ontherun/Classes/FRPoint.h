//
//  FRPoint.h
//  ontherun
//
//  Created by Matt Donahoe on 1/5/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "FRMap.h"

@interface FRPoint : NSObject {
	NSString * name;
	EdgePos pos;
	FRPoint * target;
	float speed;
	NSDictionary * dictme;
}
@property(nonatomic,retain) NSString * name;
@property(assign) EdgePos pos;
@property(nonatomic,retain) FRPoint * target;
@property(readonly) NSDictionary * dictme;

- (id) initWithDict:(NSDictionary*)dict;
@end
