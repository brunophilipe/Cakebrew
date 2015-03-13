//
//  BPLoadingView.m
//  Cakebrew
//
//  Created by Bruno Philipe on 3/13/15.
//  Copyright (c) 2015 Bruno Philipe. All rights reserved.
//

#import "BPLoadingView.h"

@implementation BPLoadingView

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	if (self) {
		[self.progressIndicator startAnimation:nil];
	}
	return self;
}

- (void)setHidden:(BOOL)hidden
{
	[super setHidden:hidden];
	if (!hidden) {
		[self.progressIndicator startAnimation:nil];
	} else {
		[self.progressIndicator stopAnimation:nil];
	}
}

@end
