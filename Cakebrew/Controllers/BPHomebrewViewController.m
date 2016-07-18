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
#import "BPToolbar.h"
#import "BPAppDelegate.h"
#import "BPStyle.h"
#import "BPLoadingView.h"
#import "BPDisabledView.h"
#import "BPBundleWindowController.h"

typedef NS_ENUM(NSUInteger, HomeBrewTab) {
	HomeBrewTabFormulae,
	HomeBrewTabDoctor,
	HomeBrewTabUpdate
};

@interface BPHomebrewViewController () <NSTableViewDelegate,
BPSideBarControllerDelegate,
BPSelectedFormulaViewControllerDelegate,
BPHomebrewManagerDelegate,
BPToolbarProtocol,
NSMenuDelegate,
NSOpenSavePanelDelegate>

@property (weak) BPAppDelegate *appDelegate;

@property NSInteger lastSelectedSidebarIndex;

@property (getter=isSearching)			BOOL searching;
@property (getter=isHomebrewInstalled)	BOOL homebrewInstalled;


@property (strong, nonatomic) BPFormulaeDataSource				*formulaeDataSource;
@property (strong, nonatomic) BPFormulaOptionsWindowController	*formulaOptionsWindowController;
@property (strong, nonatomic) NSWindowController				*operationWindowController;
@property (strong, nonatomic) BPUpdateViewController			*updateViewController;
@property (strong, nonatomic) BPDoctorViewController			*doctorViewController;
@property (strong, nonatomic) BPFormulaPopoverViewController	*formulaPopoverViewController;
@property (strong, nonatomic) BPSelectedFormulaViewController	*selectedFormulaeViewController;
@property (strong, nonatomic) BPToolbar							*toolbar;
@property (strong, nonatomic) BPDisabledView					*disabledView;
@property (strong, nonatomic) BPLoadingView						*loadingView;

@property (weak, nonatomic) IBOutlet NSSplitView *formulaeSplitView;
@property (weak, nonatomic) IBOutlet NSView		 *selectedFormulaView;


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
	[self.selectedFormulaeViewController setDelegate:self];
	
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
	
	[self.selectedFormulaView addConstraints:[NSLayoutConstraint
											  constraintsWithVisualFormat:@"V:|-0-[view]-0-|"
											  options:0
											  metrics:nil
											  views:@{@"view": selectedFormulaView}]];
	
	[self.selectedFormulaView addConstraints:[NSLayoutConstraint
											  constraintsWithVisualFormat:@"H:|-0-[view]-0-|"
											  options:0
											  metrics:nil
											  views:@{@"view": selectedFormulaView}]];
	
	[self.sidebarController setDelegate:self];
	[self.sidebarController refreshSidebarBadges];
	[self.sidebarController configureSidebarSettings];
	
	[self.splitView setHidden:YES];
	
	[self addToolbar];
	[self addLoadingView];
	
	_appDelegate = BPAppDelegateRef;
}

- (void)addToolbar
{
	self.toolbar = [[BPToolbar alloc] initWithIdentifier:@"MainToolbar"];
	self.toolbar.delegate = self.toolbar;
	self.toolbar.controller = self;
	[[[self view] window] setToolbar:self.toolbar];
	[self.toolbar lockItems];
}

- (void)addDisabledView
{
	NSView *disabledView = [[BPDisabledView alloc] initWithFrame:NSZeroRect];
	disabledView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:disabledView];
	[self.view addConstraints:[NSLayoutConstraint
							   constraintsWithVisualFormat:@"V:|-0-[view]-0-|"
							   options:0
							   metrics:nil
							   views:@{@"view": disabledView}]];
	
	[self.view addConstraints:[NSLayoutConstraint
							   constraintsWithVisualFormat:@"H:|-0-[view]-0-|"
							   options:0
							   metrics:nil
							   views:@{@"view": disabledView}]];
	self.disabledView = (BPDisabledView *)disabledView;
}

