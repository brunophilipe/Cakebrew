//
//  BPTimedDispatch.h
//  Cakebrew
//
//  Created by Bruno Philipe on 4/17/15.
//  Copyright (c) 2015 Bruno Philipe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BPTimedDispatch : NSObject

- (void)scheduleDispatchAfterTimeInterval:(NSTimeInterval)interval ofBlock:(void (^)(void))block;
- (void)scheduleDispatchAfterTimeInterval:(NSTimeInterval)interval inQueue:(dispatch_queue_t)queue ofBlock:(void (^)(void))block;

@end
