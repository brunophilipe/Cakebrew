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
#import "BPTask.h"

#define kDEBUG_WARNING @"\
User Shell: %@\n\
Command: %@\n\
OS X Version: %@\n\n\
The outputs are going to be different if run from Xcode!!\n\
Installing and upgrading formulas is not advised in DEBUG mode!\n\n"

static NSString *cakebrewOutputIdentifier = @"+++++Cakebrew+++++";

@interface BPHomebrewInterfaceListCall : NSObject

@property (strong, readonly) NSArray *arguments;

- (instancetype)initWithArguments:(NSArray *)arguments;
- (NSArray *)parseData:(NSString *)data;
- (BPFormula *)parseFormulaItem:(NSString *)item;

@end

@interface BPHomebrewInterfaceListCallInstalled : BPHomebrewInterfaceListCall
@end

@interface BPHomebrewInterfaceListCallAll : BPHomebrewInterfaceListCall
@end

@interface BPHomebrewInterfaceListCallLeaves : BPHomebrewInterfaceListCall
@end

@interface BPHomebrewInterfaceListCallUpgradeable : BPHomebrewInterfaceListCall
@end

@interface BPHomebrewInterfaceListCallRepositories: BPHomebrewInterfaceListCall
@end

@interface BPHomebrewInterface () <BPTaskCompleted>

@property (strong) NSString *path_cellar;
@property (strong) NSString *path_shell;
@property (strong) NSMutableDictionary *tasks;

@end

@implementation BPHomebrewInterface

+ (instancetype)sharedInterface
{
	@synchronized(self)
	{
		static dispatch_once_t once;
		static BPHomebrewInterface *instance;
		dispatch_once(&once, ^ { instance = [[super allocWithZone:NULL] initUniqueInstance]; });
		return instance;
	}
}

- (instancetype)initUniqueInstance
{
	self = [super init];
	if (self) {
		_tasks = [[NSMutableDictionary alloc] init];
	}
	return self;
}

+ (instancetype)allocWithZone:(NSZone *)zone
{
	return [self sharedInterface];
}

- (instancetype)copyWithZone:(NSZone *)zone
{
	return self;
}

- (void)cleanup
{
	[self.tasks enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(NSString *key, BPTask *task, BOOL *stop){
		[task cleanup];
	}];
}

- (BOOL)checkForHomebrew
{
	if (!self.path_shell) return NO;
	
	BPTask *task = [[BPTask alloc] initWithPath:self.path_shell arguments:@[@"-l", @"-c", @"which brew"]];
	task.delegate = self;
	[task execute];
	
	NSString *output = [task output];
	output = [self removeLoginShellOutputFromString:output];
#ifdef DEBUG
	NSLog(@"brew: %@", output);
#endif
	
	return output.length != 0;
}

- (void)setDelegate:(id<BPHomebrewInterfaceDelegate>)delegate
{
	if (_delegate != delegate) {
		_delegate = delegate;
		
		[self setPath_shell:[self getValidUserShellPath]];
		
		if (![self checkForHomebrew])
			[self showHomebrewNotInstalledMessage];
		else
		{
			[self setPath_cellar:[self getUserCellarPath]];
			
			NSLog(@"cellar: %@", self.path_cellar);
		}
	}
}

#pragma mark - Private Methods

- (NSString *)getValidUserShellPath
{
	NSString *userShell = [[[NSProcessInfo processInfo] environment] objectForKey:@"SHELL"];
	
	// avoid executing stuff like /sbin/nologin as a shell
	BOOL isValidShell = NO;
	for (NSString *validShell in [[NSString stringWithContentsOfFile:@"/etc/shells" encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]])
	{
		if ([[validShell stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:userShell])
		{
			isValidShell = YES;
			break;
		}
	}
	
	if (!isValidShell)
	{
		static NSAlert *alert = nil;
		if (!alert)
		{
			alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Message_Shell_Invalid_Title", nil)
									defaultButton:NSLocalizedString(@"Generic_OK", nil)
								  alternateButton:nil
									  otherButton:nil
						informativeTextWithFormat:NSLocalizedString(@"Message_Shell_Invalid_Body", nil), userShell];
		}
		[alert performSelectorOnMainThread:@selector(runModal) withObject:nil waitUntilDone:YES];
		
		NSLog(@"No valid shell found...");
		return nil;
	}
	
#ifdef DEBUG
	NSLog(@"shell: %@", userShell);
#endif
	
	return userShell;
}