- (void)addLoadingView
{
	NSView *loadingView = [[BPLoadingView alloc] initWithFrame:NSZeroRect];
	loadingView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:loadingView];
	[self.view addConstraints:[NSLayoutConstraint
							   constraintsWithVisualFormat:@"V:|-0-[view]-0-|"
							   options:0
							   metrics:nil
							   views:@{@"view": loadingView}]];
	
	[self.view addConstraints:[NSLayoutConstraint
							   constraintsWithVisualFormat:@"H:|-0-[view]-0-|"
							   options:0
							   metrics:nil
							   views:@{@"view": loadingView}]];
	self.loadingView = (BPLoadingView *)loadingView;
}

- (void)dealloc
{
	[_homebrewManager setDelegate:nil];
}

- (void)updateInterfaceItems
{
	NSInteger selectedSidebarRow	= [self.sidebarController.sidebar selectedRow];
	NSInteger selectedIndex			= [self.tableView_formulae selectedRow];
	NSIndexSet *selectedRows		= [self.tableView_formulae selectedRowIndexes];
	NSArray *selectedFormulae		= [self.formulaeDataSource formulasAtIndexSet:selectedRows];
	
	[self.selectedFormulaeViewController setFormulae:selectedFormulae];
	
	CGFloat height = [self.formulaeSplitView bounds].size.height;
	CGFloat preferedHeightOfSelectedFormulaView = 120.f;
	[self.formulaeSplitView setPosition:height - preferedHeightOfSelectedFormulaView
					   ofDividerAtIndex:0];
	
	if (selectedSidebarRow == FormulaeSideBarItemRepositories) // Repositories (Taps) sidebaritem
	{
		[self.toolbar configureForMode:BPToolbarModeTap];
		[self.formulaeSplitView setPosition:height
						   ofDividerAtIndex:0];
		
		if (selectedIndex != -1) {
			[self.toolbar configureForMode:BPToolbarModeUntap];
		} else {
			[self.toolbar configureForMode:BPToolbarModeTap];
		}
	}
	else if (selectedIndex == -1 || selectedSidebarRow > FormulaeSideBarItemToolsCategory)
	{
		[self.toolbar configureForMode:BPToolbarModeDefault];
	}
	else if ([[self.tableView_formulae selectedRowIndexes] count] > 1)
	{
		[self.toolbar configureForMode:BPToolbarModeUpdateMany];
	}
	else
	{
		BPFormula *formula = [self .formulaeDataSource formulaAtIndex:selectedIndex];

		switch ([[BPHomebrewManager sharedManager] statusForFormula:formula]) {
			case kBPFormulaInstalled:
				[self.toolbar configureForMode:BPToolbarModeUninstall];
				break;
				
			case kBPFormulaOutdated:
				if (selectedSidebarRow == FormulaeSideBarItemOutdated) {
					[self.toolbar configureForMode:BPToolbarModeUpdateSingle];
				} else {
					[self.toolbar configureForMode:BPToolbarModeUninstall];
				}
				break;
				
			case kBPFormulaNotInstalled:
				[self.toolbar configureForMode:BPToolbarModeInstall];
				break;
		}
	}
}

- (void)configureTableForListing:(BPListMode)mode
{
	[self.tableView_formulae deselectAll:nil];
	[self.formulaeDataSource setMode:mode];
	[self.tableView_formulae setMode:mode];
	[self.tableView_formulae reloadData];
	[self updateInterfaceItems];
}


#pragma mark – Footer Information Label

