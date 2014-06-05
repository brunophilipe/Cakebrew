//
//	BPFormula.m
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

#import "BPFormula.h"
#import "BPHomebrewInterface.h"
#import "BPHomebrewManager.h"

#define kBP_ENCODE_FORMULA_NAME @"BP_ENCODE_FORMULA_NAME"
#define kBP_ENCODE_FORMULA_IVER @"BP_ENCODE_FORMULA_IVER"
#define kBP_ENCODE_FORMULA_LVER @"BP_ENCODE_FORMULA_LVER"
#define kBP_ENCODE_FORMULA_PATH @"BP_ENCODE_FORMULA_PATH"
#define kBP_ENCODE_FORMULA_WURL @"BP_ENCODE_FORMULA_WURL"
#define kBP_ENCODE_FORMULA_DEPS @"BP_ENCODE_FORMULA_DEPS"
#define kBP_ENCODE_FORMULA_INST @"BP_ENCODE_FORMULA_INST"
#define kBP_ENCODE_FORMULA_CNFL @"BP_ENCODE_FORMULA_CNFL"

@implementation BPFormula

+ (BPFormula*)formulaWithName:(NSString*)name version:(NSString*)version andLatestVersion:(NSString*)latestVersion
{
	BPFormula *formula = [[BPFormula alloc] init];

	if (formula) {
		formula.name = name;
		formula.version = version;
        formula.latestVersion = latestVersion;
		formula.installed = NO;
	}

	return formula;
}

+ (BPFormula*)formulaWithName:(NSString*)name andVersion:(NSString*)version
{
	BPFormula *formula = [[BPFormula alloc] init];

	if (formula) {
		formula.name = name;
		formula.version = version;
		formula.installed = NO;
	}

	return formula;
}

+ (BPFormula*)formulaWithName:(NSString*)name
{
	return [BPFormula formulaWithName:name andVersion:nil];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	if (self.name)				[aCoder encodeObject:self.name			forKey:kBP_ENCODE_FORMULA_NAME];
	if (self.version)			[aCoder encodeObject:self.version		forKey:kBP_ENCODE_FORMULA_IVER];
	if (self.latestVersion)		[aCoder encodeObject:self.latestVersion	forKey:kBP_ENCODE_FORMULA_LVER];
	if (self.installPath)		[aCoder encodeObject:self.installPath	forKey:kBP_ENCODE_FORMULA_PATH];
	if (self.website)			[aCoder encodeObject:self.website		forKey:kBP_ENCODE_FORMULA_WURL];
	if (self.dependencies)		[aCoder encodeObject:self.dependencies	forKey:kBP_ENCODE_FORMULA_DEPS];
	if (self.conflicts)			[aCoder encodeObject:self.conflicts		forKey:kBP_ENCODE_FORMULA_CNFL];

	[aCoder encodeObject:@(self.installed) forKey:kBP_ENCODE_FORMULA_INST];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	if (self) {
		self.name			= [aDecoder decodeObjectForKey:kBP_ENCODE_FORMULA_NAME];
		self.version		= [aDecoder decodeObjectForKey:kBP_ENCODE_FORMULA_IVER];
		self.latestVersion	= [aDecoder decodeObjectForKey:kBP_ENCODE_FORMULA_LVER];
		self.installPath	= [aDecoder decodeObjectForKey:kBP_ENCODE_FORMULA_PATH];
		self.website		= [aDecoder decodeObjectForKey:kBP_ENCODE_FORMULA_WURL];
		self.dependencies	= [aDecoder decodeObjectForKey:kBP_ENCODE_FORMULA_DEPS];
		self.conflicts		= [aDecoder decodeObjectForKey:kBP_ENCODE_FORMULA_CNFL];

		self.installed = [[aDecoder decodeObjectForKey:kBP_ENCODE_FORMULA_INST] boolValue];
	}
	return self;
}

- (BOOL)getInformation
{
    NSString *line         = nil;
    NSString *output       = nil;
    NSArray *lines         = nil;
    NSUInteger lineIndex   = 0;

	output = [[BPHomebrewInterface sharedInterface] informationForFormula:self.name];

	if ([output isEqualToString:@""]) {
		[self setDeprecated:YES];
		return YES;
	}

	lines = [output componentsSeparatedByString:@"\n"];

	lineIndex = 0;
	line = [lines objectAtIndex:lineIndex];
	[self setLatestVersion:[line substringFromIndex:[self.name length]+2]];

	lineIndex = 1;
	line = [lines objectAtIndex:lineIndex];
	[self setWebsite:[NSURL URLWithString:line]];

	lineIndex = 2;
	line = [lines objectAtIndex:lineIndex];
	if ([line rangeOfString:@"Conflicts with:"].location != NSNotFound) {
		[self setConflicts:[line substringFromIndex:15]];
		lineIndex = 3;
		line = [lines objectAtIndex:lineIndex];
	}

	if ([line isEqualToString:@"Not installed"]) {
		[self setInstalled:NO];
	} else {
		[self setInstalled:YES];
		if ([line isEqualToString:@""]) { //keg-only formual has no path
			lineIndex += 1;
			[self setInstallPath:[lines objectAtIndex:lineIndex]];
		} else {
			[self setInstallPath:line];
		}
	}

	NSUInteger i=lineIndex;
	lineIndex = 0;

	for ( ; i<lines.count; i++)
	{
		line = [lines objectAtIndex:i];
		if ([line isEqualToString:@"==> Dependencies"]) {
			lineIndex = i+1;
			break;
		}
	}

	if (lineIndex == 0) {
		return YES;
	}

	[self setDependencies:nil];

	for (i=0; i<lines.count; i++) {
		line = [lines objectAtIndex:lineIndex+i];

		if (![line isEqualToString:@""] && ![line isEqualToString:@"==> Options"] && ![line isEqualToString:@"==> Caveats"]) {
			if (self.dependencies) {
				self.dependencies = [self.dependencies stringByAppendingFormat:@"; %@", line];
			} else {
				self.dependencies = line;
			}
		} else {
			return YES;
		}
	}

	return YES;
}

- (BOOL)isOutdated
{
	return [[BPHomebrewManager sharedManager] statusForFormula:self] == kBPFormulaOutdated;
}

@end
