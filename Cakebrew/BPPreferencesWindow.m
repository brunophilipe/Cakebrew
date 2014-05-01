//
//  BPPreferencesWindow.m
//  Cakebrew
//
//  Created by Bruno Philipe on 5/1/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import "BPPreferencesWindow.h"

@implementation BPPreferencesWindow

- (IBAction)didUpdateTextField_proxyURL:(id)sender {
	NSString *proxyString = [(NSTextField*)sender stringValue];
	NSURL *proxyURL = nil;
	BOOL fail = NO;

	if (![proxyString isEqualToString:@""]) {
		proxyURL = [NSURL URLWithString:proxyString];

		if (proxyURL) {
			[[NSUserDefaults standardUserDefaults] setObject:proxyString forKey:kBP_HOMEBREW_PROXY_KEY];
		} else {
			fail = YES;
		}
	} else {
		fail = YES;
	}

	if (fail) {
		[self.imageView_validURL setHidden:NO];
	} else {
		[self.imageView_validURL setHidden:YES];
	}
}

- (IBAction)didChangeCheckBox_enableProxy:(id)sender {
	NSButton *checkbox = sender;
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:(checkbox.state == NSOnState)] forKey:kBP_HOMEBREW_PROXY_ENABLE_KEY];
}

- (IBAction)showCustomBrewPathWindow:(id)sender {
	BPCustomBrewPathWindow *pathWindow = BPAppDelegateRef.customBrewPathWindow;
	[self beginSheet:pathWindow completionHandler:nil];
	[pathWindow setSheetParent:self];
}

- (IBAction)done:(id)sender {
	[BPAppDelegateRef.window endSheet:self];
}

@end
