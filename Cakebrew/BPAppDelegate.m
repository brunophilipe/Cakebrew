//
//	AppDelegate.m
//	Cakebrew – The Homebrew GUI App for OS X
//
//	Created by Vincent Saluzzo on 06/12/11.
//	Copyright (c) 2011 Bruno Philipe. All rights reserved.
//
//	This program is free software: you can redistribute it and/or modify
//	it under the terms of the GNU General Public License as published by
//	the Free Software Foundation, either version 3 of the License, or
//	(at your option) any later version.
//
//	This program is distributed in the hope that it will be useful,
//	but WITHOUT ANY WARRANTY; without even the implied warranty of
//	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//	GNU General Public License for more details.
//
//	You should have received a copy of the GNU General Public License
//	along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import "BPAppDelegate.h"
#import "BPHomebrewManager.h"
#import "DCOAboutWindowController.h"

@class DCOAboutWindowController;

@interface BPAppDelegate ()

@property (strong) DCOAboutWindowController *aboutWindowController;

@end

@implementation BPAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	self.aboutWindowController = [[DCOAboutWindowController alloc] init];
	[self.aboutWindowController setAppWebsiteURL:kBP_CAKEBREW_URL];
	[[BPHomebrewManager sharedManager] update];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag
{
    if (!flag) {
        [self.window makeKeyAndOrderFront:self];
    }
    
    return YES;
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
		alert = [NSAlert alertWithMessageText:@"Active background task!" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Sorry, a background task is already running. You can't perform two tasks at the same time."];

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

- (IBAction)showCustomBrewPathWindow:(id)sender {
	[self.window beginSheet:self.customBrewPathWindow completionHandler:nil];
	[self.customBrewPathWindow setSheetParent:self.window];
}

- (IBAction)showPreferencesWindow:(id)sender {
	[self.window beginSheet:self.preferencesWindow completionHandler:nil];
}
@end
