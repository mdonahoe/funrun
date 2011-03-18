//
//  VSSpeechSynthesizer.h
//  ontherun
//
//  Created by Matt Donahoe on 3/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//



#import  <foundation/foundation.h>

@interface VSSpeechSynthesizer : NSObject 
{ 
} 

+ (id)availableLanguageCodes; 
+ (BOOL)isSystemSpeaking; 
- (id)startSpeakingString:(id)string; 
- (id)startSpeakingString:(id)string toURL:(id)url; 
- (id)startSpeakingString:(id)string toURL:(id)url withLanguageCode:(id)code; 
- (float)rate;             // default rate: 1 
- (id)setRate:(float)rate; 
- (float)pitch;           // default pitch: 0.5
- (id)setPitch:(float)pitch; 
- (float)volume;       // default volume: 0.8
- (id)setVolume:(float)volume;
- (bool) isSpeaking; //this this real?
- (void) setDelegate:(id)delegate;
@end

