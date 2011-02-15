//
//  FRPointSequence.h
//  ontherun
//
//  Created by Matt Donahoe on 2/15/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FRPoint.h"

@interface FRPointSequence : FRPoint {
	NSArray * positions;
	NSArray * messages;
}

@end
