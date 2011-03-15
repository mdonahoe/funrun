//
//  FRMissionOne.h
//  ontherun
//
//  Created by Matt Donahoe on 3/14/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 
 Mission One.
 
 Objectives:
 1. Get to the drop point
 2. Chase after the target
 3. Get back to your hideout and await further instructions
 
 
 */


@interface FRMissionOne : NSObject {
	NSDate * start_time;
	FRPoint * droppoint;
	FRPoint * target;
	FRPoint * user;
	FRPoint * pursuer;
}



@end
