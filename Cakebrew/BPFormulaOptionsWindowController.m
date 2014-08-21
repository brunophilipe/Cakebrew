//
//  BPFormulaOptionsWindowController.m
//  Cakebrew
//
//  Created by Marek Hrusovsky on 21/08/14.
//	Copyright (c) 2014 Bruno Philipe. All rights reserved.
//
//	This program is free software: you can redistribute it and/or modify
//	it under the terms of the GNU General Public License as published by
//	the Free Software Foundation, either version 3 of the License, or
//	(at your option) any later version.
//
//	This program is distributed in the hope that it will be useful,
//	but WITHOUT ANY WARRANTY; without even the implied warranty of
//	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	See the
//	GNU General Public License for more details.
//
//	You should have received a copy of the GNU General Public License
//	along with this program.	If not, see <http://www.gnu.org/licenses/>.
//

#import "BPFormulaOptionsWindowController.h"
#import "BPFormula.h"

static void * BPFormulaOptionsWindowControllerContext = &BPFormulaOptionsWindowControllerContext;

@interface BPFormulaOptionsWindowController () <NSTableViewDataSource, NSTableViewDelegate> {
  __weak BPFormula *_formula;
}

@property (weak) IBOutlet NSTextField *infoLabel;
@property (weak) IBOutlet NSTextField *formulaNameLabel;
@property (weak) IBOutlet NSTextField *optionDetailsTextField;
@property (weak) IBOutlet NSTableView *formulaOptionsTableView;

@property NSUInteger numberOfFormulaOptions;
@property (nonatomic, strong) NSArray *availableOptions;
@property (nonatomic, strong) NSMutableArray *selectedOptions;

@end

@implementation BPFormulaOptionsWindowController
@synthesize formula = _formula;

- (void)awakeFromNib {
  [self addObserver:self
         forKeyPath:@"numberOfFormulaOptions"
            options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
            context:BPFormulaOptionsWindowControllerContext];
  [self refreshFormulaDependencies];
}

- (id)init {
  self = [super initWithWindowNibName:@"BPFormulaOptionsWindow"];
  if (self) {
    _numberOfFormulaOptions = 0;
  }
  
  return self;
}

- (id)initWithWindowNibName:(NSString *)windowNibName {
  return [self init];
}


- (void)refreshFormulaDependencies {
  self.availableOptions = [[self.formula options] copy];
  self.numberOfFormulaOptions = [self.availableOptions count];
  self.selectedOptions = [[NSMutableArray alloc] initWithCapacity:self.numberOfFormulaOptions];
  for (NSUInteger i = 0; i < self.numberOfFormulaOptions; i++) {
    [self.selectedOptions addObject:@NO];
  }
  
  [self.formulaOptionsTableView reloadData];
}

- (NSArray *)allSelectedOptions {
  NSMutableArray *options = [NSMutableArray arrayWithCapacity:self.numberOfFormulaOptions];

  for (NSInteger i = 0; i < self.numberOfFormulaOptions; i++) {

    if ([[self.selectedOptions objectAtIndex:i] boolValue])
      [options addObject:[[self.availableOptions objectAtIndex:i] objectForKey:kBP_FORMULA_OPTION_COMMAND]];
  }
  return [NSArray arrayWithArray:options];
}

- (IBAction)cancel:(id)sender {
	NSWindow *mainWindow = [NSApp mainWindow];
	if ([mainWindow respondsToSelector:@selector(endSheet:)]) {
		[mainWindow endSheet:self.window returnCode:NSModalResponseAbort];
	} else {
		[[NSApplication sharedApplication] endSheet:self.window returnCode:NSModalResponseAbort];
	}
}

- (IBAction)install:(id)sender {
	NSAlert *alert = [NSAlert alertWithMessageText:@"Attention!"
                                   defaultButton:@"Yes"
                                 alternateButton:@"Cancel"
                                     otherButton:nil
                       informativeTextWithFormat:@"Are you sure you want to install the formula %@ with the selected options?", self.formula.name];
	[alert.window setTitle:@"Cakebrew"];
  
  
	NSInteger returnValue = [alert runModal];
	NSInteger modalResponse = NSModalResponseStop;
  if (returnValue == NSAlertDefaultReturn) {

	}
	else {
    modalResponse = NSModalResponseAbort;
	}
  
  NSWindow *mainWindow = [NSApp mainWindow];
  if ([mainWindow respondsToSelector:@selector(endSheet:returnCode:)]) {
    [mainWindow endSheet:self.window returnCode:modalResponse];
  } else {
    [[NSApplication sharedApplication] endSheet:self.window returnCode:modalResponse];
  }
}

#pragma mark - Table View Delegate

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
  NSInteger selectedRow = [self.formulaOptionsTableView selectedRow];
	if (selectedRow >= 0) {
		[self.optionDetailsTextField setStringValue:[[self.availableOptions objectAtIndex:selectedRow] objectForKey:kBP_FORMULA_OPTION_DESCRIPTION]];
	} else {
		[self.optionDetailsTextField setStringValue:@""];
	}
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return self.numberOfFormulaOptions;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	if ([[aTableColumn identifier] isEqualToString:@"enabled"]) {
		NSLog(@"%s", __PRETTY_FUNCTION__);
		return [self.selectedOptions objectAtIndex:rowIndex];
	} else {
		return [[self.availableOptions objectAtIndex:rowIndex] objectForKey:kBP_FORMULA_OPTION_COMMAND];
	}
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	if ([[tableColumn identifier] isEqualToString:@"enabled"]) {
		[self.selectedOptions replaceObjectAtIndex:row withObject:object];
	}
}


#pragma mark - Getters and Setters

- (BPFormula *)formula
{
	return _formula;
}

- (void)setFormula:(BPFormula *)formula
{
  _formula = formula;
  [self refreshFormulaDependencies];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  
  if (context == BPFormulaOptionsWindowControllerContext) {
    
    if ([keyPath isEqualTo:@"numberOfFormulaOptions"]) {
      
      if (self.numberOfFormulaOptions > 0) {
        [self.infoLabel setStringValue:@"Click on option for details."];
      } else {
        [self.infoLabel setStringValue:@"This formula has no installation options available."];
      }
    }
    
  } else {
    @try {
      [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    @catch (NSException *exception) {
      ;
    }
  }
}

- (void)dealloc {
  [self removeObserver:self
            forKeyPath:@"numberOfFormulaOptions"
               context:BPFormulaOptionsWindowControllerContext];
}

@end
