//
//	BPHomebrewManager.m
//	Cakebrew – The Homebrew GUI App for OS X
//
//	Created by Bruno Philipe on 4/3/14.
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

#import "BPHomebrewManager.h"
#import "BPHomebrewInterface.h"
#import "BPAppDelegate.h"

NSString *const kBPCacheLastUpdateKey = @"BPCacheLastUpdateKey";
NSString *const kBPCacheDataKey	= @"BPCacheDataKey";

#define kBP_SECONDS_IN_A_DAY 86400

@interface BPHomebrewManager () <BPHomebrewInterfaceDelegate>

@end

@implementation BPHomebrewManager

+ (BPHomebrewManager *)sharedManager
{
	@synchronized(self)
	{
        static dispatch_once_t once;
        static BPHomebrewManager *instance;
        dispatch_once(&once, ^ { instance = [[super allocWithZone:NULL] initUniqueInstance]; });
        return instance;
	}
}

- (instancetype)initUniqueInstance
{
	self = [super init];
	if (self) {
		
	}
	return self;
}

+ (instancetype)allocWithZone:(NSZone *)zone
{
	return [self sharedManager];
}

- (instancetype)copyWithZone:(NSZone *)zone
{
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reloadFromInterfaceRebuildingCache:(BOOL)shouldRebuildCache;
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
		[[BPHomebrewInterface sharedInterface] setDelegate:self];
		
		[self setInstalledFormulae:[[BPHomebrewInterface sharedInterface] listMode:kBPListInstalled]];
		[self setLeavesFormulae:[[BPHomebrewInterface sharedInterface] listMode:kBPListLeaves]];
		[self setOutdatedFormulae:[[BPHomebrewInterface sharedInterface] listMode:kBPListOutdated]];
		[self setRepositoriesFormulae:[[BPHomebrewInterface sharedInterface] listMode:kBPListRepositories]];
		
		if (![self loadAllFormulaeCaches] || [[self allFormulae] count] <= 1 || shouldRebuildCache) {
			[self setAllFormulae:[[BPHomebrewInterface sharedInterface] listMode:kBPListAll]];
			[self storeAllFormulaeCaches];
		}
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.delegate homebrewManagerFinishedUpdating:self];
		});
	});
}

- (void)updateSearchWithName:(NSString *)name
{
	NSMutableArray *matches = [NSMutableArray array];
	NSRange range;
	
	for (BPFormula *formula in _allFormulae) {
		range = [[formula name] rangeOfString:name options:NSCaseInsensitiveSearch];
		if (range.location != NSNotFound) {
			[matches addObject:formula];
		}
	}
	
	_searchFormulae = matches;

	dispatch_async(dispatch_get_main_queue(), ^{
		[self.delegate homebrewManager:self didUpdateSearchResults:matches];
	});
}

/**
 Returns `YES` if cache exists, was created less than 24 hours ago and was loaded successfully. Otherwise returns `NO`.
 */
- (BOOL)loadAllFormulaeCaches
{
	NSURL *cachesFolder = [BPAppDelegate urlForApplicationCachesFolder];
	NSURL *allFormulaeFile = [cachesFolder URLByAppendingPathComponent:@"allFormulae.cache.bin"];
	BOOL shouldLoadCache = NO;
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kBPCacheLastUpdateKey])
	{
		NSDate *storageDate = [NSDate dateWithTimeIntervalSince1970:[[NSUserDefaults standardUserDefaults]
																	 integerForKey:kBPCacheLastUpdateKey]];
		
		if ([[NSDate date] timeIntervalSinceDate:storageDate] <= 3600*24)
		{
			shouldLoadCache = YES;
		}
	}
	
	if (shouldLoadCache && allFormulaeFile)
	{
		NSDictionary *cacheDict = nil;
		
		if ([[NSFileManager defaultManager] fileExistsAtPath:allFormulaeFile.relativePath])
		{
			NSData *data = [NSData dataWithContentsOfFile:allFormulaeFile.relativePath];
			NSError *error = nil;

			if (@available(macOS 11.0, *)) {
				NSSet *classes = [NSSet setWithArray:@[[NSDictionary class], [NSMutableArray class], [BPFormula class]]];
				cacheDict = [NSKeyedUnarchiver unarchivedObjectOfClasses:classes fromData:data error:&error];
				if (error) {
					NSLog(@"Failed decoding data: %@", [error localizedDescription]);
				}
			} else {
				cacheDict = [NSKeyedUnarchiver unarchiveObjectWithFile:allFormulaeFile.relativePath];
			}
			self.allFormulae = [cacheDict objectForKey:kBPCacheDataKey];
		}
	}
	else
	{
		// Delete all cache data
		[[NSFileManager defaultManager] removeItemAtURL:allFormulaeFile error:nil];
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:kBPCacheLastUpdateKey];
	}
	
	return self.allFormulae != nil;
}

