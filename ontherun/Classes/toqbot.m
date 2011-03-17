//
//  toqbot.m
//  ontherun
//
//  Created by Matt Donahoe on 2/2/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "toqbot.h"
#import "ASIFormDataRequest.h"
#import "JSON.h"


@implementation toqbot
-(id) init {
	self = [super init];
	if (self) {
		keys = [[NSMutableDictionary alloc] init];
		delegates = [[NSMutableDictionary alloc] init];
		selectors = [[NSMutableDictionary alloc] init];
		inrequest = nil;
	}
	return self;
}
-(void) loadObjectForKey:(NSString *)key toDelegate:(id)d usingSelector:(SEL)s {
	[keys setObject:[NSNumber numberWithInt:-1] forKey:key];
	[delegates setObject:d forKey:key];
	[selectors setObject:NSStringFromSelector(s) forKey:key];
	[self loadKeys];
}
-(void) sendObject:(NSObject *)x forKey:(NSString*)key {
	
	//extract and prepare the data
	NSString * data = [x JSONRepresentation];
	
	//create the POST request
	NSURL * url = [NSURL URLWithString:@"http://toqbot.com/db/"];
	
	//there can be many outrequests at once.
	ASIFormDataRequest * outrequest = [ASIFormDataRequest requestWithURL:url];
	[outrequest setPostValue:data forKey:key];
	
	//set the correct callback and send to server
	[outrequest setDidFinishSelector:@selector(sentObject:)];
	[outrequest setDidFailSelector:@selector(sentObject:)];
	[outrequest setDelegate:self];
	[outrequest startAsynchronous];
}
-(void) sentObject:(id)request {
	//NSLog(@"here is the request %@",request);
}
- (void) loadKeys {
	//get the path we are going to run
	NSMutableString *resultString = [NSMutableString string];
	for (NSString* key in [keys allKeys]){
		if ([resultString length] > 0)
			[resultString appendString:@"&"];
		[resultString appendFormat:@"%@=%@", key, [keys objectForKey:key]];
	}
	
	NSString * url = [NSString stringWithFormat:@"http://toqbot.com/db/?%@",resultString];
	
	[inrequest cancel];
	[inrequest release];
	inrequest = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]];
	[inrequest setTimeOutSeconds:50];
	[inrequest setDelegate:self];
	[inrequest startAsynchronous];
}
- (void) requestFinished:(ASIHTTPRequest *) request {
	NSArray * docs = [[request responseString] JSONValue];
	for (NSDictionary * doc in docs){
		int rev = [[doc valueForKey:@"rev"] intValue]+1;
		NSString * key = [doc valueForKey:@"key"];
		[keys
		 setObject:[NSNumber numberWithInt:rev]
		 forKey:key];
		id data = [[doc objectForKey:@"data"] JSONValue];
		if (data==nil) continue;
		
		SEL callback = NSSelectorFromString([selectors objectForKey:key]);
		id delegate = [delegates objectForKey:key];
		[delegate performSelector:callback withObject:data];
	}
	[self loadKeys];
}
- (void) requestFailed:(ASIHTTPRequest *) request {
	//NSLog(@"request error %@",[request error]);
	[self loadKeys];
}
- (void) sendDictionary:(NSDictionary *)keyvals {
	//create the POST request
	NSURL * url = [NSURL URLWithString:@"http://toqbot.com/db/"];
	
	//there can be many outrequests at once.
	ASIFormDataRequest * outrequest = [ASIFormDataRequest requestWithURL:url];
	
	//extract and prepare the data
	for (NSString * key in keyvals){
		NSString * data = [[keyvals objectForKey:key] JSONRepresentation];
		[outrequest setPostValue:data forKey:key];
	}
	
	//set the correct callback and send to server
	[outrequest setDidFinishSelector:@selector(sentObject:)];
	[outrequest setDidFailSelector:@selector(sentObject:)];
	[outrequest setDelegate:self];
	[outrequest startAsynchronous];
}
- (void) dealloc {
	[inrequest release];
	[delegates release];
	[selectors release];
	[keys release];
	[super dealloc];
}
@end
