//
//  BPMainWindowController.m
//  Cakebrew
//
//  Created by Bruno on 06.02.21.
//  Copyright © 2021 Bruno Philipe. All rights reserved.
//

#import "BPMainWindowController.h"
#import "NSLayoutConstraint+Shims.h"

@interface BPMainWindowController ()

@property (strong) NSSplitViewController *splitViewController;

@end

@implementation BPMainWindowController

- (void)setUpViews
{
	_splitViewController = [[NSSplitViewController alloc] initWithNibName:nil bundle:nil];

	[_splitViewController addSplitViewItem:[self makeSidebarSplitViewItem]];
	[_splitViewController addSplitViewItem:[self makeContentSplitViewItem]];

	NSView *splitControllerView = [[self splitViewController] view];
	NSView *windowContentView = [[self window] contentView];

	NSAssert(splitControllerView, @"View should not be nil");
	NSAssert(windowContentView, @"View should not be nil");

	[splitControllerView setTranslatesAutoresizingMaskIntoConstraints:NO];
	[windowContentView addSubview:splitControllerView];

	[NSLayoutConstraint activate:@[
		[NSLayoutConstraint constraintWithItem:splitControllerView attribute:NSLayoutAttributeLeading
									 relatedBy:NSLayoutRelationEqual toItem:windowContentView
									 attribute:NSLayoutAttributeLeading multiplier:1 constant:0],
		[NSLayoutConstraint constraintWithItem:splitControllerView attribute:NSLayoutAttributeTrailing
									 relatedBy:NSLayoutRelationEqual toItem:windowContentView
									 attribute:NSLayoutAttributeTrailing multiplier:1 constant:0],
		[NSLayoutConstraint constraintWithItem:splitControllerView attribute:NSLayoutAttributeTop
									 relatedBy:NSLayoutRelationEqual toItem:windowContentView
									 attribute:NSLayoutAttributeTop multiplier:1 constant:0],
		[NSLayoutConstraint constraintWithItem:splitControllerView attribute:NSLayoutAttributeBottom
									 relatedBy:NSLayoutRelationEqual toItem:windowContentView
									 attribute:NSLayoutAttributeBottom multiplier:1 constant:0],
	]];
}

- (void)setContentViewHidden:(BOOL)hide
{
	[self.windowContentView setHidden:hide];
}

- (NSSplitViewItem *)makeSidebarSplitViewItem
{
	NSViewController *sidebarViewController = [[NSViewController alloc] initWithNibName:nil bundle:nil];
	[sidebarViewController setView:[self sidebarView]];
	NSSplitViewItem *sidebarSplitViewItem;

	if (@available(macOS 10.11, *)) {
		sidebarSplitViewItem = [NSSplitViewItem sidebarWithViewController:sidebarViewController];
	} else {
		sidebarSplitViewItem = [NSSplitViewItem splitViewItemWithViewController:sidebarViewController];
		[sidebarSplitViewItem setCanCollapse:YES];
		[sidebarSplitViewItem setHoldingPriority:NSLayoutPriorityDefaultLow + 100];
	}

	return sidebarSplitViewItem;
}

- (NSSplitViewItem *)makeContentSplitViewItem
{
	NSViewController *contentViewController = [[NSViewController alloc] initWithNibName:nil bundle:nil];
	[contentViewController setView:[self windowContentView]];
	NSSplitViewItem *sidebarContentViewItem = [NSSplitViewItem splitViewItemWithViewController:contentViewController];

	return sidebarContentViewItem;
}

@end
