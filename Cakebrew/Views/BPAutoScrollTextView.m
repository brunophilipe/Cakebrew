//
//  BPAutoScrollTextView.m
//  Cakebrew
//
//  Created by Bruno Philipe on 6/17/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import "BPAutoScrollTextView.h"

@implementation BPAutoScrollTextView

- (void)setString:(NSString *)string
{
	[super setString:string];
	[self scrollToEndOfDocument:self];
}

@end
