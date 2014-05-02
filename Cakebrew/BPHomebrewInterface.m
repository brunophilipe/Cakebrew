//
//	BrewInterface.m
//	Cakebrew – The Homebrew GUI App for OS X 
//
//	Created by Vincent Saluzzo on 06/12/11.
//	Copyright (c) 2011 Bruno Philipe. All rights reserved.
//
//	This program is free software: you can redistribute it and/or modify
//	it under the terms of the GNU General Public License as published by
//	the Free Software Foundation, either version 3 of the License, or
//	(at your option) any later version.
//
//	This program is distributed in the hope that it will be useful,
//	but WITHOUT ANY WARRANTY; without even the implied warranty of
//	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//	GNU General Public License for more details.
//
//	You should have received a copy of the GNU General Public License
//	along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import "BPHomebrewInterface.h"
#import "BPFormula.h"

#define kBP_EXEC_FILE_NOT_FOUND 32512

@interface BPHomebrewInterfaceListCall : NSObject
@property (readonly) NSArray *arguments;
- (instancetype)initWithArguments:(NSArray *)arguments;
- (NSArray *)parseData:(NSString *)data;
- (BPFormula *)parseFormulaItem:(NSString *)item;
@end

@implementation BPHomebrewInterfaceListCall
- (instancetype)initWithArguments:(NSArray *)arguments
{
    self = [super init];
    if (self) {
        _arguments = arguments;
    }
    return self;
}

- (NSArray *)parseData:(NSString *)data
{
    NSMutableArray *array = [[data componentsSeparatedByString:@"\n"] mutableCopy];
    [array removeLastObject];

    NSMutableArray *formulas = [NSMutableArray arrayWithCapacity:array.count];

    for (NSString *item in array) {
        BPFormula *formula = [self parseFormulaItem:item];
        if (formula) {
            [formulas addObject:formula];
        }
    }
    return formulas;
}

- (BPFormula *)parseFormulaItem:(NSString *)item
{
    return [BPFormula formulaWithName:item];
}
@end

@interface BPHomebrewInterfaceListCallInstalled : BPHomebrewInterfaceListCall
@end

@implementation BPHomebrewInterfaceListCallInstalled
- (instancetype)init
{
    return [super initWithArguments:@[@"list", @"--versions"]];
}

- (BPFormula *)parseFormulaItem:(NSString *)item
{
    NSArray *aux = [item componentsSeparatedByString:@" "];
    return [BPFormula formulaWithName:[aux firstObject] andVersion:[aux lastObject]];
}
@end

@interface BPHomebrewInterfaceListCallAll : BPHomebrewInterfaceListCall
@end

@implementation BPHomebrewInterfaceListCallAll
- (instancetype)init
{
    return [super initWithArguments:@[@"search"]];
}
@end

@interface BPHomebrewInterfaceListCallLeaves : BPHomebrewInterfaceListCall
@end

@implementation BPHomebrewInterfaceListCallLeaves
- (instancetype)init
{
    return [super initWithArguments:@[@"leaves"]];
}
@end

@interface BPHomebrewInterfaceListCallUpgradeable : BPHomebrewInterfaceListCall
@end

@implementation BPHomebrewInterfaceListCallUpgradeable
- (instancetype)init
{
    return [super initWithArguments:@[@"outdated", @"--verbose"]];
}

- (BPFormula *)parseFormulaItem:(NSString *)item
{
    NSRange nameEnd = [item rangeOfString:@" "];
    NSRange openBracket = [item rangeOfString:@"("];
    NSRange upgradeArrow = [item rangeOfString:@" < "];
    NSRange closeBracket = [item rangeOfString:@")"];

    if (nameEnd.location == NSNotFound ||
        openBracket.location == NSNotFound ||
        upgradeArrow.location == NSNotFound ||
        closeBracket.location == NSNotFound)
    {
        return [BPFormula formulaWithName:item];
    }

    NSString *name = [item substringWithRange:NSMakeRange(0, nameEnd.location - 1)];
    NSString *version = [item substringWithRange:NSMakeRange(openBracket.location + 1, upgradeArrow.location - openBracket.location - 1)];
    NSString *latestVersion = [item substringWithRange:NSMakeRange(upgradeArrow.location + upgradeArrow.length, closeBracket.location - upgradeArrow.location - upgradeArrow.length)];

    return [BPFormula formulaWithName:name andVersion:version andLatestVersion:latestVersion];
}
@end


