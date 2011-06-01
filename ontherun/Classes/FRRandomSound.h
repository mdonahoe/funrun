//
//  FRRandomSound.h
//  ontherun
//
//  Created by Matt Donahoe on 6/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FRProgress.h"

@interface FRRandomSound : NSObject {
    NSMutableArray * filenames;
    int cycle;
    id <FRSoundFilePlayer> delegate;
}

- (id) initWithArray:(NSArray*)names delegate:(id<FRSoundFilePlayer>)d;
- (BOOL) played;
- (void) shuffle;
@end
