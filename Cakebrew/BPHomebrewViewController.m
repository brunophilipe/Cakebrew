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
#import "BPFormulaOptionsWindowController.h"
#import "BPInstallationWindowController.h"
#import "BPUpdateViewController.h"
#import "BPDoctorViewController.h"
#import "BPFormulaeDataSource.h"
#import "BPSelectedFormulaViewController.h"

typedef NS_ENUM(NSUInteger, HomeBrewTab) {
	HomeBrewTabFormulae,
	HomeBrewTabDoctor,
	HomeBrewTabUpdate
};

@interface BPHomebrewViewController () <NSTableViewDelegate, BPSideBarControllerDelegate, BPHomebrewManagerDelegate, NSMenuDelegate>

@property (unsafe_unretained) BPAppDelegate *appDelegate;

@property NSInteger lastSelectedSidebarIndex;

@property (getter=isSearching)			BOOL searching;
@property (getter=isHomebrewInstalled)	BOOL homebrewInstalled;

@property BPWindowOperation toolbarButtonOperation;


@property (strong, nonatomic) BPFormulaeDataSource *formulaeDataSource;
@property (strong, nonatomic) BPFormulaOptionsWindowController *formulaOptionsWindowController;
@property (strong, nonatomic) BPInstallationWindowController *operationWindowController;
@property (strong, nonatomic) BPUpdateViewController *updateViewController;
@property (strong, nonatomic) BPDoctorViewController *doctorViewController;
@property (strong, nonatomic) BPFormulaPopoverViewController *formulaPopoverViewController;
@property (strong, nonatomic) BPSelectedFormulaViewController *selectedFormulaeViewController;

@property (unsafe_unretained, nonatomic) IBOutlet NSSplitView *formulaeSplitView;
@property (unsafe_unretained, nonatomic) IBOutlet NSView *selectedFormulaView;


@end

@implementation BPHomebrewViewController
{
	BPHomebrewManager *_homebrewManager;
}

- (BPFormulaPopoverViewController *)formulaPopoverViewController
{
	if (!_formulaPopoverViewController) {
		_formulaPopoverViewController = [[BPFormulaPopoverViewController alloc] init];
		//this will force initialize controller with its view
		__unused NSView *view = _formulaPopoverViewController.view;
	}
	return _formulaPopoverViewController;
}

- (id)init
{
	self = [super init];
	if (self) {
		[self commonInit];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self commonInit];
	}
	return self;
}

- (void)commonInit
{
	_homebrewManager = [BPHomebrewManager sharedManager];
	[_homebrewManager setDelegate:self];
	
	self.selectedFormulaeViewController = [[BPSelectedFormulaViewController alloc] init];
	
	self.homebrewInstalled = YES;
}


