//
//  toqbot.h
//  ontherun
//
//  Created by Matt Donahoe on 2/2/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

@interface toqbot : NSObject {
	NSMutableDictionary * keys;
	NSMutableDictionary * selectors;
	NSMutableDictionary * delegates;
	ASIHTTPRequest * inrequest;
}

- (void) requestFinished:(ASIHTTPRequest *) request;
- (void) sendObject:(NSObject *)x forKey:(NSString *)key;
- (void) sentObject:(id)request;
- (void) loadKeys;
- (void) loadObjectForKey:(NSString *)key toDelegate:(id)d usingSelector:(SEL)s;
- (void) requestFinished:(ASIHTTPRequest *) request;
- (void) requestFailed:(ASIHTTPRequest *)request;
- (void) sendDictionary:(NSDictionary *)keyvals;


@end
