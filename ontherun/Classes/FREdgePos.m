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
- (NSNumber *) startObj {
	return [NSNumber numberWithInt:start];
}
- (NSNumber *) endObj {
	return [NSNumber numberWithInt:end];
}
- (BOOL) onSameEdgeAs:(FREdgePos *)other{
    return ((start==other.start && end==other.end) || (start==other.end && end==other.start));
}
- (BOOL) onEdgeFromA:(NSNumber*)nodeA toB:(NSNumber *)nodeB{
    return ([nodeA isEqualToNumber:[self startObj]] && [nodeB isEqualToNumber:[self endObj]]) ||
    ([nodeA isEqualToNumber:[self endObj]] && [nodeB isEqualToNumber:[self startObj]]);
}
@end
