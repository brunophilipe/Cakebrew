//
//	HomebrewController.m
//	Cakebrew – The Homebrew GUI App for OS X 
//
//	Created by Vincent Saluzzo on 06/12/11.
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

#import "BPHomebrewController.h"
#import "BPFormula.h"
#import "BPHomebrewManager.h"
#import "BPHomebrewInterface.h"
#import "Frameworks/PXSourceList.framework/Headers/PXSourceList.h"

@interface BPHomebrewController () <NSTableViewDataSource, NSTableViewDelegate, PXSourceListDataSource, PXSourceListDelegate, BPHomebrewManagerDelegate>

@property (strong, readonly) PXSourceListItem *rootSidebarCategory;

@property NSArray *formulasArray;

@end

@implementation BPHomebrewController
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
	}
	return self;
}

- (void)displayInformationForFormula:(BPFormula*)formula
{
	if (formula) {
		if (formula.isInstalled) {
			[self.label_formulaPath setStringValue:formula.installPath];
		} else {
			[self.label_formulaPath setStringValue:@"Formula Not Installed"];
		}

		[self.label_formulaVersion setStringValue:formula.latestVersion];

		if (formula.dependencies) {
			[self.label_formulaDependencies setStringValue:formula.dependencies];
		} else {
			[self.label_formulaDependencies setStringValue:@"This formula has no dependencies!"];
		}
	} else {
		[self.label_formulaPath setStringValue:@"--"];
		[self.label_formulaVersion setStringValue:@"--"];
		[self.label_formulaDependencies setStringValue:@"--"];
	}
}

#pragma mark - Homebrew Manager Delegate

- (void)homebrewManagerFinishedUpdating:(BPHomebrewManager *)manager
{
	[self buildSidebarTree];
	[self.outlineView_sidebar reloadData];
}

- (void)buildSidebarTree
{
	NSArray *categoriesTitles = @[@"Installed", @"Outdated", @"All Formulas", @"Leaves"];
	NSArray *categoriesIcons = @[@"installedTemplate", @"outdatedTemplate", @"allFormulasTemplate", @"pinTemplate"];
	NSArray *categoriesValues = @[[NSNumber numberWithInteger:[[[BPHomebrewManager sharedManager] formulas_installed] count]],
								  [NSNumber numberWithInteger:[[[BPHomebrewManager sharedManager] formulas_outdated] count]],
								  [NSNumber numberWithInteger:[[[BPHomebrewManager sharedManager] formulas_all] count]],
								  [NSNumber numberWithInteger:[[[BPHomebrewManager sharedManager] formulas_leaves] count]]];

	PXSourceListItem *item, *parent;
	_rootSidebarCategory = [PXSourceListItem itemWithTitle:@"" identifier:@"root"];

	parent = [PXSourceListItem itemWithTitle:@"Formulas" identifier:@"group"];
	[_rootSidebarCategory addChildItem:parent];

	for (NSUInteger i=0; i<4; i++) {
		item = [PXSourceListItem itemWithTitle:[categoriesTitles objectAtIndex:i] identifier:@"item"];
		[item setBadgeValue:[categoriesValues objectAtIndex:i]];
		[item setIcon:[NSImage imageNamed:[categoriesIcons objectAtIndex:i]]];
		[parent addChildItem:item];
	}

	parent = [PXSourceListItem itemWithTitle:@"Tools" identifier:@"group"];
	[_rootSidebarCategory addChildItem:parent];

	item = [PXSourceListItem itemWithTitle:@"Doctor" identifier:@"item"];
	[item setBadgeValue:@-1];
	[item setIcon:[NSImage imageNamed:@"wrenchTemplate"]];
	[parent addChildItem:item];

	item = [PXSourceListItem itemWithTitle:@"Update" identifier:@"item"];
	[item setBadgeValue:@-2];
	[item setIcon:[NSImage imageNamed:@"downloadTemplate"]];
	[parent addChildItem:item];

	[self displayInformationForFormula:nil];
}

#pragma mark - Getters and Setters

