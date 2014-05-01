//
//  BPCustomBrewPathWindow.m
//  Cakebrew
//
//  Created by Bruno Philipe on 4/29/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import "BPCustomBrewPathWindow.h"
#import "BPHomebrewInterface.h"

@implementation BPCustomBrewPathWindow

- (IBAction)showInformation:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/brunophilipe/Cakebrew/issues/7#issuecomment-41744710"]];
}

- (IBAction)storeCustomBrewPath:(id)sender {
	NSString *path = self.textField_brewPath.stringValue;

	if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
		[self.imageView_invalidPath setHidden:YES];
		[[NSUserDefaults standardUserDefaults] setObject:path forKey:kBP_HOMEBREW_PATH_KEY];
		[BPAppDelegateRef.window endSheet:self];
		[[BPHomebrewInterface sharedInterface] hideHomebrewNotInstalledMessage];
	} else {
		[self.imageView_invalidPath setHidden:NO];
	}
}

- (IBAction)cancel:(id)sender {
	[self.sheetParent endSheet:self];
}

@end
