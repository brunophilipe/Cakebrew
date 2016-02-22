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
#import "BPAppDelegate.h"

NSString *const kBP_HOMEBREW_WEBSITE = @"https://www.cakebrew.com";


@interface BPAppDelegate () <NSUserNotificationCenterDelegate>

@property (nonatomic, strong) DCOAboutWindowController *aboutWindowController;

@end

@interface BPAppDelegate (SignalHandler)
- (void)setupSignalHandler;
@end

@implementation BPAppDelegate

- (DCOAboutWindowController *)aboutWindowController
{
	if (!_aboutWindowController){
		_aboutWindowController = [[DCOAboutWindowController alloc] init];
		[_aboutWindowController setAppWebsiteURL:[NSURL URLWithString:kBP_HOMEBREW_WEBSITE]];
	}
	return _aboutWindowController;
}

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{	
	[self setupSignalHandler];
	
	[[BPHomebrewManager sharedManager] reloadFromInterfaceRebuildingCache:NO];
	
	[[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag
{
	if (!flag)
	{
		[self.window makeKeyAndOrderFront:self];
	}
	
	[self cleanupTaskAlerts];

	return YES;
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
	[[BPHomebrewManager sharedManager] cleanUp];
	return NSTerminateNow;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
	return YES;
}

- (void)cleanupTaskAlerts
{
	[[NSUserNotificationCenter defaultUserNotificationCenter] removeAllDeliveredNotifications];
	[[[NSApplication sharedApplication] dockTile] setBadgeLabel:nil];
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

	if (error)
	{
		NSLog(@"Error finding caches directory: %@", path);
		return nil;
	}
	
	error = nil;

	path = [path URLByAppendingPathComponent:@"com.brunophilipe.Cakebrew/"];

	[[NSFileManager defaultManager] createDirectoryAtPath:path.relativePath withIntermediateDirectories:YES attributes:nil error:&error];

	if (error)
	{
		NSLog(@"Error creating Cakebrew cache directory: %@", path);
		return nil;
	}
	
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

- (void)requestUserAttentionWithMessageTitle:(NSString*)title andDescription:(NSString*)desc
{
	[[NSApplication sharedApplication] requestUserAttention:NSInformationalRequest];
	
	if (![[NSApplication sharedApplication] isActive])
	{
		[[[NSApplication sharedApplication] dockTile] setBadgeLabel:@"●"];
	}
	
	NSUserNotification *userNotification = [NSUserNotification new];
	[userNotification setTitle:title];
	[userNotification setSubtitle:desc];
	
	[[NSUserNotificationCenter defaultUserNotificationCenter] scheduleNotification:userNotification];
}

#pragma mark - IBActions

- (IBAction)showAboutWindow:(id)sender
{
	[self.aboutWindowController showWindow:sender];
	[self.aboutWindowController.window becomeFirstResponder];
}

- (IBAction)openWebsite:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:kBP_HOMEBREW_WEBSITE]];
}

#pragma mark - User Notification Center Delegate

- (void)userNotificationCenter:(NSUserNotificationCenter *)center
	   didActivateNotification:(NSUserNotification *)notification
{
	[self cleanupTaskAlerts];
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
