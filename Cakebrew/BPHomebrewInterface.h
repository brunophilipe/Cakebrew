//
//	BrewInterface.h
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

typedef enum : NSUInteger {
	kBP_LIST_ALL,
    kBP_LIST_INSTALLED,
    kBP_LIST_LEAVES,
	kBP_LIST_UPGRADEABLE
} BP_LIST_MODE;

@interface BPHomebrewInterface : NSObject

+ (BPHomebrewInterface *)sharedInterface;

- (void)hideHomebrewNotInstalledMessage;

// Operations that return on finish
- (NSArray*)list;
- (NSArray*)listMode:(BP_LIST_MODE)mode;
- (NSArray*)searchForFormulaName:(NSString*)formula;
- (NSString*)informationForFormula:(NSString*)formula;
- (NSString*)update __deprecated;
- (NSString*)upgradeFormula:(NSString*)formula __deprecated;
- (NSString*)upgradeFormulas:(NSArray*)formulas __deprecated;
- (NSString*)installFormula:(NSString*)formula __deprecated;
- (NSString*)uninstallFormula:(NSString*)formula __deprecated;
- (NSString*)runDoctor __deprecated;

// Operations with live data callback block
- (BOOL)updateWithReturnBlock:(void (^)(NSString*))block;
- (BOOL)upgradeFormula:(NSString*)formula withReturnBlock:(void (^)(NSString*))block;
- (BOOL)upgradeFormulas:(NSArray*)formulas withReturnBlock:(void (^)(NSString*))block;
- (BOOL)installFormula:(NSString*)formula withReturnBlock:(void (^)(NSString*))block;
- (BOOL)uninstallFormula:(NSString*)formula withReturnBlock:(void (^)(NSString*))block;
- (BOOL)runDoctorWithReturnBlock:(void (^)(NSString*))block;

@end
