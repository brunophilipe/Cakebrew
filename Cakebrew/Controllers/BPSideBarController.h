//
//  BPSideBarController.h
//  Cakebrew
//
//  Created by Marek Hrusovsky on 05/09/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

@import PXSourceList;
@import Foundation;

typedef NS_ENUM(NSUInteger, FormulaeSideBarItem)
{
	FormulaeSideBarItemFormulaeCategory = 0,
	FormulaeSideBarItemInstalled = 1,
	FormulaeSideBarItemOutdated = 2,
	FormulaeSideBarItemAll = 3,
	FormulaeSideBarItemLeaves = 4,
	
	FormulaeSideBarItemCasksCategory = 5,
	CasksSideBarItemInstalled = 6,
	CasksSideBarItemOutdated = 7,
	CasksSideBarItemAll = 8,
	
	FormulaeSideBarItemToolsCategory = 9,
	FormulaeSideBarItemRepositories = 10,
	FormulaeSideBarItemDoctor = 11,
	FormulaeSideBarItemUpdate = 12,
	
};

@protocol BPSideBarControllerDelegate <NSObject>
- (void)sourceListSelectionDidChange;
@end

@interface BPSideBarController : NSObject <PXSourceListDataSource, PXSourceListDelegate>

@property (assign) IBOutlet PXSourceList *sidebar;

@property (weak) id <BPSideBarControllerDelegate>delegate;

- (void)refreshSidebarBadges;
- (void)configureSidebarSettings;

- (IBAction)selectSideBarRowWithSenderTag:(id)sender;

@end
