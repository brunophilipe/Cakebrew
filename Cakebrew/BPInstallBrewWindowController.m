//
//  BPInstallBrewWindowController.m
//  Cakebrew
//
//  Created by Bruno Philipe on 5/23/15.
//  Copyright (c) 2015 Bruno Philipe. All rights reserved.
//

#import "BPInstallBrewWindowController.h"
#import "BPHomebrewInterface.h"
#import "NSFont+Appearance.h"

@interface BPInstallBrewWindowController ()

@property (strong) IBOutlet NSTextView *textView;
@property (strong) IBOutlet NSButton *okButton;
@property (strong) IBOutlet NSProgressIndicator *progressIndicator;

@property (strong) NSPipe *inputPipe;
@property (strong) NSFileHandle *inputPipeHandle;

@end

@implementation BPInstallBrewWindowController

- (void)windowDidLoad
{
    [super windowDidLoad];
	
	NSFont *font = [NSFont bp_defaultFixedWidthFont];
	[self.textView setFont:font];
}

+ (BPInstallBrewWindowController*)run
{
	BPInstallBrewWindowController *operationWindowController;
	operationWindowController = [[BPInstallBrewWindowController alloc]
								 initWithWindowNibName:@"BPInstallBrewWindowController"];
	
	NSWindow *operationWindow = operationWindowController.window;
	
	[BPAppDelegateRef setRunningBackgroundTask:YES];
	
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

- (void)executeInstallation
{
	[self.okButton setEnabled:NO];
	[self.progressIndicator startAnimation:nil];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		NSString __block *outputValue;
		BPHomebrewInterface *homebrewInterface = [BPHomebrewInterface sharedInterface];
		
		self.inputPipe = [NSPipe pipe];
		self.inputPipeHandle = [self.inputPipe fileHandleForWriting];
		
		[homebrewInterface installHomebrewUsingInputPipe:self.inputPipe andWithReturnBlock:^(NSString *output) {
			if (outputValue) {
				outputValue = [outputValue stringByAppendingString:output];
			} else {
				outputValue = output;
			}
			[self.textView performSelectorOnMainThread:@selector(setString:)
											withObject:outputValue
										 waitUntilDone:YES];
		}];
		
		[self.progressIndicator stopAnimation:nil];
		[self.okButton setEnabled:YES];
	});
}

- (IBAction)didClickOK:(id)sender
{
	self.textView.string = @"";
	NSWindow *mainWindow = [NSApp mainWindow];
	if ([mainWindow respondsToSelector:@selector(endSheet:)]) {
		[mainWindow endSheet:self.window];
	} else {
		[[NSApplication sharedApplication] endSheet:self.window];
	}
}

- (IBAction)inputFieldDidReturn:(NSTextField*)sender
{
	[self.inputPipeHandle writeData:[[sender stringValue] dataUsingEncoding:NSUTF8StringEncoding]];
}

@end
