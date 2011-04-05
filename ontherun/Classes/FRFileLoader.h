//
//  FRFileLoader.h
//  ontherun
//
//  Caches files in the app's Documents directory
//
//  Created by Matt Donahoe on 2/14/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FRFileLoader : NSObject {
	NSString * baseurl;
}
- (id) initWithBaseURLString:(NSString *) url;
- (NSString *) pathForFile:(NSString *) filename;
- (void) deleteCacheForFile:(NSString *) filename;
@end