- (void)setSplitView:(DMSplitView *)splitView
{
	_splitView = splitView;
	[_splitView setMinSize:150.f ofSubviewAtIndex:0];
	[_splitView setMinSize:400.f ofSubviewAtIndex:1];
	[_splitView setDividerColor:kBPSidebarDividerColor];
	[_splitView setDividerThickness:0];
}

- (DMSplitView*)splitView
{
	return _splitView;
}

- (void)setOutlineView_sidebar:(NSOutlineView *)outlineView_sidebar
{
	_outlineView_sidebar = outlineView_sidebar;

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
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
        } else if ([columnIdentifer isEqualToString:@"Version"]) {
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

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
	NSUInteger selectedIndex = [self.tableView_formulas selectedRow];
    if(selectedIndex == -1) {
		[self.toolbarButton_installUninstall setEnabled:NO];
		[self.toolbarButton_formulaInfo setEnabled:NO];
    } else {
		[self.toolbarButton_installUninstall setEnabled:YES];
		[self.toolbarButton_formulaInfo setEnabled:YES];
		BPFormula *formula = [_formulasArray objectAtIndex:selectedIndex];

		switch ([[BPHomebrewManager sharedManager] statusForFormula:formula]) {
			case kBP_FORMULA_INSTALLED:
				[self.toolbarButton_installUninstall setImage:[NSImage imageNamed:@"delete.icns"]];
				[self.toolbarButton_installUninstall setLabel:@"Uninstall Formula"];
				break;

			case kBP_FORMULA_OUTDATED:
				[self.toolbarButton_installUninstall setImage:[NSImage imageNamed:@"reload.icns"]];
				[self.toolbarButton_installUninstall setLabel:@"Update Formula"];
				break;

			case kBP_FORMULA_NOT_INSTALLED:
				[self.toolbarButton_installUninstall setImage:[NSImage imageNamed:@"download.icns"]];
				[self.toolbarButton_installUninstall setLabel:@"Install Formula"];
				break;
		}

		[formula getInformation];
		[self displayInformationForFormula:formula];
    }
}

#pragma mark - PXSourceList Data Source

- (NSUInteger)sourceList:(PXSourceList*)sourceList numberOfChildrenOfItem:(id)item
{
	if (!item) { //Is root
		return [[_rootSidebarCategory children] count];
	} else {
		return [[(PXSourceListItem*)item children] count];
	}
}

