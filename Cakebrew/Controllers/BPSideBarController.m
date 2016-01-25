//
//  BPSideBarController.m
//  Cakebrew
//
//  Created by Marek Hrusovsky on 05/09/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import "BPSideBarController.h"
#import "BPHomebrewManager.h"

@interface BPSideBarController()

@property (strong, nonatomic) PXSourceListItem *rootSidebarCategory;

@property (strong, nonatomic) PXSourceListItem *instaledFormulaeSidebarItem;
@property (strong, nonatomic) PXSourceListItem *outdatedFormulaeSidebarItem;
@property (strong, nonatomic) PXSourceListItem *allFormulaeSidebarItem;
@property (strong, nonatomic) PXSourceListItem *leavesFormulaeSidebarItem;
@property (strong, nonatomic) PXSourceListItem *repositoriesFormulaeSidebarItem;
@property (strong, nonatomic) PXSourceListItem *doctorSidebarItem;
@property (strong, nonatomic) PXSourceListItem *updateSidebarItem;

@end

@implementation BPSideBarController

- (instancetype)init
{
	self = [super init];
	if (self) {
		[self buildSidebarTree];
	}
	return self;
}

- (void)buildSidebarTree
{
	PXSourceListItem *parent;
	_rootSidebarCategory = [PXSourceListItem itemWithTitle:@"" identifier:@"root"];
	
	parent = [PXSourceListItem itemWithTitle:NSLocalizedString(@"Sidebar_Group_Formulae", nil) identifier:@"group"];
	[_rootSidebarCategory addChildItem:parent];  //FormulaeSideBarItemFormulaeCategory = 0,
	
	_instaledFormulaeSidebarItem = [PXSourceListItem itemWithTitle:NSLocalizedString(@"Sidebar_Item_Installed", nil) identifier:@"item"];
	_instaledFormulaeSidebarItem.icon = [NSImage imageNamed:@"installedTemplate"];
	[parent addChildItem:_instaledFormulaeSidebarItem];  //FormulaeSideBarItemInstalled = 1,
	
	_outdatedFormulaeSidebarItem = [PXSourceListItem itemWithTitle:NSLocalizedString(@"Sidebar_Item_Outdated", nil) identifier:@"item"];
	_outdatedFormulaeSidebarItem.icon = [NSImage imageNamed:@"outdatedTemplate"];
	[parent addChildItem:_outdatedFormulaeSidebarItem]; //FormulaeSideBarItemOutdated = 2,
	
	_allFormulaeSidebarItem = [PXSourceListItem itemWithTitle:NSLocalizedString(@"Sidebar_Item_All", nil) identifier:@"item"];
	_allFormulaeSidebarItem.icon = [NSImage imageNamed:@"allFormulaeTemplate"];
	[parent addChildItem:_allFormulaeSidebarItem];  //FormulaeSideBarItemAll = 3,
	
	_leavesFormulaeSidebarItem = [PXSourceListItem itemWithTitle:NSLocalizedString(@"Sidebar_Item_Leaves", nil) identifier:@"item"];
	_leavesFormulaeSidebarItem.icon = [NSImage imageNamed:@"pinTemplate"];
	[parent addChildItem:_leavesFormulaeSidebarItem];  //FormulaeSideBarItemLeaves = 4,
	
	_repositoriesFormulaeSidebarItem = [PXSourceListItem itemWithTitle:NSLocalizedString(@"Sidebar_Item_Repos", nil) identifier:@"item"];
	_repositoriesFormulaeSidebarItem.icon = [NSImage imageNamed:@"cloudTemplate"];
	[parent addChildItem:_repositoriesFormulaeSidebarItem];  //FormulaeSideBarItemRepositories = 5,
	
	parent = [PXSourceListItem itemWithTitle:NSLocalizedString(@"Sidebar_Group_Tools", nil) identifier:@"group"];
	[_rootSidebarCategory addChildItem:parent];  //FormulaeSideBarItemToolsCategory = 6,
	
	_doctorSidebarItem = [PXSourceListItem itemWithTitle:NSLocalizedString(@"Sidebar_Item_Doctor", nil) identifier:@"item"];
	[_doctorSidebarItem setBadgeValue:@(-1)];
	[_doctorSidebarItem setIcon:[NSImage imageNamed:@"doctorTemplate"]];
	[parent addChildItem:_doctorSidebarItem];  //FormulaeSideBarItemDoctor = 7,
	
	_updateSidebarItem = [PXSourceListItem itemWithTitle:NSLocalizedString(@"Sidebar_Item_Update", nil) identifier:@"item"];
	[_updateSidebarItem setBadgeValue:@(-1)];
	[_updateSidebarItem setIcon:[NSImage imageNamed:@"updateTemplate"]];
	[parent addChildItem:_updateSidebarItem];  //FormulaeSideBarItemUpdate = 8,
}

