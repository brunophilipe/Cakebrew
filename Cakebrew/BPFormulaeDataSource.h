//
//  BPFormulaeDataSource.h
//  Cakebrew
//
//  Created by Marek Hrusovsky on 04/09/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BPHomebrewInterface.h"
#import "BPFormula.h"

@interface BPFormulaeDataSource : NSObject <NSTableViewDataSource>

@property (nonatomic, assign) BPListMode mode;

- (instancetype)initWithMode:(BPListMode)aMode;
- (BPFormula *)formulaAtIndex:(NSInteger)index;
- (NSArray *)formulasAtIndexSet:(NSIndexSet *)indexSet;
- (void)refreshBackingArray;
@end
