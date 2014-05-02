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

@interface BPHomebrewInterface ()
{
	BOOL testedForInstallation;

	void (^operationUpdateBlock)(NSString*);
}

@end

@implementation BPHomebrewInterface

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

- (id)init
{
	self = [super init];
	if (self) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatedFileHandle:) name:NSFileHandleDataAvailableNotification object:nil];
	}
	return self;
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

- (BOOL)performBrewCommandWithArguments:(NSArray*)arguments dataReturnBlock:(void (^)(NSString*))block
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
			return NO;
		}
		testedForInstallation = YES;
	}

	operationUpdateBlock = block;

	NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath:pathString];
    [task setArguments:arguments];

	NSPipe *pipe_output = [NSPipe pipe];
	NSPipe *pipe_error = [NSPipe pipe];
    [task setStandardOutput:pipe_output];
    [task setStandardInput:[NSPipe pipe]];
	[task setStandardError:pipe_error];

	NSFileHandle *handle_output = [pipe_output fileHandleForReading];
	[handle_output waitForDataInBackgroundAndNotify];

	NSFileHandle *handle_error = [pipe_error fileHandleForReading];
	[handle_error waitForDataInBackgroundAndNotify];

	[task launch];
    [task waitUntilExit];

	return YES;
}

- (void)updatedFileHandle:(NSNotification*)n
{
	NSFileHandle *fh = [n object];
    NSData *data = [fh availableData];
	dispatch_async(dispatch_get_main_queue(), ^{
		operationUpdateBlock([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
	});
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

- (NSString*)update __deprecated
{
	NSString *string = [self performBrewCommandWithArguments:@[@"update"]];
//	NSLog (@"script returned:\n%@", string);
	[[NSNotificationCenter defaultCenter] postNotificationName:kBP_NOTIFICATION_FORMULAS_CHANGED object:nil];
    return string;
}

- (NSString*)upgradeFormula:(NSString*)formula __deprecated
{
	NSString *string = [self performBrewCommandWithArguments:@[@"upgrade", formula]];
//	NSLog (@"script returned:\n%@", string);
	[[NSNotificationCenter defaultCenter] postNotificationName:kBP_NOTIFICATION_FORMULAS_CHANGED object:nil];
    return string;
}

- (NSString*)upgradeFormulas:(NSArray*)formulas __deprecated
{
	NSString *string = [self performBrewCommandWithArguments:[@[@"upgrade"] arrayByAddingObjectsFromArray:formulas]];
//	NSLog (@"script returned:\n%@", string);
	[[NSNotificationCenter defaultCenter] postNotificationName:kBP_NOTIFICATION_FORMULAS_CHANGED object:nil];
    return string;
}

- (NSString*)installFormula:(NSString*)formula __deprecated
{
	NSString *string = [self performBrewCommandWithArguments:@[@"install", formula]];
//	NSLog (@"script returned:\n%@", string);
	[[NSNotificationCenter defaultCenter] postNotificationName:kBP_NOTIFICATION_FORMULAS_CHANGED object:nil];
    return string;
}

- (NSString*)uninstallFormula:(NSString*)formula __deprecated
{
    NSString *string = [self performBrewCommandWithArguments:@[@"uninstall", formula]];
//	NSLog (@"script returned:\n%@", string);
	[[NSNotificationCenter defaultCenter] postNotificationName:kBP_NOTIFICATION_FORMULAS_CHANGED object:nil];
    return string;
}

- (NSString*)runDoctor __deprecated
{
	NSString *string = [self performBrewCommandWithArguments:@[@"doctor"] captureError:YES];
//	NSLog (@"script returned:\n%@", string);
    return string;
}

- (BOOL)updateWithReturnBlock:(void (^)(NSString*output))block
{
	BOOL val = [self performBrewCommandWithArguments:@[@"update"] dataReturnBlock:block];
	[[NSNotificationCenter defaultCenter] postNotificationName:kBP_NOTIFICATION_FORMULAS_CHANGED object:nil];
	return val;
}

- (BOOL)upgradeFormula:(NSString*)formula withReturnBlock:(void (^)(NSString*output))block
{
	BOOL val = [self performBrewCommandWithArguments:@[@"upgrade", formula] dataReturnBlock:block];
	[[NSNotificationCenter defaultCenter] postNotificationName:kBP_NOTIFICATION_FORMULAS_CHANGED object:nil];
	return val;
}

- (BOOL)upgradeFormulas:(NSArray*)formulas withReturnBlock:(void (^)(NSString*output))block
{
	BOOL val = [self performBrewCommandWithArguments:[@[@"upgrade"] arrayByAddingObjectsFromArray:formulas] dataReturnBlock:block];
	[[NSNotificationCenter defaultCenter] postNotificationName:kBP_NOTIFICATION_FORMULAS_CHANGED object:nil];
	return val;
}

- (BOOL)installFormula:(NSString*)formula withReturnBlock:(void (^)(NSString*output))block
{
	BOOL val = [self performBrewCommandWithArguments:@[@"install", formula] dataReturnBlock:block];
	[[NSNotificationCenter defaultCenter] postNotificationName:kBP_NOTIFICATION_FORMULAS_CHANGED object:nil];
	return val;
}

- (BOOL)uninstallFormula:(NSString*)formula withReturnBlock:(void (^)(NSString*output))block
{
	BOOL val = [self performBrewCommandWithArguments:@[@"uninstall", formula] dataReturnBlock:block];
	[[NSNotificationCenter defaultCenter] postNotificationName:kBP_NOTIFICATION_FORMULAS_CHANGED object:nil];
	return val;
}

- (BOOL)runDoctorWithReturnBlock:(void (^)(NSString*output))block
{
	BOOL val = [self performBrewCommandWithArguments:@[@"doctor"] dataReturnBlock:block];
	[[NSNotificationCenter defaultCenter] postNotificationName:kBP_NOTIFICATION_FORMULAS_CHANGED object:nil];
	return val;
}

@end
