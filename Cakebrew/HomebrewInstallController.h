//
//  HomebrewInstallController.h
//  Cakebrew – The Homebrew GUI App for OS X 
//
//  Created by Vincent Saluzzo on 08/12/11.
//  Copyright (c) 2011 Bruno Philipe. All rights reserved.
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

#import <Foundation/Foundation.h>

@interface HomebrewInstallController :NSViewController <NSTableViewDataSource, NSTableViewDelegate, NSWindowDelegate, NSOutlineViewDataSource, NSOutlineViewDelegate> {
    IBOutlet NSTableView* listOfApplicationToInstall;

    IBOutlet NSToolbar* InstallToolbar;
    IBOutlet NSToolbarItem* InstallToolbarItem_Install;

    NSArray* arrayOfApplicationToInstall;

    IBOutlet NSWindow* window;

}
- (IBAction)showInstallWindow:(id)sender;
- (IBAction)install:(id)sender;
@end