@implementation BPHomebrewInterface

BOOL testedForInstallation;

+ (BPHomebrewInterface *)sharedInterface
{
    @synchronized(self)
	{
        static dispatch_once_t once;
        static BPHomebrewInterface *instance;
        dispatch_once(&once, ^ { instance = [[BPHomebrewInterface alloc] init]; });
        return instance;
	}
}

- (void)showHomebrewNotInstalledMessage
{
	static BOOL isShowing = NO;
	if (!isShowing) {
		isShowing = YES;
		[[NSNotificationCenter defaultCenter] postNotificationName:kBP_NOTIFICATION_LOCK_WINDOW object:self];
	}
}

- (void)hideHomebrewNotInstalledMessage
{
	[[NSNotificationCenter defaultCenter] postNotificationName:kBP_NOTIFICATION_UNLOCK_WINDOW object:self];
}

//This method returns nil because brew is never in the default $PATH used by NSTask
- (NSString*)getHomebrewPath __deprecated
{
	NSTask *task;
    task = [[NSTask alloc] init];

	[task setLaunchPath:@"/usr/bin/which"];
	[task setArguments:@[@"which"]];

	NSPipe *output = [NSPipe pipe];
	[task setStandardOutput:output];

	[task launch];

	[task waitUntilExit];
	NSString *string = [[NSString alloc] initWithData:[[output fileHandleForReading] readDataToEndOfFile] encoding:NSUTF8StringEncoding];

	if (string && ![string isEqualToString:@""] && [[NSFileManager defaultManager] fileExistsAtPath:[string stringByReplacingOccurrencesOfString:@"\n" withString:@""]]) {
		return string;
	} else {
		return nil;
	}
}

- (NSString*)performBrewCommandWithArguments:(NSArray*)arguments
{
	return [self performBrewCommandWithArguments:arguments captureError:NO];
}

- (NSString*)performBrewCommandWithArguments:(NSArray*)arguments captureError:(BOOL)captureError
{
	// Test if homebrew is installed
	static NSString *pathString;

	if (!testedForInstallation || !pathString) {
		pathString = [[NSUserDefaults standardUserDefaults] objectForKey:kBP_HOMEBREW_PATH_KEY];
		if (!pathString)
			pathString = kBP_HOMEBREW_PATH;
		
		NSInteger retval = system([pathString UTF8String]);
		if (retval == kBP_EXEC_FILE_NOT_FOUND) {
			[self showHomebrewNotInstalledMessage];
			return nil;
		}
		testedForInstallation = YES;
	}

	BOOL enableProxy = [[NSUserDefaults standardUserDefaults] boolForKey:kBP_HOMEBREW_PROXY_ENABLE_KEY];
	NSString *proxyURL = [[NSUserDefaults standardUserDefaults] objectForKey:kBP_HOMEBREW_PROXY_KEY];

	NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath:pathString];
    [task setArguments:arguments];

	if (enableProxy && proxyURL) {
		[task setEnvironment:@{@"http_proxy": proxyURL, @"https_proxy": proxyURL}];
	}

	NSPipe *pipe_output, *pipe_error;

	pipe_output = [NSPipe pipe];
    [task setStandardOutput:pipe_output];

	if (captureError) {
		pipe_error = [NSPipe pipe];
		[task setStandardError:pipe_error];
	}

    [task setStandardInput:[NSPipe pipe]];
	[task launch];

    [task waitUntilExit];

	NSString *string_output, *string_error;
    string_output = [[NSString alloc] initWithData:[[pipe_output fileHandleForReading] readDataToEndOfFile] encoding:NSUTF8StringEncoding];

	if (!captureError) {
		return string_output;
	} else {
		string_error = [[NSString alloc] initWithData:[[pipe_error fileHandleForReading] readDataToEndOfFile] encoding:NSUTF8StringEncoding];
		return [NSString stringWithFormat:@"%@\n%@", string_output, string_error];
	}
}

