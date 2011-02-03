//
//  MapView.m
//  ontherun
//
//  Created by Matt Donahoe on 2/2/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "MapView.h"


@implementation MapView
@synthesize points;


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		edges = nil;
		points = [[NSMutableArray alloc] initWithCapacity:3];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetLineWidth(context, 2.0);
	CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
	
	float maxX,minX,maxY,minY;
	maxX = -1000000000;
	maxY = maxX;
	minX = 1000000000;
	minY = minX;
	for (NSArray * edge in edges){
		CGPoint p1 = [[edge objectAtIndex:0] CGPointValue];
		CGPoint p2 = [[edge objectAtIndex:1] CGPointValue];
		maxX = MAX(MAX(p2.x,p1.x),maxX);
		maxY = MAX(MAX(p2.y,p1.y),maxY);
		minX = MIN(MIN(p2.x,p1.x),minX);
		minY = MIN(MIN(p2.y,p1.y),minY);		
	}
	float mx = 640.0 / (maxX - minX);
	float bx = (maxX + minX)/2;
	float my = 960.0 / (maxY - minY);
	float by = (maxY + minY)/2;
	//NSLog(@"maxX = %f,maxY = %f,minX = %f,minY = %f,mx = %f,my = %f,bx = %f,by = %f",maxX,maxY,minX,minY,mx,my,bx,by);
	
	for (NSArray * edge in edges){
		CGPoint p1 = [[edge objectAtIndex:0] CGPointValue];
		CGPoint p2 = [[edge objectAtIndex:1] CGPointValue];
		//NSLog(@"A = <%f,%f>",mx*(p1.x - bx),my*(p1.y - by));
		//NSLog(@"B = <%f,%f>",mx*(p2.x - bx),my*(p2.y - by));
		//CGContextMoveToPoint(context,-p1.x,p1.y);
		//CGContextAddLineToPoint(context,-p2.x,p2.y);
		
		CGContextMoveToPoint(context,mx*(p1.x - bx),my*(p1.y - by));
		CGContextAddLineToPoint(context,mx*(p2.x - bx),my*(p2.y - by));
		
	}
	
	CGContextStrokePath(context);
	CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
	
	
	for (NSValue * p in points){
		CGPoint pt = [p CGPointValue];
		float x = mx*(pt.x - bx);
		float y = my*(pt.y - by);
		CGRect rectangle = CGRectMake(x,y,x+4,y+4);
        CGContextAddRect(context, rectangle);
        CGContextStrokePath(context);
	}
}
//- (void) setCenter
- (void) setEdges:(NSArray *)es {
	[es retain];
	[edges release];
	edges = es;
	[self setNeedsDisplay];
}
- (void)dealloc {
    [super dealloc];
}


@end
