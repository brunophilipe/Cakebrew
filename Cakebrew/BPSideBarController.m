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

@end

@implementation BPSideBarController

- (instancetype)init
{
  self = [super init];
  if (self) {
    [self buildSidebarTree];
    [self refreshSidebarBadges];
  }
  return self;
}


- (void)buildSidebarTree
{
	PXSourceListItem *item, *parent;
	_rootSidebarCategory = [PXSourceListItem itemWithTitle:@"" identifier:@"root"];
  
	parent = [PXSourceListItem itemWithTitle:@"Formulae" identifier:@"group"];
	[_rootSidebarCategory addChildItem:parent];
  
  _instaledFormulaeSidebarItem = [PXSourceListItem itemWithTitle:@"Installed" identifier:@"item"];
  _instaledFormulaeSidebarItem.icon = [NSImage imageNamed:@"installedTemplate"];
  [parent addChildItem:_instaledFormulaeSidebarItem];
  
  _outdatedFormulaeSidebarItem = [PXSourceListItem itemWithTitle:@"Outdated" identifier:@"item"];
  _outdatedFormulaeSidebarItem.icon = [NSImage imageNamed:@"outdatedTemplate"];
  [parent addChildItem:_outdatedFormulaeSidebarItem];
  
  _allFormulaeSidebarItem = [PXSourceListItem itemWithTitle:@"All Formulae" identifier:@"item"];
  _allFormulaeSidebarItem.icon = [NSImage imageNamed:@"allFormulaeTemplate"];
  [parent addChildItem:_allFormulaeSidebarItem];
  
  _leavesFormulaeSidebarItem = [PXSourceListItem itemWithTitle:@"Leaves" identifier:@"item"];
  _leavesFormulaeSidebarItem.icon = [NSImage imageNamed:@"pinTemplate"];
  [parent addChildItem:_leavesFormulaeSidebarItem];

  _repositoriesFormulaeSidebarItem = [PXSourceListItem itemWithTitle:@"Repositories" identifier:@"item"];
  _repositoriesFormulaeSidebarItem.icon = [NSImage imageNamed:@"cloudTemplate"];
  [parent addChildItem:_repositoriesFormulaeSidebarItem];
  
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
}


- (void)refreshSidebarBadges
{
  
  self.instaledFormulaeSidebarItem.badgeValue = @([[[BPHomebrewManager sharedManager] formulae_installed] count]);
  self.outdatedFormulaeSidebarItem.badgeValue = @([[[BPHomebrewManager sharedManager] formulae_outdated] count]);
  self.allFormulaeSidebarItem.badgeValue = @([[[BPHomebrewManager sharedManager] formulae_all] count]);
  self.leavesFormulaeSidebarItem.badgeValue = @([[[BPHomebrewManager sharedManager] formulae_leaves] count]);
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
  if ([self.delegate respondsToSelector:@selector(sourceListSelectionDidChange)]) {
    [self.delegate sourceListSelectionDidChange];
  }
}

@end
