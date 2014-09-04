//
//  BPInstallationViewController.m
//  Cakebrew
//
//  Created by Bruno Philipe on 4/7/14.
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

#pragma clang diagnostic push
#pragma ide diagnostic ignored "OCUnusedMethodInspection"
- (void)setTextView:(NSTextView *)textView
{
	NSFont *font = [BPAppDelegateRef defaultFixedWidthFont];
	
	_textView = textView;
	[_textView setFont:font];
	[_textView setSelectable:YES];
}
#pragma clang diagnostic pop

- (NSTextView*)textView
{
	return _textView;
}

- (void)setFormulae:(NSArray *)formulae
{
	_formulae = formulae;

	NSUInteger count = [formulae count];

	if (count == 1) {
		[self.label_formulaName setStringValue:[(BPFormula*)[formulae firstObject] name]];
	} else if (count > 1) {
		NSString *formulaeNames = [[self namesOfFormulae:formulae] componentsJoinedByString:@", "];
		[self.label_formulaName setStringValue:formulaeNames];
	} else {
		[self.label_formulaName setStringValue:@"All Outdated Formulae"];
	}
}

- (void)setWindowOperation:(BPWindowOperation)windowOperation
{
	_windowOperation = windowOperation;
	NSString *message;
	switch (windowOperation) {
		case kBPWindowOperationInstall:
			message = @"Installing Formula:";
			break;

		case kBPWindowOperationUninstall:
			message = @"Uninstalling Formula:";
			break;

		case kBPWindowOperationUpgrade:
			message = @"Upgrading Formula:";
			break;

		case kBPWindowOperationTap:
			message = @"Tapping Repository:";
			break;

		case kBPWindowOperationUntap:
			message = @"Untapping Repository:";
			break;
	}
	[self.label_windowTitle setStringValue:message];
}

- (NSArray*)namesOfFormulae:(NSArray*)formulae
{
	NSMutableArray *names = [NSMutableArray arrayWithCapacity:formulae.count];
	for (BPFormula *formula in formulae) {
		[names addObject:formula.name];
	}
	return [names copy];
}

- (void)windowDidAppear
{
	[self.progressIndicator startAnimation:nil];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		NSString __block *outputValue;
		if (self.windowOperation == kBPWindowOperationInstall)
		{
			NSString *name = [[self.formulae firstObject] name];
			[[BPHomebrewInterface sharedInterface] installFormula:name withOptions:self.options andReturnBlock:^(NSString *output) {
				if (outputValue) outputValue = [outputValue stringByAppendingString:output];
				else outputValue = output;
				[self.textView performSelectorOnMainThread:@selector(setString:) withObject:outputValue waitUntilDone:YES];
			}];
		}
		else if (self.windowOperation == kBPWindowOperationUninstall)
		{
			NSString *name = [[self.formulae firstObject] name];
			[[BPHomebrewInterface sharedInterface] uninstallFormula:name withReturnBlock:^(NSString *output) {
				if (outputValue) outputValue = [outputValue stringByAppendingString:output];
				else outputValue = output;
				[self.textView performSelectorOnMainThread:@selector(setString:) withObject:outputValue waitUntilDone:YES];
			}];
		}
		else if (self.windowOperation == kBPWindowOperationUpgrade)
		{
			if (self.formulae) {
				NSArray *names = [self namesOfFormulae:self.formulae];
				[[BPHomebrewInterface sharedInterface] upgradeFormulae:names withReturnBlock:^(NSString *output) {
					if (outputValue) outputValue = [outputValue stringByAppendingString:output];
					else outputValue = output;
					[self.textView performSelectorOnMainThread:@selector(setString:) withObject:outputValue waitUntilDone:YES];
				}];
			} else {
				[[BPHomebrewInterface sharedInterface] upgradeFormula:kBP_UPGRADE_ALL_FORMULAS withReturnBlock:^(NSString *output) {
					if (outputValue) outputValue = [outputValue stringByAppendingString:output];
					else outputValue = output;
					[self.textView performSelectorOnMainThread:@selector(setString:) withObject:outputValue waitUntilDone:YES];
				}];
			}
		}
		else if (self.windowOperation == kBPWindowOperationTap)
		{
			NSString *name = [[self.formulae firstObject] name];
			[[BPHomebrewInterface sharedInterface] tapRepository:name withReturnsBlock:^(NSString *output) {
					if (outputValue) outputValue = [outputValue stringByAppendingString:output];
					else outputValue = output;
					[self.textView performSelectorOnMainThread:@selector(setString:) withObject:outputValue waitUntilDone:YES];
			}];
		}
		else if (self.windowOperation == kBPWindowOperationUntap)
		{
			NSString *name = [[self.formulae firstObject] name];
			[[BPHomebrewInterface sharedInterface] untapRepository:name withReturnsBlock:^(NSString *output) {
				if (outputValue) outputValue = [outputValue stringByAppendingString:output];
				else outputValue = output;
				[self.textView performSelectorOnMainThread:@selector(setString:) withObject:outputValue waitUntilDone:YES];
			}];
		}

		[self.progressIndicator stopAnimation:nil];
		[self.button_ok setEnabled:YES];
		[BPAppDelegateRef setRunningBackgroundTask:NO];
	});
}

- (IBAction)ok:(id)sender {
    NSWindow *mainWindow = self.parentSheet;
	if (!mainWindow) mainWindow = BPAppDelegateRef.window;
	
	if ([mainWindow respondsToSelector:@selector(endSheet:)]) {
		[mainWindow endSheet:self.window];
	} else {
		[[NSApplication sharedApplication] endSheet:self.window];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:kBP_NOTIFICATION_FORMULAS_CHANGED object:nil];
}
@end
