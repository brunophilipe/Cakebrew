//
//	BPHomebrewManager.h
//	Cakebrew – The Homebrew GUI App for OS X
//
//	Created by Bruno Philipe on 4/3/14.
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

@class BPHomebrewManager;

typedef NS_ENUM(NSInteger, BPFormulaStatus) {
	kBPFormulaNotInstalled,
	kBPFormulaInstalled,
	kBPFormulaOutdated,
};

@protocol BPHomebrewManagerDelegate <NSObject>

- (void)homebrewManagerFinishedUpdating:(BPHomebrewManager*)manager;
- (void)homebrewManager:(BPHomebrewManager *)manager shouldDisplayNoBrewMessage:(BOOL)yesOrNo;

@end

@interface BPHomebrewManager : NSObject

@property NSUInteger installedFormulaeCount;
@property NSUInteger outdatedFormulaeCount;
@property (strong) NSArray *formulae_all;
@property NSUInteger allFormulaeCount;
@property NSUInteger leavesFormulaeCount;
@property (strong) NSArray *formulae_repositories;
@property NSUInteger repositoriesFormulaeCount;

@property (weak) id<BPHomebrewManagerDelegate> delegate;

+ (instancetype)sharedManager;
+ (instancetype)alloc __attribute__((unavailable("alloc not available, call sharedManager instead")));
- (instancetype)init __attribute__((unavailable("init not available, call sharedManager instead")));
+ (instancetype)new __attribute__((unavailable("new not available, call sharedManager instead")));

- (void)reloadFromInterfaceRebuildingCache:(BOOL)shouldRebuildCache;

- (void)cleanUp;

@end
