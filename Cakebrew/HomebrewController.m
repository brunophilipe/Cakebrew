//
//  HomebrewController.m
//  Cakebrew
//
//  Created by Vincent Saluzzo on 06/12/11.
//  Copyright (c) 2011 Bruno Philipe. All rights reserved.
//

#import "HomebrewController.h"
#import "BrewInterface.h"
@implementation HomebrewController


-(IBAction)refreshListOfApplicationAlreadyInstalled:(id)sender {

    if(arrayOfApplicationInstalled) {
        [arrayOfApplicationInstalled release];
    }

    arrayOfApplicationInstalled = [[BrewInterface list] retain];

    [listOfApplicationAlreadyInstalled reloadData];
}

-(IBAction)showHUDAbout:(id)sender {
    /*
     if([HUDAbout isVisible]) {
        [HUDAbout orderOut:self];
        //NSLog(@"isVisible : => GoBack");
    } else {
        [HUDAbout orderFront:self];
        //NSLog(@"isNotVisible : => GoFront");
    }
    */

    if([popoverAbout isShown]) {
        [popoverAbout close];
    } else {
        [popoverAbout showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMaxXEdge];
    }
}

-(IBAction)showHUDMoreInfo:(id)sender {
    if([listOfApplicationAlreadyInstalled selectedRow] != -1) {

        NSString* appName = [arrayOfApplicationInstalled objectAtIndex:[listOfApplicationAlreadyInstalled selectedRow]];
        NSString* appInfo = [BrewInterface info:appName];
//      [MoreInfoHUD_AppInfo setStringValue:[appInfo retain]];
        [MoreInfoHUD_AppInfo.textContainer.textView setString:[appInfo retain]];
        [MoreInfoHUD_AppTitle setStringValue:[NSString stringWithFormat:@"More information on %@",[appName retain]]];
        [MoreInfoHUD_AppInfo.textContainer.textView setTextColor:[NSColor whiteColor]];

        /*
        if([HUDMoreInfo isVisible]) {
            [HUDMoreInfo orderOut:self];
            //NSLog(@"isVisible : => GoBack");
        } else {
            [HUDMoreInfo orderFront:self];
            //NSLog(@"isNotVisible : => GoFront");
        }
         */
        if([popoverMoreInfo isShown]) {
            [popoverMoreInfo close];
        } else {
            [popoverMoreInfo showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMaxYEdge];
        }

    }
}

-(IBAction)uninstall:(id)sender {
    if([listOfApplicationAlreadyInstalled selectedRow] != -1) {
        NSString* resultOfUninstall = [[BrewInterface uninstall:[arrayOfApplicationInstalled objectAtIndex:[listOfApplicationAlreadyInstalled selectedRow]]] retain];

        NSAlert* alert = [NSAlert alertWithMessageText:resultOfUninstall defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
        [alert runModal];
        [self performSelector:@selector(refreshListOfApplicationAlreadyInstalled:)];
    }
}

#pragma mark - NSTableView DataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {

//    NSLog(@"%lu", );
    if(arrayOfApplicationInstalled) {
        return [arrayOfApplicationInstalled count];
    } else return 0;
}

-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    // the return value is typed as (id) because it will return a string in all cases with the exception of the
    if(arrayOfApplicationInstalled) {
        id returnValue=nil;

        // The column identifier string is the easiest way to identify a table column. Much easier
        // than keeping a reference to the table column object.
        NSString *columnIdentifer = [tableColumn identifier];
        //NSLog(@"%@", columnIdentifer);
        // Get the name at the specified row in the namesArray
        NSString *theName = [arrayOfApplicationInstalled objectAtIndex:row];


        // Compare each column identifier and set the return value to
        // the Person field value appropriate for the column.
        if ([columnIdentifer isEqualToString:@"Name"]) {
            returnValue = theName;
        } else if ([columnIdentifer isEqualToString:@"Description"]) {
            returnValue = theName;
        } else if ([columnIdentifer isEqualToString:@"Delete"]) {
            returnValue = [NSImage imageNamed:NSImageNameStopProgressTemplate];
        }


        return returnValue;
    } else {
		return @"";
	}
}

#pragma mark - NSTableView Delegate
/*
-(NSView*) tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {

    NSTableCellView* cell = [tableView makeViewWithIdentifier:[tableColumn.identifier stringByAppendingFormat:@"_row_%d",row] owner:self];
    if(!cell) {
        if([[tableColumn.headerCell stringValue] isEqualToString:@"Name"]) {
            cell = [[[NSTextField alloc] init] autorelease];
            cell.identifier = [tableColumn.identifier stringByAppendingFormat:@"_row_%d",row];
            [(NSTextField*)cell setBordered:NO];
            [(NSTextField*)cell setEditable:NO];

        } else if([[tableColumn.headerCell stringValue] isEqualToString:@"Description"]) {
            cell = [[[NSTextField alloc] init] autorelease];
            cell.identifier = [tableColumn.identifier stringByAppendingFormat:@"_row_%d",row];
            [(NSTextField*)cell setBordered:NO];
            [(NSTextField*)cell setEditable:NO];
        } else if([[tableColumn.headerCell stringValue] isEqualToString:@"Delete"]) {
            cell = [[[NSButton alloc] init] autorelease];
            cell.identifier = [tableColumn.identifier stringByAppendingFormat:@"_row_%d",row];

        }
    }


    NSLog(@"kaka %@", tableColumn.identifier);
    if([[tableColumn.headerCell stringValue] isEqualToString:@"Name"]) {
        cell.textField.stringValue = [[BrewInterface list] objectAtIndex:row];
        //((NSTextField*)cell).stringValue = [[BrewInterface list] objectAtIndex:row];
    } else if([[tableColumn.headerCell stringValue] isEqualToString:@"Description"]) {
        cell.textField.stringValue = [[NSString alloc] initWithFormat:@"aaa"];
    } else if([[tableColumn.headerCell stringValue] isEqualToString:@"Delete"]) {
        //((NSButton*)cell).title = @"Delete";
        //cell.
    }

    return cell;
}*/
/*
-(NSTableRowView*) tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
    return [tableView rowViewAtRow:row makeIfNecessary:YES];
}
 */

-(void) tableViewSelectionDidChange:(NSNotification *)notification {
    if([listOfApplicationAlreadyInstalled selectedRow] == -1) {
        [MainToolbarItem_MoreInfo setAction:nil];
        [MainToolbarItem_Uninstall setAction:nil];
    } else {
        [MainToolbarItem_MoreInfo setAction:@selector(showHUDMoreInfo:)];
        [MainToolbarItem_Uninstall setAction:@selector(uninstall:)];
    }
}
@end