- (NSString *)getUserCellarPath
{
	NSString __block *path = [[NSUserDefaults standardUserDefaults] objectForKey:@"BPBrewCellarPath"];
	
	if (!path) {
		NSString *brew_config = [self performBrewCommandWithArguments:@[@"config"]];
		
		[brew_config enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
			if ([line hasPrefix:@"HOMEBREW_CELLAR"]) {
				path = [line substringFromIndex:17];
			}
		}];
		
		[[NSUserDefaults standardUserDefaults] setObject:path forKey:@"BPBrewCellarPath"];
	}
	
	return path;
}

- (NSArray *)formatArguments:(NSArray *)extraArguments sendOutputId:(BOOL)sendOutputID
{
	NSString *command = nil;
	if (sendOutputID) {
		command = [NSString stringWithFormat:@"echo \"%@\";brew %@", cakebrewOutputIdentifier, [extraArguments componentsJoinedByString:@" "]];
	} else {
		command = [NSString stringWithFormat:@"brew %@", [extraArguments componentsJoinedByString:@" "]];
	}
	NSArray *arguments = @[@"-l", @"-c", command];
	
	return arguments;
}

- (void)showHomebrewNotInstalledMessage
{
	static BOOL isShowing = NO;
	if (!isShowing) {
		isShowing = YES;
		if (self.delegate) {
			id delegate = self.delegate;
			dispatch_async(dispatch_get_main_queue(), ^{
				[delegate homebrewInterfaceShouldDisplayNoBrewMessage:YES];
			});
		}
	}
}

- (void)task:(BPTask *)task didFinishWithOutput:(NSString *)output error:(NSString *)error
{
	[self.tasks removeObjectForKey:[NSString stringWithFormat:@"%p",task]];
}

- (BOOL)performBrewCommandWithArguments:(NSArray*)arguments dataReturnBlock:(void (^)(NSString*))block
{
	return [self performBrewCommandWithArguments:arguments wrapsSynchronousRequest:NO dataReturnBlock:block];
}

- (BOOL)performBrewCommandWithArguments:(NSArray*)arguments wrapsSynchronousRequest:(BOOL)isSynchronous dataReturnBlock:(void (^)(NSString*))block
{
	arguments = [self formatArguments:arguments sendOutputId:isSynchronous];
	
	if (!self.path_shell || !arguments)
	{
		return NO;
	}
	
	BPTask *task = [[BPTask alloc] initWithPath:self.path_shell arguments:arguments];
	task.delegate = self;
	[self.tasks setObject:task forKey:[NSString stringWithFormat:@"%p", task]];
	
	task.updateBlock = block;

#ifdef DEBUG
	if (!isSynchronous)
	{
		block([NSString stringWithFormat:kDEBUG_WARNING,
			   self.path_shell,
			   [arguments componentsJoinedByString:@" "],
			   [[NSProcessInfo processInfo] operatingSystemVersionString]]);
	}
#endif
	
	int status = [task execute];
	
	NSString *taskDoneString = [NSString stringWithFormat:@"%@:(%d) %@ %@!",
								NSLocalizedString(@"Homebrew_Task_Finished", nil),
								status,
								NSLocalizedString(@"Homebrew_Task_Finished_At", nil),
								[NSDateFormatter localizedStringFromDate:[NSDate date]
															   dateStyle:NSDateFormatterShortStyle
															   timeStyle:NSDateFormatterShortStyle]];
	
	block(taskDoneString);
	
	return status == 0;
}

- (BOOL)isRunningBackgroundTask
{
	return [[self.tasks allKeys] count] > 0;
}

- (NSString*)performBrewCommandWithArguments:(NSArray*)arguments
{
	return [self performBrewCommandWithArguments:arguments captureError:NO];
}

