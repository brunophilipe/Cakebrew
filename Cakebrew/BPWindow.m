//
//  BPWindow.m
//  Cakebrew
//
//  Created by Bruno on 06.02.21.
//  Copyright © 2021 Bruno Philipe. All rights reserved.
//

#import "BPWindow.h"

@implementation BPWindow

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	if ([menuItem action] == @selector(runToolbarCustomizationPalette:)) {
		return NO;
	}

	return [super validateMenuItem:menuItem];
}

@end
