//
//  main.m
//  gap
//
//  Created by Matt Donahoe on 2/1/11.
//  Copyright MIT Media Lab 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, @"gapAppDelegate");
    [pool release];
    return retVal;
}