- (void)storeAllFormulaeCaches
{
	if (self.allFormulae)
	{
		NSURL *cachesFolder = [BPAppDelegate urlForApplicationCachesFolder];
		if (cachesFolder)
		{
			NSURL *allFormulaeFile = [cachesFolder URLByAppendingPathComponent:@"allFormulae.cache.bin"];
			NSDate *storageDate = [NSDate date];
			
			if ([[NSUserDefaults standardUserDefaults] objectForKey:kBPCacheLastUpdateKey])
			{
				storageDate = [NSDate dateWithTimeIntervalSince1970:[[NSUserDefaults standardUserDefaults]
																	 integerForKey:kBPCacheLastUpdateKey]];
			}
			
			NSDictionary *cacheDict = @{kBPCacheDataKey: self.allFormulae};
			NSData *cacheData;

			if (@available(macOS 11.0, *)) {
				NSError *error = nil;
				cacheData = [NSKeyedArchiver archivedDataWithRootObject:cacheDict
												  requiringSecureCoding:YES
																  error:&error];

				if (error) {
					NSLog(@"Failed encoding data: %@", [error localizedDescription]);
				}
			} else {
				cacheData = [NSKeyedArchiver archivedDataWithRootObject:cacheDict];
			}
			
			if ([[NSFileManager defaultManager] fileExistsAtPath:allFormulaeFile.relativePath])
			{
				[cacheData writeToURL:allFormulaeFile atomically:YES];
			}
			else
			{
				[[NSFileManager defaultManager] createFileAtPath:allFormulaeFile.relativePath
														contents:cacheData attributes:nil];
			}
			
			[[NSUserDefaults standardUserDefaults] setInteger:[storageDate timeIntervalSince1970]
													   forKey:kBPCacheLastUpdateKey];
		}
		else
		{
			NSLog(@"Could not store cache file. BPAppDelegate function returned nil!");
		}
	}
}

- (NSInteger)searchForFormula:(BPFormula*)formula inArray:(NSArray*)array
{
	NSUInteger index = 0;
	
	for (BPFormula* item in array)
	{
		if ([[item installedName] isEqualToString:[formula installedName]])
		{
			return index;
		}
		
		index++;
	}
	
	return -1;
}

- (BPFormulaStatus)statusForFormula:(BPFormula*)formula
{
	if ([self searchForFormula:formula inArray:self.installedFormulae] >= 0)
	{
		if ([self searchForFormula:formula inArray:self.outdatedFormulae] >= 0)
		{
			return kBPFormulaOutdated;
		}
		else
		{
			return kBPFormulaInstalled;
		}
	}
	else
	{
		return kBPFormulaNotInstalled;
	}
}

- (void)cleanUp
{
	[[BPHomebrewInterface sharedInterface] cleanup];
}

#pragma - Homebrew Interface Delegate

- (void)homebrewInterfaceDidUpdateFormulae
{
	[self reloadFromInterfaceRebuildingCache:YES];
}

- (void)homebrewInterfaceShouldDisplayNoBrewMessage:(BOOL)yesOrNo
{
	if (self.delegate) {
		[self.delegate homebrewManager:self shouldDisplayNoBrewMessage:yesOrNo];
	}
}

@end
