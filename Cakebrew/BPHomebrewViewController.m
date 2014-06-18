//
//	HomebrewController.m
//	Cakebrew – The Homebrew GUI App for OS X
//
//	Created by Vincent Saluzzo on 06/12/11.
//	Copyright (c) 2014 Bruno Philipe. All rights reserved.
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

#import "BPHomebrewViewController.h"
#import "BPFormula.h"
#import "BPHomebrewManager.h"
#import "BPHomebrewInterface.h"
#import "BPInstallationViewController.h"
#import "BPFormulaOptionsViewController.h"
#import "Frameworks/PXSourceList.framework/Headers/PXSourceList.h"

@interface BPHomebrewViewController () <NSTableViewDataSource, NSTableViewDelegate, PXSourceListDataSource, PXSourceListDelegate, BPHomebrewManagerDelegate, NSMenuDelegate>

@property (strong, readonly) PXSourceListItem *rootSidebarCategory;
@property (strong)           NSPopover        *formulaPopover;
@property (weak)			 BPAppDelegate	  *appDelegate;

@property NSArray   *formulaeArray;
@property NSInteger lastSelectedSidebarIndex;

@property BOOL isSearching;
@property BPWindowOperation toolbarButtonOperation;

@property NSWindow *alsoModalWindow;

@end

@implementation BPHomebrewViewController
{
	NSWindow					   *_operationWindow;
	NSWindow					   *_formulaOptionsWindow;
	NSOutlineView __weak		   *_outlineView_sidebar;
	NSTableView					   *_tableView_formulae;
	DMSplitView __weak			   *_splitView;
	BPHomebrewManager			   *_homebrewManager;
	BPInsetShadowView __weak	   *_view_disablerLock;
	BPInstallationViewController   *_operationViewController;
	BPFormulaOptionsViewController *_formulaOptionsViewController;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		_homebrewManager = [BPHomebrewManager sharedManager];
		[_homebrewManager setDelegate:self];

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lockWindow) name:kBP_NOTIFICATION_LOCK_WINDOW object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unlockWindow) name:kBP_NOTIFICATION_UNLOCK_WINDOW object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchUpdatedNotification:) name:kBP_NOTIFICATION_SEARCH_UPDATED object:nil];
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_homebrewManager setDelegate:nil];
}

- (void)displayInformationForFormula:(BPFormula*)formula
{
	static NSString *depString = @"Formula no longer available.";
	static NSString *emptyString = @"--";

	[self setCurrentFormula:formula];

	if (formula) {
		if (!formula.isDeprecated) {
			if (formula.isInstalled) {
				[self.label_formulaPath setStringValue:formula.installPath];
			} else {
				[self.label_formulaPath setStringValue:@"Formula Not Installed."];
			}

			[self.label_formulaVersion setStringValue:formula.latestVersion];

			if (formula.dependencies) {
				[self.label_formulaDependencies setStringValue:formula.dependencies];
			} else {
				[self.label_formulaDependencies setStringValue:@"This formula has no dependencies!"];
			}

			if (formula.conflicts) {
				[self.label_formulaConflicts setStringValue:formula.conflicts];
			} else {
				[self.label_formulaConflicts setStringValue:@"This formula has no known conflicts."];
			}
		} else {
			[self.label_formulaPath setStringValue:depString];
			[self.label_formulaDependencies setStringValue:emptyString];
			[self.label_formulaConflicts setStringValue:emptyString];
		}
	} else {
		[self.label_formulaPath setStringValue:emptyString];
		[self.label_formulaVersion setStringValue:emptyString];
		[self.label_formulaDependencies setStringValue:emptyString];
		[self.label_formulaConflicts setStringValue:emptyString];
	}
}

- (void)prepareFormula:(BPFormula*)formula forOperation:(BPWindowOperation)operation
{
    [self prepareFormula:formula forOperation:operation inWindow:_appDelegate.window alsoModal:NO];
}

