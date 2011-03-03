//
//  FREdgePos.m
//  ontherun
//
//  Created by Matt Donahoe on 2/15/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "FREdgePos.h"


@implementation FREdgePos
@synthesize start,end,position;
- (NSString *) description {
	return [NSString stringWithFormat:@"ep(start:%i,end:%i,position:%f)",start,end,position];
}
@end
