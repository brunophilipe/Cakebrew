//
//	BrewInterface.h
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

typedef NS_ENUM(NSInteger, BPListMode) {
	kBPListAll,
    kBPListInstalled,
    kBPListLeaves,
	kBPListOutdated,
	kBPListSearch, /* Don't call -[BPHomebrewInterface listMode:] with this parameter. */
	kBPListRepositories
};

@protocol BPHomebrewInterfaceDelegate <NSObject>

/**
 *  Caled when the formulae cache has been updated.
 */
- (void)homebrewInterfaceDidUpdateFormulae;

/**
 *  Called if homebrew is not detected in the system.
 *
 */
- (void)homebrewInterfaceDisplayNoBrewMessage;

@end

@interface BPHomebrewInterface : NSObject

+ (BPHomebrewInterface *)sharedInterface;

/**
 *  Currently running task.
 */
@property (strong, nonatomic) NSTask *task; // default nil;

/**
 *  The delegate object.
 */
@property (weak, nonatomic) id<BPHomebrewInterfaceDelegate> delegate;

#pragma mark - Operations with live data callback block

/**
 *  Update Homebrew.
 *
 *  @param block Data callback block. This block will be called with new data to be diplayed while the process runs.
 *
 *  @return `YES` if successful.
 */
- (BOOL)updateWithReturnBlock:(void (^)(NSString*))block;

/**
 *  Upgrade parameter formulae to the latest available version.
 *
 *  @param formulae The list of formulae to be upgraded.
 *  @param block	Data callback block. This block will be called with new data to be diplayed while the process runs.
 *
 *  @return `YES` if successful.
 */
- (BOOL)upgradeFormulae:(NSArray*)formulae withReturnBlock:(void (^)(NSString*))block;

/**
 *  Install formula with options.
 *
 *  @param formula The formula to be installed.
 *  @param options Options for the formula installation (as explained in the info for a formula).
 *  @param block   Data callback block. This block will be called with new data to be diplayed while the process runs.
 *
 *  @return `YES` if successful.
 */
- (BOOL)installFormula:(NSString*)formula withOptions:(NSArray*)options andReturnBlock:(void (^)(NSString*output))block;

/**
 *  Uninstalls a formula.
 *
 *  @param formula The formula to be uninstalled.
 *  @param block   Data callback block. This block will be called with new data to be diplayed while the process runs.
 *
 *  @return `YES` if successful.
 */
- (BOOL)uninstallFormula:(NSString*)formula withReturnBlock:(void (^)(NSString*))block;

/**
 *  Taps a repo.
 *
 *  @param repository The repo to be tapped.
 *  @param block Data callback block. This block will be called with new data to be diplayed while the process runs.
 *
 *  @return `YES` if successful.
 */
- (BOOL)tapRepository:(NSString*)repository withReturnsBlock:(void (^)(NSString*))block;

/**
 *  Untaps a repo.
 *
 *  @param repository The repo to be untapped.
 *  @param block Data callback block. This block will be called with new data to be diplayed while the process runs.
 *
 *  @return `YES` if successful.
 */
- (BOOL)untapRepository:(NSString*)repository withReturnsBlock:(void (^)(NSString*))block;

/**
 *  Runs Homebrew cleanup tool.
 *
 *  @param block Data callback block. This block will be called with new data to be diplayed while the process runs.
 *
 *  @return `YES` if successful.
 */
- (BOOL)runCleanupWithReturnBlock:(void (^)(NSString*output))block;

/**
 *  Runs Homebrew doctor tool.
 *
 *  @param block Data callback block. This block will be called with new data to be diplayed while the process runs.
 *
 *  @return `YES` if successful.
 */
- (BOOL)runDoctorWithReturnBlock:(void (^)(NSString*))block;

#pragma mark - Operations that return on finish

/**
 *  Lists all formulae that fits the description of the parameter mode.
 *
 *  @param mode All, Installed, Leaves, Outdated, etc.
 *
 *  @return List of BPFormula objects.
 */
- (NSArray*)listMode:(BPListMode)mode;

/**
 *  Executes `brew info` for parameter formula name.
 *
 *  @param formula The name of the formula.
 *
 *  @return The information for the parameter formula as output by Homebrew.
 */
- (NSString*)informationForFormula:(NSString*)formula;

@end
