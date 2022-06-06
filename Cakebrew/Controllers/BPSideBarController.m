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

@property (strong, nonatomic) PXSourceListItem *instaledCasksSidebarItem;
@property (strong, nonatomic) PXSourceListItem *outdatedCasksSidebarItem;
@property (strong, nonatomic) PXSourceListItem *allCasksSidebarItem;

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
	PXSourceListItem *item, *parent;
	_rootSidebarCategory = [PXSourceListItem itemWithTitle:@"" identifier:@"root"];
	
	parent = [PXSourceListItem itemWithTitle:NSLocalizedString(@"Sidebar_Group_Formulae", nil)
								  identifier:@"group"];
	[_rootSidebarCategory addChildItem:parent];
	
	_instaledFormulaeSidebarItem = [PXSourceListItem itemWithTitle:NSLocalizedString(@"Sidebar_Item_Installed", nil)
														identifier:@"item"];
	_instaledFormulaeSidebarItem.icon = [self installedSidebarIconImage];
	[parent addChildItem:_instaledFormulaeSidebarItem];
	
	_outdatedFormulaeSidebarItem = [PXSourceListItem itemWithTitle:NSLocalizedString(@"Sidebar_Item_Outdated", nil)
														identifier:@"item"];
	_outdatedFormulaeSidebarItem.icon = [self outdatedSidebarIconImage];
	[parent addChildItem:_outdatedFormulaeSidebarItem];
	
	_allFormulaeSidebarItem = [PXSourceListItem itemWithTitle:NSLocalizedString(@"Sidebar_Item_All", nil)
												   identifier:@"item"];
	_allFormulaeSidebarItem.icon = [self allFormulaeSidebarIconImage];
	[parent addChildItem:_allFormulaeSidebarItem];
	
	_leavesFormulaeSidebarItem = [PXSourceListItem itemWithTitle:NSLocalizedString(@"Sidebar_Item_Leaves", nil)
													  identifier:@"item"];
	_leavesFormulaeSidebarItem.icon = [self leavesSidebarIconImage];
	[parent addChildItem:_leavesFormulaeSidebarItem];
	
	
	parent = [PXSourceListItem itemWithTitle:NSLocalizedString(@"Sidebar_Group_Casks", nil)
								  identifier:@"group"];
	[_rootSidebarCategory addChildItem:parent];
	
	_instaledCasksSidebarItem = [PXSourceListItem itemWithTitle:NSLocalizedString(@"Sidebar_Item_Installed_Casks", nil)
														identifier:@"item"];
	_instaledCasksSidebarItem.icon = [self installedSidebarIconImage];
	[parent addChildItem:_instaledCasksSidebarItem];
	
	_outdatedCasksSidebarItem = [PXSourceListItem itemWithTitle:NSLocalizedString(@"Sidebar_Item_Outdated_Casks", nil)
														identifier:@"item"];
	_outdatedCasksSidebarItem.icon = [self outdatedSidebarIconImage];
	[parent addChildItem:_outdatedCasksSidebarItem];
	
	_allCasksSidebarItem = [PXSourceListItem itemWithTitle:NSLocalizedString(@"Sidebar_Item_All_Casks", nil)
												   identifier:@"item"];
	_allCasksSidebarItem.icon = [self allFormulaeSidebarIconImage];
	[parent addChildItem:_allCasksSidebarItem];
	
	
	parent = [PXSourceListItem itemWithTitle:NSLocalizedString(@"Sidebar_Group_Tools", nil)
								  identifier:@"group"];
	[_rootSidebarCategory addChildItem:parent];
	
	_repositoriesFormulaeSidebarItem = [PXSourceListItem itemWithTitle:NSLocalizedString(@"Sidebar_Item_Repos", nil)
															identifier:@"item"];
	_repositoriesFormulaeSidebarItem.icon = [self repositoriesSidebarIconImage];
	[parent addChildItem:_repositoriesFormulaeSidebarItem];
	
	item = [PXSourceListItem itemWithTitle:NSLocalizedString(@"Sidebar_Item_Doctor", nil)
								identifier:@"item"];
	[item setBadgeValue:@(-1)];
	[item setIcon:[self doctorSidebarIconImage]];
	[parent addChildItem:item];
	
	item = [PXSourceListItem itemWithTitle:NSLocalizedString(@"Sidebar_Item_Update", nil)
								identifier:@"item"];
	[item setBadgeValue:@(-1)];
	[item setIcon:[self updateSidebarIconImage]];
	[parent addChildItem:item];
}

- (NSImage *)installedSidebarIconImage
{
	if (@available(macOS 11.0, *)) {
		return [NSImage imageWithSystemSymbolName:@"checkmark.square"
						 accessibilityDescription:NSLocalizedString(@"Sidebar_Item_Installed", nil)];
	} else {
		return [NSImage imageNamed:@"installedTemplate"];
	}
}

- (NSImage *)outdatedSidebarIconImage
{
	if (@available(macOS 11.0, *)) {
		return [NSImage imageWithSystemSymbolName:@"clock.arrow.circlepath"
						 accessibilityDescription:NSLocalizedString(@"Sidebar_Item_Outdated", nil)];
	} else {
		return [NSImage imageNamed:@"outdatedTemplate"];
	}
}

