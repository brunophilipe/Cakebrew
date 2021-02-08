//
//  BPFormulaOption.h
//  Cakebrew
//
//  Created by Marek Hrusovsky on 09/10/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BPFormulaOption : NSObject <NSSecureCoding, NSCopying>

@property (copy) NSString *explanation;
@property (copy) NSString *name;

@end
