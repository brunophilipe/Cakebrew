//
//  HomebrewInstallController.h
//  HomebrewGUI
//
//  Created by Vincent Saluzzo on 08/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HomebrewInstallController : NSViewController<NSTableViewDataSource, NSTableViewDelegate, NSWindowDelegate> {
    IBOutlet NSTableView* listOfApplicationToInstall;
    
    IBOutlet NSToolbar* InstallToolbar;
    IBOutlet NSToolbarItem* InstallToolbarItem_Install;
    
    NSArray* arrayOfApplicationToInstall;
    
    IBOutlet NSWindow* window;
    
}
-(IBAction) showInstallWindow:(id)sender;
-(IBAction) install:(id)sender;
@end
