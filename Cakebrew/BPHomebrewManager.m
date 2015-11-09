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
		
		[self setFormulae_installed:[[BPHomebrewInterface sharedInterface] listMode:kBPListInstalled]];
		[self setFormulae_leaves:[[BPHomebrewInterface sharedInterface] listMode:kBPListLeaves]];
		[self setFormulae_outdated:[[BPHomebrewInterface sharedInterface] listMode:kBPListOutdated]];
		[self setFormulae_repositories:[[BPHomebrewInterface sharedInterface] listMode:kBPListRepositories]];
		
		if (![self loadAllFormulaeCaches] || shouldRebuildCache) {
			[self setFormulae_all:[[BPHomebrewInterface sharedInterface] listMode:kBPListAll]];
			[self storeAllFormulaeCaches];
		}
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.delegate homebrewManagerFinishedUpdating:self];
		});
	});
}

- (void)updateSearchWithName:(NSString *)name
{
	NSMutableArray *array = [NSMutableArray array];
	NSRange range;
	
	for (BPFormula *formula in _formulae_all) {
		range = [[formula name] rangeOfString:name options:NSCaseInsensitiveSearch];
		if (range.location != NSNotFound) {
			[array addObject:formula];
		}
	}
	
	_formulae_search = array;
	
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.delegate homebrewManager:self didUpdateSearchResults:_formulae_search];
	});
}

/**
 Returns `YES` if cache exists, was created less than 24 hours ago and was loaded successfully. Otherwise returns `NO`.
 */
- (BOOL)loadAllFormulaeCaches
{
	NSURL *cachesFolder = [BPAppDelegateRef urlForApplicationCachesFolder];
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
			cacheDict = [NSKeyedUnarchiver unarchiveObjectWithFile:allFormulaeFile.relativePath];
			self.formulae_all = [cacheDict objectForKey:kBPCacheDataKey];
		}
	}
	else
	{
		// Delete all cache data
		[[NSFileManager defaultManager] removeItemAtURL:allFormulaeFile error:nil];
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:kBPCacheLastUpdateKey];
	}
	
	return self.formulae_all != nil;
}

- (void)storeAllFormulaeCaches
{
	if (self.formulae_all)
	{
		NSURL *cachesFolder = [BPAppDelegateRef urlForApplicationCachesFolder];
		if (cachesFolder)
		{
			NSURL *allFormulaeFile = [cachesFolder URLByAppendingPathComponent:@"allFormulae.cache.bin"];
			NSDate *storageDate = [NSDate date];
			
			if ([[NSUserDefaults standardUserDefaults] objectForKey:kBPCacheLastUpdateKey])
			{
				storageDate = [NSDate dateWithTimeIntervalSince1970:[[NSUserDefaults standardUserDefaults]
																	 integerForKey:kBPCacheLastUpdateKey]];
			}
			
			NSDictionary *cacheDict = @{kBPCacheDataKey: self.formulae_all};
			NSData *cacheData = [NSKeyedArchiver archivedDataWithRootObject:cacheDict];
			
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
	if ([self searchForFormula:formula inArray:self.formulae_installed] >= 0)
	{
		if ([self searchForFormula:formula inArray:self.formulae_outdated] >= 0)
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