- (void)awakeFromNib
{
	self.formulaeDataSource = [[BPFormulaeDataSource alloc] initWithMode:kBPListAll];
	self.tableView_formulae.dataSource = self.formulaeDataSource;
	self.tableView_formulae.delegate = self;
	[self.tableView_formulae accessibilitySetOverrideValue:NSLocalizedString(@"Formulae", nil) forAttribute:NSAccessibilityDescriptionAttribute];

	//link formulae tableview
	NSView *formulaeView = self.formulaeSplitView;
	if ([[self.tabView tabViewItems] count] > HomeBrewTabFormulae) {
		NSTabViewItem *formulaeTab = [self.tabView tabViewItemAtIndex:HomeBrewTabFormulae];
		[formulaeTab setView:formulaeView];
	}
	
	//Creating view for update tab
	self.updateViewController = [[BPUpdateViewController alloc] initWithNibName:nil bundle:nil];
	NSView *updateView = [self.updateViewController view];
	if ([[self.tabView tabViewItems] count] > HomeBrewTabUpdate) {
		NSTabViewItem *updateTab = [self.tabView tabViewItemAtIndex:HomeBrewTabUpdate];
		[updateTab setView:updateView];
	}
	
	//Creating view for doctor tab
	self.doctorViewController = [[BPDoctorViewController alloc] initWithNibName:nil bundle:nil];
	NSView *doctorView = [self.doctorViewController view];
	if ([[self.tabView tabViewItems] count] > HomeBrewTabDoctor) {
		NSTabViewItem *doctorTab = [self.tabView tabViewItemAtIndex:HomeBrewTabDoctor];
		[doctorTab setView:doctorView];
	}
	
	
	NSView *selectedFormulaView = [self.selectedFormulaeViewController view];
	[self.selectedFormulaView addSubview:selectedFormulaView];
	selectedFormulaView.translatesAutoresizingMaskIntoConstraints = NO;
	
	[self.selectedFormulaView addConstraint:[NSLayoutConstraint constraintWithItem:selectedFormulaView
																		 attribute:NSLayoutAttributeTop
																		 relatedBy:NSLayoutRelationEqual
																			toItem:self.selectedFormulaView
																		 attribute:NSLayoutAttributeTop
																		multiplier:1.0f
																		  constant:0.0f]];
	
	[self.selectedFormulaView addConstraint:[NSLayoutConstraint constraintWithItem:selectedFormulaView
																		 attribute:NSLayoutAttributeLeft
																		 relatedBy:NSLayoutRelationEqual
																			toItem:self.selectedFormulaView
																		 attribute:NSLayoutAttributeLeft
																		multiplier:1.0f
																		  constant:0.0f]];
	
	[self.selectedFormulaView addConstraint:[NSLayoutConstraint constraintWithItem:selectedFormulaView
																		 attribute:NSLayoutAttributeBottom
																		 relatedBy:NSLayoutRelationEqual
																			toItem:self.selectedFormulaView
																		 attribute:NSLayoutAttributeBottom
																		multiplier:1.0f
																		  constant:0.0f]];
	
	[self.selectedFormulaView addConstraint:[NSLayoutConstraint constraintWithItem:selectedFormulaView
																		 attribute:NSLayoutAttributeRight
																		 relatedBy:NSLayoutRelationEqual
																			toItem:self.selectedFormulaView
																		 attribute:NSLayoutAttributeRight
																		multiplier:1.0f
																		  constant:0.0f]];
	
	
	[self.splitView setMinSize:185.f ofSubviewAtIndex:0];
	[self.splitView setMinSize:380.f ofSubviewAtIndex:1];
	[self.splitView setDividerColor:kBPSidebarDividerColor];
	[self.splitView setDividerThickness:1];
	
	[self.sidebarController setDelegate:self];
	[self.sidebarController refreshSidebarBadges];
	[self.sidebarController configureSidebarSettings];

	[self.view_loading setHidden:NO];
	[self.splitView setHidden:YES];
	[self setToolbarItemsEnabled:NO];
	
	[self.searchField.cell accessibilitySetOverrideValue:@[self.tableView_formulae] forAttribute:NSAccessibilityLinkedUIElementsAttribute];

	_appDelegate = BPAppDelegateRef;
}

- (void)dealloc
{
	[_homebrewManager setDelegate:nil];
}

- (void)prepareFormulae:(NSArray*)formulae forOperation:(BPWindowOperation)operation withOptions:(NSArray*)options
{
	self.operationWindowController = [BPInstallationWindowController runWithOperation:operation
																			 formulae:formulae
																			  options:options];
}

