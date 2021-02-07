//
//  BPBackgroundView.m
//  Cakebrew
//
//  Created by Bruno Philipe on 10/15/15.
//  Copyright © 2015 Bruno Philipe. All rights reserved.
//

#import "BPBackgroundView.h"

@implementation BPBackgroundView

- (id)init
{
	self = [super init];
	if (self) {
		[self setUp];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	if (self) {
		[self setUp];
	}
	return self;
}

- (id)initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame:frameRect];
	if (self) {
		[self setUp];
	}
	return self;
}

- (void)setUp
{
	if (!self.backgroundColor) {
		[self setBackgroundColor:[NSColor controlColor]];
		[self setWantsLayer:YES];
	}
}

- (void)drawRect:(NSRect)dirtyRect {
	[[self backgroundColor] setFill];
	
	NSRectFill(dirtyRect);
}

@end
