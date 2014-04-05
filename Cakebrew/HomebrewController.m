//
//  HomebrewController.m
//  Cakebrew
//
//  Created by Vincent Saluzzo on 06/12/11.
//  Copyright (c) 2011 Bruno Philipe. All rights reserved.
//

#import "HomebrewController.h"
#import "BPFormula.h"
#import "BPHomebrewManager.h"
#import "Frameworks/PXSourceList.framework/Headers/PXSourceList.h"

@interface HomebrewController () <NSTableViewDataSource, NSTableViewDelegate, PXSourceListDataSource, PXSourceListDelegate, BPHomebrewManagerDelegate>

@property (strong, readonly) PXSourceListItem *rootSidebarCategory;

@property NSArray *formulasArray;

@end

@implementation HomebrewController
{
	NSOutlineView *_outlineView_sidebar;
	DMSplitView *_splitView;
	BPHomebrewManager *_homebrewManager;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		_homebrewManager = [BPHomebrewManager sharedManager];
		[_homebrewManager setDelegate:self];
		[self refreshListOfApplicationAlreadyInstalled:nil];
		[self buildSidebarTree];
	}
	return self;
}

#pragma mark - Homebrew Manager Delegate

- (void)homebrewManagerFinishedUpdating:(BPHomebrewManager *)manager
{
//	[self buildSidebarTree];
	[self.outlineView_sidebar reloadData];
}

- (void)buildSidebarTree
{
	NSArray *categoriesTitles = @[@"Installed", @"Outdated", @"All Formulas", @"Leaves"];
	NSArray *categoriesValues = @[[NSNumber numberWithInteger:[[[BPHomebrewManager sharedManager] formulas_installed] count]],
								  [NSNumber numberWithInteger:[[[BPHomebrewManager sharedManager] formulas_outdated] count]],
								  [NSNumber numberWithInteger:[[[BPHomebrewManager sharedManager] formulas_all] count]],
								  [NSNumber numberWithInteger:[[[BPHomebrewManager sharedManager] formulas_leaves] count]]];

	PXSourceListItem *item;
	_rootSidebarCategory = [PXSourceListItem itemWithTitle:@"" identifier:@"root"];

	item = [PXSourceListItem itemWithTitle:@"Formulas" identifier:@"group"];
	[_rootSidebarCategory addChildItem:item];

	PXSourceListItem *aux;
	for (NSUInteger i=0; i<4; i++) {
		aux = [PXSourceListItem itemWithTitle:[categoriesTitles objectAtIndex:i] identifier:@"item"];
		[aux setBadgeValue:[categoriesValues objectAtIndex:i]];
		[_rootSidebarCategory addChildItem:aux];
	}

	item = [PXSourceListItem itemWithTitle:@"Tools" identifier:@"group"];
	[_rootSidebarCategory addChildItem:item];

	item = [PXSourceListItem itemWithTitle:@"Doctor" identifier:@"item"];
	[_rootSidebarCategory addChildItem:item];
}

#pragma mark - Getters and Setters

- (void)setSplitView:(DMSplitView *)splitView
{
	_splitView = splitView;
	[_splitView setMinSize:150.f ofSubviewAtIndex:0];
	[_splitView setMinSize:400.f ofSubviewAtIndex:1];
	[_splitView setDividerColor:kBPSidebarDividerColor];
}

- (DMSplitView*)splitView
{
	return _splitView;
}

- (void)setOutlineView_sidebar:(NSOutlineView *)outlineView_sidebar
{
	_outlineView_sidebar = outlineView_sidebar;

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[_outlineView_sidebar selectRowIndexes:[NSIndexSet indexSetWithIndex:1] byExtendingSelection:NO];
	});
}

- (NSOutlineView*)outlineView_sidebar
{
	return _outlineView_sidebar;
}

