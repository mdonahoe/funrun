//
//  FRFileLoader.m
//  ontherun
//
//  Created by Matt Donahoe on 2/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FRFileLoader.h"
#import "ASIHTTPRequest.h"

@implementation FRFileLoader
-(id) initWithBaseURLString:(NSString *)url {
	self = [super init];
	[url retain];
	baseurl = url;
	return self;
}
- (void) deleteCacheForFile:(NSString *) filename {
	if (filename==nil) return;
	
	// Point to Document directory
	NSString * documentsDirectory = [NSHomeDirectory() 
									 stringByAppendingPathComponent:@"Documents"];
	// File we want to create in the documents directory 
	NSString *filePath = [documentsDirectory 
						  stringByAppendingPathComponent:filename];
	
	
	//check if it actually exists
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]==NO){
		//delete it
	}
}
- (NSString *) pathForFile:(NSString *) filename {
	if (filename==nil) return nil;
	
	// Point to Document directory
	NSString * documentsDirectory = [NSHomeDirectory() 
									 stringByAppendingPathComponent:@"Documents"];
	// File we want to create in the documents directory 
	NSString *filePath = [documentsDirectory 
						  stringByAppendingPathComponent:filename];
	
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]==NO){
		
		//download
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",baseurl,filename]];
		ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
		[request startSynchronous];
		NSError *error = [request error];
		
		BOOL success=YES;
		NSString * statusstring;
		if (!error) {
			NSData *data = [request responseData];
			if ([[NSFileManager defaultManager] createFileAtPath:filePath contents:data attributes:nil]){
				statusstring = [NSString stringWithFormat:@"%@ saved.",filename];
			} else {
				statusstring = [NSString stringWithFormat:@"%@ could not be saved.",filename];
				success = NO;
			}
		} else {
			success = NO;
			statusstring = [NSString stringWithFormat:@"%@ download error: %@",filename,error];
		}
		NSLog(@"%@",statusstring);
		if (!success) return nil;
	}
	
	return filePath;
	
}
- (void) dealloc {
	[baseurl release];
	[super dealloc];
}

@end