- (NSString*)performBrewCommandWithArguments:(NSArray*)arguments captureError:(BOOL)captureError
{
	arguments = [self formatArguments:arguments sendOutputId:YES];
	
	BPTask *task = [[BPTask alloc] initWithPath:self.path_shell arguments:arguments];
	task.delegate = self;
	[task execute];
	
	NSString *output = task.output;
	output = [self removeLoginShellOutputFromString:output];
	
	NSString *error = task.error;
	error = [self removeLoginShellOutputFromString:error];
	
	
	if (!captureError) {
		return output;
	} else {
		return [NSString stringWithFormat:@"%@\n%@", output, error];
	}
}

/**
 * This method performs a brew command in an asynchronous mode so that long chunks of data can be returned,
 * but to the callee it behaves like a synchronous call.
 */
- (NSString*)performWrappedBrewCommandWithArguments:(NSArray*)arguments
{
	NSMutableString *output = [NSMutableString new];
	
	[self performBrewCommandWithArguments:arguments wrapsSynchronousRequest:YES dataReturnBlock:^(NSString *partialOutput) {
			[output appendString:partialOutput];
	}];
	
	return [self removeLoginShellOutputFromString:output];
}

#pragma mark - Operations that return on finish

- (NSArray*)listMode:(BPListMode)mode
{
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
			
		case kBPListRepositories:
			listCall = [[BPHomebrewInterfaceListCallRepositories alloc] init];
			break;
			
		default:
			return nil;
	}
	
	NSString *string = [self performWrappedBrewCommandWithArguments:listCall.arguments];
	
	if (string)
	{
		return [listCall parseData:string];
	}
	else
	{
		return nil;
	}
}

- (NSString *)informationForFormulaName:(NSString *)name;
{
	return [self performBrewCommandWithArguments:@[@"info", name]];
}

- (NSString*)removeLoginShellOutputFromString:(NSString*)string {
	if (string) {
		NSRange range = [string rangeOfString:cakebrewOutputIdentifier];
		if (range.location != NSNotFound) {
			return [string substringFromIndex:range.location + range.length+1];
		} else {
			return string;
		}
	}
	//If all else fails...
	return nil;
}

#pragma mark - Operations with live data callback block

- (BOOL)updateWithReturnBlock:(void (^)(NSString*output))block
{
	BOOL val = [self performBrewCommandWithArguments:@[@"update"] dataReturnBlock:block];
	[self sendDelegateFormulaeUpdatedCall];
	return val;
}

- (BOOL)upgradeFormulae:(NSArray*)formulae withReturnBlock:(void (^)(NSString*output))block
{
	BOOL val = [self performBrewCommandWithArguments:[@[@"upgrade"] arrayByAddingObjectsFromArray:formulae] dataReturnBlock:block];
	[self sendDelegateFormulaeUpdatedCall];
	return val;
}

- (BOOL)installFormula:(NSString*)formula withOptions:(NSArray*)options andReturnBlock:(void (^)(NSString*output))block
{
	NSArray *params = @[@"install", formula];
	if (options) {
		params = [params arrayByAddingObjectsFromArray:options];
	}
	BOOL val = [self performBrewCommandWithArguments:params dataReturnBlock:block];
	[self sendDelegateFormulaeUpdatedCall];
	return val;
}

- (BOOL)uninstallFormula:(NSString*)formula withReturnBlock:(void (^)(NSString*output))block
{
	BOOL val = [self performBrewCommandWithArguments:@[@"uninstall", formula] dataReturnBlock:block];
	[self sendDelegateFormulaeUpdatedCall];
	return val;
}

- (BOOL)tapRepository:(NSString *)repository withReturnsBlock:(void (^)(NSString *))block
{
	BOOL val = [self performBrewCommandWithArguments:@[@"tap", repository] dataReturnBlock:block];
	[self sendDelegateFormulaeUpdatedCall];
	return val;
}

- (BOOL)untapRepository:(NSString *)repository withReturnsBlock:(void (^)(NSString *))block
{
	BOOL val = [self performBrewCommandWithArguments:@[@"untap", repository] dataReturnBlock:block];
	[self sendDelegateFormulaeUpdatedCall];
	return val;
}

- (BOOL)runCleanupWithReturnBlock:(void (^)(NSString*output))block
{
	return [self performBrewCommandWithArguments:@[@"cleanup"] dataReturnBlock:block];;
}