#pragma mark - NSTableView DataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [self.formulasArray count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    // the return value is typed as (id) because it will return a string in all cases with the exception of the
    if(self.formulasArray) {
        NSString *columnIdentifer = [tableColumn identifier];
        id element = [self.formulasArray objectAtIndex:row];

        // Compare each column identifier and set the return value to
        // the Person field value appropriate for the column.
        if ([columnIdentifer isEqualToString:@"Name"]) {
			if ([element isKindOfClass:[BPFormula class]]) {
				return [(BPFormula*)element name];
			} else {
				return element;
			}
        } else if ([columnIdentifer isEqualToString:@"Description"]) {
			if ([element isKindOfClass:[BPFormula class]]) {
				return [(BPFormula*)element version];
			} else {
				return element;
			}
		}
    }

	return @"";
}

#pragma mark - NSTableView Delegate

/*
- (NSView*) tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {

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
- (NSTableRowView*) tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
    return [tableView rowViewAtRow:row makeIfNecessary:YES];
}
 */

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    if([self.tableView_formulas selectedRow] == -1) {
        [self.MainToolbarItem_MoreInfo setAction:nil];
        [self.MainToolbarItem_Uninstall setAction:nil];
    } else {
        [self.MainToolbarItem_MoreInfo setAction:@selector(showHUDMoreInfo:)];
        [self.MainToolbarItem_Uninstall setAction:@selector(uninstall:)];
    }
}

#pragma mark - PXSourceList Data Source

- (NSUInteger)sourceList:(PXSourceList*)sourceList numberOfChildrenOfItem:(id)item
{
	if (!_rootSidebarCategory) {
		[self buildSidebarTree];
	}

	if (!item) { //Is root
		return [[_rootSidebarCategory children] count];
	} else {
		return [[(PXSourceListItem*)item children] count];
	}
}

- (id)sourceList:(PXSourceList*)aSourceList child:(NSUInteger)index ofItem:(id)item
{
	if (!item) {
		NSLog(@"%@",[[_rootSidebarCategory children] objectAtIndex:index]);
		return [[_rootSidebarCategory children] objectAtIndex:index];
	} else {
		NSLog(@"%@", [[(PXSourceListItem*)item children] objectAtIndex:index]);
		return [[(PXSourceListItem*)item children] objectAtIndex:index];
	}
}

- (BOOL)sourceList:(PXSourceList*)aSourceList isItemExpandable:(id)item
{
	if (!item) {
		return YES;
	} else {
		return [item hasChildren];
	}
}

#pragma mark - PXSourceList Delegate

- (NSView *)sourceList:(PXSourceList *)aSourceList viewForItem:(id)item
{
	PXSourceListTableCellView *cellView = nil;
    if ([[(PXSourceListItem*)item identifier] isEqualToString:@"group"])
        cellView = [aSourceList makeViewWithIdentifier:@"HeaderCell" owner:nil];
    else
        cellView = [aSourceList makeViewWithIdentifier:@"DataCell" owner:nil];

    PXSourceListItem *sourceListItem = item;

    cellView.textField.stringValue = sourceListItem.title;
    cellView.badgeView.badgeValue = sourceListItem.badgeValue.integerValue;

    return cellView;
}

