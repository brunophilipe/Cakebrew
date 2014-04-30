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

- (void)setFormulas:(NSArray *)formulas
{
	_formulas = formulas;
	[self.label_formulaName setStringValue:@"All outdated formulas"];
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
	NSString __block *output;
	dispatch_async(dispatch_get_main_queue(), ^{
		switch (self.windowOperation) {
			case kBP_WINDOW_OPERATION_INSTALL:
				output = [[BPHomebrewInterface sharedInterface] installFormula:self.formula.name];
				break;

			case kBP_WINDOW_OPERATION_UNINSTALL:
				output = [[BPHomebrewInterface sharedInterface] uninstallFormula:self.formula.name];
				break;

			case kBP_WINDOW_OPERATION_UPGRADE:
				if (self.formula) {
					output = [[BPHomebrewInterface sharedInterface] upgradeFormula:self.formula.name];
				} else {
					NSMutableArray *names = [NSMutableArray arrayWithCapacity:self.formulas.count];
					for (BPFormula *formula in self.formulas) {
						[names addObject:formula.name];
					}
					output = [[BPHomebrewInterface sharedInterface] upgradeFormulas:names];
				}
				break;
		}

		[self.textView setString:output];
		[self.progressIndicator stopAnimation:nil];
		[self.button_ok setEnabled:YES];
	});
}

- (IBAction)ok:(id)sender {
	NSWindow *mainWindow = BPAppDelegateRef.window;
	[mainWindow endSheet:self.window];
}
@end
