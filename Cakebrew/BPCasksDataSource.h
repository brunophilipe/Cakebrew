//
//  BPCasksDataSource.h
//  Cakebrew
//

#import <Foundation/Foundation.h>
#import "BPHomebrewInterface.h"
#import "BPFormula.h"

@interface BPCasksDataSource : NSObject <NSTableViewDataSource>

@property (nonatomic, assign) BPListMode mode;

- (instancetype)initWithMode:(BPListMode)aMode;
- (BPFormula *)caskAtIndex:(NSInteger)index;
- (NSArray *)casksAtIndexSet:(NSIndexSet *)indexSet;
- (void)refreshBackingArray;
@end
