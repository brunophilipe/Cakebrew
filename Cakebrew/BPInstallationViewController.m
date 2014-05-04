//
//  BPInstallationViewController.m
//  Cakebrew
//
//  Created by Bruno Philipe on 4/7/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import "BPInstallationViewController.h"
#import "BPHomebrewInterface.h"

@interface BPInstallationViewController ()

@end

@implementation BPInstallationViewController
{
	NSTextView *_textView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)setTextView:(NSTextView *)textView
{
	_textView = textView;

	NSFont *font;
	font = [NSFont fontWithName:@"Andale Mono" size:12];
	if (!font)
		font = [NSFont fontWithName:@"Menlo" size:12];
	if (!font)
		font = [NSFont systemFontOfSize:12];

	[_textView setFont:font];
	[_textView setSelectable:YES];
}

- (NSTextView*)textView
{
	return _textView;
}

- (void)setFormula:(BPFormula *)formula
{
	_formula = formula;
	[self.label_formulaName setStringValue:formula.name];
}

- (void)setFormulae:(NSArray *)formulae
{
	_formulae = formulae;
	[self.label_formulaName setStringValue:@"All outdated formulae"];
}

- (void)setWindowOperation:(BP_WINDOW_OPERATION)windowOperation
{
	_windowOperation = windowOperation;
	NSString *message;
	switch (windowOperation) {
		case kBP_WINDOW_OPERATION_INSTALL:
			message = @"Installing Formula:";
			break;

		case kBP_WINDOW_OPERATION_UNINSTALL:
			message = @"Uninstalling Formula:";
			break;

		case kBP_WINDOW_OPERATION_UPGRADE:
			message = @"Upgrading Formula:";
			break;
	}
	[self.label_windowTitle setStringValue:message];
}

- (void)windowDidAppear
{
	[self.progressIndicator startAnimation:nil];
	NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
		NSString __block *outputValue;
		if (self.windowOperation == kBP_WINDOW_OPERATION_INSTALL) {
			[[BPHomebrewInterface sharedInterface] installFormula:self.formula.name withReturnBlock:^(NSString *output) {
				if (outputValue) outputValue = [outputValue stringByAppendingString:output];
				else outputValue = output;
				[self.textView setString:outputValue];
			}];
		} else if (self.windowOperation == kBP_WINDOW_OPERATION_UNINSTALL) {
			[[BPHomebrewInterface sharedInterface] uninstallFormula:self.formula.name withReturnBlock:^(NSString *output) {
				if (outputValue) outputValue = [outputValue stringByAppendingString:output];
				else outputValue = output;
				[self.textView setString:outputValue];
			}];
		} else if (self.windowOperation == kBP_WINDOW_OPERATION_UPGRADE) {
			if (self.formula) {
				[[BPHomebrewInterface sharedInterface] upgradeFormula:self.formula.name withReturnBlock:^(NSString *output) {
					if (outputValue) outputValue = [outputValue stringByAppendingString:output];
					else outputValue = output;
					[self.textView setString:outputValue];
				}];
			} else {
				NSMutableArray *names = [NSMutableArray arrayWithCapacity:self.formulae.count];
				for (BPFormula *formula in self.formulae) {
					[names addObject:formula.name];
				}
				[[BPHomebrewInterface sharedInterface] upgradeFormulae:names withReturnBlock:^(NSString *output) {
					if (outputValue) outputValue = [outputValue stringByAppendingString:output];
					else outputValue = output;
					[self.textView setString:outputValue];
				}];
			}
		}

		[self.progressIndicator stopAnimation:nil];
		[self.button_ok setEnabled:YES];
		[BPAppDelegateRef setRunningBackgroundTask:NO];
	}];
	[blockOperation performSelector:@selector(start) withObject:nil afterDelay:0.1];
}

- (IBAction)ok:(id)sender {
	NSWindow *mainWindow = BPAppDelegateRef.window;
	[mainWindow endSheet:self.window];
	[[NSNotificationCenter defaultCenter] postNotificationName:kBP_NOTIFICATION_FORMULAS_CHANGED object:nil];
}
@end
