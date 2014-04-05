//
//  BPFormula.h
//  Cakebrew
//
//  Created by Bruno Philipe on 4/3/14.
//
//

#import <Foundation/Foundation.h>

@interface BPFormula : NSObject <NSCoding>

@property (strong) NSString *name;
@property (strong) NSString *version;
@property (strong) NSString *latestVersion;
@property (strong) NSString *installPath;
@property (strong) NSURL *website;

+ (BPFormula*)formulaWithName:(NSString*)name andVersion:(NSString*)version;
+ (BPFormula*)formulaWithName:(NSString*)name;

@end
