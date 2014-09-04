//
//  NSFont+Appearane.m
//  Cakebrew
//
//  Created by Marek Hrusovsky on 04/09/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import "NSFont+Appearance.h"

@implementation NSFont (Appearance)


+ (NSFont*)bp_defaultFixedWidthFont
{
	static NSFont *font = nil;
  
	if (!font) {
    font = [self fontWithName:@"Andale Mono" size:12];
		if (!font)
      font = [self fontWithName:@"Menlo" size:12];
		if (!font)
			font = [self systemFontOfSize:12];
	}
  
	return font;
}

@end