- (void)updateInterfaceItems
{
	NSInteger selectedSidebarRow = [self.sidebarController.sidebar selectedRow];
	NSInteger selectedIndex = [self.tableView_formulae selectedRow];
	NSIndexSet *selectedRows = [self.tableView_formulae selectedRowIndexes];
	NSArray *selectedFormulae = [self.formulaeDataSource formulasAtIndexSet:selectedRows];
	if ([selectedFormulae count] == 1) {
		[self setCurrentFormula:[selectedFormulae firstObject]];
	}
	[self.selectedFormulaeViewController setFormulae:selectedFormulae];
	
	
	CGFloat height = [self.formulaeSplitView bounds].size.height;
	CGFloat preferedHeightOfSelectedFormulaView = 120.f;
	[self.formulaeSplitView setPosition:height - preferedHeightOfSelectedFormulaView
					   ofDividerAtIndex:0];
	
	if (selectedSidebarRow == FormulaeSideBarItemRepositories) { // Repositories sidebaritem
		[self.toolbarButton_installUninstall setEnabled:YES];
		[self.toolbarButton_formulaInfo setEnabled:NO];
		[self.formulaeSplitView setPosition:height
						   ofDividerAtIndex:0];
		
		if (selectedIndex != -1) {
			[self.toolbarButton_installUninstall setImage:[NSImage imageNamed:@"delete.icns"]];
			[self.toolbarButton_installUninstall setLabel:NSLocalizedString(@"Toolbar_Untap_Repo", nil)];
			[self setToolbarButtonOperation:kBPWindowOperationUntap];
		} else {
			[self.toolbarButton_installUninstall setImage:[NSImage imageNamed:@"download.icns"]];
			[self.toolbarButton_installUninstall setLabel:NSLocalizedString(@"Toolbar_Tap_Repo", nil)];
			[self setToolbarButtonOperation:kBPWindowOperationTap];
		}
	}
	else if (selectedIndex == -1 || selectedSidebarRow > FormulaeSideBarItemToolsCategory)
	{
		[self.toolbarButton_installUninstall setEnabled:NO];
		[self.toolbarButton_formulaInfo setEnabled:NO];
	}
	else if ([[self.tableView_formulae selectedRowIndexes] count] > 1)
	{
		[self.toolbarButton_installUninstall setImage:[NSImage imageNamed:@"reload.icns"]];
		[self.toolbarButton_installUninstall setLabel:NSLocalizedString(@"Toolbar_Update_Selected", nil)];
		[self setToolbarButtonOperation:kBPWindowOperationUpgrade];
	}
	else
	{
		BPFormula *formula = [self.formulaeDataSource formulaAtIndex:selectedIndex];
		
		[self.toolbarButton_installUninstall setEnabled:YES];
		[self.toolbarButton_formulaInfo setEnabled:YES];
		
		switch ([[BPHomebrewManager sharedManager] statusForFormula:formula]) {
			case kBPFormulaInstalled:
				[self.toolbarButton_installUninstall setImage:[NSImage imageNamed:@"delete.icns"]];
				[self.toolbarButton_installUninstall setLabel:NSLocalizedString(@"Toolbar_Uninstall_Formula", nil)];
				[self setToolbarButtonOperation:kBPWindowOperationUninstall];
				break;
				
			case kBPFormulaOutdated:
				if (selectedSidebarRow == FormulaeSideBarItemOutdated) {
					[self.toolbarButton_installUninstall setImage:[NSImage imageNamed:@"reload.icns"]];
					[self.toolbarButton_installUninstall setLabel:NSLocalizedString(@"Toolbar_Update_Formula", nil)];
					[self setToolbarButtonOperation:kBPWindowOperationUpgrade];
				} else {
					[self.toolbarButton_installUninstall setImage:[NSImage imageNamed:@"delete.icns"]];
					[self.toolbarButton_installUninstall setLabel:NSLocalizedString(@"Toolbar_Uninstall_Formula", nil)];
					[self setToolbarButtonOperation:kBPWindowOperationUninstall];
				}
				break;
				
			case kBPFormulaNotInstalled:
				[self.toolbarButton_installUninstall setImage:[NSImage imageNamed:@"download.icns"]];
				[self.toolbarButton_installUninstall setLabel:NSLocalizedString(@"Toolbar_Install_Formula", nil)];
				[self setToolbarButtonOperation:kBPWindowOperationInstall];
				break;
		}
	}
}

- (void)configureTableForListing:(BPListMode)mode
{
	[self.tableView_formulae deselectAll:nil];
	[self.tableView_formulae setMode:mode];
	[self.formulaeDataSource setMode:mode];
	[self.tableView_formulae reloadData];
	[self updateInterfaceItems];
}

