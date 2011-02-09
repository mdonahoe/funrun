//
//  FRTrigger.m
//  ontherun
//
//  Created by Matt Donahoe on 1/5/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "FRTrigger.h"
#import "ASIHTTPRequest.h"

@implementation FRTrigger

@synthesize active,name,point,ons,offs,swaptargets;

- (id) initWithDict:(NSDictionary*)dict {
	self = [super init];
	
	if (self) {
		name = [[NSString alloc] initWithString:[dict objectForKey:@"name"]];
		NSNumber * c = [dict objectForKey:@"countdown"];
		if (c!=nil){
			countdown = [c floatValue];
		} else {
			countdown = -1;
		}
		
		NSNumber * lt = [dict objectForKey:@"lessthan"];
		if (lt!=nil){
			lessthan = [lt floatValue];
		} else {
			lessthan = 0;
		}
		
		NSNumber * gt = [dict objectForKey:@"greaterthan"];
		if (gt!=nil){
			greaterthan = [gt floatValue];
		} else {
			greaterthan = 10000000000000; //big number
		}
		lastdistance = -1.0;
		dictme = dict;
		[dictme retain];
		
		[self loadSoundFile:[dictme objectForKey:@"sound"]];
	}
	
	return self;
}
- (void) ticktock {
	if (countdown>0) countdown--;
	if (countdown==0) {
		[self execute];
		countdown = -1;
	}
}
- (void) loadSoundFile:(NSString *) filename {
	if (filename==nil) return;
	
	// Point to Document directory
	NSString * documentsDirectory = [NSHomeDirectory() 
									stringByAppendingPathComponent:@"Documents"];
	// File we want to create in the documents directory 
	NSString *filePath = [documentsDirectory 
						  stringByAppendingPathComponent:filename];
	
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]==NO){
		
		//download
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://toqbot.com/funrun/sounds/%@",filename]];
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
		UIAlertView * messageAlert = [[UIAlertView alloc] initWithTitle:@"Download & Save" message:statusstring delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
		[messageAlert show];
		[messageAlert release];
		if (!success) return; //no more!
	}
 
	// Write the file
	//[str writeToFile:filePath atomically:YES 
	//		encoding:NSUTF8StringEncoding error:&error];
	
	// Show contents of Documents directory
	//NSLog(@"Documents directory: %@",
	//	  [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error]);
	
	NSLog(@"file path = %@",filePath);
	sound = [[SoundEffect alloc] initWithContentsOfFile:filePath];

}
- (NSString *)displayname {
	return [NSString stringWithFormat:@"%@:%1.1f %1.1f",name,countdown,lastdistance];
}
- (void) setDelegate:(id)x {
	delegate = x;
}
- (void) activate {
	active = YES;
	//if (countdown<0) return;
	//[self performSelector:@selector(execute) withObject:self afterDelay:countdown];
}
- (void) deactivate {
	//[NSObject cancelPreviousPerformRequestsWithTarget:self];
	active = NO;
}
- (void) execute {
	//speak or play sound
	NSLog(@"trig %@ has succeeded!",name);
	[self deactivate];
	[sound play];
	
	for (FRTrigger * trig in ons){
		[trig activate];
	}
	for (FRTrigger * trig in offs){
		[trig deactivate];
	}
	//for (pair in swaptargets){
		
	//}
	if (delegate) [delegate triggered];
}
- (void) finishByUsingTriggerList:(NSArray *)triggers andPointList:(NSArray*)points {

	NSMutableArray * _ons = [NSMutableArray arrayWithCapacity:3];
	for (NSString * nm in [dictme objectForKey:@"ons"]){
		for (FRTrigger * trig in triggers){
			if ([nm isEqualToString:trig.name]) [_ons addObject:trig];
		}
	}
	ons = [[NSArray alloc] initWithArray:_ons];
	
	NSMutableArray * _offs = [NSMutableArray arrayWithCapacity:3];
	for (NSString * nm in [dictme objectForKey:@"ons"]){
		for (FRTrigger * trig in triggers){
			if ([nm isEqualToString:trig.name]) [_ons addObject:trig];
		}
	}
	offs = [[NSArray alloc] initWithArray:_offs];
	
	NSString * pname = [dictme objectForKey:@"point"];
	if (pname!=nil){
		NSLog(@"name = %@",pname);
		for (FRPoint * pt in points){
			if ([pname isEqualToString:pt.title]) {
				point = pt;
			}
		}
		[point retain];
	}
	
	if ([[dictme objectForKey:@"active"] boolValue]) [self activate];
	[dictme release];
	dictme = nil;
	
}
- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
		NSString * temp = name;
        name = [NSString stringWithFormat:@"good - %@",temp];
		[name retain];
		[temp release];
    }
	[delegate triggered];
}
- (void) dealloc {
	[name release];
	[sound release];
	[dictme release];
	[ons release];
	[offs release];
	[point release];
	[super dealloc];
}
@end