//
//  FRPointTimerList.h
//  ontherun
//
//  Created by Matt Donahoe on 3/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FRPoint.h"

@interface FRPointTimerList : FRPoint{
	NSArray * positions;
	NSArray * messages;
	NSArray * times;
	int timer;
}

/*
 This object can be used for creating race events with Checkpoints
 
 
 provide a list of places, messages and times
 
 
 might be good to have a local PathSearch object so that we can direct the player
 to this location
 
 */


@end