- (void)setToolbarItemsEnabled:(BOOL)yesOrNo
{
	[self.toolbar.items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if ([obj respondsToSelector:@selector(setEnabled:)]) {
			[obj setEnabled:yesOrNo];
		}
	}];
}

#pragma mark – Footer Information Label

- (void)updateInfoLabelWithSidebarSelection
{
	FormulaeSideBarItem selectedSidebarRow = [self.sidebarController.sidebar selectedRow];
	NSString *message = nil;
	
	switch (selectedSidebarRow)
	{
		case FormulaeSideBarItemInstalled: // Installed Formulae
			message = NSLocalizedString(@"Sidebar_Info_Installed", nil);
			break;
			
		case FormulaeSideBarItemOutdated: // Outdated Formulae
			message = NSLocalizedString(@"Sidebar_Info_Outdated", nil);
			break;
			
		case FormulaeSideBarItemAll: // All Formulae
			message = NSLocalizedString(@"Sidebar_Info_All", nil);
			break;
			
		case FormulaeSideBarItemLeaves:	// Leaves
			message = NSLocalizedString(@"Sidebar_Info_Leaves", nil);
			break;
			
		case FormulaeSideBarItemRepositories: // Repositories
			message = NSLocalizedString(@"Sidebar_Info_Repos", nil);
			break;
			
		case FormulaeSideBarItemDoctor: // Doctor
			message = NSLocalizedString(@"Sidebar_Info_Doctor", nil);
			break;
			
		case FormulaeSideBarItemUpdate: // Update Tool
			message = NSLocalizedString(@"Sidebar_Info_Update", nil);
			break;
			
		default:
			break;
	}
	
	if (self.isSearching)
	{
		message = NSLocalizedString(@"Sidebar_Info_SearchResults", nil);
	}
	
	[self updateInfoLabelWithText:message];
}

- (void)updateInfoLabelWithText:(NSString*)message
{
	if (message)
	{
		[self.label_information setStringValue:message];
	}
}

#pragma mark - Homebrew Manager Delegate

- (void)homebrewManagerFinishedUpdating:(BPHomebrewManager *)manager
{
	if (self.isHomebrewInstalled)
	{
		[[self.tableView_formulae menu] cancelTracking];
		
		self.currentFormula = nil;
		self.selectedFormulaeViewController.formulae = nil;
		
		[self.view_loading setHidden:YES];
		[self.splitView	   setHidden:NO];
		
		[self setToolbarItemsEnabled:YES];
		[self.formulaeDataSource refreshBackingArray];
		[self.sidebarController refreshSidebarBadges];
		
		// Used after unlocking the app when inserting custom homebrew installation path
		BOOL shouldReselectFirstRow = ([self.sidebarController.sidebar selectedRow] < 0);
		
		[self.sidebarController.sidebar reloadData];
		
		[self setEnableUpgradeFormulasMenu:([[BPHomebrewManager sharedManager] formulae_outdated].count > 0)];
		
		if (shouldReselectFirstRow)
			[self.sidebarController.sidebar selectRowIndexes:[NSIndexSet indexSetWithIndex:FormulaeSideBarItemInstalled] byExtendingSelection:NO];
		else
			[self.sidebarController.sidebar selectRowIndexes:[NSIndexSet indexSetWithIndex:(NSUInteger)_lastSelectedSidebarIndex] byExtendingSelection:NO];
	}
}

- (void)homebrewManager:(BPHomebrewManager *)manager didUpdateSearchResults:(NSArray *)searchResults
{
	[self setSearching:YES];
	
	[self.sidebarController.sidebar selectRowIndexes:[NSIndexSet indexSetWithIndex:FormulaeSideBarItemAll] byExtendingSelection:NO];
	
	[self configureTableForListing:kBPListSearch];
}

