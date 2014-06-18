//
//  BPFormulaOptionsViewController.h
//  Cakebrew
//
//  Created by Bruno Philipe on 6/17/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BPFormula.h"
#import "BPHomebrewViewController.h"

@interface BPFormulaOptionsViewController : NSViewController

@property (weak) BPFormula *formula;
@property (weak) BPHomebrewViewController *homebrewViewController;

@property (strong) NSWindow *window;

- (IBAction)cancel:(id)sender;
- (IBAction)install:(id)sender;

@end
