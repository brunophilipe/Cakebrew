//
//  BPToolbar.h
//  Cakebrew
//
//  Created by Marek Hrusovsky on 16/08/15.
//	Copyright (c) 2014 Bruno Philipe. All rights reserved.
//
//	This program is free software: you can redistribute it and/or modify
//	it under the terms of the GNU General Public License as published by
//	the Free Software Foundation, either version 3 of the License, or
//	(at your option) any later version.
//
//	This program is distributed in the hope that it will be useful,
//	but WITHOUT ANY WARRANTY; without even the implied warranty of
//	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	See the
//	GNU General Public License for more details.
//
//	You should have received a copy of the GNU General Public License
//	along with this program.	If not, see <http://www.gnu.org/licenses/>.
//

#import <Cocoa/Cocoa.h>

@protocol BPToolbarProtocol <NSObject>

@required
- (void)performSearchWithString:(NSString *)search;
- (void)updateHomebrew:(id)sender;
- (void)upgradeSelectedFormulae:(id)sender;
- (void)showFormulaInfo:(id)sender;
- (void)tapRepository:(id)sender;
- (void)untapRepository:(id)sender;
- (void)installFormula:(id)sender;
- (void)uninstallFormula:(id)sender;
@end

@interface BPToolbar : NSToolbar <NSToolbarDelegate>

typedef NS_ENUM(NSUInteger, BPToolbarMode) {
	BPToolbarModeInitial,
	BPToolbarModeDefault,
	BPToolbarModeInstall,
	BPToolbarModeUninstall,
	BPToolbarModeUpdateSingle,
	BPToolbarModeUpdateMany,
	BPToolbarModeTap,
	BPToolbarModeUntap
};

@property (nonatomic, weak) id controller;

- (void)configureForMode:(BPToolbarMode)mode;
- (void)lockItems;
- (void)unlockItems;
- (void)makeSearchFieldFirstResponder;
- (NSSearchField*)searchField;

@end
