//
//  BPCustomBrewPathWindow.h
//  Cakebrew
//
//  Created by Bruno Philipe on 4/29/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BPCustomBrewPathWindow : NSWindow

@property (strong) IBOutlet NSTextField *textField_brewPath;
@property (strong) IBOutlet NSImageView *imageView_invalidPath;

@property (assign) NSWindow *sheetParent;

// Must be called in order to setup content
- (void)didBecomeVisible;

- (IBAction)showInformation:(id)sender;
- (IBAction)storeCustomBrewPath:(id)sender;
- (IBAction)cancel:(id)sender;

@end
