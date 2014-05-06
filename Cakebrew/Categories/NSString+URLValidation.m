//
//  NSString+URLValidation.m
//  Cakebrew
//
//  Created by Marek Hrusovsky on 05/05/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import "NSString+URLValidation.h"

@implementation NSString (URLValidation)

- (BOOL)bp_containsValidURL
{
  //TODO: Implement more sophisticated validation
  NSURL *URL = [NSURL URLWithString:self];
  if (URL) {
    return YES;
  } else {
    return NO;
  }
}

@end
