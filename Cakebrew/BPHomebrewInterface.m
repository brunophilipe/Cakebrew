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

@implementation BPHomebrewInterface

+ (void)showHomebrewNotInstalledMessage
{
	static BOOL isShowing = NO;
	if (!isShowing) {
		isShowing = YES;
		[[NSNotificationCenter defaultCenter] postNotificationName:kBP_NOTIFICATION_LOCK_WINDOW object:self];
	}
}

+ (NSString*)performBrewCommandWithArguments:(NSArray*)arguments
{
	// Test if homebrew is installed
	NSInteger retval = system("sdjh");//[kBP_HOMEBREW_PATH UTF8String]);
	if (retval == kBP_EXEC_FILE_NOT_FOUND) {
		[BPHomebrewInterface showHomebrewNotInstalledMessage];
		return nil;
	}

	NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath:kBP_HOMEBREW_PATH];
    [task setArguments:arguments];

	NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    [task setStandardInput:[NSPipe pipe]];

    NSFileHandle *file;
    file = [pipe fileHandleForReading];

    [task launch];

    NSData *data;
    data = [file readDataToEndOfFile];

    NSString *string;
    /*
	 string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	 NSLog (@"script returned:\n%@", string);
	 */

    [task waitUntilExit];

    string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	return string;
}

+ (NSArray*)list
{
	return [BPHomebrewInterface listMode:kBP_LIST_INSTALLED];
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

    NSString *string = [BPHomebrewInterface performBrewCommandWithArguments:arguments];
	NSArray *aux = nil;
    if (string) {
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
	} else {
		return nil;
	}
}

+ (NSArray*)searchForFormulaName:(NSString*)name {
    NSString *string = [BPHomebrewInterface performBrewCommandWithArguments:@[@"search", name]];
    if (string) {
		NSMutableArray* array = [[string componentsSeparatedByString:@"\n"] mutableCopy];
		[array removeLastObject];
		return array;
	} else {
		return nil;
	}
}

+ (NSString*)informationForFormula:(NSString*)formula {
	return [BPHomebrewInterface performBrewCommandWithArguments:@[@"info", formula]];
}

+ (NSString*)update {
	NSString *string = [BPHomebrewInterface performBrewCommandWithArguments:@[@"update"]];
    NSLog (@"script returned:\n%@", string);
	[[NSNotificationCenter defaultCenter] postNotificationName:kBP_NOTIFICATION_FORMULAS_CHANGED object:nil];
    return string;
}

+ (NSString*)upgradeFormula:(NSString*)formula {
	NSString *string = [BPHomebrewInterface performBrewCommandWithArguments:@[@"upgrade", formula]];
    NSLog (@"script returned:\n%@", string);
	[[NSNotificationCenter defaultCenter] postNotificationName:kBP_NOTIFICATION_FORMULAS_CHANGED object:nil];
    return string;
}

+ (NSString*)installFormula:(NSString*)formula {
	NSString *string = [BPHomebrewInterface performBrewCommandWithArguments:@[@"install", formula]];
    NSLog (@"script returned:\n%@", string);
	[[NSNotificationCenter defaultCenter] postNotificationName:kBP_NOTIFICATION_FORMULAS_CHANGED object:nil];
    return string;
}

+ (NSString*)uninstallFormula:(NSString*)formula {
    NSString *string = [BPHomebrewInterface performBrewCommandWithArguments:@[@"uninstall", formula]];
    NSLog (@"script returned:\n%@", string);
	[[NSNotificationCenter defaultCenter] postNotificationName:kBP_NOTIFICATION_FORMULAS_CHANGED object:nil];
    return string;
}

+ (void)runDoctorWithOutput:(id)output
{
	// Test if homebrew is installed
	NSInteger retval = system("sdjh");//[kBP_HOMEBREW_PATH UTF8String]);
	if (retval == kBP_EXEC_FILE_NOT_FOUND) {
		[BPHomebrewInterface showHomebrewNotInstalledMessage];
		output = nil;
		return;
	}

	NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath:kBP_HOMEBREW_PATH];
#ifdef DEBUG
	[task setArguments:@[@"leaves"]];
#else
	[task setArguments:@[@"doctor"]];
#endif

    [task setStandardOutput:output];
    [task setStandardInput:[NSPipe pipe]];

    [task launch];
    [task waitUntilExit];

	NSLog(@"Finished task!");
}
@end
