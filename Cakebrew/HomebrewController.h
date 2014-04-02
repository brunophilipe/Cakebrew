//
//  HomebrewController.h
//  Cakebrew
//
//  Created by Vincent Saluzzo on 06/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HomebrewController : NSViewController<NSTableViewDataSource, NSTableViewDelegate> {
    IBOutlet NSWindow* HUDAbout;
    IBOutlet NSTableView* listOfApplicationAlreadyInstalled;
    NSArray* arrayOfApplicationInstalled;

    IBOutlet NSWindow* HUDMoreInfo;
    IBOutlet NSTextField* MoreInfoHUD_AppTitle;
    IBOutlet NSTextView* MoreInfoHUD_AppInfo;


    IBOutlet NSToolbar* MainToolbar;
    IBOutlet NSToolbarItem* MainToolbarItem_MoreInfo;
    IBOutlet NSToolbarItem* MainToolbarItem_Uninstall;
    IBOutlet NSToolbarItem* MainToolbarItem_About;

    IBOutlet NSPopover* popoverAbout;
    IBOutlet NSPopover* popoverMoreInfo;
}

-(IBAction) refreshListOfApplicationAlreadyInstalled:(id)sender;
-(IBAction) showHUDAbout:(id)sender;
-(IBAction) showHUDMoreInfo:(id)sender;
-(IBAction) uninstall:(id)sender;
@end