- (void)updateInfoLabelWithSidebarSelection
{
	FormulaeSideBarItem selectedSidebarRow = [self.sidebarController.sidebar selectedRow];
	NSString *message = nil;
	
	if (self.isSearching)
	{
		message = NSLocalizedString(@"Sidebar_Info_SearchResults", nil);
	}
	else
	{
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
	[self.loadingView removeFromSuperview];
	self.loadingView = nil;
	
	if (self.isHomebrewInstalled)
	{
		[[self.tableView_formulae menu] cancelTracking];
		
		self.currentFormula = nil;
		self.selectedFormulaeViewController.formulae = nil;
		
		[self.splitView			setHidden:NO];
		[self.label_information setHidden:NO];
		
		[self.toolbar configureForMode:BPToolbarModeDefault];
		[self.toolbar unlockItems];
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
	[self loadSearchResults];
}

- (void)homebrewManager:(BPHomebrewManager *)manager shouldDisplayNoBrewMessage:(BOOL)yesOrNo
{
	[self setHomebrewInstalled:!yesOrNo];
	
	if (yesOrNo)
	{
		[self addDisabledView];
		[self.label_information setHidden:YES];
		[self.splitView setHidden:YES];
		[self.toolbar lockItems];
		
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
		[self.disabledView removeFromSuperview];
		self.disabledView = nil;
		[self.label_information setHidden:NO];
		[self.splitView setHidden:NO];
		
		[self.toolbar unlockItems];
		
		[[BPHomebrewManager sharedManager] reloadFromInterfaceRebuildingCache:YES];
	}
}

#pragma mark - Search Mode

- (void)loadSearchResults
{
	[self.sidebarController.sidebar selectRowIndexes:[NSIndexSet indexSetWithIndex:FormulaeSideBarItemAll]
								byExtendingSelection:NO];
	[self setSearching:YES];
	[self configureTableForListing:kBPListSearch];
}

- (void)endSearchAndCleanup
{
	[self.toolbar.searchField setStringValue:@""];
	[self setSearching:NO];
	[self updateInfoLabelWithSidebarSelection];
}

#pragma mark - NSTableView Delegate

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	[self updateInterfaceItems];
}

#pragma mark - BPSelectedFormulaViewController Delegate

- (void)selectedFormulaViewDidUpdateFormulaInfoForFormula:(BPFormula *)formula
{
	if (formula) [self setCurrentFormula:formula];
}

#pragma mark - BPSideBarDelegate Delegate

- (void)sourceListSelectionDidChange
{
	NSUInteger tabIndex = HomeBrewTabFormulae;
	NSInteger selectedSidebarRow = [self.sidebarController.sidebar selectedRow];
	
	if ([self isSearching])
	{
		[self endSearchAndCleanup];
	}
	
	if (selectedSidebarRow >= 0)
		_lastSelectedSidebarIndex = selectedSidebarRow;
	
	[self.tableView_formulae deselectAll:nil];
	[self setCurrentFormula:nil];
	
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
	BPFormula *formula = [self selectedFormula];
	if (!formula) {
		return;
	}
	[self.formulaPopoverViewController setFormula:formula];
	
	NSRect anchorRect = [self.tableView_formulae rectOfRow:selectedIndex];
	anchorRect.origin = [self.scrollView_formulae convertPoint:anchorRect.origin fromView:self.tableView_formulae];
	
	[popover showRelativeToRect:anchorRect
						 ofView:self.scrollView_formulae
				  preferredEdge:NSMaxXEdge];
}


- (IBAction)installFormula:(id)sender
{
	[self checkForBackgroundTask];
	BPFormula *formula = [self selectedFormula];
	if (!formula) {
		return;
	}
	NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Generic_Attention", nil)
									 defaultButton:NSLocalizedString(@"Generic_Yes", nil)
								   alternateButton:NSLocalizedString(@"Generic_Cancel", nil)
									   otherButton:nil
						 informativeTextWithFormat:NSLocalizedString(@"Confirmation_Install_Formula", nil),formula.name];
	[alert.window setTitle:NSLocalizedString(@"Cakebrew", nil)];
	
	if ([alert runModal] == NSAlertDefaultReturn) {
		self.operationWindowController = [BPInstallationWindowController runWithOperation:kBPWindowOperationInstall
																				 formulae:@[formula]
																				  options:nil];
	}
}

- (IBAction)installFormulaWithOptions:(id)sender
{
	[self checkForBackgroundTask];
	BPFormula *formula = [self selectedFormula];
	if (!formula) {
		return;
	}
	self.formulaOptionsWindowController = [BPFormulaOptionsWindowController runFormula:formula withCompletionBlock:^(NSArray *options) {
		self.operationWindowController = [BPInstallationWindowController runWithOperation:kBPWindowOperationInstall
																				 formulae:@[formula]
																				  options:options];
	}];
}

