//
//  BPTopMarginView.m
//  Cakebrew
//
//  Created by Bruno Philipe on 4/3/14.
//
//

#import "BPTopBorderView.h"

@interface BPTopBorderView ()

@property (strong) NSBezierPath *topPath;

@end

@implementation BPTopBorderView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[self configure];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self configure];
	}
	return self;
}

- (void)configure
{
	[self setTopPath:[[NSBezierPath alloc] init]];

	[self setBorderColor:kBPViewBorderColor];
	[self setBackgroundColor:kBPViewBackgroundColor];
}

- (void)drawRect:(NSRect)dirtyRect
{
	[self.backgroundColor setFill];
	[self.borderColor setStroke];

	NSRectFill(dirtyRect);

	[_topPath removeAllPoints];
	[_topPath moveToPoint:NSMakePoint(0, self.frame.size.height)];
	[_topPath lineToPoint:NSMakePoint(self.frame.size.width, self.frame.size.height)];
	[_topPath setLineWidth:3];
	[_topPath stroke];
}

@end
