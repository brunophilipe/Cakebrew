//
//  BPInstallationWindowController.m
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

#import "BPInstallationWindowController.h"
#import "BPHomebrewInterface.h"
#import "BPHomebrewManager.h"
#import "BPStyle.h"
#import "BPAppDelegate.h"

@interface BPInstallationWindowController ()

@property (weak) IBOutlet NSTextField *windowTitleLabel;
@property (weak) IBOutlet NSTextField *formulaNameLabel;
@property (unsafe_unretained) IBOutlet NSTextView *recordTextView; //NSTextView does not support weak in ARC at all (not just 10.7)
@property (weak) IBOutlet NSButton *okButton;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;

@property (nonatomic) BPWindowOperation windowOperation;
@property (strong, nonatomic) NSArray *formulae;
@property (strong, nonatomic) NSArray *options;

@end

@implementation BPInstallationWindowController

+ (NSDictionary*)sharedTaskMessagesMap
{
	static NSDictionary *taskMessages = nil;
	
	if (!taskMessages)
	{
		taskMessages   = @{@(kBPWindowOperationInstall)		: NSLocalizedString(@"Installation_Window_Operation_Install", nil),
						   @(kBPWindowOperationUninstall)	: NSLocalizedString(@"Installation_Window_Operation_Uninstall", nil),
						   @(kBPWindowOperationUpgrade)		: NSLocalizedString(@"Installation_Window_Operation_Update", nil),
						   @(kBPWindowOperationTap)			: NSLocalizedString(@"Installation_Window_Operation_Tap", nil),
						   @(kBPWindowOperationUntap)		: NSLocalizedString(@"Installation_Window_Operation_Untap", nil),
						   @(kBPWindowOperationCleanup)		: NSLocalizedString(@"Installation_Window_Operation_Cleanup", nil)};
	}
	
	return taskMessages;
}

- (void)awakeFromNib
{
	[self setupUI];
}

- (void)setupUI
{
	NSDictionary *messagesMap = [self.class sharedTaskMessagesMap];
	NSFont *font = [BPStyle defaultFixedWidthFont];
	
	[self.recordTextView setFont:font];
	self.windowTitleLabel.stringValue = messagesMap[@(self.windowOperation)] ?: @"";
	
	NSUInteger count = [self.formulae count];
	
	if (count >= 1)
	{
		NSString *formulaeNames = [[self namesOfAllFormulae] componentsJoinedByString:@", "];
		self.formulaNameLabel.stringValue = formulaeNames;
	}
	else {
		if (self.windowOperation != kBPWindowOperationCleanup)
		{
			self.formulaNameLabel.stringValue = NSLocalizedString(@"Installation_Window_All_Formulae", nil);
		}
		else
		{
			self.formulaNameLabel.stringValue = @"";
		}
	}
}

+ (BPInstallationWindowController *)runWithOperation:(BPWindowOperation)windowOperation
											formulae:(NSArray *)formulae
											 options:(NSArray *)options
{
	BPInstallationWindowController *operationWindowController;
	operationWindowController = [[BPInstallationWindowController alloc] initWithWindowNibName:@"BPInstallationWindow"];
	operationWindowController.windowOperation = windowOperation;
	operationWindowController.formulae = formulae;
	operationWindowController.options = options;
	[BPAppDelegateRef setRunningBackgroundTask:YES];
	
	
	NSWindow *operationWindow = operationWindowController.window;
	
	if ([[NSApp mainWindow] respondsToSelector:@selector(beginSheet:completionHandler:)]) {
		[[NSApp mainWindow] beginSheet:operationWindow completionHandler:^(NSModalResponse returnCode) {
			[BPAppDelegateRef setRunningBackgroundTask:NO];
		}];
	} else {
		[[NSApplication sharedApplication] beginSheet:operationWindow
									   modalForWindow:[NSApp mainWindow]
										modalDelegate:operationWindowController
									   didEndSelector:@selector(windowOperationSheetDidEnd:returnCode:contextInfo:)
										  contextInfo:NULL];
	}
	[operationWindowController executeInstallation];
	
	return operationWindowController;
}

