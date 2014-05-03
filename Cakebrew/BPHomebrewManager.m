//
//	BPHomebrewManager.m
//	Cakebrew – The Homebrew GUI App for OS X 
//
//	Created by Bruno Philipe on 4/3/14.
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

#import "BPHomebrewManager.h"
#import "BPHomebrewInterface.h"

#define kBP_CACHE_DICT_DATE_KEY @"BP_CACHE_DICT_DATE_KEY"
#define kBP_CACHE_DICT_DATA_KEY @"BP_CACHE_DICT_DATA_KEY"
#define kBP_SECONDS_IN_A_DAY 86400

@implementation BPHomebrewManager

+ (BPHomebrewManager *)sharedManager
{
    @synchronized(self)
	{
        static dispatch_once_t once;
        static BPHomebrewManager *instance;
        dispatch_once(&once, ^ { instance = [[BPHomebrewManager alloc] init]; });
        return instance;
	}
}

- (id)init
{
	self = [super init];
	if (self) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update) name:kBP_NOTIFICATION_FORMULAS_CHANGED object:nil];
	}
	return self;
}

- (void)update
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setFormulae_installed:[[BPHomebrewInterface sharedInterface] listMode:kBP_LIST_INSTALLED]];
        [self setFormulae_leaves:[[BPHomebrewInterface sharedInterface] listMode:kBP_LIST_LEAVES]];
        [self setFormulae_outdated:[[BPHomebrewInterface sharedInterface] listMode:kBP_LIST_UPGRADEABLE]];

        if (![self loadAllFormulaeCaches]) {

			[self setFormulae_all:[[BPHomebrewInterface sharedInterface] listMode:kBP_LIST_ALL]];
			[self storeAllFormulaeCaches];
			[self.delegate homebrewManagerFinishedUpdating:self];
            
        }
    });
}

/**
 Returns `YES` if cache exists, was created less than 24 hours ago and was loaded successfully. Otherwise returns `NO`.
 */
- (BOOL)loadAllFormulaeCaches
{
	NSURL *cachesFolder = [BPAppDelegateRef urlForApplicationCachesFolder];
	if (cachesFolder) {
		NSURL *allFormulaeFile = [cachesFolder URLByAppendingPathComponent:@"allFormulae.cache.bin"];
		NSDictionary *cacheDict = nil;// = @{kBP_CACHE_DICT_DATE_KEY: [NSDate date], kBP_CACHE_DICT_DATA_KEY: self.formulae_all};

		if ([[NSFileManager defaultManager] fileExistsAtPath:allFormulaeFile.relativePath]) {
			cacheDict = [NSKeyedUnarchiver unarchiveObjectWithFile:allFormulaeFile.relativePath];
			self.formulae_all = [cacheDict objectForKey:kBP_CACHE_DICT_DATA_KEY];
			[self.delegate homebrewManagerFinishedUpdating:self];
			return self.formulae_all != nil;
		}
	} else {
		NSLog(@"Could not load cache file. BPAppDelegate function returned nil!");
	}

	return NO;
}

- (void)storeAllFormulaeCaches
{
	if (self.formulae_all) {
		NSURL *cachesFolder = [BPAppDelegateRef urlForApplicationCachesFolder];
		if (cachesFolder) {
			NSURL *allFormulaeFile = [cachesFolder URLByAppendingPathComponent:@"allFormulae.cache.bin"];
			NSDictionary *cacheDict = @{kBP_CACHE_DICT_DATE_KEY: [NSDate date], kBP_CACHE_DICT_DATA_KEY: self.formulae_all};
			NSData *cacheData = [NSKeyedArchiver archivedDataWithRootObject:cacheDict];

			if ([[NSFileManager defaultManager] fileExistsAtPath:allFormulaeFile.relativePath]) {
				[cacheData writeToURL:allFormulaeFile atomically:YES];
			} else {
				[[NSFileManager defaultManager] createFileAtPath:allFormulaeFile.relativePath contents:cacheData attributes:nil];
			}
		} else {
			NSLog(@"Could not store cache file. BPAppDelegate function returned nil!");
		}
	}
}

- (NSInteger)searchForFormula:(BPFormula*)formula inArray:(NSArray*)array
{
	NSUInteger index = 0;
	for (BPFormula* item in array) {
		if ([item.name isEqualToString:formula.name]) {
			return index;
		}
		index++;
	}

	return -1;
}

- (BP_FORMULA_STATUS)statusForFormula:(BPFormula*)formula
{
	if ([self searchForFormula:formula inArray:self.formulae_installed] >= 0)
	{
		if ([self searchForFormula:formula inArray:self.formulae_outdated] >= 0) {
			return kBP_FORMULA_OUTDATED;
		} else {
			return kBP_FORMULA_INSTALLED;
		}
	} else {
		return kBP_FORMULA_NOT_INSTALLED;
	}
}

@end
