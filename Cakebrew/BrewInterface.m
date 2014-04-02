//
//  BrewInterface.m
//  Cakebrew
//
//  Created by Vincent Saluzzo on 06/12/11.
//  Copyright (c) 2011 Bruno Philipe. All rights reserved.
//

#import "BrewInterface.h"

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

+ (NSArray*)list {
    NSString *string = [BrewInterface performBrewCommandWithArguments:@[@"list"]];
    NSMutableArray* array = [[string componentsSeparatedByString:@"\n"] mutableCopy];
    [array removeLastObject];
    return array;
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
