//
//  BPFormulaeDataSource.m
//  Cakebrew
//
//  Created by Marek Hrusovsky on 04/09/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import "BPFormulaeDataSource.h"
#import "BPHomebrewManager.h"
#import "BPFormulaeTableView.h"

@interface BPFormulaeDataSource() 
@property (nonatomic, strong) NSArray *formulaeArray;
@end

@implementation BPFormulaeDataSource

- (instancetype)init
{
  return [self initWithMode:kBPListAll];
}

- (instancetype)initWithMode:(BPListMode)aMode
{
  self = [super init];
  if (self) {
    _mode = aMode;
  }
  [self refreshBackingArray];
  return self;
}

- (void)setMode:(BPListMode)mode
{
  _mode = mode;
  [self refreshBackingArray];
}

- (void)refreshBackingArray
{
  switch (self.mode) {
		case kBPListAll:
			_formulaeArray = [[BPHomebrewManager sharedManager] formulae_all];
			break;
      
		case kBPListInstalled:
			_formulaeArray = [[BPHomebrewManager sharedManager] formulae_installed];
			break;
      
		case kBPListLeaves:
			_formulaeArray = [[BPHomebrewManager sharedManager] formulae_leaves];
			break;
      
		case kBPListOutdated:
			_formulaeArray = [[BPHomebrewManager sharedManager] formulae_outdated];
			break;
      
		case kBPListSearch:
			_formulaeArray = [[BPHomebrewManager sharedManager] formulae_search];
			break;
      
    case kBPListRepositories:
			_formulaeArray = [[BPHomebrewManager sharedManager] formulae_repositories];
      
		default:
			break;
	}
}


#pragma mark - NSTableView DataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
  return [self.formulaeArray count];
}

- (BPFormula *)formulaAtIndex:(NSInteger)index
{
  if ([self.formulaeArray count] > index && index >= 0) {
    return [self.formulaeArray objectAtIndex:index];
  }
  return nil;
}

- (NSArray *)formulasAtIndexSet:(NSIndexSet *)indexSet
{
  if (indexSet.count > 0 && [self.formulaeArray count] > indexSet.lastIndex) {
    return [self.formulaeArray objectsAtIndexes:indexSet];
  }
  return nil;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
  // the return value is typed as (id) because it will return a string in all cases with the exception of the
  if(self.formulaeArray) {
    NSString *columnIdentifer = [tableColumn identifier];
    id element = [self.formulaeArray objectAtIndex:(NSUInteger)row];
    
    // Compare each column identifier and set the return value to
    // the Person field value appropriate for the column.
    if ([columnIdentifer isEqualToString:kColumnIdentifierName]) {
			if ([element isKindOfClass:[BPFormula class]]) {
				return [(BPFormula*)element name];
			} else {
				return element;
			}
    } else if ([columnIdentifer isEqualToString:kColumnIdentifierVersion]) {
			if ([element isKindOfClass:[BPFormula class]]) {
				return [(BPFormula*)element version];
			} else {
				return element;
			}
		} else if ([columnIdentifer isEqualToString:kColumnIdentifierLatestVersion]) {
			if ([element isKindOfClass:[BPFormula class]]) {
				return [(BPFormula*)element shortLatestVersion];
			} else {
				return element;
			}
    } else if ([columnIdentifer isEqualToString:kColumnIdentifierStatus]) {
			if ([element isKindOfClass:[BPFormula class]]) {
				switch ([[BPHomebrewManager sharedManager] statusForFormula:element]) {
					case kBPFormulaInstalled:
						return NSLocalizedString(@"Formula_Status_Installed", nil);
            
					case kBPFormulaNotInstalled:
						return NSLocalizedString(@"Formula_Status_Not_Installed", nil);
            
					case kBPFormulaOutdated:
						return NSLocalizedString(@"Formula_Status_Outdated", nil);
            
					default:
						return @"";
				}
			} else {
				return element;
			}
		}
  }
  
	return @"";
}

@end
