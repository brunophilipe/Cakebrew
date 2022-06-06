//
//  BPCasksDataSource.m
//  Cakebrew
//

#import "BPCasksDataSource.h"
#import "BPHomebrewManager.h"
#import "BPFormulaeTableView.h"

@interface BPCasksDataSource()
@property (nonatomic, strong) NSArray *CasksArray;
@end

@implementation BPCasksDataSource

- (instancetype)init
{
	return [self initWithMode:kBPListAllCasks];
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
		case kBPListAllCasks:
			_CasksArray = [[BPHomebrewManager sharedManager] allCasks];
			break;
			
		case kBPListInstalledCasks:
			_CasksArray = [[BPHomebrewManager sharedManager] installedCasks];
			break;
			
		case kBPListOutdatedCasks:
			_CasksArray = [[BPHomebrewManager sharedManager] outdatedCasks];
			break;
			
		case kBPListSearchCasks:
			_CasksArray = [[BPHomebrewManager sharedManager] searchCasks];
			break;
			
		default:
			break;
	}
}


#pragma mark - NSTableView DataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [self.CasksArray count];
}

- (BPFormula *)caskAtIndex:(NSInteger)index
{
	if ([self.CasksArray count] > index && index >= 0) {
		return [self.CasksArray objectAtIndex:index];
	}
	return nil;
}

- (NSArray *)casksAtIndexSet:(NSIndexSet *)indexSet
{
	if (indexSet.count > 0 && [self.CasksArray count] > indexSet.lastIndex) {
		return [self.CasksArray objectsAtIndexes:indexSet];
	}
	return nil;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	// the return value is typed as (id) because it will return a string in all cases with the exception of the
	if(self.CasksArray) {
		NSString *columnIdentifer = [tableColumn identifier];
		id element = [self.CasksArray objectAtIndex:(NSUInteger)row];
		
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
				switch ([[BPHomebrewManager sharedManager] statusForCask:element]) {
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
