//
//  BPPreferencesWindowController.m
//  Cakebrew
//
//  Created by Marek Hrusovsky on 05/05/14.
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

#import "NSString+URLValidation.h"
#import "BPPreferencesWindowController.h"

NSString *const BPProxyEnabledDidChangeNotification = @"BPProxyEnabledDidChangeNotification";
NSString *const BPProxyStringDidChangeNotification = @"BPProxyStringDidChangeNotification";

@interface BPPreferencesWindowController ()

@property (nonatomic, copy) NSString *proxyString;
@property (getter = isProxyEnabled) BOOL proxyEnabled;
@property BOOL containsValidProxyString;

@end

@implementation BPPreferencesWindowController

- (void)awakeFromNib
{
	
}

- (instancetype)initWithWindow:(NSWindow *)window
{
	self = [super initWithWindow:window];
	
	if (self) {
		_proxyString = @"";
		_proxyEnabled = NO;
		_containsValidProxyString = NO;
		[self setup];
	}
	
	return self;
}

- (NSString *)windowNibName
{
	return @"BPPreferencesWindow";
}

- (void)setup
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	id proxyString = [defaults objectForKey:kBP_HOMEBREW_PROXY_KEY];
	
	if ([proxyString isKindOfClass:[NSString class]]) {
		_proxyString = [(NSString *)proxyString copy];
		
		if([_proxyString bp_containsValidURL]) {
			_containsValidProxyString = YES;
		}
	}
	_proxyEnabled = [defaults boolForKey:kBP_HOMEBREW_PROXY_ENABLE_KEY];
	
}

- (void)saveSettings
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:@(self.isProxyEnabled)
				 forKey:kBP_HOMEBREW_PROXY_ENABLE_KEY];
	
	if([self.proxyString bp_containsValidURL]) {
		[defaults setObject:self.proxyString
					 forKey:kBP_HOMEBREW_PROXY_ENABLE_KEY];
	}
	
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center postNotificationName:BPProxyEnabledDidChangeNotification
						  object:@(self.proxyEnabled)];
	if([self.proxyString bp_containsValidURL]) {
		[center postNotificationName:BPProxyStringDidChangeNotification
							  object:self.proxyString];
	}
	
	
}

#pragma mark - NSTextFieldDelegate

-(void)controlTextDidChange:(NSNotification *)aNotification
{
	self.containsValidProxyString = [self.proxyString bp_containsValidURL];
}

#pragma mark - IBActions

- (IBAction)save:(id)sender
{
	[self saveSettings];
	[self close];
}

@end
