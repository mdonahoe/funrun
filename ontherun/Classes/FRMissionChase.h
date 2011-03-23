//
//  FRMissionChase.h
//  ontherun
//
//  Created by Matt Donahoe on 3/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FRMissionTemplate.h"

@interface FRMissionChase : FRMissionTemplate {

	FRPoint * target;
	BOOL running;
}


/*
 Problems from latest test:
	1. i dont want to chase after people that arent on my way.
	2. dead ends are terrible
	3. repeats shit alot because of "click". come up with a better description system
	4. no way to say that i dont want to follow someone
	5. doesnt detect that i am off the map.
	6. still no music!?
 */

@end
