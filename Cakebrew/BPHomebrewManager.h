//
//  BPHomebrewManager.h
//  Cakebrew
//
//  Created by Bruno Philipe on 4/3/14.
//
//

#import <Foundation/Foundation.h>
#import "BPFormula.h"

@class BPHomebrewManager;

typedef enum : NSUInteger {
    kBP_FORMULA_NOT_INSTALLED,
    kBP_FORMULA_INSTALLED,
    kBP_FORMULA_OUTDATED,
} BP_FORMULA_STATUS;

@protocol BPHomebrewManagerDelegate <NSObject>

- (void)homebrewManagerFinishedUpdating:(BPHomebrewManager*)manager;

@end

@interface BPHomebrewManager : NSObject

@property (strong) NSArray *formulas_installed;
@property (strong) NSArray *formulas_outdated;
@property (strong) NSArray *formulas_all;
@property (strong) NSArray *formulas_leaves;

@property (weak) id<BPHomebrewManagerDelegate> delegate;

+ (BPHomebrewManager *)sharedManager;

- (void)update;
- (BP_FORMULA_STATUS)statusForFormula:(BPFormula*)formula;

@end
