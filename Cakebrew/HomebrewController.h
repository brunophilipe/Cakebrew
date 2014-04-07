//
//	HomebrewController.h
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

#import <Foundation/Foundation.h>
#import "DMSplitView.h"

@class DMSplitView;

@interface HomebrewController : NSViewController

@property IBOutlet NSWindow *HUDAbout;
@property IBOutlet NSWindow *HUDMoreInfo;

@property (weak) IBOutlet NSTableView *tableView_formulas;
@property (weak) IBOutlet NSOutlineView *outlineView_sidebar;
@property (weak) IBOutlet DMSplitView *splitView;
@property (weak) IBOutlet NSTextField *label_formulasCount;
@property (weak) IBOutlet NSTextField *label_formulaPath;
@property (weak) IBOutlet NSTextField *label_formulaVersion;
@property (weak) IBOutlet NSTextField *label_formulaDependencies;

@property IBOutlet NSToolbarItem *toolbarButton_formulaInfo;
@property IBOutlet NSToolbarItem *toolbarButton_installUninstall;

- (IBAction)showFormulaInfo:(id)sender;
- (IBAction)installOrUninstall:(id)sender;
- (IBAction)updateHomebrew:(id)sender;
- (IBAction)openSelectedFormulaWebsite:(id)sender;

@end
