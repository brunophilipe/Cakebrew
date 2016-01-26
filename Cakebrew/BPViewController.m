//
//  BPViewController.m
//  Cakebrew
//
//  Created by Marek Hrusovsky on 26/01/16.
//  Copyright © 2016 Bruno Philipe. All rights reserved.
//

#import "BPViewController.h"

@interface BPViewController ()

@end

@implementation BPViewController

- (void)awakeFromNib
{
  NSView *view = [self viewToSubstitute];
  if (view) {
	[self setViewToSubstitute:nil];
	[[self view] setFrame:[view frame]];
	[[self view] setAutoresizingMask:[view autoresizingMask]];
	[[view superview] replaceSubview:view with:[self view]];
	
  }
}
@end