- (IBAction)uninstallFormula:(id)sender
{
	[self checkForBackgroundTask];
	BPFormula *formula = [self selectedFormula];
	if (!formula) {
		return;
	}
	NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Generic_Attention", nil)
									 defaultButton:NSLocalizedString(@"Generic_Yes", nil)
								   alternateButton:NSLocalizedString(@"Generic_Cancel", nil)
									   otherButton:nil
						 informativeTextWithFormat:NSLocalizedString(@"Confirmation_Uninstall_Formula", nil),formula.name];
	[alert.window setTitle:NSLocalizedString(@"Cakebrew", nil)];
	
	if ([alert runModal] == NSAlertDefaultReturn) {
		self.operationWindowController = [BPInstallationWindowController runWithOperation:kBPWindowOperationUninstall
																				 formulae:@[formula]
																				  options:nil];
	}
}

- (IBAction)upgradeSelectedFormulae:(id)sender
{
	[self checkForBackgroundTask];
	NSArray *selectedFormulae = [self selectedFormulae];
	if (![selectedFormulae count]) {
		return;
	}
	NSString *formulaNames = [[self selectedFormulaNames] componentsJoinedByString:@", "];
	
	
	NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Message_Update_Formulae_Title", nil)
									 defaultButton:NSLocalizedString(@"Generic_Yes", nil)
								   alternateButton:NSLocalizedString(@"Generic_Cancel", nil)
									   otherButton:nil
						 informativeTextWithFormat:NSLocalizedString(@"Message_Update_Formulae_Body", nil), formulaNames];
	
	[alert.window setTitle:NSLocalizedString(@"Cakebrew", nil)];
	if ([alert runModal] == NSAlertDefaultReturn)
	{
		self.operationWindowController = [BPInstallationWindowController runWithOperation:kBPWindowOperationUpgrade
																				 formulae:selectedFormulae
																				  options:nil];
	}
}


- (IBAction)upgradeAllOutdatedFormulae:(id)sender
{
	[self checkForBackgroundTask];
	
	NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Message_Update_All_Outdated_Title", nil)
									 defaultButton:NSLocalizedString(@"Generic_Yes", nil)
								   alternateButton:NSLocalizedString(@"Generic_Cancel", nil)
									   otherButton:nil
						 informativeTextWithFormat:NSLocalizedString(@"Message_Update_All_Outdated_Body", nil)];
	
	[alert.window setTitle:NSLocalizedString(@"Cakebrew", nil)];
	
	if ([alert runModal] == NSAlertDefaultReturn)
	{
		self.operationWindowController = [BPInstallationWindowController runWithOperation:kBPWindowOperationUpgrade
																				 formulae:nil
																				  options:nil];
	}
}

- (IBAction)tapRepository:(id)sender
{
	[self checkForBackgroundTask];
	NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Message_Tap_Title", nil)
									 defaultButton:NSLocalizedString(@"Generic_OK", nil)
								   alternateButton:NSLocalizedString(@"Generic_Cancel", nil)
									   otherButton:nil
						 informativeTextWithFormat:NSLocalizedString(@"Message_Tap_Body", nil)];
	
	[alert.window setTitle:NSLocalizedString(@"Cakebrew", nil)];
	
	NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0,0,200,24)];
	[alert setAccessoryView:input];
	
	NSInteger returnValue = [alert runModal];
	if (returnValue == NSAlertDefaultReturn)
	{
		NSString* name = [input stringValue];
		if ([name length] <= 0)
		{
			return;
		}
		BPFormula *lformula = [BPFormula formulaWithName:name];
		self.operationWindowController = [BPInstallationWindowController runWithOperation:kBPWindowOperationTap
																				 formulae:@[lformula]
																				  options:nil];
	}
}

- (IBAction)untapRepository:(id)sender
{
	[self checkForBackgroundTask];
	BPFormula *formula = [self selectedFormula];
	
	if (!formula)
	{
		return;
	}
	
	NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Message_Untap_Title", nil)
									 defaultButton:NSLocalizedString(@"Generic_OK", nil)
								   alternateButton:NSLocalizedString(@"Generic_Cancel", nil)
									   otherButton:nil
						 informativeTextWithFormat:NSLocalizedString(@"Message_Untap_Body", nil), formula.name];
	
	[alert.window setTitle:NSLocalizedString(@"Cakebrew", nil)];
	
	if ([alert runModal] == NSAlertDefaultReturn)
	{
		self.operationWindowController = [BPInstallationWindowController runWithOperation:kBPWindowOperationUntap
																				 formulae:@[formula]
																				  options:nil];
	}
}

