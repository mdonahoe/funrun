//
//  FREdgePos.h
//  ontherun
//
//  Created by Matt Donahoe on 2/15/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FREdgePos : NSObject {
	int start;
	int end;
	float position;
}
@property(assign) int start;
@property(assign) int end;
@property(assign) float position;

@end