- (NSArray*)list
{
	return [self listMode:kBP_LIST_INSTALLED];
}

- (NSArray*)listMode:(BP_LIST_MODE)mode {
    BPHomebrewInterfaceListCall *listCall = nil;

	switch (mode) {
		case kBP_LIST_INSTALLED:
            listCall = [[BPHomebrewInterfaceListCallInstalled alloc] init];
			break;

		case kBP_LIST_ALL:
            listCall = [[BPHomebrewInterfaceListCallAll alloc] init];
			break;

		case kBP_LIST_LEAVES:
            listCall = [[BPHomebrewInterfaceListCallLeaves alloc] init];
			break;

		case kBP_LIST_UPGRADEABLE:
            listCall = [[BPHomebrewInterfaceListCallUpgradeable alloc] init];
			break;

		default:
			return nil;
	}

    NSString *string = [self performBrewCommandWithArguments:listCall.arguments];
    if (string) {
        return [listCall parseData:string];
	} else {
		return nil;
	}
}

- (NSArray*)searchForFormulaName:(NSString*)name {
    NSString *string = [self performBrewCommandWithArguments:@[@"search", name]];
    if (string) {
		NSMutableArray* array = [[string componentsSeparatedByString:@"\n"] mutableCopy];
		[array removeLastObject];
		return array;
	} else {
		return nil;
	}
}

- (NSString*)informationForFormula:(NSString*)formula {
	return [self performBrewCommandWithArguments:@[@"info", formula]];
}

- (NSString*)update {
	NSString *string = [self performBrewCommandWithArguments:@[@"update"]];
    NSLog (@"script returned:\n%@", string);
	[[NSNotificationCenter defaultCenter] postNotificationName:kBP_NOTIFICATION_FORMULAS_CHANGED object:nil];
    return string;
}

- (NSString*)upgradeFormula:(NSString*)formula {
	NSString *string = [self performBrewCommandWithArguments:@[@"upgrade", formula]];
    NSLog (@"script returned:\n%@", string);
	[[NSNotificationCenter defaultCenter] postNotificationName:kBP_NOTIFICATION_FORMULAS_CHANGED object:nil];
    return string;
}

- (NSString*)upgradeFormulas:(NSArray*)formulas
{
	NSString *string = [self performBrewCommandWithArguments:[@[@"upgrade"] arrayByAddingObjectsFromArray:formulas]];
	NSLog (@"script returned:\n%@", string);
	[[NSNotificationCenter defaultCenter] postNotificationName:kBP_NOTIFICATION_FORMULAS_CHANGED object:nil];
    return string;
}

- (NSString*)installFormula:(NSString*)formula {
	NSString *string = [self performBrewCommandWithArguments:@[@"install", formula]];
    NSLog (@"script returned:\n%@", string);
	[[NSNotificationCenter defaultCenter] postNotificationName:kBP_NOTIFICATION_FORMULAS_CHANGED object:nil];
    return string;
}

- (NSString*)uninstallFormula:(NSString*)formula {
    NSString *string = [self performBrewCommandWithArguments:@[@"uninstall", formula]];
    NSLog (@"script returned:\n%@", string);
	[[NSNotificationCenter defaultCenter] postNotificationName:kBP_NOTIFICATION_FORMULAS_CHANGED object:nil];
    return string;
}

- (NSString*)runDoctor
{
	NSString *string = [self performBrewCommandWithArguments:@[@"doctor"] captureError:YES];
    NSLog (@"script returned:\n%@", string);
    return string;
}

@end