- (void)homebrewManager:(BPHomebrewManager *)manager shouldDisplayNoBrewMessage:(BOOL)yesOrNo
{
	[self setHomebrewInstalled:!yesOrNo];
	
	if (yesOrNo)
	{
		[self.view_disablerLock setHidden:NO];
		[self.view_disablerLock setWantsLayer:YES];
		[self.label_information setHidden:YES];
		[self.view_loading setHidden:YES];
		[self.splitView setHidden:YES];
		
		[self setToolbarItemsEnabled:NO];
		
		NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Generic_Error", nil)
										 defaultButton:NSLocalizedString(@"Message_No_Homebrew_Title", nil)
									   alternateButton:NSLocalizedString(@"Generic_Cancel", nil)
										   otherButton:nil
							 informativeTextWithFormat:NSLocalizedString(@"Message_No_Homebrew_Body", nil)];
		
		[alert.window setTitle:NSLocalizedString(@"Cakebrew", nil)];
		
		NSURL *brew_URL = [NSURL URLWithString:@"http://brew.sh"];
		
		if ([alert respondsToSelector:@selector(beginSheetModalForWindow:completionHandler:)]) {
			[alert beginSheetModalForWindow:_appDelegate.window completionHandler:^(NSModalResponse returnCode) {
				if (returnCode == NSAlertDefaultReturn) {
					[[NSWorkspace sharedWorkspace] openURL:brew_URL];
				}
			}];
		} else {
			NSModalResponse returnCode = [alert runModal];
			if (returnCode == NSAlertDefaultReturn) {
				[[NSWorkspace sharedWorkspace] openURL:brew_URL];
			}
		}
	}
	else
	{
		[self.view_disablerLock setHidden:YES];
		[self.label_information setHidden:NO];
		[self.splitView setHidden:NO];
		
		[self setToolbarItemsEnabled:YES];
		
		[[BPHomebrewManager sharedManager] reloadFromInterfaceRebuildingCache:YES];
	}
}

#pragma mark - NSTableView Delegate

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	[self updateInterfaceItems];
}

#pragma mark - BPSideBarDelegate Delegate

- (void)sourceListSelectionDidChange
{
	NSUInteger tabIndex = 0;
	NSInteger selectedSidebarRow = [self.sidebarController.sidebar selectedRow];
	
	if (selectedSidebarRow >= 0)
		_lastSelectedSidebarIndex = selectedSidebarRow;
	
	[self.tableView_formulae deselectAll:nil];
	
	[self updateInterfaceItems];
	
	switch (selectedSidebarRow)
	{
		case FormulaeSideBarItemInstalled: // Installed Formulae
			[self configureTableForListing:kBPListInstalled];
			break;
			
		case FormulaeSideBarItemOutdated: // Outdated Formulae
			[self configureTableForListing:kBPListOutdated];
			break;
			
		case FormulaeSideBarItemAll: // All Formulae
			[self configureTableForListing:kBPListAll];
			break;
			
		case FormulaeSideBarItemLeaves:	// Leaves
			[self configureTableForListing:kBPListLeaves];
			break;
			
		case FormulaeSideBarItemRepositories: // Repositories
			[self configureTableForListing:kBPListRepositories];
			break;
			
		case FormulaeSideBarItemDoctor: // Doctor
			tabIndex = HomeBrewTabDoctor;
			break;
			
		case FormulaeSideBarItemUpdate: // Update Tool
			tabIndex = HomeBrewTabUpdate;
			break;
			
		default:
			break;
	}
	
	[self updateInfoLabelWithSidebarSelection];
	
	[self.tabView selectTabViewItemAtIndex:tabIndex];
}

#pragma mark - NSMenu Delegate

- (void)menuNeedsUpdate:(NSMenu *)menu
{
	[self.tableView_formulae selectRowIndexes:[NSIndexSet indexSetWithIndex:[self.tableView_formulae clickedRow]] byExtendingSelection:NO];
}

#pragma mark - IBActions

