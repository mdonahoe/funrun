//
//  FRMissionChase.h
//  ontherun
//
//  Created by Matt Donahoe on 3/18/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FRMissionTemplate.h"

@interface FRMissionChase : FRMissionTemplate {

	FRPoint * target;
	BOOL running;
}

@end
