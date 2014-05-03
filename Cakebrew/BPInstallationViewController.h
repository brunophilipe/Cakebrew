//
//  BPInstallationViewController.h
//  Cakebrew
//
//  Created by Bruno Philipe on 4/7/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BPFormula.h"

typedef enum : NSUInteger {
    kBP_WINDOW_OPERATION_INSTALL,
    kBP_WINDOW_OPERATION_UNINSTALL,
	kBP_WINDOW_OPERATION_UPGRADE
} BP_WINDOW_OPERATION;

@interface BPInstallationViewController : NSViewController

@property (strong) IBOutlet NSTextField *label_windowTitle;
@property (strong) IBOutlet NSTextField *label_formulaName;
@property (strong) IBOutlet NSTextView *textView;
@property (strong) IBOutlet NSButton *button_ok;
@property (strong) IBOutlet NSProgressIndicator *progressIndicator;

@property (assign, nonatomic) BPFormula *formula;
@property (strong, nonatomic) NSArray *formulae;
@property (assign) NSWindow *window;

@property (nonatomic) BP_WINDOW_OPERATION windowOperation;

- (void)windowDidAppear;

- (IBAction)ok:(id)sender;

@end
