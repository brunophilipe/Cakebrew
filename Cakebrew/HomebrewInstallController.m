//
//  HomebrewInstallController.m
//  Cakebrew
//
//  Created by Vincent Saluzzo on 08/12/11.
//  Copyright (c) 2011 Bruno Philipe. All rights reserved.
//

#import "HomebrewInstallController.h"
#import "BrewInterface.h"
@implementation HomebrewInstallController

-(IBAction) showInstallWindow:(id)sender {

    arrayOfApplicationToInstall = [[BrewInterface search:@""] retain];

    if(self.view.window.isVisible) {
        [self.view.window orderBack:sender];
    } else {
        [self.view.window orderFront:sender];
    }

    [listOfApplicationToInstall reloadData];
}

-(IBAction) install:(id)sender {
    if([listOfApplicationToInstall selectedRow] != -1) {
        [BrewInterface install:[arrayOfApplicationToInstall objectAtIndex:[listOfApplicationToInstall selectedRow]]];
    }
}

#pragma mark - NSTableView DataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {

    //    NSLog(@"%lu", );
    if(arrayOfApplicationToInstall) {
        return [arrayOfApplicationToInstall count];
    } else return 0;
}

-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
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
-(void) tableViewSelectionDidChange:(NSNotification *)notification {
    if([listOfApplicationToInstall selectedRow] == -1) {
        [InstallToolbarItem_Install setAction:nil];
    } else {
        [InstallToolbarItem_Install setAction:@selector(install:)];
    }
}

@end