- (NSImage *)allFormulaeSidebarIconImage
{
	if (@available(macOS 11.0, *)) {
		return [NSImage imageWithSystemSymbolName:@"books.vertical"
						 accessibilityDescription:NSLocalizedString(@"Sidebar_Item_All", nil)];
	} else {
		return [NSImage imageNamed:@"allFormulaeTemplate"];
	}
}

- (NSImage *)leavesSidebarIconImage
{
	if (@available(macOS 11.0, *)) {
		return [NSImage imageWithSystemSymbolName:@"leaf"
						 accessibilityDescription:NSLocalizedString(@"Sidebar_Item_Leaves", nil)];
	} else {
		return [NSImage imageNamed:@"pinTemplate"];
	}
}

- (NSImage *)repositoriesSidebarIconImage
{
	if (@available(macOS 11.0, *)) {
		return [NSImage imageWithSystemSymbolName:@"building.columns"
						 accessibilityDescription:NSLocalizedString(@"Sidebar_Item_Repos", nil)];
	} else {
		return [NSImage imageNamed:@"cloudTemplate"];
	}
}

- (NSImage *)doctorSidebarIconImage
{
	if (@available(macOS 11.0, *)) {
		return [NSImage imageWithSystemSymbolName:@"stethoscope"
						 accessibilityDescription:NSLocalizedString(@"Sidebar_Item_Doctor", nil)];
	} else {
		return [NSImage imageNamed:@"doctorTemplate"];
	}
}

- (NSImage *)updateSidebarIconImage
{
	if (@available(macOS 11.0, *)) {
		return [NSImage imageWithSystemSymbolName:@"arrow.triangle.2.circlepath.circle"
						 accessibilityDescription:NSLocalizedString(@"Sidebar_Item_Update", nil)];
	} else {
		return [NSImage imageNamed:@"updateTemplate"];
	}
}


- (void)configureSidebarSettings
{
	[self.sidebar selectRowIndexes:[NSIndexSet indexSetWithIndex:FormulaeSideBarItemInstalled] byExtendingSelection:NO];
	[self.sidebar setAccessibilityLabel:NSLocalizedString(@"Sidebar_VoiceOver_Tools", nil)];
}

- (void)refreshSidebarBadges
{
	self.instaledFormulaeSidebarItem.badgeValue		= @([[[BPHomebrewManager sharedManager] installedFormulae] count]);
	self.outdatedFormulaeSidebarItem.badgeValue		= @([[[BPHomebrewManager sharedManager] outdatedFormulae] count]);
	self.allFormulaeSidebarItem.badgeValue			= @([[[BPHomebrewManager sharedManager] allFormulae] count]);
	self.leavesFormulaeSidebarItem.badgeValue		= @([[[BPHomebrewManager sharedManager] leavesFormulae] count]);
	self.repositoriesFormulaeSidebarItem.badgeValue = @([[[BPHomebrewManager sharedManager] repositoriesFormulae] count]);
	
	self.instaledCasksSidebarItem.badgeValue		= @([[[BPHomebrewManager sharedManager] installedCasks] count]);
	self.outdatedCasksSidebarItem.badgeValue		= @([[[BPHomebrewManager sharedManager] outdatedCasks] count]);
	self.allCasksSidebarItem.badgeValue				= @([[[BPHomebrewManager sharedManager] allCasks] count]);
	
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

- (id)sourceList:(PXSourceList*)sourceList child:(NSUInteger)index ofItem:(id)item
{
	if (!item) {
		return [[self.rootSidebarCategory children] objectAtIndex:index];
	} else {
		return [[(PXSourceListItem*)item children] objectAtIndex:index];
	}
}

- (BOOL)sourceList:(PXSourceList*)sourceList isItemExpandable:(id)item
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
	} else {
		cellView = [aSourceList makeViewWithIdentifier:@"MainCell" owner:nil];
	}

	PXSourceListItem *sourceListItem = item;
	cellView.textField.stringValue = sourceListItem.title;

	if (sourceListItem.badgeValue.integerValue >= 0)
	{
		cellView.badgeView.badgeValue = (NSUInteger) sourceListItem.badgeValue.integerValue;
		[cellView.badgeView setHidden:NO];
	}
	else
	{
		[cellView.badgeView setHidden:YES];
	}

	if (sourceListItem.icon) {
		[cellView.imageView setImage:sourceListItem.icon];
	}

	[cellView.badgeView calcSize];

	return cellView;
}

- (void)sourceListSelectionDidChange:(NSNotification *)notification
{
	if ([self.delegate respondsToSelector:@selector(sourceListSelectionDidChange)]) {
		[self.delegate sourceListSelectionDidChange];
	}
}

#pragma mark - Actions

- (IBAction)selectSideBarRowWithSenderTag:(id)sender
{
	[self.sidebar selectRowIndexes:[NSIndexSet indexSetWithIndex:[sender tag]] byExtendingSelection:NO];
}

@end
