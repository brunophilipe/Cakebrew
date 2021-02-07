//
//  BPWindow.m
//  Cakebrew
//
//  Created by Bruno on 06.02.21.
//  Copyright © 2021 Bruno Philipe. All rights reserved.
//

#import "BPWindow.h"

@implementation BPWindow

- (instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSWindowStyleMask)style backing:(NSBackingStoreType)backingStoreType defer:(BOOL)flag
{
	self = [super initWithContentRect:contentRect styleMask:style backing:backingStoreType defer:flag];
	if (self) {
		[self sharedInit];
	}
	return self;
}

- (instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSWindowStyleMask)style backing:(NSBackingStoreType)backingStoreType defer:(BOOL)flag screen:(nullable NSScreen *)screen
{
	self = [super initWithContentRect:contentRect styleMask:style backing:backingStoreType defer:flag screen:screen];
	if (self) {
		[self sharedInit];
	}
	return self;
}

- (void)sharedInit
{
	if (@available(macOS 11.0, *)) {
		NSWindowStyleMask mask = [self styleMask];
		mask |= NSWindowStyleMaskFullSizeContentView;
		[self setStyleMask:mask];
	} else {
		[self setContentBorderThickness:22 forEdge:NSRectEdgeMinY];
	}
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	if ([menuItem action] == @selector(runToolbarCustomizationPalette:)) {
		return NO;
	}

	return [super validateMenuItem:menuItem];
}

@end
