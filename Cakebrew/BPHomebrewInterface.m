//
//	BrewInterface.m
//	Cakebrew – The Homebrew GUI App for OS X 
//
//	Created by Vincent Saluzzo on 06/12/11.
//	Copyright (c) 2014 Bruno Philipe. All rights reserved.
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
NSString *const cakebrewOutputIdentifier = @"+++++Cakebrew+++++";

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
	static NSString *regexString = @"(\\S*)\\s\\((\\S*) < (\\S*)\\)";

	BPFormula __block *formula = nil;
	NSError *error = nil;
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:NSRegularExpressionCaseInsensitive error:&error];

	[regex enumerateMatchesInString:item options:0 range:NSMakeRange(0, [item length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		if (result.resultType == NSTextCheckingTypeRegularExpression) {
			formula = [BPFormula formulaWithName:[item substringWithRange:[result rangeAtIndex:1]]
										 version:[item substringWithRange:[result rangeAtIndex:2]]
								andLatestVersion:[item substringWithRange:[result rangeAtIndex:3]]];
		}
	}];

	if (!formula) {
		formula = [BPFormula formulaWithName:item];
	}

	return formula;
}

@end

@interface BPHomebrewInterfaceListCallSearch : BPHomebrewInterfaceListCall

@end

@implementation BPHomebrewInterfaceListCallSearch

- (instancetype)initWithSearchParameter:(NSString*)param
{
    return [super initWithArguments:@[@"search", param]];
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

- (id)init
{
	self = [super init];
	if (self) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatedFileHandle:) name:NSFileHandleDataAvailableNotification object:nil];
        self.task = nil;
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public Methods

- (void)hideHomebrewNotInstalledMessage
{
	[[NSNotificationCenter defaultCenter] postNotificationName:kBP_NOTIFICATION_UNLOCK_WINDOW object:self];
}

#pragma mark - Private Methods

- (NSString *)getValidUserShell
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

	if (!isValidShell)
	{
		static NSAlert *alert = nil;
		if (!alert)
			alert = [NSAlert alertWithMessageText:@"No Valid shell was found!" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Please add your shell \"%@\" to the valid shells file at \"/etc/shells\" before trying again.", userShell];
		[alert performSelectorOnMainThread:@selector(runModal) withObject:nil waitUntilDone:YES];

		NSLog(@"No valid shell found...");
		return nil;
	}

	return userShell;
}

- (NSArray *)formatArgumentsForShell:(NSString *)shellName withExtraArguments:(NSArray *)extraArguments
{
	NSString *command = [NSString stringWithFormat:@"echo \"%@\";brew %@", cakebrewOutputIdentifier, [extraArguments componentsJoinedByString:@" "]];
	NSArray *arguments = @[@"-l", @"-c", command];

	return arguments;
}

- (void)showHomebrewNotInstalledMessage
{
	static BOOL isShowing = NO;
	if (!isShowing) {
		isShowing = YES;
		[[NSNotificationCenter defaultCenter] postNotificationName:kBP_NOTIFICATION_LOCK_WINDOW object:self];
	}
}

- (BOOL)performBrewCommandWithArguments:(NSArray*)arguments dataReturnBlock:(void (^)(NSString*))block
{
	NSString *userShell = [self getValidUserShell];
	NSString *shellName = [userShell lastPathComponent];

	arguments = [self formatArgumentsForShell:shellName withExtraArguments:arguments];

	if (!userShell || !arguments) return NO;

	operationUpdateBlock = block;

    self.task = [[NSTask alloc] init];

	[self.task setLaunchPath:userShell];
	[self.task setArguments:arguments];

	NSPipe *pipe_output = [NSPipe pipe];
	NSPipe *pipe_error = [NSPipe pipe];
    [self.task setStandardOutput:pipe_output];
    [self.task setStandardInput:[NSPipe pipe]];
	[self.task setStandardError:pipe_error];

	NSFileHandle *handle_output = [pipe_output fileHandleForReading];
	[handle_output waitForDataInBackgroundAndNotify];

	NSFileHandle *handle_error = [pipe_error fileHandleForReading];
	[handle_error waitForDataInBackgroundAndNotify];

	#ifdef DEBUG
	block([NSString stringWithFormat:@"User Shell: %@\nCommand: %@ %@\nThe Doctor output is going to be different if run from Xcode!!\n\n", userShell, userShell, [arguments componentsJoinedByString:@" "]]);
	#endif

	[self.task launch];
    [self.task waitUntilExit];

	return YES;
}

