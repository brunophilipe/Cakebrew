//
//  AppDelegate.h
//  Cakebrew
//
//  Created by Vincent Saluzzo on 06/12/11.
//  Copyright (c) 2011 Bruno Philipe. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BPAppDelegate : NSObject <NSApplicationDelegate>

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *aboutDesc;

- (NSURL*)urlForApplicationSupportFolder;
- (NSURL*)urlForApplicationCachesFolder;

@end
