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
	kBPListSearch /* Don't call -[BPHomebrewInterface listMode:] with this parameter. */
};

@interface BPHomebrewInterface : NSObject
@property (nonatomic) NSTask *task; // default nil;

+ (BPHomebrewInterface *)sharedInterface;

- (void)hideHomebrewNotInstalledMessage;

#pragma mark - Operations with live data callback block

- (BOOL)updateWithReturnBlock:(void (^)(NSString*))block;
- (BOOL)upgradeFormula:(NSString*)formula withReturnBlock:(void (^)(NSString*))block;
- (BOOL)upgradeFormulae:(NSArray*)formulae withReturnBlock:(void (^)(NSString*))block;
- (BOOL)installFormula:(NSString*)formula withOptions:(NSArray*)options andReturnBlock:(void (^)(NSString*output))block;
- (BOOL)uninstallFormula:(NSString*)formula withReturnBlock:(void (^)(NSString*))block;
- (BOOL)runDoctorWithReturnBlock:(void (^)(NSString*))block;

#pragma mark - Operations that return on finish

- (NSArray*)listMode:(BPListMode)mode;
- (NSString*)informationForFormula:(NSString*)formula;

@end
