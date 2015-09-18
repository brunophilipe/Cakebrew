//
//  BPLoadingView.m
//  Cakebrew
//
//  Created by Bruno Philipe on 3/13/15.
//  Copyright (c) 2015 Bruno Philipe. All rights reserved.
//

#import "BPLoadingView.h"

@interface BPLoadingView()

@property (strong) IBOutlet NSView *view;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;

@end

@implementation BPLoadingView

- (void)awakeFromNib
{
	[self.progressIndicator startAnimation:self];
}

- (instancetype)initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame:frameRect];
	if (self) {
		[self commonInit];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	if (self) {
		[self commonInit];
	}
	return self;
}

- (void)commonInit
{
	NSNib *nib = [[NSNib alloc] initWithNibNamed:@"Loading" bundle:nil];
	[nib instantiateWithOwner:self topLevelObjects:NULL];
	self.view.frame = self.bounds;
	[self addSubview:self.view];
	
	self.view.translatesAutoresizingMaskIntoConstraints = NO;
	
	[self addConstraint:[self pin:self.view attribute:NSLayoutAttributeTop]];
	[self addConstraint:[self pin:self.view attribute:NSLayoutAttributeLeft]];
	[self addConstraint:[self pin:self.view attribute:NSLayoutAttributeBottom]];
	[self addConstraint:[self pin:self.view attribute:NSLayoutAttributeRight]];
}

- (NSLayoutConstraint *)pin:(id)item attribute:(NSLayoutAttribute)attribute
{
	return [NSLayoutConstraint constraintWithItem:self
										attribute:attribute
										relatedBy:NSLayoutRelationEqual
										   toItem:item
										attribute:attribute
									   multiplier:1.0
										 constant:0.0];
}

@end
