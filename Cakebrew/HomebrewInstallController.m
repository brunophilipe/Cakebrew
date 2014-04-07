//
//	HomebrewInstallController.m
//	Cakebrew – The Homebrew GUI App for OS X 
//
//	Created by Vincent Saluzzo on 08/12/11.
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

#import "HomebrewInstallController.h"
#import "BPHomebrewInterface.h"
@implementation HomebrewInstallController

- (IBAction) showInstallWindow:(id)sender {

    arrayOfApplicationToInstall = [BPHomebrewInterface searchForFormulaName:@""];

    if(self.view.window.isVisible) {
        [self.view.window orderBack:sender];
    } else {
        [self.view.window orderFront:sender];
    }

    [listOfApplicationToInstall reloadData];
}

- (IBAction) install:(id)sender {
    if([listOfApplicationToInstall selectedRow] != -1) {
        [BPHomebrewInterface installFormula:[arrayOfApplicationToInstall objectAtIndex:[listOfApplicationToInstall selectedRow]]];
    }
}

#pragma mark - NSTableView DataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {

    //	  NSLog(@"%lu", );
    if(arrayOfApplicationToInstall) {
        return [arrayOfApplicationToInstall count];
    } else return 0;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    // the return value is typed as (id) because it will return a string in all cases with the exception of the
    if(arrayOfApplicationToInstall) {
        id returnValue=nil;

        // The column identifier string is the easiest way to identify a table column. Much easier
        // than keeping a reference to the table column object.
        NSString *columnIdentifer = [tableColumn identifier];
        //NSLog(@"%@", columnIdentifer);
        // Get the name at the specified row in the namesArray
        NSString *theName = [arrayOfApplicationToInstall objectAtIndex:row];


        // Compare each column identifier and set the return value to
        // the Person field value appropriate for the column.
        if ([columnIdentifer isEqualToString:@"App Name"]) {
            returnValue = theName;
            //NSLog(@"kaka");
        }

        return returnValue;
    } else return nil;
}

#pragma mark - NSTableView Delegate
- (void) tableViewSelectionDidChange:(NSNotification *)notification {
    if([listOfApplicationToInstall selectedRow] == -1) {
        [InstallToolbarItem_Install setAction:nil];
    } else {
        [InstallToolbarItem_Install setAction:@selector(install:)];
    }
}

@end