- (void)configureSidebarSettings
{
	[self.sidebar selectRowIndexes:[NSIndexSet indexSetWithIndex:FormulaeSideBarItemInstalled] byExtendingSelection:NO];
	[self.sidebar accessibilitySetOverrideValue:NSLocalizedString(@"Sidebar_VoiceOver_Tools", nil) forAttribute:NSAccessibilityDescriptionAttribute];
}

- (void)refreshSidebarBadges
{
	self.instaledFormulaeSidebarItem.badgeValue		= @([[[BPHomebrewManager sharedManager] formulae_installed] count]);
	self.outdatedFormulaeSidebarItem.badgeValue		= @([[[BPHomebrewManager sharedManager] formulae_outdated] count]);
	self.allFormulaeSidebarItem.badgeValue			= @([[[BPHomebrewManager sharedManager] formulae_all] count]);
	self.leavesFormulaeSidebarItem.badgeValue		= @([[[BPHomebrewManager sharedManager] formulae_leaves] count]);
	self.repositoriesFormulaeSidebarItem.badgeValue = @([[[BPHomebrewManager sharedManager] formulae_repositories] count]);
}

#pragma mark - PXSourceList Data Source

- (NSUInteger)sourceList:(PXSourceList*)sourceList numberOfChildrenOfItem:(id)item
{
	if (!item) { //Is root
		return [[self.rootSidebarCategory children] count];
	} else {
		return [[(PXSourceListItem*)item children] count];
	}
}

- (id)sourceList:(PXSourceList*)aSourceList child:(NSUInteger)index ofItem:(id)item
{
	if (!item) {
		return [[self.rootSidebarCategory children] objectAtIndex:index];
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
	
	if ([[(PXSourceListItem*)item identifier] isEqualToString:@"group"]) {
	  cellView = [aSourceList makeViewWithIdentifier:@"HeaderCell" owner:nil];
	}
	else {
	  cellView = [aSourceList makeViewWithIdentifier:@"MainCell" owner:nil];
	}
	
	PXSourceListItem *sourceListItem = item;
	cellView.textField.stringValue = sourceListItem.title;
	
	if (sourceListItem.badgeValue.integerValue >= 0)
	{
		cellView.badgeView.badgeValue = (NSUInteger) sourceListItem.badgeValue.integerValue;
	}
	else {
		[cellView.badgeView setHidden:YES];
	}
	
  
	if (sourceListItem.icon) {
	  [cellView.imageView setImage:sourceListItem.icon];
	}
	
	[self addToolTipForItem:item view:cellView];
  
	[cellView.badgeView calcSize];
	
	return cellView;
}

- (void)sourceListSelectionDidChange:(NSNotification *)notification
{
	if ([self.delegate respondsToSelector:@selector(sourceListSelectionDidChange)]) {
		[self.delegate sourceListSelectionDidChange];
	}
}

- (void)addToolTipForItem:(id)item view:(NSView *)view
{
  NSString *tooltip;
  if ([item  isEqual:self.instaledFormulaeSidebarItem]) {
	tooltip = NSLocalizedString(@"Sidebar_Info_Installed", nil);
  } else if ([item  isEqual:self.outdatedFormulaeSidebarItem]) {
	tooltip = NSLocalizedString(@"Sidebar_Info_Outdated", nil);
  } else if ([item  isEqual:self.allFormulaeSidebarItem]) {
	tooltip = NSLocalizedString(@"Sidebar_Info_All", nil);
  } else if ([item  isEqual:self.leavesFormulaeSidebarItem]) {
	tooltip = NSLocalizedString(@"Sidebar_Info_Leaves", nil);
  } else if ([item  isEqual:self.repositoriesFormulaeSidebarItem]) {
	tooltip = NSLocalizedString(@"Sidebar_Info_Repos", nil);
  } else if ([item  isEqual:self.updateSidebarItem]) {
	tooltip = NSLocalizedString(@"Sidebar_Info_Update", nil);
  } else if ([item  isEqual:self.doctorSidebarItem]) {
	tooltip = NSLocalizedString(@"Sidebar_Info_Doctor", nil);
  }
  view.toolTip = tooltip;
}

#pragma mark - Actions

- (IBAction)selectSideBarRowWithSenderTag:(id)sender
{
	[self.sidebar selectRowIndexes:[NSIndexSet indexSetWithIndex:[sender tag]] byExtendingSelection:NO];
}

@end
