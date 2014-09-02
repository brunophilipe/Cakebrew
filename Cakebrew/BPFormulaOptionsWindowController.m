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

//these constants must match arraycontroller in XIB (array controller + binding on table columns)
static NSString const * kFormulaOptionCommand = @"formulaOptionCommand";
static NSString const * kIsFormulaOptionCommandApplied = @"isFormulaOptionCommandApplied";
static NSString const * kFormulaOptionDescription = @"formulaOptionDescription";

@interface BPFormulaOptionsWindowController ()

@property (weak) IBOutlet NSTextField *userHelpLabel;
@property (weak) IBOutlet NSTextField *formulaNameLabel;
@property (weak) IBOutlet NSTextField *optionDetailsTextField;
@property (weak) IBOutlet NSTableView *formulaOptionsTableView;
@property (strong) IBOutlet NSArrayController *formulasArrayController;

@property (nonatomic, strong) NSMutableArray *availableOptions;
@property (strong) BPFormula *formula;

@end

@implementation BPFormulaOptionsWindowController

- (void)awakeFromNib {
  
  NSUInteger numberOfFormulaOptions = [self.availableOptions count];
  if (numberOfFormulaOptions > 0) {
    [self.userHelpLabel setStringValue:@"Click on option for details."];
  } else {
    [self.userHelpLabel setStringValue:@"This formula has no installation options available."];
  }
  
  //load array controller with array of mutable dictionaries with options
  [self.formulasArrayController addObjects:self.availableOptions];
  
  [self.formulaOptionsTableView reloadData];
}

+ (BPFormulaOptionsWindowController *)runFormula:(BPFormula *)formula withCompletionBlock:(InstalWithOptionsBlock_t)completionBlock
{
  BPFormulaOptionsWindowController *formulaOptionsWindowController;
  formulaOptionsWindowController = [[BPFormulaOptionsWindowController alloc] initWithWindowNibName:@"BPFormulaOptionsWindow"];
  formulaOptionsWindowController.formula = formula;
  formulaOptionsWindowController.installWithOptionsBlock = completionBlock;
  NSMutableArray *availableOptions = [[NSMutableArray alloc] init];
  
  for (id option in [formula options]) {
    id optionCommand = [option objectForKey:kBP_FORMULA_OPTION_COMMAND];;
    id optionDescription = [option objectForKey:kBP_FORMULA_OPTION_DESCRIPTION] ? : @"";
    if (optionCommand) {
      
      // We want to be able to modify content of kWantsToInstallOption within table view
      NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithDictionary:@{ kFormulaOptionCommand : optionCommand,
                                                                                           kIsFormulaOptionCommandApplied : @NO,
                                                                                           kFormulaOptionDescription : optionDescription}];
      [availableOptions addObject:dictionary];
    }
  }
  formulaOptionsWindowController.availableOptions = availableOptions;
  
  
  NSWindow *formulaWindow = formulaOptionsWindowController.window;
  [BPAppDelegateRef setRunningBackgroundTask:YES];
  
  if ([[NSApp mainWindow] respondsToSelector:@selector(beginSheet:completionHandler:)]) {
    [[NSApp mainWindow] beginSheet:formulaWindow completionHandler:^(NSModalResponse returnCode) {
      if (returnCode == NSModalResponseStop) {
        NSArray *options = [formulaOptionsWindowController allSelectedOptions];
        formulaOptionsWindowController.installWithOptionsBlock(options);
      } else {
        [BPAppDelegateRef setRunningBackgroundTask:NO];
      }
      
    }];
  } else {
    [[NSApplication sharedApplication] beginSheet:formulaWindow
                                   modalForWindow:[NSApp mainWindow]
                                    modalDelegate:formulaOptionsWindowController
                                   didEndSelector:@selector(windowOperationSheetDidEnd:returnCode:contextInfo:)
                                      contextInfo:NULL];
  }
  return formulaOptionsWindowController;
}


- (void)windowOperationSheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
  [sheet orderOut:self];
  
  if(returnCode == NSModalResponseStop) {
    NSArray *options = [self allSelectedOptions];
    self.installWithOptionsBlock(options);
  } else {
    [BPAppDelegateRef setRunningBackgroundTask:NO];
  }
}

/*
 * Return an array with formula options that user wants to use with formula
 */
- (NSArray *)allSelectedOptions {
  NSPredicate *selectedFormulas = [NSPredicate predicateWithFormat:@"%K == %@", kIsFormulaOptionCommandApplied, @YES];
  NSArray *filteredArray = [self.availableOptions filteredArrayUsingPredicate:selectedFormulas];
  NSArray *allOptions = [filteredArray valueForKeyPath:@"formulaOptionCommand"];
  return allOptions;
}

- (IBAction)cancel:(id)sender {
	NSWindow *mainWindow = [NSApp mainWindow];
	if ([mainWindow respondsToSelector:@selector(endSheet:returnCode:)]) {
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

	} else {
    modalResponse = NSModalResponseAbort;
	}
  
  NSWindow *mainWindow = [NSApp mainWindow];
  if ([mainWindow respondsToSelector:@selector(endSheet:returnCode:)]) {
    [mainWindow endSheet:self.window returnCode:modalResponse];
  } else {
    [[NSApplication sharedApplication] endSheet:self.window returnCode:modalResponse];
  }
}

@end