- (id)sourceList:(PXSourceList*)aSourceList child:(NSUInteger)index ofItem:(id)item
{
	if (!item) {
		return [[_rootSidebarCategory children] objectAtIndex:index];
	} else {
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

- (BOOL)sourceList:(PXSourceList *)aSourceList isGroupAlwaysExpanded:(id)group
{
    return YES;
}

- (NSView *)sourceList:(PXSourceList *)aSourceList viewForItem:(id)item
{
	PXSourceListTableCellView *cellView = nil;
	
    if ([[(PXSourceListItem*)item identifier] isEqualToString:@"group"])
        cellView = [aSourceList makeViewWithIdentifier:@"HeaderCell" owner:nil];
    else
        cellView = [aSourceList makeViewWithIdentifier:@"MainCell" owner:nil];

    PXSourceListItem *sourceListItem = item;
    cellView.textField.stringValue = sourceListItem.title;

	if (sourceListItem.badgeValue.integerValue >= 0)
	{
		cellView.badgeView.badgeValue = sourceListItem.badgeValue.integerValue;
	}
	else
	{
		if (sourceListItem.badgeValue.integerValue == -2)
			[cellView.badgeView setBadgeText:@"!"];
		else
			[cellView.badgeView setHidden:YES];
	}

	if (sourceListItem.icon)
		[cellView.imageView setImage:sourceListItem.icon];

	[cellView.badgeView calcSize];

    return cellView;
}

- (void)sourceListSelectionDidChange:(NSNotification *)notification
{
	NSString *message;
	NSUInteger tabIndex = 0;

	switch ([self.outlineView_sidebar selectedRow]) {
		case 1: // Installed Formulas
			_formulasArray = [[BPHomebrewManager sharedManager] formulas_installed];
			[[self.tableView_formulas tableColumnWithIdentifier:@"Version"] setHidden:NO];
			message = @"These are the formulas already installed in your system.";
			break;

		case 2: // Upgradeable Formulas
			_formulasArray = [[BPHomebrewManager sharedManager] formulas_outdated];
			[[self.tableView_formulas tableColumnWithIdentifier:@"Version"] setHidden:NO];
			message = @"These formulas are already installed, but have an update available.";
			break;

		case 3: // All Formulas
			_formulasArray = [[BPHomebrewManager sharedManager] formulas_all];
			[[self.tableView_formulas tableColumnWithIdentifier:@"Version"] setHidden:YES];
			message = @"These are all the formulas available for instalation with Homebrew.";
			break;

		case 4:	// Leaves
			_formulasArray = [[BPHomebrewManager sharedManager] formulas_leaves];
			[[self.tableView_formulas tableColumnWithIdentifier:@"Version"] setHidden:YES];
			message = @"These formulas are not dependencies of any other formulas.";
			break;

		case 6: // Doctor
			message = @"The doctor is a Homebrew feature that detects the most common causes of errors.";
			tabIndex = 1;
			break;

		case 7: // Update Tool
			message = @"Updating Homebrew means fetching the latest info about the available formulas.";
			tabIndex = 2;
			break;

		default:
			break;
	}

	if (message) [self.label_formulasCount setStringValue:message];
	if (tabIndex == 1) {
		[self.tableView_formulas deselectAll:nil];
		[self.tableView_formulas reloadData];
	}
	[self.tabView selectTabViewItemAtIndex:tabIndex];
}

#pragma mark - IBActions

- (IBAction)refreshListOfApplicationAlreadyInstalled:(id)sender {
}

- (IBAction)showHUDAbout:(id)sender {

}

- (IBAction)showFormulaInfo:(id)sender {
    /*if([self.tableView_formulas selectedRow] != -1) {
		NSToolbarItem *toolbarItem = sender;

        NSString* appName = [self.formulasArray objectAtIndex:[self.tableView_formulas selectedRow]];
        NSString* appInfo = [BrewInterface info:appName];
		//	    [MoreInfoHUD_AppInfo setStringValue:[appInfo retain]];
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

- (IBAction)installOrUninstall:(id)sender {
	NSInteger selectedIndex = [self.tableView_formulas selectedRow];

	if (selectedIndex >= 0) {
		BPFormula *formula = [_formulasArray objectAtIndex:selectedIndex];
		NSString *message;
		void (^operationBlock)(void);

		switch ([[BPHomebrewManager sharedManager] statusForFormula:formula]) {
			case kBP_FORMULA_INSTALLED:
			{
				message = @"Are you sure you want to uninstall the formula '%@'?";
				operationBlock = ^{
					[BPHomebrewInterface uninstallFormula:formula.name];
				};
			}
				break;

			case kBP_FORMULA_NOT_INSTALLED:
			{
				message = @"Are you sure you want to install the formula '%@'?";
				operationBlock = ^{
					[BPHomebrewInterface installFormula:formula.name];
				};
			}
				break;

			case kBP_FORMULA_OUTDATED:
			{
				message = nil;
				operationBlock = ^{
					[BPHomebrewInterface uninstallFormula:formula.name];
				};
			}
				break;
		}

		if (message) {
			NSAlert *alert = [NSAlert alertWithMessageText:@"Attention!" defaultButton:@"Yes" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:message, formula.name];
			[alert.window setTitle:@"Cakebrew"];
			if ([alert runModal] == NSAlertDefaultReturn) {
				operationBlock();
			}
		} else {
			operationBlock();
		}
	}
}

- (IBAction)updateHomebrew:(id)sender
{
//	[self.tableView_formulas show]
}

- (IBAction)openSelectedFormulaWebsite:(id)sender {
}

@end
