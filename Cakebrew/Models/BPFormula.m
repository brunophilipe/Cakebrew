//
//	BPFormula.m
//	Cakebrew – The Homebrew GUI App for OS X 
//
//	Created by Bruno Philipe on 4/3/14.
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

#import "BPFormula.h"
#import "BPHomebrewInterface.h"

#define kBP_ENCODE_FORMULA_NAME @"BP_ENCODE_FORMULA_NAME"
#define kBP_ENCODE_FORMULA_IVER @"BP_ENCODE_FORMULA_IVER"
#define kBP_ENCODE_FORMULA_LVER @"BP_ENCODE_FORMULA_LVER"
#define kBP_ENCODE_FORMULA_PATH @"BP_ENCODE_FORMULA_PATH"
#define kBP_ENCODE_FORMULA_WURL @"BP_ENCODE_FORMULA_WURL"
#define kBP_ENCODE_FORMULA_DEPS @"BP_ENCODE_FORMULA_DEPS"
#define kBP_ENCODE_FORMULA_INST @"BP_ENCODE_FORMULA_INST"

@implementation BPFormula

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

	[aCoder encodeObject:[NSNumber numberWithBool:self.installed]		forKey:kBP_ENCODE_FORMULA_INST];
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

		self.installed = [[aDecoder decodeObjectForKey:kBP_ENCODE_FORMULA_INST] boolValue];
	}
	return self;
}

- (BOOL)getInformation
{
	NSString *line = nil, *output = [BPHomebrewInterface informationForFormula:self.name];
	NSArray *lines = [output componentsSeparatedByString:@"\n"];
	NSUInteger lineIndex = 0;
	NSLog(@"%@", lines);

	line = [lines objectAtIndex:0];
	[self setLatestVersion:[line substringFromIndex:[self.name length]+2]];

	line = [lines objectAtIndex:1];
	[self setWebsite:[NSURL URLWithString:line]];

	line = [lines objectAtIndex:2];
	if ([line isEqualToString:@"Not installed"]) {
		[self setInstalled:NO];
	} else {
		[self setInstalled:YES];
		if ([line isEqualToString:@""]) {
			[self setInstallPath:[lines objectAtIndex:3]];
		} else {
			[self setInstallPath:line];
		}
	}

	for (NSUInteger i=3; i<lines.count; i++)
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

	for (NSUInteger i=0; i<lines.count; i++) {
		line = [lines objectAtIndex:lineIndex+i];

		if (![line isEqualToString:@""] && ![line isEqualToString:@"==> Options"]) {
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

@end
