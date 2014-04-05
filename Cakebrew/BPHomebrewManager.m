//
//  BPHomebrewManager.m
//  Cakebrew
//
//  Created by Bruno Philipe on 4/3/14.
//
//

#import "BPHomebrewManager.h"
#import "BrewInterface.h"

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

	}
	return self;
}

- (void)update
{
	[self setFormulas_installed:[BrewInterface listMode:kBP_LIST_INSTALLED]];
	[self setFormulas_leaves:[BrewInterface listMode:kBP_LIST_LEAVES]];
	[self setFormulas_outdated:[BrewInterface listMode:kBP_LIST_UPGRADEABLE]];

	if (![self loadAllFormulasCaches]) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[self setFormulas_all:[BrewInterface listMode:kBP_LIST_ALL]];
			[self.delegate homebrewManagerFinishedUpdating:self];
			[self storeAllFormulasCaches];
		});
	}
}

/**
 Returns `YES` if cache exists, was created less than 24 hours ago and was loaded successfully. Otherwise returns `NO`.
 */
- (BOOL)loadAllFormulasCaches
{
	NSURL *cachesFolder = [BPAppDelegateRef urlForApplicationCachesFolder];
	if (cachesFolder) {
		NSURL *allFormulasFile = [cachesFolder URLByAppendingPathComponent:@"allFormulas.cache.bin"];
		NSDictionary *cacheDict;// = @{kBP_CACHE_DICT_DATE_KEY: [NSDate date], kBP_CACHE_DICT_DATA_KEY: self.formulas_all};

		if ([[NSFileManager defaultManager] fileExistsAtPath:allFormulasFile.relativePath]) {
			cacheDict = [NSKeyedUnarchiver unarchiveObjectWithFile:allFormulasFile.relativePath];
			NSDate *encodingDate = [cacheDict objectForKey:kBP_CACHE_DICT_DATE_KEY];
			if (encodingDate && [(NSDate*)[encodingDate dateByAddingTimeInterval:kBP_SECONDS_IN_A_DAY] compare:[NSDate date]] == NSOrderedDescending) {
				// Cache was created less than 24 hours ago, should load!
				self.formulas_all = [cacheDict objectForKey:kBP_CACHE_DICT_DATA_KEY];
				[self.delegate homebrewManagerFinishedUpdating:self];
				return self.formulas_all != nil;
			}
		}
	} else {
		NSLog(@"Could not load cache file. BPAppDelegate function returned nil!");
	}

	return NO;
}

- (void)storeAllFormulasCaches
{
	NSURL *cachesFolder = [BPAppDelegateRef urlForApplicationCachesFolder];
	if (cachesFolder) {
		NSURL *allFormulasFile = [cachesFolder URLByAppendingPathComponent:@"allFormulas.cache.bin"];
		NSDictionary *cacheDict = @{kBP_CACHE_DICT_DATE_KEY: [NSDate date], kBP_CACHE_DICT_DATA_KEY: self.formulas_all};
		NSData *cacheData = [NSKeyedArchiver archivedDataWithRootObject:cacheDict];

		NSLog(@"\n%@\n%@\n%@", allFormulasFile.relativePath, allFormulasFile.relativeString, allFormulasFile.absoluteString);

		if ([[NSFileManager defaultManager] fileExistsAtPath:allFormulasFile.relativePath]) {
			[cacheData writeToURL:allFormulasFile atomically:YES];
		} else {
			[[NSFileManager defaultManager] createFileAtPath:allFormulasFile.relativePath contents:cacheData attributes:nil];
		}
	} else {
		NSLog(@"Could not store cache file. BPAppDelegate function returned nil!");
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
	if ([self searchForFormula:formula inArray:self.formulas_installed] >= 0)
	{
		if ([self searchForFormula:formula inArray:self.formulas_outdated]) {
			return kBP_FORMULA_OUTDATED;
		} else {
			return kBP_FORMULA_INSTALLED;
		}
	} else {
		return kBP_FORMULA_NOT_INSTALLED;
	}
}

@end