- (IBAction)updateHomebrew:(id)sender
{
	[self.sidebarController.sidebar selectRowIndexes:[NSIndexSet indexSetWithIndex:FormulaeSideBarItemUpdate] byExtendingSelection:NO];
	[self.updateViewController runStopUpdate:nil];
}

- (IBAction)openSelectedFormulaWebsite:(id)sender
{
	BPFormula *formula = [self selectedFormula];
	if (!formula) {
		return;
	}
	[[NSWorkspace sharedWorkspace] openURL:formula.website];
}

- (void)performSearchWithString:(NSString *)searchPhrase
{
	if ([searchPhrase isEqualToString:@""])
	{
		[self endSearchAndCleanup];
	}
	else
	{
		[[BPHomebrewManager sharedManager] updateSearchWithName:searchPhrase];
	}
}

- (IBAction)beginFormulaSearch:(id)sender
{
	[self.toolbar makeSearchFieldFirstResponder];
}

- (IBAction)runHomebrewCleanup:(id)sender
{
	self.operationWindowController = [BPInstallationWindowController runWithOperation:kBPWindowOperationCleanup
																			 formulae:nil
																			  options:nil];
}

- (IBAction)runHomebrewExport:(id)sender
{
	NSSavePanel *savePanel = [NSSavePanel savePanel];
	[savePanel setNameFieldLabel:@"Export To:"];
	[savePanel setPrompt:@"Export"];
	[savePanel setNameFieldStringValue:@"Brewfile"];
	
	[savePanel beginSheetModalForWindow:[NSApp mainWindow] completionHandler:^(NSInteger result) {
		NSURL *fileURL = [savePanel URL];
		
		if (fileURL && result)
		{
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),
						   dispatch_get_main_queue(), ^{
							   self.operationWindowController = [BPBundleWindowController runExportOperationWithFile:fileURL];
						   });
		}
	}];
}

- (IBAction)runHomebrewImport:(id)sender
{
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setNameFieldLabel:@"Import From:"];
	[openPanel setPrompt:@"Import"];
	[openPanel setNameFieldStringValue:@"Brewfile"];
	[openPanel setAllowsMultipleSelection:NO];
	[openPanel setCanChooseDirectories:NO];
	[openPanel setCanChooseFiles:YES];
	[openPanel setDelegate:self];
	
	[openPanel beginSheetModalForWindow:[NSApp mainWindow] completionHandler:^(NSInteger result) {
		NSURL *fileURL = [openPanel URL];
		
		if (fileURL && result)
		{
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),
						   dispatch_get_main_queue(), ^{
							   self.operationWindowController = [BPBundleWindowController runImportOperationWithFile:fileURL];
						   });
		}
	}];
}

- (void)checkForBackgroundTask
{
	if (_appDelegate.isRunningBackgroundTask)
	{
		[_appDelegate displayBackgroundWarning];
		return;
	}
}

- (BPFormula *)selectedFormula
{
	NSInteger selectedIndex = [self.tableView_formulae selectedRow];
	return [self.formulaeDataSource formulaAtIndex:selectedIndex];
}

- (NSArray *)selectedFormulae
{
	NSIndexSet *selectedIndexes = [self.tableView_formulae selectedRowIndexes];
	return [self.formulaeDataSource formulasAtIndexSet:selectedIndexes];
}

- (NSArray *)selectedFormulaNames
{
	NSArray *formulas = [self selectedFormulae];
	return [formulas valueForKeyPath:@"@unionOfObjects.name"];
}

#pragma mark - OPen Save Panels Delegate

- (BOOL)panel:(id)sender shouldEnableURL:(NSURL *)url
{
	return [[[url pathComponents] lastObject] isEqualToString:@"Brewfile"];
}

@end
