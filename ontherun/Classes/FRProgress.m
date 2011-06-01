//
//  FRProgress.m
//  ontherun
//
//  Created by Matt Donahoe on 5/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FRProgress.h"


@implementation FRProgress
- (id) initWithStart:(float)s delegate:(id<FRSoundFilePlayer>)d{
    self = [super init];
    if (!self) return nil;
    start = s;
    percentage = 0;
    absolute = 0;
    delegate = d;
    //kilometer
    //500 meters
    //200 meters
    //100 meters
    //50 meters
    
    if (start < 1000) absolute=1;
    if (start < 500) absolute=2;
    if (start < 200) absolute=3;
    if (start < 100) absolute=4;
    if (start < 50) absolute=5;
    
    
    
    return self;
}
- (void) update:(float)x {
    switch (percentage){
        case 0:
            //just starting
            if (x > 100 && x / start < .5 && [delegate playSoundFile:@"ok youre halfway there"]) percentage++;
            break;
        case 1:
            //over halfway
            if (x / start < .2 && [delegate playSoundFile:@"youre getting close"]) percentage++;
            break;
        case 2:
            if (x / start < .1 && [delegate playSoundFile:@"youre almost there"]) percentage++;
            break;
        default:
            break;
    }
    
    
    switch (absolute){
        case 0:
            if (x<1000 && [delegate playSoundFile:@"1000 meters"]) absolute++;
            break;
        case 1:
            if (x<500 && [delegate playSoundFile:@"500 meters"]) absolute++;
            break;
        case 2:
            if (x<200 && [delegate playSoundFile:@"200 meters"]) absolute++;
            break;
        case 3:
            if (x<100 && [delegate playSoundFile:@"100 meters"]) absolute++;
            break;
        case 4:
            if (x<50 && [delegate playSoundFile:@"50 meters"]) absolute++;
            break;
        default:
            break;
    }
}
@end
