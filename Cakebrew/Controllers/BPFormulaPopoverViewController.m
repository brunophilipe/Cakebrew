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
#import "BPAppDelegate.h"
#import "BPTimedDispatch.h"

@interface BPFormulaPopoverViewController ()

@property (strong) BPTimedDispatch *timedDispatch;

@end

@implementation BPFormulaPopoverViewController

- (void)awakeFromNib
{
	NSFont *font = [NSFont bp_defaultFixedWidthFont];
	[self.formulaTextView setFont:font];
	[self.formulaTextView setTextColor:[NSColor blackColor]];
	[self.formulaPopover setContentViewController:self];
	[self setTimedDispatch:[BPTimedDispatch new]];
}

- (void)setFormula:(BPFormula *)formula
{
	_formula = formula;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateView:)
												 name:BPFormulaDidUpdateNotification
											   object:formula];

	[self displayConsoleInformationForFormulae];
	[self.timedDispatch scheduleDispatchAfterTimeInterval:0.3
												  inQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
												ofBlock:^{

												  [_formula setNeedsInformation:YES];
												}];
	
}

- (NSString *)nibName
{
	return @"BPFormulaPopoverView";
}

- (void)updateView:(NSNotification *)notification
{
  dispatch_async(dispatch_get_main_queue(), ^{
	[self displayConsoleInformationForFormulae];
  });
}

- (void)displayConsoleInformationForFormulae
{
  NSString *string = self.formula.information;
  if (string) {
	[self.formulaTextView setString:string];
	
	// Recognize links in info text
	[self.formulaTextView setEditable:YES];
	[self.formulaTextView checkTextInDocument:nil];
	[self.formulaTextView setEditable:NO];
	
	[self.formulaTitleLabel setStringValue:[NSString stringWithFormat:NSLocalizedString(@"Formula_Popover_Title", nil), [_formula performSelector:@selector(name)]]];
  }
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
