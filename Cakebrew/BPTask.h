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

extern NSString * _Nonnull const kDidBeginBackgroundActivityNotification;
extern NSString * _Nonnull const kDidEndBackgroundActivityNotification;

@class BPTask;

@protocol BPTaskCompleted <NSObject>
- (void)task:(BPTask * _Nonnull)task didFinishWithOutput:(NSString * _Nonnull)output error:(NSString * _Nonnull)error;
@end

@interface BPTask : NSObject

- (_Nonnull instancetype)initWithPath:(NSString * _Nonnull)path
							arguments:(NSArray * _Nonnull)arguments;
- (int)execute;
- (void)cleanup;

@property (nonatomic, nullable, copy) void (^updateBlock)(NSString * _Nonnull);
@property (nonatomic, nullable) dispatch_queue_t updateBlockQueue;
@property (readonly, nonnull) NSString *output;
@property (readonly, nonnull) NSString *error;
@property (weak, nullable) id<BPTaskCompleted> delegate;

@end