- (void)windowOperationSheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
{
	[sheet orderOut:self];
	[BPAppDelegateRef setRunningBackgroundTask:NO];
}

- (NSArray*)namesOfAllFormulae
{
	return [self.formulae valueForKeyPath:@"@unionOfObjects.name"];
}

- (void)executeInstallation
{
	[self.okButton setEnabled:NO];
	[self.progressIndicator startAnimation:nil];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		
		NSString __block *outputValue;
		__weak BPInstallationWindowController *weakSelf = self;
		void (^displayTerminalOutput)(NSString *outputValue) = ^(NSString *output) {
			if (outputValue) {
				outputValue = [outputValue stringByAppendingString:output];
			} else {
				outputValue = output;
			}
			[weakSelf.recordTextView performSelectorOnMainThread:@selector(setString:)
													  withObject:outputValue
												   waitUntilDone:YES];
		};
		
		BPHomebrewInterface *homebrewInterface = [BPHomebrewInterface sharedInterface];
		if (self.windowOperation == kBPWindowOperationInstall)
		{
			NSString *name = [[self.formulae firstObject] name];
			[homebrewInterface installFormula:name
								  withOptions:self.options
							   andReturnBlock:displayTerminalOutput];
		}
		else if (self.windowOperation == kBPWindowOperationUninstall)
		{
			NSString *name = [[self.formulae firstObject] name];
			[homebrewInterface uninstallFormula:name
								withReturnBlock:displayTerminalOutput];
		}
		else if (self.windowOperation == kBPWindowOperationUpgrade)
		{
			if (self.formulae) {
				NSArray *names = [self namesOfAllFormulae];
				[homebrewInterface upgradeFormulae:names
								   withReturnBlock:displayTerminalOutput];
			} else {
				//no parameter is necessary to upgrade all formulas; recycling API with empty string
				[homebrewInterface upgradeFormulae:@[@""]
								   withReturnBlock:displayTerminalOutput];
			}
		}
		else if (self.windowOperation == kBPWindowOperationTap)
		{
			if (self.formulae) {
				NSString *name = [[self.formulae firstObject] name];
				[homebrewInterface tapRepository:name withReturnsBlock:displayTerminalOutput];
			}
		}
		else if (self.windowOperation == kBPWindowOperationUntap)
		{
			if (self.formulae) {
				NSString *name = [[self.formulae firstObject] name];
				[[BPHomebrewInterface sharedInterface] untapRepository:name withReturnsBlock:displayTerminalOutput];
			}
		}
		else if (self.windowOperation == kBPWindowOperationCleanup)
		{
			[[BPHomebrewInterface sharedInterface] runCleanupWithReturnBlock:displayTerminalOutput];
		}
		
		[self finishTask];
	});
}


- (void)finishTask
{
	dispatch_async(dispatch_get_main_queue(), ^(){
		[self.progressIndicator stopAnimation:nil];
	});
	[self.okButton setEnabled:YES];
	
	[[NSApplication sharedApplication] requestUserAttention:NSInformationalRequest];
	
	NSUserNotification *userNotification = [NSUserNotification new];
	[userNotification setTitle:[NSLocalizedString(@"Homebrew_Task_Finished", nil) capitalizedString]];
	[userNotification setSubtitle:[NSString stringWithFormat:@"%@ %@",
								   self.windowTitleLabel.stringValue,
								   self.formulaNameLabel.stringValue]];
	
	[[NSUserNotificationCenter defaultUserNotificationCenter] scheduleNotification:userNotification];
}

- (IBAction)okAction:(id)sender
{
	self.recordTextView.string = @"";
	NSWindow *mainWindow = [NSApp mainWindow];
	if ([mainWindow respondsToSelector:@selector(endSheet:)]) {
		[mainWindow endSheet:self.window];
	} else {
		[[NSApplication sharedApplication] endSheet:self.window];
	}
}

@end
