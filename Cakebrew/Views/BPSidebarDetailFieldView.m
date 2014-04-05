//
//  BPSidebarDetailFieldView.m
//  Cakebrew
//
//  Created by Bruno Philipe on 4/3/14.
//
//

#import "BPSidebarDetailFieldView.h"

@implementation BPSidebarDetailFieldView

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
	self.textColor = [NSColor whiteColor];
}

- (void)drawRect:(NSRect)dirtyRect
{
	NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:self.bounds xRadius:8 yRadius:8];

	[kBPDetailBackgroundColor setFill];

	[path fill];
    
    // Drawing code here.
	[super drawRect:dirtyRect];
}

- (void)setIntegerValue:(NSInteger)anInteger
{
	[super setIntegerValue:anInteger];
	CGFloat stringWidth = [self.attributedStringValue size].width;
	NSRect frame = self.frame;
	frame.size.width = stringWidth+8;
	[self setFrame:frame];
}

@end