- (IBAction)showFormulaInfo:(id)sender
{
	NSPopover *popover = self.formulaPopoverViewController.formulaPopover;
	if ([popover isShown]) {
		[popover close];
	}
	NSInteger selectedIndex = [self.tableView_formulae selectedRow];
	BPFormula *formula = [self.formulaeDataSource formulaAtIndex:selectedIndex];
	[self.formulaPopoverViewController setFormula:formula];
	
	NSRect anchorRect = [self.tableView_formulae rectOfRow:selectedIndex];
	anchorRect.origin = [self.scrollView_formulae convertPoint:anchorRect.origin fromView:self.tableView_formulae];
	
	[popover showRelativeToRect:anchorRect
						 ofView:self.scrollView_formulae
				  preferredEdge:NSMaxXEdge];
}

- (IBAction)installUninstallUpdate:(id)sender
{
	// Check if there is a background task running. It is not smart to run two different Homebrew tasks at the same time!
	if (_appDelegate.isRunningBackgroundTask)
	{
		[_appDelegate displayBackgroundWarning];
		return;
	}
	[_appDelegate setRunningBackgroundTask:YES];
	
	NSInteger selectedFormula = [self.tableView_formulae selectedRow];
	NSInteger selectedSidebarRow = [self.sidebarController.sidebar selectedRow];
	BPFormula *formula = [self.formulaeDataSource formulaAtIndex:selectedFormula];
	
	if (formula)
	{
		NSString *message;
		void (^operationBlock)(void);
		
		switch (_toolbarButtonOperation) {
			case kBPWindowOperationInstall:
			{
				message = NSLocalizedString(@"Confirmation_Install_Formula", nil);
				operationBlock = ^{
					[self prepareFormulae:@[formula] forOperation:kBPWindowOperationInstall withOptions:nil];
				};
			}
				break;
				
			case kBPWindowOperationUninstall:
			{
				message = NSLocalizedString(@"Confirmation_Uninstall_Formula", nil);
				operationBlock = ^{
					[self prepareFormulae:@[formula] forOperation:kBPWindowOperationUninstall withOptions:nil];
				};
			}
				break;
				
			case kBPWindowOperationUpgrade:
			{
				message = NSLocalizedString(@"Confirmation_Update_Formula", nil);
				NSIndexSet *indexes = [self.tableView_formulae selectedRowIndexes];
				NSArray *formulae = [self.formulaeDataSource formulasAtIndexSet:indexes];
				
				operationBlock = ^{
					[self prepareFormulae:formulae forOperation:kBPWindowOperationUpgrade withOptions:nil];
				};
			}
				break;
				
			case kBPWindowOperationUntap:
			{
				message = NSLocalizedString(@"Confirmation_Untap_Repo", nil);
				operationBlock = ^{
					[self prepareFormulae:@[formula] forOperation:kBPWindowOperationUntap withOptions:nil];
				};
			}
				break;
				
			case kBPWindowOperationTap:
			{
				message = NSLocalizedString(@"Confirmation_Tap_Repo", nil);
				operationBlock = ^{
					[self prepareFormulae:@[formula] forOperation:kBPWindowOperationTap withOptions:nil];
				};
			}
				break;
		}
		
		if (message)
		{
			NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Generic_Attention", nil)
											 defaultButton:NSLocalizedString(@"Generic_Yes", nil)
										   alternateButton:NSLocalizedString(@"Generic_Cancel", nil)
											   otherButton:nil
								 informativeTextWithFormat:message, formula.name];
			
			[alert.window setTitle:NSLocalizedString(@"Cakebrew", nil)];
			
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
	else if (selectedSidebarRow == FormulaeSideBarItemRepositories && _toolbarButtonOperation == kBPWindowOperationTap)
	{
		NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Message_Tap_Title", nil)
										 defaultButton:NSLocalizedString(@"Generic_OK", nil)
									   alternateButton:NSLocalizedString(@"Generic_Cancel", nil)
										   otherButton:nil
							 informativeTextWithFormat:NSLocalizedString(@"Message_Tap_Body", nil)];
		
		[alert.window setTitle:NSLocalizedString(@"Cakebrew", nil)];
		
		NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0,0,200,24)];
		[input setStringValue:@""];
		[alert setAccessoryView:input];
		
		NSInteger returnValue = [alert runModal];
		if (returnValue == NSAlertDefaultReturn)
		{
			NSString* name = [input stringValue];
			if ([name length] > 0)
			{
				BPFormula *lformula = [BPFormula formulaWithName:name];
				[self prepareFormulae:@[lformula] forOperation:kBPWindowOperationTap withOptions:nil];
			}
			else
			{
				[_appDelegate setRunningBackgroundTask:NO];
			}
		}
		else
		{
			[_appDelegate setRunningBackgroundTask:NO];
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
	
	NSInteger selectedIndex = [self.tableView_formulae selectedRow];
	BPFormula *formula = [self.formulaeDataSource formulaAtIndex:selectedIndex];
	if (formula)
	{
		self.formulaOptionsWindowController = [BPFormulaOptionsWindowController runFormula:formula withCompletionBlock:^(NSArray *options) {
			[self prepareFormulae:@[formula] forOperation:kBPWindowOperationInstall withOptions:options];
		}];
	}
}

