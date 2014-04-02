//
//  BrewInterface.h
//  Cakebrew
//
//  Created by Vincent Saluzzo on 06/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BrewInterface : NSObject
+(NSArray*) list;
+(NSArray*) search:(NSString*)formula;
+(NSString*) info:(NSString*)formula;
+(NSString*) update;
+(NSString*) upgrade:(NSString*)formula;
+(NSString*) install:(NSString*)formula;
+(NSString*) uninstall:(NSString*)formula;
@end
