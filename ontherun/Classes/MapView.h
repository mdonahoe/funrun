//
//  MapView.h
//  ontherun
//
//  Created by Matt Donahoe on 2/2/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MapView : UIView {
	NSArray * edges;
	NSMutableArray * points;
}
@property(nonatomic,retain) NSMutableArray * points;

-(void) setEdges:(NSArray *)es;

@end
