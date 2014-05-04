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

    NSMutableArray *formulae = [NSMutableArray arrayWithCapacity:array.count];

    for (NSString *item in array) {
        BPFormula *formula = [self parseFormulaItem:item];
        if (formula) {
            [formulae addObject:formula];
        }
    }
    return formulae;
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

    NSString *name = [item substringWithRange:NSMakeRange(0, nameEnd.location)];
    NSString *version = [item substringWithRange:NSMakeRange(openBracket.location + 1, upgradeArrow.location - openBracket.location - 1)];
    NSString *latestVersion = [item substringWithRange:NSMakeRange(upgradeArrow.location + upgradeArrow.length, closeBracket.location - upgradeArrow.location - upgradeArrow.length)];

    return [BPFormula formulaWithName:name version:version andLatestVersion:latestVersion];
}

@end


@implementation BPHomebrewInterface
{
	NSString *brewPathString;
	void (^operationUpdateBlock)(NSString*);
}

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

- (NSDictionary *)findUserEnvironmentVariables:(NSArray *)variables
{
	NSString *userShell = [[[NSProcessInfo processInfo] environment] objectForKey:@"SHELL"];
	NSLog(@"User shell: %@", userShell);

	// avoid executing stuff like /sbin/nologin as a shell
	BOOL isValidShell = NO;
	for (NSString *validShell in [[NSString stringWithContentsOfFile:@"/etc/shells" encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]]) {
		if ([[validShell stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:userShell]) {
			isValidShell = YES;
			break;
		}
	}

	if (!isValidShell) return nil;

	NSMutableString *instruction = [NSMutableString string];

	for (NSString *variable in variables) {
		[instruction appendFormat:@"echo $%@; ", variable];
	}

	NSTask *task;
    task = [[NSTask alloc] init];

	[task setLaunchPath:userShell];
	[task setArguments:@[@"-l", @"-c", instruction]];

	NSLog(@"Sending instruction: %@ -l -c %@", userShell, instruction);

	NSPipe *output = [NSPipe pipe];
	[task setStandardOutput:output];

	[task launch];
	[task waitUntilExit];

	NSString *results = [[NSString alloc] initWithData:[output.fileHandleForReading readDataToEndOfFile] encoding:NSUTF8StringEncoding];
	NSDictionary *environment = [NSDictionary dictionaryWithObjects:[results componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] forKeys:[variables arrayByAddingObject:@""]];

	return [environment dictionaryWithValuesForKeys:variables];
}

- (NSString *)findHomebrewPath
{
	NSString *pathString = [[NSUserDefaults standardUserDefaults] objectForKey:kBP_HOMEBREW_PATH_KEY];

	// User has set custom path string
	if (pathString)
		return pathString;

	NSDictionary *environment = [self findUserEnvironmentVariables:@[@"PATH", @"HOME"]];
	if (environment) {
		NSTask *task;

		task = [[NSTask alloc] init];

		[task setLaunchPath:@"/usr/bin/which"];
		[task setArguments:@[@"brew"]];
		[task setEnvironment:environment];

		NSPipe *output = [NSPipe pipe];
		[task setStandardOutput:output];

		[task launch];
		[task waitUntilExit];

		pathString = [[[NSString alloc] initWithData:[[output fileHandleForReading] readDataToEndOfFile] encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];

		if (pathString && ![pathString isEqualToString:@""] && [[NSFileManager defaultManager] fileExistsAtPath:pathString]) {
			NSInteger retval = system([[pathString stringByAppendingString:@" -v"] UTF8String]);
			if (retval != kBP_EXEC_FILE_NOT_FOUND) {
				return pathString;
			}
		}
	}
	[self showHomebrewNotInstalledMessage];
	return nil;
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

- (BOOL)performBrewCommandWithArguments:(NSArray*)arguments dataReturnBlock:(void (^)(NSString*))block
{
	// Test if homebrew is installed
	static NSDictionary *userEnvironment;

	if (!brewPathString) {
		brewPathString = [self findHomebrewPath];
	}

	operationUpdateBlock = block;

	if (!userEnvironment)
		userEnvironment = [self findUserEnvironmentVariables:@[@"PATH", @"HOME"]];

	if (!brewPathString || !userEnvironment)
		return NO;

	BOOL enableProxy = [[NSUserDefaults standardUserDefaults] boolForKey:kBP_HOMEBREW_PROXY_ENABLE_KEY];
	NSString *proxyURL = [[NSUserDefaults standardUserDefaults] objectForKey:kBP_HOMEBREW_PROXY_KEY];

	NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath:brewPathString];
    [task setArguments:arguments];

	if (enableProxy && proxyURL) {
		NSMutableDictionary *env = [userEnvironment mutableCopy];
		[env setObject:proxyURL forKey:@"http_proxy"];
		[env setObject:proxyURL forKey:@"https_proxy"];
		[task setEnvironment:env];
	} else {
		[task setEnvironment:userEnvironment];
	}

	NSPipe *pipe_output = [NSPipe pipe];
	NSPipe *pipe_error = [NSPipe pipe];
    [task setStandardOutput:pipe_output];
    [task setStandardInput:[NSPipe pipe]];
	[task setStandardError:pipe_error];

	NSFileHandle *handle_output = [pipe_output fileHandleForReading];
	[handle_output waitForDataInBackgroundAndNotify];

	NSFileHandle *handle_error = [pipe_error fileHandleForReading];
	[handle_error waitForDataInBackgroundAndNotify];

	#ifdef DEBUG
	block([NSString stringWithFormat:@"Environment Variables (DEBUG Only):\n%@\n", [userEnvironment description]]);
	#endif

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
	static NSDictionary *userEnvironment;

	if (!brewPathString) {
		brewPathString = [self findHomebrewPath];
	}

	if (!userEnvironment)
		userEnvironment = [self findUserEnvironmentVariables:@[@"PATH", @"HOME"]];

	if (!brewPathString || !userEnvironment)
		return NO;

	BOOL enableProxy = [[NSUserDefaults standardUserDefaults] boolForKey:kBP_HOMEBREW_PROXY_ENABLE_KEY];
	NSString *proxyURL = [[NSUserDefaults standardUserDefaults] objectForKey:kBP_HOMEBREW_PROXY_KEY];

	NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath:brewPathString];
    [task setArguments:arguments];

	if (enableProxy && proxyURL) {
		NSMutableDictionary *env = [userEnvironment mutableCopy];
		[env setObject:proxyURL forKey:@"http_proxy"];
		[env setObject:proxyURL forKey:@"https_proxy"];
		[task setEnvironment:env];
	} else {
		[task setEnvironment:userEnvironment];
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

- (NSString*)upgradeFormulae:(NSArray*)formulae __deprecated
{
	NSString *string = [self performBrewCommandWithArguments:[@[@"upgrade"] arrayByAddingObjectsFromArray:formulae]];
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

- (BOOL)upgradeFormulae:(NSArray*)formulae withReturnBlock:(void (^)(NSString*output))block
{
	BOOL val = [self performBrewCommandWithArguments:[@[@"upgrade"] arrayByAddingObjectsFromArray:formulae] dataReturnBlock:block];
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
