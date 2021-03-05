//
//  BPMainWindowController.m
//  Cakebrew
//
//  Created by Bruno on 06.02.21.
//  Copyright © 2021 Bruno Philipe. All rights reserved.
//

#import "BPMainWindowController.h"

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

	[splitControllerView setTranslatesAutoresizingMaskIntoConstraints:NO];
	[windowContentView addSubview:splitControllerView];

	[NSLayoutConstraint activateConstraints:@[
		[[splitControllerView leadingAnchor] constraintEqualToAnchor:[windowContentView leadingAnchor]],
		[[splitControllerView trailingAnchor] constraintEqualToAnchor:[windowContentView trailingAnchor]],
		[[splitControllerView topAnchor] constraintEqualToAnchor:[windowContentView topAnchor]],
		[[splitControllerView bottomAnchor] constraintEqualToAnchor:[windowContentView bottomAnchor]]
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
	NSSplitViewItem *sidebarSplitViewItem = [NSSplitViewItem sidebarWithViewController:sidebarViewController];

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
