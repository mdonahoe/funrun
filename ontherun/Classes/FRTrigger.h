//
//  FRTrigger.h
//  ontherun
//
//  Created by Matt Donahoe on 1/5/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FRPoint.h"

@interface FRTrigger : NSObject {
	BOOL active;
	NSString * name;
	float countdown;
	float lessthan;
	float greaterthan; //ugh hack town
	FRPoint * point;
	NSArray * ons;
	NSArray * offs;
	NSArray * swaptargets;
	NSDictionary * dictme;
	id delegate;
}
@property(nonatomic) BOOL active;
@property(nonatomic,retain) NSString * name;
@property(nonatomic,retain) FRPoint * point;
@property(nonatomic,retain) NSArray * ons;
@property(nonatomic,retain) NSArray * offs;
@property(nonatomic,retain) NSArray * swaptargets;

- (id) initWithDict:(NSDictionary*)dict;
- (void) finishByUsingTriggerList:(NSArray *)triggers andPointList:(NSArray *)points;
- (float) checkdistancefrom:(CLLocation *)user;
@end
