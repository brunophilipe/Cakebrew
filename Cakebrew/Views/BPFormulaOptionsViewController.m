//
//  BPFormulaOptionsViewController.m
//  Cakebrew
//
//  Created by Bruno Philipe on 6/17/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import "BPFormulaOptionsViewController.h"

@interface BPFormulaOptionsViewController () <NSTableViewDataSource, NSTableViewDelegate>

@property (strong) IBOutlet NSTextField *label_info;
@property (strong) IBOutlet NSTextField *label_formulaName;
@property (strong) IBOutlet NSTableView *tableView_formulaOptions;
@property (strong) IBOutlet NSTextField *textField_optionDetails;

@end

@implementation BPFormulaOptionsViewController
{
	BPFormula __weak *_formula;
	NSUInteger _optionsCount;
	NSArray *_options;
	NSMutableArray *_useOptions;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
		
    }
    return self;
}

- (IBAction)cancel:(id)sender {
	NSWindow *mainWindow = BPAppDelegateRef.window;
	if ([mainWindow respondsToSelector:@selector(endSheet:)]) {
		[mainWindow endSheet:self.window];
	} else {
		[[NSApplication sharedApplication] endSheet:self.window];
	}
	[BPAppDelegateRef setRunningBackgroundTask:NO];
}

- (IBAction)install:(id)sender {
	NSAlert *alert = [NSAlert alertWithMessageText:@"Attention!" defaultButton:@"Yes" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:@"Are you sure you want to install the formula %@ with the selected options?", self.formula.name];
	[alert.window setTitle:@"Cakebrew"];

	NSInteger returnValue = [alert runModal];
	if (returnValue == NSAlertDefaultReturn) {
        [self.homebrewViewController prepareFormula:self.formula forOperation:kBPWindowOperationInstall inWindow:self.window alsoModal:YES];
	}
	else {
		[BPAppDelegateRef setRunningBackgroundTask:NO];
	}
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return _optionsCount;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	if ([[aTableColumn identifier] isEqualToString:@"enabled"]) {
		NSLog(@"%s", __PRETTY_FUNCTION__);
		return [_useOptions objectAtIndex:rowIndex];
	} else {
		return [[_options objectAtIndex:rowIndex] objectForKey:kBP_FORMULA_OPTION_COMMAND];
	}
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	if ([[tableColumn identifier] isEqualToString:@"enabled"]) {
		[_useOptions replaceObjectAtIndex:row withObject:object];
	}
}

#pragma mark - Table View Delegate

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	NSInteger selectedRow = [self.tableView_formulaOptions selectedRow];
	if (selectedRow >= 0) {
		[self.textField_optionDetails setStringValue:[[_options objectAtIndex:selectedRow] objectForKey:kBP_FORMULA_OPTION_DESCRIPTION]];
	} else {
		[self.textField_optionDetails setStringValue:@""];
	}
}

#pragma mark - Getters and Setters

- (BPFormula*)formula
{
	return _formula;
}

- (void)setFormula:(BPFormula *)formula
{
	_formula = formula;

	[self.label_formulaName setStringValue:formula.name];

	_options = [self.formula options];
	_optionsCount = [_options count];

	if (_optionsCount > 0) {
		_useOptions = [NSMutableArray arrayWithCapacity:_optionsCount];
		for (NSUInteger i=0; i<_optionsCount; i++)
			[_useOptions addObject:@NO];

		[self.tableView_formulaOptions reloadData];
		[self.label_info setStringValue:@"Click on option for details."];
	} else {
		[self.label_info setStringValue:@"This formula has no installation options available."];
	}
}

@end