- (BOOL)runDoctorWithReturnBlock:(void (^)(NSString*output))block
{
	BOOL val = [self performBrewCommandWithArguments:@[@"doctor"] dataReturnBlock:block];
	[self sendDelegateFormulaeUpdatedCall];
	return val;
}

- (NSError*)runBrewExportToolWithPath:(NSString*)path
{
	NSString *output = [self performBrewCommandWithArguments:@[@"bundle",
															   @"dump",
															   @"--force",
															   [NSString stringWithFormat:@"--file=%@", path]]
												captureError:YES];
	
	[self sendDelegateFormulaeUpdatedCall];
	
	if ([output length] == 0)
	{
		return nil;
	}
	else
	{
		__block NSError *error = nil;
		
		[output enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
			if ([line hasPrefix:@"Error:"] || [line hasPrefix:@"fatal:"])
			{
				error = [NSError errorWithDomain:@"Cakebrew"
								   code:2701
							   userInfo:@{NSLocalizedDescriptionKey: line}];
				
				*stop = YES;
			}
		}];
		
		return error;
	}
}

- (BOOL)runBrewImportToolWithPath:(NSString*)path withReturnsBlock:(void (^)(NSString *))block
{
	NSArray *arguments = @[@"bundle", [NSString stringWithFormat:@"--file=%@", path]];
	[self sendDelegateFormulaeUpdatedCall];
	return [self performBrewCommandWithArguments:arguments
								 dataReturnBlock:block];
}

- (void)sendDelegateFormulaeUpdatedCall
{
	if (self.delegate) {
		id delegate = self.delegate;
		dispatch_async(dispatch_get_main_queue(), ^{
			[delegate homebrewInterfaceDidUpdateFormulae];
		});
	}
}

@end

#pragma mark - Homebrew Interface List Calls

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

@implementation BPHomebrewInterfaceListCallInstalled

- (instancetype)init
{
	return (BPHomebrewInterfaceListCallInstalled *)[super initWithArguments:@[@"list", @"--versions"]];
}

- (BPFormula *)parseFormulaItem:(NSString *)item
{
	NSArray *aux = [item componentsSeparatedByString:@" "];
	return [BPFormula formulaWithName:[aux firstObject] andVersion:[aux lastObject]];
}

@end

@implementation BPHomebrewInterfaceListCallAll

- (instancetype)init
{
	return (BPHomebrewInterfaceListCallAll *)[super initWithArguments:@[@"search"]];
}

@end

@implementation BPHomebrewInterfaceListCallLeaves

- (instancetype)init
{
	return (BPHomebrewInterfaceListCallLeaves *)[super initWithArguments:@[@"leaves"]];
}

@end

@implementation BPHomebrewInterfaceListCallUpgradeable

- (instancetype)init
{
	return (BPHomebrewInterfaceListCallUpgradeable *)[super initWithArguments:@[@"outdated", @"--verbose"]];
}

- (BPFormula *)parseFormulaItem:(NSString *)item
{
	static NSString *regexString = @"(\\S+)\\s\\((.*)\\)";
	
	BPFormula __block *formula = nil;
	NSError *error = nil;
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:NSRegularExpressionCaseInsensitive error:&error];
	
	[regex enumerateMatchesInString:item options:0 range:NSMakeRange(0, [item length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		if (result.resultType == NSTextCheckingTypeRegularExpression)
		{
			NSRange lastRange = [result rangeAtIndex:[result numberOfRanges]-1];
			NSArray *versionsTuple = [[[[item substringWithRange:lastRange] componentsSeparatedByString:@","] lastObject] componentsSeparatedByString:@"<"];
			formula = [BPFormula formulaWithName:[item substringWithRange:[result rangeAtIndex:1]]
										 version:[[versionsTuple firstObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
								andLatestVersion:[[versionsTuple lastObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
		}
	}];
	
	if (!formula) {
		formula = [BPFormula formulaWithName:item];
	}
	
	return formula;
}

@end

@implementation BPHomebrewInterfaceListCallRepositories

- (instancetype)init
{
	return (BPHomebrewInterfaceListCallRepositories *)[super initWithArguments:@[@"tap"]];
}

@end