- (IBAction)upgradeSelectedFormulae:(id)sender
{
	NSMutableString *names = [NSMutableString string];
	NSIndexSet *indexes = [self.tableView_formulae selectedRowIndexes];
	NSArray *selectedFormulae = [self.formulaeDataSource formulasAtIndexSet:indexes];
	[selectedFormulae enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if ([names compare:@""] == NSOrderedSame) {
			[names appendString:[obj name]];
		} else {
			[names appendFormat:@", %@", [obj name]];
		}
	}];
	
	NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Message_Update_Formulae_Title", nil)
									 defaultButton:NSLocalizedString(@"Generic_Yes", nil)
								   alternateButton:NSLocalizedString(@"Generic_Cancel", nil)
									   otherButton:nil
						 informativeTextWithFormat:NSLocalizedString(@"Message_Update_Formulae_Body", nil), names];
	
	[alert.window setTitle:NSLocalizedString(@"Cakebrew", nil)];
	if ([alert runModal] == NSAlertDefaultReturn)
	{
		[self prepareFormulae:selectedFormulae forOperation:kBPWindowOperationUpgrade withOptions:nil];
	}
}


- (IBAction)upgradeAllOutdatedFormulae:(id)sender
{
	NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Message_Update_All_Outdated_Title", nil)
									 defaultButton:NSLocalizedString(@"Generic_Yes", nil)
								   alternateButton:NSLocalizedString(@"Generic_Cancel", nil)
									   otherButton:nil
						 informativeTextWithFormat:NSLocalizedString(@"Message_Update_All_Outdated_Body", nil)];

	[alert.window setTitle:NSLocalizedString(@"Cakebrew", nil)];
	
	if ([alert runModal] == NSAlertDefaultReturn) {
		[self prepareFormulae:nil forOperation:kBPWindowOperationUpgrade withOptions:nil];
	}
}

- (IBAction)updateHomebrew:(id)sender
{
	[self.sidebarController.sidebar selectRowIndexes:[NSIndexSet indexSetWithIndex:8] byExtendingSelection:NO];
	[self.updateViewController runStopUpdate:nil];
}

- (IBAction)openSelectedFormulaWebsite:(id)sender
{
	NSInteger selectedIndex = [self.tableView_formulae selectedRow];
	BPFormula *formula = [self.formulaeDataSource formulaAtIndex:selectedIndex];
	if (formula) {
		[[NSWorkspace sharedWorkspace] openURL:formula.website];
	}
}

- (IBAction)searchFormulasFieldDidChange:(id)sender
{
	NSSearchField *searchField = sender;
	NSString *searchPhrase = searchField.stringValue;
	
	if ([searchPhrase isEqualToString:@""])
	{
		[self setSearching:NO];
		[self updateInfoLabelWithSidebarSelection];
	}
	else
	{
		[[BPHomebrewManager sharedManager] updateSearchWithName:searchPhrase];
	}
	
	[self configureTableForListing:kBPListAll];
}

- (IBAction)beginFormulaSearch:(id)sender {
	[self.searchField becomeFirstResponder];
}

@end
