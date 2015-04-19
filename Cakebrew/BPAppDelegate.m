//
//	AppDelegate.m
//	Cakebrew – The Homebrew GUI App for OS X
//
//	Created by Vincent Saluzzo on 06/12/11.
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

#import "BPHomebrewManager.h"
#import "DCOAboutWindowController.h"
#import "BPPreferencesWindowController.h"

NSString *const kBP_HOMEBREW_PROXY_KEY = @"BP_HOMEBREW_PROXY_KEY";
NSString *const kBP_HOMEBREW_PROXY_ENABLE_KEY = @"BP_HOMEBREW_PROXY_ENABLE_KEY";
NSString *const kBP_HOMEBREW_WEBSITE = @"https://www.cakebrew.com";

NSString *const kBP_FORMULA_OPTION_COMMAND = @"BP_FORMULA_OPTION_COMMAND";
NSString *const kBP_FORMULA_OPTION_DESCRIPTION = @"BP_FORMULA_OPTION_DESCRIPTION";


@interface BPAppDelegate ()

@property (nonatomic, strong) DCOAboutWindowController *aboutWindowController;
@property (nonatomic, strong) BPPreferencesWindowController *preferencesWindowController;

@end

@interface BPAppDelegate (SignalHandler)
- (void)setupSignalHandler;
@end

@implementation BPAppDelegate

- (BPPreferencesWindowController *)preferencesWindowController
{
	if (!_preferencesWindowController) {
		_preferencesWindowController = [[BPPreferencesWindowController alloc] init];
	}
	return _preferencesWindowController;
}

- (DCOAboutWindowController *)aboutWindowController
{
	if (!_aboutWindowController){
		_aboutWindowController = [[DCOAboutWindowController alloc] init];
		[_aboutWindowController setAppWebsiteURL:kBP_CAKEBREW_URL];
	}
	return _aboutWindowController;
}

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[self setupSignalHandler];
	[[BPHomebrewManager sharedManager] reloadFromInterfaceRebuildingCache:NO];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag
{
	if (!flag) {
		[self.window makeKeyAndOrderFront:self];
	}

	return YES;
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
	[[BPHomebrewManager sharedManager] cleanUp];
	return NSTerminateNow;
}

- (NSURL*)urlForApplicationSupportFolder
{
	NSError *error = nil;
	NSURL *path = [[NSFileManager defaultManager] URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&error];

	if (error) return nil;
	error = nil;

	path = [path URLByAppendingPathComponent:@"Cakebrew/"];

	[[NSFileManager defaultManager] createDirectoryAtPath:path.relativePath withIntermediateDirectories:YES attributes:nil error:&error];

	if (error) return nil;
	error = nil;

	return path;
}

- (NSURL*)urlForApplicationCachesFolder
{
	NSError *error = nil;
	NSURL *path = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&error];

	if (error) return nil;
	error = nil;

	path = [path URLByAppendingPathComponent:@"com.brunophilipe.Cakebrew/"];

	[[NSFileManager defaultManager] createDirectoryAtPath:path.relativePath withIntermediateDirectories:YES attributes:nil error:&error];

	if (error) return nil;
	error = nil;

	return path;
}

- (void)displayBackgroundWarning
{
	static NSAlert *alert= nil;
	if (!alert)
		alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Message_BGTask_Title", nil)
								defaultButton:NSLocalizedString(@"Generic_OK", nil)
							  alternateButton:nil
								  otherButton:nil
					informativeTextWithFormat:NSLocalizedString(@"Message_BGTask_Body", nil)];

	[alert runModal];
}

- (IBAction)showAboutWindow:(id)sender
{
	[self.aboutWindowController showWindow:nil];
}

- (IBAction)openWebsite:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:kBP_CAKEBREW_URL];
}

- (IBAction)showPreferencesWindow:(id)sender {
	[self.preferencesWindowController showWindow:nil];
}

- (float)OSXVersion
{
	float osxVersion;
	if (floor(NSAppKitVersionNumber) <= NSAppKitVersionNumber10_6) {
		//10.6.x or earlier systems
		osxVersion = 10.06;
		NSLog(@"Mac OSX Snow Leopard");
	} else if (floor(NSAppKitVersionNumber) <= NSAppKitVersionNumber10_7) {
		/* On a 10.7 - 10.7.x system */
		osxVersion = 10.07;
		NSLog(@"Mac OSX Lion");
	} else if (floor(NSAppKitVersionNumber) <= NSAppKitVersionNumber10_8) {
		/* On a 10.8 - 10.8.x system */
		osxVersion = 10.08;
		NSLog(@"Mac OSX Moutain Lion");
	} else if (floor(NSAppKitVersionNumber) <= NSAppKitVersionNumber10_9) {
		/* 10.9 or later system */
		osxVersion = 10.09;
		NSLog(@"Mac OSX: Mavericks");
	} else {
		/* 10.9 or later system */
		osxVersion = 10.10;
		NSLog(@"Mac OSX: Yosemite or Later");
	}
	return osxVersion;
}

@end

@implementation BPAppDelegate (SignalHandler)
void signalHandler(int sig);

- (void)setupSignalHandler
{
	signal(SIGTERM, signalHandler);
}

void signalHandler(int sig) {
	if (sig == SIGTERM) {
		// Force Quit
		[[BPHomebrewManager sharedManager] cleanUp];
	}

	signal(sig, SIG_DFL);
}

@end
