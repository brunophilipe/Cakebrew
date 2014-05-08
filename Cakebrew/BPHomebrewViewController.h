//
//	HomebrewController.h
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

#import <Foundation/Foundation.h>
#import "BPFormula.h"
#import "DMSplitView.h"
#import "BPInsetShadowView.h"
#import "BPUpdateDoctorController.h"
#import "BPGenericTextPopoverView.h"

typedef NS_ENUM(NSUInteger, BPWindowOperation) {
    kBPWindowOperationInstall,
    kBPWindowOperationUninstall,
	kBPWindowOperationUpgrade
};

@class DMSplitView;
@class BPInsetShadowView;
@class BPUpdateDoctorController;

@interface BPHomebrewViewController : NSViewController

@property (weak) IBOutlet NSTableView *tableView_formulae;
@property (weak) IBOutlet NSClipView *clippingView_formulae;
@property (weak) IBOutlet NSScrollView *scrollView_formulae;
@property (weak) IBOutlet NSOutlineView *outlineView_sidebar;
@property (weak) IBOutlet DMSplitView *splitView;
@property (weak) IBOutlet NSTabView *tabView;
@property (weak) IBOutlet NSTextField *label_information;
@property (weak) IBOutlet NSTextField *label_formulaPath;
@property (weak) IBOutlet NSTextField *label_formulaVersion;
@property (weak) IBOutlet NSTextField *label_formulaDependencies;
@property (weak) IBOutlet NSTextField *label_formulaConflicts;
@property (weak) IBOutlet BPGenericTextPopoverView *formulaPopoverView;
@property (weak) IBOutlet BPInsetShadowView *view_disablerLock;
@property (weak) IBOutlet NSToolbar *toolbar;

@property (unsafe_unretained) IBOutlet BPUpdateDoctorController *updateDoctorViewController;

@property IBOutlet NSToolbarItem *toolbarButton_formulaInfo;
@property IBOutlet NSToolbarItem *toolbarButton_installUninstall;

// Cocoa bindings
@property (strong, nonatomic) NSString *formulaMenuTitle;
@property BOOL enableUpgradeFormulasMenu;

@property (weak) BPFormula *currentFormula;


- (IBAction)showFormulaInfo:(id)sender;
- (IBAction)installUninstallUpdate:(id)sender;
- (IBAction)upgradeAllOutdatedFormulae:(id)sender;
- (IBAction)updateHomebrew:(id)sender;
- (IBAction)openSelectedFormulaWebsite:(id)sender;
- (IBAction)searchFormulasFieldDidChange:(id)sender;

@end