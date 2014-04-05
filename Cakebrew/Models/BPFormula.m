//
//  BPFormula.m
//  Cakebrew
//
//  Created by Bruno Philipe on 4/3/14.
//
//

#import "BPFormula.h"

#define kBP_ENCODE_FORMULA_NAME @"BP_ENCODE_FORMULA_NAME"
#define kBP_ENCODE_FORMULA_IVER @"BP_ENCODE_FORMULA_IVER"
#define kBP_ENCODE_FORMULA_LVER @"BP_ENCODE_FORMULA_LVER"
#define kBP_ENCODE_FORMULA_PATH @"BP_ENCODE_FORMULA_PATH"
#define kBP_ENCODE_FORMULA_WURL @"BP_ENCODE_FORMULA_WURL"

@implementation BPFormula

+ (BPFormula*)formulaWithName:(NSString*)name andVersion:(NSString*)version
{
	BPFormula *formula = [[BPFormula alloc] init];

	if (formula) {
		formula.name = name;
		formula.version = version;
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
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	if (self) {
		self.name			= [aDecoder decodeObjectForKey:kBP_ENCODE_FORMULA_NAME];
		self.version		= [aDecoder decodeObjectForKey:kBP_ENCODE_FORMULA_NAME];
		self.latestVersion	= [aDecoder decodeObjectForKey:kBP_ENCODE_FORMULA_NAME];
		self.installPath	= [aDecoder decodeObjectForKey:kBP_ENCODE_FORMULA_NAME];
		self.website		= [aDecoder decodeObjectForKey:kBP_ENCODE_FORMULA_NAME];
	}
	return self;
}

@end
