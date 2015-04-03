//
//  BPFormulaPopoverViewController.h
//  Cakebrew
//
//  Created by Marek Hrusovsky on 05/09/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BPFormula.h"

@interface BPFormulaPopoverViewController : NSViewController

@property (strong) IBOutlet NSTextView *formulaTextView;
@property (unsafe_unretained) IBOutlet NSTextField *formulaTitleLabel;
@property (unsafe_unretained, nonatomic) BPFormula *formula;
@property (unsafe_unretained) IBOutlet NSPopover *formulaPopover;

@end
