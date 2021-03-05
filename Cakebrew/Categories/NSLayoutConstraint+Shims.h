//
//  NSLayoutConstraint+Shims.h
//  Cakebrew
//
//  Created by Bruno Philipe on 06.03.21.
//  Copyright © 2021 Bruno Philipe. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSLayoutConstraint (Shims)

+ (void)activate:(NSArray<NSLayoutConstraint *> *)constraints;

@end

NS_ASSUME_NONNULL_END
