//
//  BPSelectedFormulaViewController.h
//  Cakebrew
//
//  Created by Marek Hrusovsky on 05/09/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BPSelectedFormulaViewController : NSViewController

@property (unsafe_unretained, nonatomic) NSArray *formulae;

@property (unsafe_unretained) IBOutlet NSTextField *formulaPathLabel;
@property (unsafe_unretained) IBOutlet NSTextField *formulaVersionLabel;
@property (unsafe_unretained) IBOutlet NSTextField *formulaDependenciesLabel;
@property (unsafe_unretained) IBOutlet NSTextField *formulaConflictsLabel;

@end
