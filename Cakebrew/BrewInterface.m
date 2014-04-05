//
//  BrewInterface.m
//  Cakebrew
//
//  Created by Vincent Saluzzo on 06/12/11.
//  Copyright (c) 2011 Bruno Philipe. All rights reserved.
//

#import "BrewInterface.h"
#import "BPFormula.h"

#define kBP_HOMEBREW_PATH @"/usr/local/bin/brew"

@implementation BrewInterface

+ (NSString*)performBrewCommandWithArguments:(NSArray*)arguments
{
	NSTask *listTask;
    listTask = [[NSTask alloc] init];
    [listTask setLaunchPath:kBP_HOMEBREW_PATH];
    [listTask setArguments:arguments];

	NSPipe *pipe;
    pipe = [NSPipe pipe];
    [listTask setStandardOutput:pipe];
    [listTask setStandardInput:[NSPipe pipe]];

    NSFileHandle *file;
    file = [pipe fileHandleForReading];

    [listTask launch];

    NSData *data;
    data = [file readDataToEndOfFile];

    NSString *string;
    /*
	 string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	 NSLog (@"script returned:\n%@", string);
	 */

    [listTask waitUntilExit];

    string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	return string;
}

+ (NSArray*)list
{
	return [BrewInterface listMode:kBP_LIST_INSTALLED];
}

+ (NSArray*)listMode:(BP_LIST_MODE)mode {
	NSArray *arguments = nil;
	BOOL displaysVersions = NO;

	switch (mode) {
		case kBP_LIST_INSTALLED:
			arguments = @[@"list", @"--versions"];
			displaysVersions = YES;
			break;

		case kBP_LIST_ALL:
			arguments = @[@"search"];
			break;

		case kBP_LIST_LEAVES:
			arguments = @[@"leaves"];
			break;

		case kBP_LIST_UPGRADEABLE:
			arguments = @[@"outdated"];
			displaysVersions = YES;
			break;

		default:
			return nil;
	}

    NSString *string = [BrewInterface performBrewCommandWithArguments:arguments];
	NSArray *aux = nil;
    NSMutableArray *array = [[string componentsSeparatedByString:@"\n"] mutableCopy];
	NSMutableArray *formulas = [NSMutableArray arrayWithCapacity:array.count-1];
	BPFormula *formula = nil;

	[array removeLastObject];

	for (NSString *item in array) {
		if (displaysVersions) {
			aux = [item componentsSeparatedByString:@" "];
			formula = [BPFormula formulaWithName:[aux firstObject] andVersion:[aux lastObject]];
		} else {
			formula = [BPFormula formulaWithName:item];
		}
		[formulas addObject:formula];
	}

    return formulas;
}

+ (NSArray*)search:(NSString*)formula {
    NSString *string = [BrewInterface performBrewCommandWithArguments:@[@"search", formula]];
    NSMutableArray* array = [[string componentsSeparatedByString:@"\n"] mutableCopy];
    [array removeLastObject];
    return array;
}

+ (NSString*)info:(NSString*)formula {
	NSString *string = [BrewInterface performBrewCommandWithArguments:@[@"info", formula]];
	return string;
}

+ (NSString*)update {
	NSString *string = [BrewInterface performBrewCommandWithArguments:@[@"update"]];
    NSLog (@"script returned:\n%@", string);
    return string;
}

+ (NSString*)upgrade:(NSString*)formula {
	NSString *string = [BrewInterface performBrewCommandWithArguments:@[@"upgrade", formula]];
    NSLog (@"script returned:\n%@", string);
    return string;
}

+ (NSString*)install:(NSString*)formula {
	NSString *string = [BrewInterface performBrewCommandWithArguments:@[@"install", formula]];
    NSLog (@"script returned:\n%@", string);
    return string;
}

+ (NSString*)uninstall:(NSString*)formula {
    NSString *string = [BrewInterface performBrewCommandWithArguments:@[@"uninstall", formula]];
    NSLog (@"script returned:\n%@", string);
    return string;
}
@end
