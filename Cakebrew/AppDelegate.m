//
//  AppDelegate.m
//  Cakebrew
//
//  Created by Vincent Saluzzo on 06/12/11.
//  Copyright (c) 2011 Bruno Philipe. All rights reserved.
//

#import "AppDelegate.h"
#import "BrewInterface.h"
@implementation AppDelegate

@synthesize window = _window;
@synthesize AboutDesc;
- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [AboutDesc setStringValue:@"Homebrew is a UNIX package manager for OS X like MacPorts (OS X), Yum (Fedora), Apt (Ubuntu/Debian), etc.\nHomebrew GUI is a user interface for Homebrew command-line tool, to simplify its use (and also for person who detest command-line ;) )"];
}

@end
