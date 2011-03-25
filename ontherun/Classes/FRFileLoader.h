//
//  FRFileLoader.h
//  ontherun
//
//  Created by Matt Donahoe on 2/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 
 permenantly caches remote resources into the app's Documents directory
 
 todo:
 provide an easy way to dump the cache for everything
 
 */
@interface FRFileLoader : NSObject {
	NSString * baseurl;
}
- (id) initWithBaseURLString:(NSString *) url;
- (NSString *) pathForFile:(NSString *) filename;
- (void) deleteCacheForFile:(NSString *) filename;
@end
