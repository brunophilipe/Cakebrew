//
//	BrewInterface.h
//	Cakebrew – The Homebrew GUI App for OS X
//
//  Created by Marek Hrusovsky on 24/08/15.
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
@class BPTask;

@protocol BPTaskCompleted <NSObject>
- (void)task:(BPTask *)task didFinishWithOutput:(NSString *)output error:(NSString *)error;
@end

@interface BPTask : NSObject

- (instancetype)initWithPath:(NSString *)path
				   arguments:(NSArray *)arguments;
- (int)execute;
- (void)cleanup;

@property (nonatomic, copy) void (^updateBlock)(NSString *);
@property (readonly) NSString *output;
@property (readonly) NSString *error;
@property (weak) id<BPTaskCompleted> delegate;

@end
