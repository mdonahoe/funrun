//
//  FRTrigger.h
//  ontherun
//
//  Created by Matt Donahoe on 1/5/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FRPoint.h"
#import "SoundEffect.h"

@interface FRTrigger : NSObject <UIAlertViewDelegate>{
	BOOL active;
	NSString * name;
	float countdown;
	float lastdistance;
	float lessthan;
	float greaterthan; //ugh hack town
	FRPoint * point;
	NSArray * ons;
	NSArray * offs;
	NSArray * swaptargets;
	NSDictionary * dictme;
	SoundEffect * sound;
	id delegate;
}

/*
 I am beginning to wonder if triggers have a place in my new architecture.
 
 I really need to plan this out more.
 
 Triggers are hard to setup.
 
 If Points start getting intelligent, it will be tough to have generalized triggers introspect them.
 
 
 
 */

@property(nonatomic) BOOL active;
@property(nonatomic,retain) NSString * name;
@property(nonatomic,retain) FRPoint * point;
@property(nonatomic,retain) NSArray * ons;
@property(nonatomic,retain) NSArray * offs;
@property(nonatomic,retain) NSArray * swaptargets;

- (id) initWithDict:(NSDictionary*)dict;
- (void) finishByUsingTriggerList:(NSArray *)triggers andPointList:(NSArray *)points;
- (float) checkdistancefrom:(CLLocation *)user;
- (NSString *)displayname;
- (void)loadSoundFile:(NSString *)filename;
- (void)execute;
- (void)setDelegate:(id)x;
- (void)ticktock;

@end
