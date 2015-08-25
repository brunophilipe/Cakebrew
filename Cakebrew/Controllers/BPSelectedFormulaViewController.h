//
//  BPSelectedFormulaViewController.h
//  Cakebrew
//
//  Created by Marek Hrusovsky on 05/09/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "BPFormula.h"

@protocol BPSelectedFormulaViewControllerDelegate <NSObject>

- (void)selectedFormulaViewDidUpdateFormulaInfoForFormula:(BPFormula*)formula;

@end

@interface BPSelectedFormulaViewController : NSViewController

@property (strong, nonatomic) NSArray *formulae;

@property (weak) id<BPSelectedFormulaViewControllerDelegate> delegate;

@property (weak) IBOutlet NSTextField *formulaDescriptionLabel;
@property (weak) IBOutlet NSTextField *formulaPathLabel;
@property (weak) IBOutlet NSTextField *formulaVersionLabel;
@property (weak) IBOutlet NSTextField *formulaDependenciesLabel;
@property (weak) IBOutlet NSTextField *formulaConflictsLabel;

@end
