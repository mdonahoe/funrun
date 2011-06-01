//
//  FRRandomSound.m
//  ontherun
//
//  Created by Matt Donahoe on 6/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FRRandomSound.h"


@implementation FRRandomSound
- (id) initWithArray:(NSArray *)names delegate:(id<FRSoundFilePlayer>)d{
    self = [super init];
    if (!self) return nil;
    delegate = d;
    filenames = [[NSMutableArray alloc] initWithArray:names];
    cycle = [filenames count];
    
    return self;
}


- (BOOL) played {
    BOOL p = [delegate playSoundFile:[filenames objectAtIndex:cycle-1]];
    if (p) cycle--;
    if (cycle==0) [self shuffle];
    return p;
}

- (void) shuffle {
    //shuffle the order
    NSMutableArray * newarray = [[NSMutableArray alloc] initWithCapacity:[filenames count]];
    while ([filenames count]>0) {
        int rand_index = arc4random()%[filenames count];
        [newarray addObject:[filenames objectAtIndex:rand_index]];
        [filenames removeObjectAtIndex:rand_index];
    }
    [filenames release];
    filenames = newarray;
    cycle = [filenames count];
}

- (void) dealloc {
    [filenames release];
    [super dealloc];
}
@end
