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
#import "BPRepository.h"

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
	  
#ifdef DEBUG
		NSDate *startDate = [NSDate date];
#endif
		NSArray *installed = [[BPHomebrewInterface sharedInterface] listMode:kBPListInstalled];
		[self setInstalledFormulaeCount:[installed count]];
		NSMutableDictionary *mutDictionary = [NSMutableDictionary dictionaryWithCapacity:[installed count]];
		for (BPFormula *formula in installed) {
		  mutDictionary[[formula name]] = formula;
		}
		
		NSArray *leaves = [[BPHomebrewInterface sharedInterface] listMode:kBPListLeaves];
		[self setLeavesFormulaeCount:[leaves count]];
		for (BPFormula *formula in leaves) {
		  if ([mutDictionary objectForKey:[formula name]]) {
			[formula mergeWithFormula:mutDictionary[[formula name]]];
			mutDictionary[[formula name]] =  formula;
		  }
		}

		NSArray *outdated = [[BPHomebrewInterface sharedInterface] listMode:kBPListOutdated];
		[self setOutdatedFormulaeCount:[outdated count]];
		for (BPFormula *formula in outdated) {
		  if ([mutDictionary objectForKey:[formula name]]) {
			[formula mergeWithFormula:mutDictionary[[formula name]]];
			mutDictionary[[formula name]] =  formula;
		  }
		}
		
	  
		
		NSArray *repositories = [[BPHomebrewInterface sharedInterface] listMode:kBPListRepositories];
		[self setFormulae_repositories:repositories];
		[self setRepositoriesFormulaeCount:[repositories count]];
	  
		NSMutableArray *allFormulae;
		if (!shouldRebuildCache) {
			allFormulae = [self loadAllFormulaeCaches];
		}
		if (!allFormulae) {
			allFormulae = [[BPHomebrewInterface sharedInterface] listMode:kBPListAll];
		}
	  
		for (NSUInteger index = 0;index < [allFormulae count]; index++) {
		  BPFormula *formula = [mutDictionary objectForKey:[allFormulae[index] name]];
		  if (formula) {
			[allFormulae replaceObjectAtIndex:index withObject:formula];
		  }
		}
		
		[self setFormulae_all:allFormulae];
		[self setAllFormulaeCount:[allFormulae count]];
	  
		if (shouldRebuildCache) {
		  [self storeAllFormulaeCaches];
		}
#ifdef DEBUG
		NSLog(@"Formula reload time:%f seconds", [[NSDate date] timeIntervalSinceDate:startDate]);
#endif
	  
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.delegate homebrewManagerFinishedUpdating:self];
		});
	});
}


/**
 Returns cache if it was created less than 24 hours ago and it was loaded successfully. Otherwise returns nil.
 */
- (NSMutableArray *)loadAllFormulaeCaches
{
	NSURL *cachesFolder = [BPAppDelegateRef urlForApplicationCachesFolder];
	NSURL *allFormulaeFile = [cachesFolder URLByAppendingPathComponent:@"allFormulae.cache.bin"];
	BOOL shouldLoadCache = NO;
	NSMutableArray *mutCachedAllFormulae = nil;
	
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
			mutCachedAllFormulae = [[cacheDict objectForKey:kBPCacheDataKey] mutableCopy];
		}
	}
	else
	{
		// Delete all cache data
		[[NSFileManager defaultManager] removeItemAtURL:allFormulaeFile error:nil];
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:kBPCacheLastUpdateKey];
	}
	
	return mutCachedAllFormulae;
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
