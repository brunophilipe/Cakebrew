//
//  BPFormulaPopoverViewController.h
//  Cakebrew
//
//  Created by Marek Hrusovsky on 05/09/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BPFormula.h"

typedef NS_ENUM(NSInteger, BPFormulaInfoType) {
	kBPFormulaInfoTypeGeneral,
	kBPFormulaInfoTypeInstalledDependents,
	kBPFormulaInfoTypeAllDependents
};

@interface BPFormulaPopoverViewController : NSViewController

@property (strong) IBOutlet NSTextView *formulaTextView;
@property (weak) IBOutlet NSTextField *formulaTitleLabel;
@property (weak, nonatomic) BPFormula *formula;
@property (weak) IBOutlet NSPopover *formulaPopover;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;

@property BPFormulaInfoType infoType;

@end
