//
//  BPFormulaPopoverViewController.m
//  Cakebrew
//
//  Created by Marek Hrusovsky on 05/09/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import "BPFormulaPopoverViewController.h"
#import "NSFont+Appearance.h"
#import "BPFormula.h"
#import "BPHomebrewInterface.h"

@interface BPFormulaPopoverViewController ()

@end

@implementation BPFormulaPopoverViewController

- (void)awakeFromNib
{
	NSFont *font = [NSFont bp_defaultFixedWidthFont];
	[self.formulaTextView setFont:font];
	[self.formulaTextView setTextColor:[NSColor blackColor]];
	[self.formulaPopover setContentViewController:self];
}

- (void)setFormula:(BPFormula *)formula
{
	_formula = formula;
	NSString *string = [[BPHomebrewInterface sharedInterface] informationForFormula:[_formula performSelector:@selector(name)]];
	if (string) {
		[self.formulaTextView setString:string];
		[self.formulaTitleLabel setStringValue:[NSString stringWithFormat:NSLocalizedString(@"Formula_Popover_Title", nil), [_formula performSelector:@selector(name)]]];
	} else {
		[self.formulaTextView setString:NSLocalizedString(@"Formula_Popover_Error", nil)];
	}
	
	float OSXVersion = [BPAppDelegateRef OSXVersion];
	
	[self.formulaTitleLabel setTextColor:(OSXVersion >= 10.10 ? [NSColor blackColor] : [NSColor whiteColor])];
	[self.formulaTextView   setTextColor:(OSXVersion >= 10.10 ? [NSColor blackColor] : [NSColor whiteColor])];
}

- (NSString *)nibName
{
	return @"BPFormulaPopoverView";
}

@end