#pragma mark - Outline View Data Source
/*
- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
	if (!_rootSidebarCategory) {
		[self buildSidebarTree];
	}

	if (!item) { //Is root
		return [[_rootSidebarCategory children] count];
	} else {
		return [[(PXSourceListItem*)item children] count];
	}
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
	if (!item) {
		return [[_rootSidebarCategory children] objectAtIndex:index];
	} else {
		return [[(PXSourceListItem*)item children] objectAtIndex:index];
	}
}

- (id)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
	NSTableCellView *view = nil;
	if (!item) {
		view = [outlineView makeViewWithIdentifier:@"item_view" owner:self];
	} else {
		if ([(PXSourceListItem*)item isLabel]) {
			view = [outlineView makeViewWithIdentifier:@"item_view" owner:self];
			[view.textField setStringValue:[[(PXSourceListItem*)item title] uppercaseString]];
		} else {
			if ([tableColumn.identifier isEqualToString:@"title"]) {
				view = [outlineView makeViewWithIdentifier:@"item_view" owner:self];
				[view.textField setStringValue:[(PXSourceListItem*)item title]];
			} else if (![[(PXSourceListItem*)item title] isEqualToString:@"Doctor"]) {
				view = [outlineView makeViewWithIdentifier:@"detail_view" owner:self];
				[view.textField setIntegerValue:[[(PXSourceListItem*)item value] integerValue]];
				[view.textField calcSize];
				[view.textField sizeToFit];
			} else {
				return nil;
			}
		}
	}

	return view;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
	if (!item) {
		return YES;
	} else {
		return [item hasChildren];
	}
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
	return (item && ![(PXSourceListItem*)item isLabel]);
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item
{
	return (item && [(PXSourceListItem*)item isLabel]);
}

- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item
{
	return 22;
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
	switch ([self.outlineView_sidebar selectedRow]) {
		case 1: // Installed Formulas
			_formulasArray = [[BPHomebrewManager sharedManager] formulas_installed];
			break;

		case 2: // Upgradeable Formulas
			_formulasArray = [[BPHomebrewManager sharedManager] formulas_upgradeable];
			break;

		case 3: // All Formulas
			_formulasArray = [[BPHomebrewManager sharedManager] formulas_all];
			break;

		case 4:	// Leaves
			_formulasArray = [[BPHomebrewManager sharedManager] formulas_leaves];
			break;

		case 6: // Doctor

			break;

		default:
			break;
	}

	[self.tableView_formulas reloadData];
}
*/
#pragma mark - IBActions

- (IBAction)refreshListOfApplicationAlreadyInstalled:(id)sender {
}

- (IBAction)showHUDAbout:(id)sender {
    /*
     if([HUDAbout isVisible]) {
	 [HUDAbout orderOut:self];
	 //NSLog(@"isVisible :=> GoBack");
	 } else {
	 [HUDAbout orderFront:self];
	 //NSLog(@"isNotVisible :=> GoFront");
	 }
	 */

    if([self.popoverAbout isShown]) {
        [self.popoverAbout close];
    } else {
        [self.popoverAbout showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMaxXEdge];
    }
}

- (IBAction)showHUDMoreInfo:(id)sender {
    /*if([self.tableView_formulas selectedRow] != -1) {
		NSToolbarItem *toolbarItem = sender;

        NSString* appName = [self.formulasArray objectAtIndex:[self.tableView_formulas selectedRow]];
        NSString* appInfo = [BrewInterface info:appName];
		//      [MoreInfoHUD_AppInfo setStringValue:[appInfo retain]];
        [self.MoreInfoHUD_AppInfo.textContainer.textView setString:appInfo];
        [self.MoreInfoHUD_AppTitle setStringValue:[NSString stringWithFormat:@"More information on %@",appName]];
        [self.MoreInfoHUD_AppInfo.textContainer.textView setTextColor:[NSColor whiteColor]];

        / *
		 if([HUDMoreInfo isVisible]) {
		 [HUDMoreInfo orderOut:self];
		 //NSLog(@"isVisible :=> GoBack");
		 } else {
		 [HUDMoreInfo orderFront:self];
		 //NSLog(@"isNotVisible :=> GoFront");
		 }
         * /
        if([self.popoverMoreInfo isShown]) {
            [self.popoverMoreInfo close];
        } else {
            [self.popoverMoreInfo showRelativeToRect:[toolbarItem.view frame] ofView:toolbarItem.view preferredEdge:NSMaxYEdge];
        }

    }*/
}

- (IBAction)uninstall:(id)sender {
	/*
    if([self.tableView_formulas selectedRow] != -1) {
        NSString* resultOfUninstall = [BrewInterface uninstall:[self.formulasArray objectAtIndex:[self.tableView_formulas selectedRow]]];

        NSAlert* alert = [NSAlert alertWithMessageText:resultOfUninstall defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
        [alert runModal];
        [self performSelector:@selector(refreshListOfApplicationAlreadyInstalled:)];
    }
	 */
}

@end
