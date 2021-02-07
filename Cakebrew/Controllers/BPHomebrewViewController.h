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
#import <PXSourceList/PXSourceList.h>
#import "BPFormula.h"
#import "BPFormulaeTableView.h"
#import "BPFormulaPopoverViewController.h"
#import "BPSideBarController.h"

typedef NS_ENUM(NSUInteger, BPWindowOperation) {
	kBPWindowOperationInstall,
	kBPWindowOperationUninstall,
	kBPWindowOperationUpgrade,
	kBPWindowOperationTap,
	kBPWindowOperationUntap,
	kBPWindowOperationCleanup
};

@class BPUpdateDoctorController;

@interface BPHomebrewViewController : NSViewController

@property (weak) IBOutlet BPSideBarController      *sidebarController;
@property (weak) IBOutlet BPFormulaeTableView      *formulaeTableView;
@property (weak) IBOutlet NSScrollView             *scrollView_formulae;
@property (weak) IBOutlet NSTabView                *tabView;
@property (weak) IBOutlet NSTextField              *label_information;
@property (weak) IBOutlet NSMenu                   *menu_formula;

// Cocoa bindings
@property BOOL enableUpgradeFormulasMenu;
@property (copy) BPFormula *currentFormula;

- (BOOL)isHomebrewInstalled;

- (IBAction)showFormulaInfo:(id)sender;
- (IBAction)installFormulaWithOptions:(id)sender;
- (IBAction)upgradeSelectedFormulae:(id)sender;
- (IBAction)upgradeAllOutdatedFormulae:(id)sender;
- (IBAction)updateHomebrew:(id)sender;
- (IBAction)openSelectedFormulaWebsite:(id)sender;
- (IBAction)beginFormulaSearch:(id)sender;
- (IBAction)runHomebrewCleanup:(id)sender;
- (IBAction)runHomebrewExport:(id)sender;
- (IBAction)runHomebrewImport:(id)sender;

@end
