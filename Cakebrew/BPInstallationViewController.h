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
    kBPWindowOperationInstall,
    kBPWindowOperationUninstall,
	kBPWindowOperationUpgrade
} BPWindowOperation;

@interface BPInstallationViewController : NSViewController

@property (strong) IBOutlet NSTextField *label_windowTitle;
@property (strong) IBOutlet NSTextField *label_formulaName;
@property (strong) IBOutlet NSTextView *textView;
@property (strong) IBOutlet NSButton *button_ok;
@property (strong) IBOutlet NSProgressIndicator *progressIndicator;

@property (assign, nonatomic) BPFormula *formula;
@property (strong, nonatomic) NSArray *formulae;
@property (assign) NSWindow *window;

@property (nonatomic) BPWindowOperation windowOperation;

- (void)windowDidAppear;

- (IBAction)ok:(id)sender;

@end
