//
//  NSLayoutConstraint+Shims.m
//  Cakebrew
//
//  Created by Bruno Philipe on 06.03.21.
//  Copyright © 2021 Bruno Philipe. All rights reserved.
//

#import "NSLayoutConstraint+Shims.h"

@implementation NSLayoutConstraint (Shims)

+ (void)activate:(NSArray<NSLayoutConstraint *> *)constraints
{
	if ([self respondsToSelector:@selector(activateConstraints:)]) {
		[self activateConstraints:constraints];
	} else {
		for (NSLayoutConstraint *constraint in constraints) {
			[constraint.firstItem addConstraint:constraint];
		}
	}
}

@end
