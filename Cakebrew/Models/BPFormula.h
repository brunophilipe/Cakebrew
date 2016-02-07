//
//	BPFormula.h
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
#import "BPFormulaOption.h"

extern NSString *const BPFormulaDidUpdateNotification;

@protocol BPFormulaDataProvider <NSObject>
@required
- (NSString *)informationForFormulaName:(NSString *)name;
@end

@interface BPFormula : NSObject <NSCoding, NSCopying>

@property (copy, readonly) NSString *name;
@property (copy, readonly) NSString *version;
@property (nonatomic, copy, readonly) NSString *latestVersion;
@property (copy, readonly) NSString *information;
@property (nonatomic, copy, readonly) NSString *installPath;
@property (nonatomic, copy, readonly) NSString *dependencies;
@property (nonatomic, copy, readonly) NSString *conflicts;
@property (nonatomic, copy, readonly) NSString *shortDescription;
@property (nonatomic, strong, readonly) NSURL    *website;
@property (nonatomic, strong, readonly) NSArray  *options;
@property (assign, readonly, getter=isLeave) BOOL leave; //installed + does not depend on other
@property (assign, readonly, getter=isInstalled) BOOL installed; //installed + does not depend on other

@property BOOL needsInformation;

+ (instancetype)formulaWithName:(NSString *)name;

/**
 *  The short name for the formula. Useful for taps. Returns the remaining substring after the last slash character.
 *
 *  @return The last substring after the last slash character.
 */
- (NSString*)installedName;

- (BOOL)isOutdated;
- (NSString *)status;


- (void)mergeWithFormula:(BPFormula *)formula;
- (BOOL)isEqualToFormula:(BPFormula *)formula;

@end

@protocol BPFormulaBuilder <NSObject>

@required
@property (assign) NSString *name;

@optional
@property (copy) NSString *version;
@property (copy) NSString *latestVersion;
@property BOOL leave;
@property BOOL installed;

@end

@interface BPFormula(BPFormulaBuilder) <BPFormulaBuilder>

+ (instancetype)build:(void(^)(id<BPFormulaBuilder>builder))buildBlock;

@end

