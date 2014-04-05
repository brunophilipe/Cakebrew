//
//  BrewInterface.h
//  Cakebrew
//
//  Created by Vincent Saluzzo on 06/12/11.
//  Copyright (c) 2011 Bruno Philipe. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
	kBP_LIST_ALL,
    kBP_LIST_INSTALLED,
    kBP_LIST_LEAVES,
	kBP_LIST_UPGRADEABLE
} BP_LIST_MODE;

#define kBP_EXCEPTION_HOMEBREW_NOT_INSTALLED @"BP_EXCEPTION_HOMEBREW_NOT_INSTALLED"

@interface BrewInterface :NSObject

+ (NSArray*)list;
+ (NSArray*)listMode:(BP_LIST_MODE)mode;
+ (NSArray*)search:(NSString*)formula;
+ (NSString*)info:(NSString*)formula;
+ (NSString*)update;
+ (NSString*)upgrade:(NSString*)formula;
+ (NSString*)install:(NSString*)formula;
+ (NSString*)uninstall:(NSString*)formula;

@end
