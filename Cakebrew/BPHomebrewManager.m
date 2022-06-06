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
	NSUInteger previousCountOfAllFormulae = [self allFormulae].count;
	NSUInteger previousCountOfAllCasks = [self allCasks].count;

	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
		[[BPHomebrewInterface sharedInterface] setDelegate:self];
		
		NSArray *installedFormulae = [[BPHomebrewInterface sharedInterface] listMode:kBPListInstalledFormulae];
		NSArray *leavesFormulae = [[BPHomebrewInterface sharedInterface] listMode:kBPListLeaves];
		NSArray *outdatedFormulae = [[BPHomebrewInterface sharedInterface] listMode:kBPListOutdatedFormulae];
		NSArray *repositoriesFormulae = [[BPHomebrewInterface sharedInterface] listMode:kBPListRepositories];

		NSArray *installedCasks = [[BPHomebrewInterface sharedInterface] listMode:kBPListInstalledCasks];
		NSArray *outdatedCasks = [[BPHomebrewInterface sharedInterface] listMode:kBPListOutdatedCasks];
		
		NSArray *allFormulae = nil;
		NSArray *allCasks = nil;

		if (![self loadAllFormulaeCaches] || previousCountOfAllFormulae <= 100 || shouldRebuildCache) {
			allFormulae = [[BPHomebrewInterface sharedInterface] listMode:kBPListAllFormulae];
		}
		
		if (![self loadAllCasksCaches] || previousCountOfAllCasks <= 10 || shouldRebuildCache) {
			allCasks = [[BPHomebrewInterface sharedInterface] listMode:kBPListAllCasks];
		}

		dispatch_async(dispatch_get_main_queue(), ^{
			if (allFormulae != nil) {
				[self setAllFormulae:allFormulae];
				[self storeAllFormulaeCaches];
			}
			if (allCasks != nil) {
				[self setAllCasks:allCasks];
				[self storeAllCasksCaches];
			}
			[self setInstalledFormulae:installedFormulae];
			[self setLeavesFormulae:leavesFormulae];
			[self setOutdatedFormulae:outdatedFormulae];
			[self setRepositoriesFormulae:repositoriesFormulae];
			[self setInstalledCasks:installedCasks];
			[self setOutdatedCasks:outdatedCasks];
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

- (BOOL)loadAllFormulaeCaches
{
	return [self loadCache:@"allFormulae.cache.bin" array:self.allFormulae];
}

- (BOOL)loadAllCasksCaches
{
	return [self loadCache:@"allCasks.cache.bin" array:self.allCasks];
}

/**
 Returns `YES` if cache exists, was created less than 24 hours ago and was loaded successfully. Otherwise returns `NO`.
 */
- (BOOL)loadCache:(NSString*)fileName array:(NSArray<BPFormula*>*)cache
{
   NSURL *cachesFolder = [BPAppDelegate urlForApplicationCachesFolder];
   NSURL *allFile = [cachesFolder URLByAppendingPathComponent:fileName];
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
   
   if (shouldLoadCache && allFile)
   {
	   NSDictionary *cacheDict = nil;
	   
	   if ([[NSFileManager defaultManager] fileExistsAtPath:allFile.relativePath])
	   {
		   NSData *data = [NSData dataWithContentsOfFile:allFile.relativePath];
		   NSError *error = nil;

		   if (@available(macOS 10.13, *)) {
			   NSSet *classes = [NSSet setWithArray:@[[NSDictionary class], [NSMutableArray class], [BPFormula class]]];
			   cacheDict = [NSKeyedUnarchiver unarchivedObjectOfClasses:classes fromData:data error:&error];
			   if (error) {
				   NSLog(@"Failed decoding data: %@", [error localizedDescription]);
			   }
		   } else {
			   cacheDict = [NSKeyedUnarchiver unarchiveObjectWithFile:allFile.relativePath];
		   }
		   cache = [cacheDict objectForKey:kBPCacheDataKey];
	   }
   } else {
	   // Delete all cache data
	   [[NSFileManager defaultManager] removeItemAtURL:allFile error:nil];
	   [[NSUserDefaults standardUserDefaults] removeObjectForKey:kBPCacheLastUpdateKey];
   }
   return cache != nil;
}

- (void)storeAllFormulaeCaches
{
	[self storeCache:@"allFormulae.cache.bin" array:self.allFormulae];
}

- (void)storeAllCasksCaches
{
	[self storeCache:@"allCasks.cache.bin" array:self.allCasks];
}

- (void)storeCache:(NSString*)fileName array:(NSArray<BPFormula*>*)cache
{
	if (self.allCasks)
	{
		NSURL *cachesFolder = [BPAppDelegate urlForApplicationCachesFolder];
		if (cachesFolder)
		{
			NSURL *allFile = [cachesFolder URLByAppendingPathComponent:fileName];
			NSDate *storageDate = [NSDate date];
			
			if ([[NSUserDefaults standardUserDefaults] objectForKey:kBPCacheLastUpdateKey])
			{
				storageDate = [NSDate dateWithTimeIntervalSince1970:[[NSUserDefaults standardUserDefaults]
																	 integerForKey:kBPCacheLastUpdateKey]];
			}
			
			NSDictionary *cacheDict = @{kBPCacheDataKey: cache};
			NSData *cacheData;

			if (@available(macOS 10.13, *)) {
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
			
			if ([[NSFileManager defaultManager] fileExistsAtPath:allFile.relativePath])
			{
				[cacheData writeToURL:allFile atomically:YES];
			}
			else
			{
				[[NSFileManager defaultManager] createFileAtPath:allFile.relativePath
														contents:cacheData attributes:nil];
			}
			
			[[NSUserDefaults standardUserDefaults] setInteger:[storageDate timeIntervalSince1970]
													   forKey:kBPCacheLastUpdateKey];
		} else {
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

- (BPFormulaStatus)statusForFormula:(BPFormula*)formula {
	if ([self searchForFormula:formula inArray:self.installedFormulae] >= 0) {
		if ([self searchForFormula:formula inArray:self.outdatedFormulae] >= 0)
		{
			return kBPFormulaOutdated;
		} else {
			return kBPFormulaInstalled;
		}
	} else {
		return kBPFormulaNotInstalled;
	}
}

- (BPFormulaStatus)statusForCask:(BPFormula*)formula {
	if ([self searchForFormula:formula inArray:self.installedCasks] >= 0) {
		if ([self searchForFormula:formula inArray:self.outdatedCasks] >= 0) {
			return kBPFormulaOutdated;
		} else {
			return kBPFormulaInstalled;
		}
	} else {
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
