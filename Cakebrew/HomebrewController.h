//
//  HomebrewController.h
//  Cakebrew
//
//  Created by Vincent Saluzzo on 06/12/11.
//  Copyright (c) 2011 Bruno Philipe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMSplitView.h"

@class DMSplitView;

@interface HomebrewController : NSViewController

@property IBOutlet NSWindow *HUDAbout;
@property IBOutlet NSWindow *HUDMoreInfo;

@property IBOutlet NSTableView *tableView_formulas;
@property IBOutlet NSOutlineView *outlineView_sidebar;
@property IBOutlet NSTextField *MoreInfoHUD_AppTitle;
@property IBOutlet NSTextView *MoreInfoHUD_AppInfo;
@property IBOutlet NSToolbar *MainToolbar;
@property IBOutlet NSPopover *popoverAbout;
@property IBOutlet NSPopover *popoverMoreInfo;
@property IBOutlet DMSplitView *splitView;

@property IBOutlet NSToolbarItem *MainToolbarItem_MoreInfo;
@property IBOutlet NSToolbarItem *MainToolbarItem_Uninstall;
@property IBOutlet NSToolbarItem *MainToolbarItem_About;

- (IBAction)refreshListOfApplicationAlreadyInstalled:(id)sender;
- (IBAction)showHUDAbout:(id)sender;
- (IBAction)showHUDMoreInfo:(id)sender;
- (IBAction)uninstall:(id)sender;

@end
