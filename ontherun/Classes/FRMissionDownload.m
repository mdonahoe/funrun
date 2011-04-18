//
//  FRMissionDownload.m
//  ontherun
//
//  Created by Matt Donahoe on 4/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FRMissionDownload.h"


@implementation FRMissionDownload


- (void) ticktock {
    switch (current_state){
        case 0:
            [self intro];
            break;
        case 1:
            break;
        case 2:
            break;
    }
}


- (void) intro {
    //play ulysses' sound files one after another.
}


@end