- (void)updatedFileHandle:(NSNotification*)n
{
	NSFileHandle *fh = [n object];
    NSData *data = [fh availableData];
	[fh waitForDataInBackgroundAndNotify];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		operationUpdateBlock([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
	});
}

- (NSString*)performBrewCommandWithArguments:(NSArray*)arguments
{
	return [self performBrewCommandWithArguments:arguments captureError:NO];
}

- (NSString*)performBrewCommandWithArguments:(NSArray*)arguments captureError:(BOOL)captureError
{
	NSString *userShell = [self getValidUserShell];
	NSString *shellName = [userShell lastPathComponent];

	arguments = [self formatArgumentsForShell:shellName withExtraArguments:arguments];

	if (!userShell || !arguments) return NO;

    self.task = [[NSTask alloc] init];

	[self.task setLaunchPath:userShell];
	[self.task setArguments:arguments];

	NSPipe *pipe_output = [NSPipe pipe];
	NSPipe *pipe_error = [NSPipe pipe];
    [self.task setStandardOutput:pipe_output];
    [self.task setStandardInput:[NSPipe pipe]];
	[self.task setStandardError:pipe_error];

	[self.task launch];
    [self.task waitUntilExit];
    
	NSString *string_output, *string_error;
    string_output = [[NSString alloc] initWithData:[[pipe_output fileHandleForReading] readDataToEndOfFile] encoding:NSUTF8StringEncoding];
	string_error = [[NSString alloc] initWithData:[[pipe_error fileHandleForReading] readDataToEndOfFile] encoding:NSUTF8StringEncoding];

	if (!captureError) {
		return string_output;
	} else {
		return [NSString stringWithFormat:@"%@\n%@", string_output, string_error];
	}
}

#pragma mark - Operations that return on finish

- (NSArray*)list
{
	return [self listMode:kBPListInstalled];
}

- (NSArray*)listMode:(BPListMode)mode {
    BPHomebrewInterfaceListCall *listCall = nil;

	switch (mode) {
		case kBPListInstalled:
            listCall = [[BPHomebrewInterfaceListCallInstalled alloc] init];
			break;

		case kBPListAll:
            listCall = [[BPHomebrewInterfaceListCallAll alloc] init];
			break;

		case kBPListLeaves:
            listCall = [[BPHomebrewInterfaceListCallLeaves alloc] init];
			break;

		case kBPListOutdated:
            listCall = [[BPHomebrewInterfaceListCallUpgradeable alloc] init];
			break;

		default:
			return nil;
	}

    NSString *string = [self performBrewCommandWithArguments:listCall.arguments];
    string = [self removeLoginShellOutputFromResults:string];

    if (string) {
        return [listCall parseData:string];
	} else {
		return nil;
	}
}

- (NSArray*)searchForFormulaName:(NSString*)name {
    BPHomebrewInterfaceListCall *listCall = [[BPHomebrewInterfaceListCallSearch alloc] initWithSearchParameter:name];
	NSString *string = [self performBrewCommandWithArguments:listCall.arguments];
	if (string) {
		return [listCall parseData:string];
	} else {
		return nil;
	}
}

- (NSString*)informationForFormula:(NSString*)formula {
	NSString *string = [self performBrewCommandWithArguments:@[@"info", formula]];
    return [self removeLoginShellOutputFromResults:string];
}

- (NSString*)removeLoginShellOutputFromResults:(NSString*)results {
    if (results) {
        NSString *identifierWithEOL = [NSString stringWithFormat:@"%@\n", cakebrewOutputIdentifier];
        NSRange range = [results rangeOfString:identifierWithEOL];
        return [results substringFromIndex:range.location + identifierWithEOL.length];
    }
    //If all else fails...
    return nil;
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

#pragma mark - Operations with live data callback block

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