- (void)prepareFormula:(BPFormula*)formula forOperation:(BPWindowOperation)operation inWindow:(NSWindow*)window alsoModal:(BOOL)alsoModal
{
	_operationViewController = [[BPInstallationViewController alloc] initWithNibName:@"BPInstallationViewController" bundle:nil];
	_operationWindow = [[NSWindow alloc] initWithContentRect:_operationViewController.view.frame styleMask:NSTitledWindowMask|NSResizableWindowMask backing:NSBackingStoreBuffered defer:NO];
	[_operationWindow setContentView:_operationViewController.view];
	[_operationViewController setWindow:_operationWindow];

	if (alsoModal) [_operationViewController setParentSheet:window];

	if (formula) {
		[_operationViewController setFormula:formula];
	} else {
		[_operationViewController setFormulae:[_formulaeArray copy]];
	}
	[_operationViewController setWindowOperation:operation];

    if ([window respondsToSelector:@selector(beginSheet:completionHandler:)]) {
        [window beginSheet:_operationWindow completionHandler:^(NSModalResponse returnCode) {
            _operationWindow = nil;
            _operationViewController = nil;
            if (alsoModal) {
                [_appDelegate.window endSheet:window];
            }
        }];
    } else {
        if (alsoModal)
        {
            _alsoModalWindow = window;
        }
        [[NSApplication sharedApplication] beginSheet:_operationWindow modalForWindow:window modalDelegate:self didEndSelector:@selector(windowOperationSheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
    }

	[_operationViewController windowDidAppear];
}

- (void)windowOperationSheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
{
    if (_alsoModalWindow) {
        [[NSApplication sharedApplication] endSheet:_alsoModalWindow];
        _alsoModalWindow = nil;
    }
    _operationWindow = nil;
    _operationViewController = nil;
	_formulaOptionsWindow = nil;
	_formulaOptionsViewController = nil;
}

- (void)lockWindow
{
	[self.view_disablerLock setHidden:NO];
	[self.label_information setHidden:YES];
	[self.toolbar.items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if ([obj respondsToSelector:@selector(setEnabled:)]) {
			[obj performSelector:@selector(setEnabled:) withObject:@NO];
		}
	}];

	NSAlert *alert = [NSAlert alertWithMessageText:@"Error!" defaultButton:@"Homebrew Website" alternateButton:@"OK" otherButton:nil informativeTextWithFormat:@"Homebrew was not found in your system. Please install Homebrew before using Cakebrew. You can click the button below to open Homebrew's website."];
	[alert.window setTitle:@"Cakebrew"];

    if ([alert respondsToSelector:@selector(beginSheet:completionHandler:)]) {
        [alert beginSheetModalForWindow:_appDelegate.window completionHandler:^(NSModalResponse returnCode) {
            if (returnCode == NSAlertDefaultReturn) {
                [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://brew.sh"]];
            }
        }];
    } else {
        [[NSApplication sharedApplication] beginSheet:alert.window modalForWindow:_appDelegate.window modalDelegate:self didEndSelector:@selector(openBrewWebsiteSheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
    }
}

- (void)openBrewWebsiteSheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
{
    if (returnCode == NSAlertDefaultReturn) {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://brew.sh"]];
    }
}

- (void)unlockWindow
{
	[self.view_disablerLock setHidden:YES];
	[self.label_information setHidden:NO];
	[self.toolbar.items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if ([obj respondsToSelector:@selector(setEnabled:)]) {
			[obj performSelector:@selector(setEnabled:) withObject:@YES];
		}
	}];

	[[BPHomebrewManager sharedManager] update];
}

- (void)updateInterfaceItems
{
	NSUInteger selectedTab = (NSUInteger)[self.outlineView_sidebar selectedRow];
	NSUInteger selectedIndex = (NSUInteger)[self.tableView_formulae selectedRow];
    if(selectedIndex == -1 || selectedTab > 4)
	{
		[self.toolbarButton_installUninstall setEnabled:NO];
		[self.toolbarButton_formulaInfo setEnabled:NO];
		[self displayInformationForFormula:nil];
    }
	else
	{
		BPFormula *formula = [_formulaeArray objectAtIndex:selectedIndex];

		[self.toolbarButton_installUninstall setEnabled:YES];
		[self.toolbarButton_formulaInfo setEnabled:YES];

		switch ([[BPHomebrewManager sharedManager] statusForFormula:formula]) {
			case kBPFormulaInstalled:
				[self.toolbarButton_installUninstall setImage:[NSImage imageNamed:@"delete.icns"]];
				[self.toolbarButton_installUninstall setLabel:@"Uninstall Formula"];
				[self setToolbarButtonOperation:kBPWindowOperationUninstall];
				break;

			case kBPFormulaOutdated:
				if ([self.outlineView_sidebar selectedRow] == 2) {
					[self.toolbarButton_installUninstall setImage:[NSImage imageNamed:@"reload.icns"]];
					[self.toolbarButton_installUninstall setLabel:@"Update Formula"];
					[self setToolbarButtonOperation:kBPWindowOperationUpgrade];
				} else {
					[self.toolbarButton_installUninstall setImage:[NSImage imageNamed:@"delete.icns"]];
					[self.toolbarButton_installUninstall setLabel:@"Uninstall Formula"];
					[self setToolbarButtonOperation:kBPWindowOperationUninstall];
				}
				break;

			case kBPFormulaNotInstalled:
				[self.toolbarButton_installUninstall setImage:[NSImage imageNamed:@"download.icns"]];
				[self.toolbarButton_installUninstall setLabel:@"Install Formula"];
				[self setToolbarButtonOperation:kBPWindowOperationInstall];
				break;
		}

		[formula getInformation];
		[self displayInformationForFormula:formula];
    }
}

- (void)searchUpdatedNotification:(NSNotification*)notification
{
	_isSearching = YES;
	if ([self.outlineView_sidebar selectedRow] != 2)
		[self.outlineView_sidebar selectRowIndexes:[NSIndexSet indexSetWithIndex:3] byExtendingSelection:NO];

	[self configureTableForListing:kBPListSearch];
}

- (void)buildSidebarTree
{
	NSArray *categoriesTitles = @[@"Installed", @"Outdated", @"All Formulae", @"Leaves"];
	NSArray *categoriesIcons = @[@"installedTemplate", @"outdatedTemplate", @"allFormulaeTemplate", @"pinTemplate"];
	NSArray *categoriesValues = @[[NSNumber numberWithInteger:[[[BPHomebrewManager sharedManager] formulae_installed] count]],
								  [NSNumber numberWithInteger:[[[BPHomebrewManager sharedManager] formulae_outdated] count]],
								  [NSNumber numberWithInteger:[[[BPHomebrewManager sharedManager] formulae_all] count]],
								  [NSNumber numberWithInteger:[[[BPHomebrewManager sharedManager] formulae_leaves] count]]];

	PXSourceListItem *item, *parent;
	_rootSidebarCategory = [PXSourceListItem itemWithTitle:@"" identifier:@"root"];

	parent = [PXSourceListItem itemWithTitle:@"Formulae" identifier:@"group"];
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
	[item setBadgeValue:@-1];
	[item setIcon:[NSImage imageNamed:@"downloadTemplate"]];
	[parent addChildItem:item];

	[self displayInformationForFormula:nil];
	[self setEnableUpgradeFormulasMenu:([[BPHomebrewManager sharedManager] formulae_outdated].count > 0)];
}

- (void)configureTableForListing:(BPListMode)mode
{
	CGFloat totalWidth = 0;
	NSInteger titleWidth = 0;

	totalWidth = [self.clippingView_formulae frame].size.width;

	switch (mode) {
		case kBPListAll:
			titleWidth = (NSInteger)(totalWidth - 125);
			_formulaeArray = [[BPHomebrewManager sharedManager] formulae_all];
			[[self.tableView_formulae tableColumnWithIdentifier:@"Version"] setHidden:YES];
			[[self.tableView_formulae tableColumnWithIdentifier:@"LatestVersion"] setHidden:YES];
			[[self.tableView_formulae tableColumnWithIdentifier:@"Status"] setHidden:NO];
			[[self.tableView_formulae tableColumnWithIdentifier:@"Status"] setWidth:(totalWidth-titleWidth)*0.90];
			break;

		case kBPListInstalled:
			titleWidth = (NSInteger)(totalWidth * 0.4);
			_formulaeArray = [[BPHomebrewManager sharedManager] formulae_installed];
			[[self.tableView_formulae tableColumnWithIdentifier:@"Version"] setHidden:NO];
			[[self.tableView_formulae tableColumnWithIdentifier:@"Version"] setWidth:(totalWidth-titleWidth)*0.95];
			[[self.tableView_formulae tableColumnWithIdentifier:@"LatestVersion"] setHidden:YES];
			[[self.tableView_formulae tableColumnWithIdentifier:@"Status"] setHidden:YES];
			break;

		case kBPListLeaves:
			titleWidth = (NSInteger)(totalWidth * 0.99);
			_formulaeArray = [[BPHomebrewManager sharedManager] formulae_leaves];
			[[self.tableView_formulae tableColumnWithIdentifier:@"Version"] setHidden:YES];
			[[self.tableView_formulae tableColumnWithIdentifier:@"LatestVersion"] setHidden:YES];
			[[self.tableView_formulae tableColumnWithIdentifier:@"Status"] setHidden:YES];
			break;

		case kBPListOutdated:
			titleWidth = (NSInteger)(totalWidth * 0.4);
			_formulaeArray = [[BPHomebrewManager sharedManager] formulae_outdated];
			[[self.tableView_formulae tableColumnWithIdentifier:@"Version"] setHidden:NO];
			[[self.tableView_formulae tableColumnWithIdentifier:@"Version"] setWidth:(totalWidth-titleWidth)*0.48];
			[[self.tableView_formulae tableColumnWithIdentifier:@"LatestVersion"] setHidden:NO];
			[[self.tableView_formulae tableColumnWithIdentifier:@"LatestVersion"] setWidth:(totalWidth-titleWidth)*0.48];
			[[self.tableView_formulae tableColumnWithIdentifier:@"Status"] setHidden:YES];
			break;

		case kBPListSearch:
			titleWidth = (NSInteger)(totalWidth - 90);
			_formulaeArray = [[BPHomebrewManager sharedManager] formulae_search];
			[[self.tableView_formulae tableColumnWithIdentifier:@"Version"] setHidden:YES];
			[[self.tableView_formulae tableColumnWithIdentifier:@"LatestVersion"] setHidden:YES];
			[[self.tableView_formulae tableColumnWithIdentifier:@"Status"] setHidden:NO];
			[[self.tableView_formulae tableColumnWithIdentifier:@"Status"] setWidth:(totalWidth-titleWidth)*0.90];
			break;

		default:
			break;
	}

	[[self.tableView_formulae tableColumnWithIdentifier:@"Name"] setWidth:titleWidth];
	[self.tableView_formulae deselectAll:nil];
	[self.tableView_formulae reloadData];
	[self updateInterfaceItems];
}

#pragma mark - Homebrew Manager Delegate

- (void)homebrewManagerFinishedUpdating:(BPHomebrewManager *)manager
{
	[self buildSidebarTree];

	// Used after unlocking the app when inserting custom homebrew installation path
	BOOL shouldReselectFirstRow = ([_outlineView_sidebar selectedRow] < 0);

	[self.outlineView_sidebar reloadData];

	if (shouldReselectFirstRow)
		[_outlineView_sidebar selectRowIndexes:[NSIndexSet indexSetWithIndex:1] byExtendingSelection:NO];
	else
		[_outlineView_sidebar selectRowIndexes:[NSIndexSet indexSetWithIndex:(NSUInteger)_lastSelectedSidebarIndex] byExtendingSelection:NO];
}

#pragma mark - Getters and Setters

- (void)setSplitView:(DMSplitView *)splitView
{
	_splitView = splitView;
	[_splitView setMinSize:165.f ofSubviewAtIndex:0];
	[_splitView setMinSize:400.f ofSubviewAtIndex:1];
	[_splitView setDividerColor:kBPSidebarDividerColor];
	[_splitView setDividerThickness:0];

	_appDelegate = BPAppDelegateRef;
}

- (DMSplitView*)splitView
{
	return _splitView;
}

- (void)setTableView_formulae:(NSTableView *)tableView_formulae
{
	_tableView_formulae = tableView_formulae;
}

- (NSTableView*)tableView_formulae
{
	return _tableView_formulae;
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

- (void)setView_disablerLock:(BPInsetShadowView *)view_disablerLock
{
	_view_disablerLock = view_disablerLock;
	[_view_disablerLock setShouldDrawBackground:YES];
}

- (BPInsetShadowView*)view_disablerLock
{
	return _view_disablerLock;
}

#pragma mark - NSTableView DataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [self.formulaeArray count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    // the return value is typed as (id) because it will return a string in all cases with the exception of the
    if(self.formulaeArray) {
        NSString *columnIdentifer = [tableColumn identifier];
        id element = [self.formulaeArray objectAtIndex:(NSUInteger)row];

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
		} else if ([columnIdentifer isEqualToString:@"LatestVersion"]) {
			if ([element isKindOfClass:[BPFormula class]]) {
				return [(BPFormula*)element latestVersion];
			} else {
				return element;
			}
        } else if ([columnIdentifer isEqualToString:@"Status"]) {
			if ([element isKindOfClass:[BPFormula class]]) {
				switch ([[BPHomebrewManager sharedManager] statusForFormula:element]) {
					case kBPFormulaInstalled:
						return @"Installed";

					case kBPFormulaNotInstalled:
						return @"Not Installed";

					case kBPFormulaOutdated:
						return @"Update Available";

					default:
						return @"";
				}
			} else {
				return element;
			}
		}
    }

	return @"";
}

#pragma mark - NSTableView Delegate

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
	[self updateInterfaceItems];
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
		cellView.badgeView.badgeValue = (NSUInteger) sourceListItem.badgeValue.integerValue;
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

	if ([self.outlineView_sidebar selectedRow] >= 0)
		_lastSelectedSidebarIndex = [self.outlineView_sidebar selectedRow];

	[self updateInterfaceItems];

	switch ([self.outlineView_sidebar selectedRow]) {
		case 1: // Installed Formulae
			[self configureTableForListing:kBPListInstalled];
			message = @"These are the formulae already installed in your system.";
			break;

		case 2: // Outdated Formulae
			[self configureTableForListing:kBPListOutdated];
			message = @"These formulae are already installed, but have an update available.";
			break;

		case 3: // All Formulae
			[self configureTableForListing:kBPListAll];
			message = @"These are all the formulae available for installation with Homebrew.";
			break;

		case 4:	// Leaves
			[self configureTableForListing:kBPListLeaves];
			message = @"These formulae are not dependencies of any other formulae.";
			break;

		case 6: // Doctor
			message = @"The doctor is a Homebrew feature that detects the most common causes of errors.";
			tabIndex = 1;
			break;

		case 7: // Update Tool
			message = @"Updating Homebrew means fetching the latest info about the available formulae.";
			tabIndex = 2;
			break;

		default:
			break;
	}

	if (message) [self.label_information setStringValue:message];
	[self.tabView selectTabViewItemAtIndex:tabIndex];
}

#pragma mark - NSMenu Delegate

- (void)menuNeedsUpdate:(NSMenu *)menu
{
	[self.tableView_formulae selectRowIndexes:[NSIndexSet indexSetWithIndex:[self.tableView_formulae clickedRow]] byExtendingSelection:NO];
}

#pragma mark - IBActions

- (IBAction)showFormulaInfo:(id)sender {
	NSInteger selectedIndex;

	selectedIndex = [self.tableView_formulae selectedRow];

	if (selectedIndex >= 0) {
		if ([self.formulaPopover isShown]) {
			[self.formulaPopover close];
		}

		[self.formulaPopoverView setDataObject:[_formulaeArray objectAtIndex:(NSUInteger)selectedIndex]];

		if (!self.formulaPopover) {
			self.formulaPopover = [[NSPopover alloc] init];
			[self.formulaPopover setBehavior:NSPopoverBehaviorSemitransient];
			[self.formulaPopover setAppearance:NSPopoverAppearanceHUD];
		}

		NSViewController *controller = [[NSViewController alloc] init];
		[controller setView:self.formulaPopoverView];

		[self.formulaPopover setContentViewController:controller];

		NSRect anchorRect = [self.tableView_formulae rectOfRow:selectedIndex];
		anchorRect.origin = [self.scrollView_formulae convertPoint:anchorRect.origin fromView:self.tableView_formulae];

		[self.formulaPopover showRelativeToRect:anchorRect ofView:self.scrollView_formulae preferredEdge:NSMaxXEdge];
	}
}

- (IBAction)installUninstallUpdate:(id)sender {
	// Check if there is a background task running. It is not smart to run two different Homebrew tasks at the same time!
	if (_appDelegate.isRunningBackgroundTask)
	{
		[_appDelegate displayBackgroundWarning];
		return;
	}
	[_appDelegate setRunningBackgroundTask:YES];

	NSInteger selectedIndex = [self.tableView_formulae selectedRow];

	if (selectedIndex >= 0) {
		BPFormula *formula = [_formulaeArray objectAtIndex:(NSUInteger)selectedIndex];
		NSString *message;
		void (^operationBlock)(void);

		switch (_toolbarButtonOperation) {
			case kBPWindowOperationInstall:
			{
				message = @"Are you sure you want to install the formula '%@'?";
				operationBlock = ^{
					[self prepareFormula:formula forOperation:kBPWindowOperationInstall];
				};
			}
				break;

			case kBPWindowOperationUninstall:
			{
				message = @"Are you sure you want to uninstall the formula '%@'?";
				operationBlock = ^{
					[self prepareFormula:formula forOperation:kBPWindowOperationUninstall];
				};
			}
				break;

			case kBPWindowOperationUpgrade:
			{
				message = nil;
				operationBlock = ^{
					[self prepareFormula:formula forOperation:kBPWindowOperationUpgrade];
				};
			}
				break;
		}

		if (message) {
			NSAlert *alert = [NSAlert alertWithMessageText:@"Attention!" defaultButton:@"Yes" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:message, formula.name];
			[alert.window setTitle:@"Cakebrew"];

            NSInteger returnValue = [alert runModal];
			if (returnValue == NSAlertDefaultReturn) {
				operationBlock();
			}
            else {
                [_appDelegate setRunningBackgroundTask:NO];
            }
		} else {
			operationBlock();
		}
	}
}

- (IBAction)installFormulaWithOptions:(id)sender
{
	if (_appDelegate.isRunningBackgroundTask)
	{
		[_appDelegate displayBackgroundWarning];
		return;
	}
	[_appDelegate setRunningBackgroundTask:YES];

	NSInteger selectedIndex = [self.tableView_formulae selectedRow];

	if (selectedIndex >= 0) {
		BPFormula *formula = [_formulaeArray objectAtIndex:(NSUInteger)selectedIndex];

		_formulaOptionsViewController = [[BPFormulaOptionsViewController alloc] initWithNibName:@"BPFormulaOptionsViewController" bundle:nil];
		_formulaOptionsWindow = [[NSWindow alloc] initWithContentRect:_formulaOptionsViewController.view.frame styleMask:NSTitledWindowMask|NSResizableWindowMask backing:NSBackingStoreBuffered defer:NO];
		[_formulaOptionsWindow setContentView:_formulaOptionsViewController.view];
		[_formulaOptionsViewController setWindow:_formulaOptionsWindow];
		[_formulaOptionsViewController setFormula:formula];
		[_formulaOptionsViewController setHomebrewViewController:self];

		if ([_appDelegate.window respondsToSelector:@selector(beginSheet:completionHandler:)]) {
			[_appDelegate.window beginSheet:_formulaOptionsWindow completionHandler:^(NSModalResponse returnCode) {
				_formulaOptionsWindow = nil;
				_formulaOptionsViewController = nil;
			}];
		} else {
			[[NSApplication sharedApplication] beginSheet:_formulaOptionsWindow modalForWindow:_appDelegate.window modalDelegate:self didEndSelector:@selector(windowOperationSheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
		}
	}
}

- (IBAction)upgradeAllOutdatedFormulae:(id)sender {
	NSAlert *alert = [NSAlert alertWithMessageText:@"Attention!" defaultButton:@"Yes" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:@"Are you sure you want to upgrade all outdated formulae?"];
	[alert.window setTitle:@"Cakebrew"];
	if ([alert runModal] == NSAlertDefaultReturn) {
		[self prepareFormula:nil forOperation:kBPWindowOperationUpgrade];
	}
}

- (IBAction)updateHomebrew:(id)sender
{
	[self.outlineView_sidebar selectRowIndexes:[NSIndexSet indexSetWithIndex:7] byExtendingSelection:NO];
	if (![self.updateDoctorViewController isRunning]) {
		[self.updateDoctorViewController runStopUpdate:nil];
	}
}

- (IBAction)openSelectedFormulaWebsite:(id)sender {
	NSInteger selectedIndex = [self.tableView_formulae selectedRow];
	if (selectedIndex >= 0) {
		BPFormula *formula = [_formulaeArray objectAtIndex:(NSUInteger)selectedIndex];
		[[NSWorkspace sharedWorkspace] openURL:formula.website];
	}
}

- (IBAction)searchFormulasFieldDidChange:(id)sender {
	NSSearchField *searchField = sender;
	NSString *searchPhrase = searchField.stringValue;
	if ([searchPhrase isEqualToString:@""]) {
		_isSearching = NO;
		[self configureTableForListing:kBPListAll];
	} else {
		[[BPHomebrewManager sharedManager] updateSearchWithName:searchPhrase];
	}
}

- (IBAction)beginFormulaSearch:(id)sender {
	[self.searchField becomeFirstResponder];
}

@end
