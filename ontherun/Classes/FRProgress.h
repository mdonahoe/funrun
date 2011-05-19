//
//  FRProgress.h
//  ontherun
//
//  Created by Matt Donahoe on 5/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FRSoundFilePlayer <NSObject>

- (BOOL)playSoundFile:(NSString*)filename;

@end


@interface FRProgress : NSObject {
    
    int percentage;
    int absolute;
    float start;
    id <FRSoundFilePlayer> delegate;
}

- (id) initWithStart:(float)s delegate:(id<FRSoundFilePlayer>)d;
- (void) update:(float)x;

@end
