//
//  BPTimedDispatch.m
//  Cakebrew
//
//  Created by Bruno Philipe on 4/17/15.
//  Copyright (c) 2015 Bruno Philipe. All rights reserved.
//

#import "BPTimedDispatch.h"

@interface BPTimedDispatch ()

@property (nonatomic, copy) void (^schedulledBlock)(void);
@property (atomic, strong) NSTimer *dispatchTimer;
@property dispatch_queue_t dispatchQueue;

@end

@implementation BPTimedDispatch

- (void)scheduleDispatchAfterTimeInterval:(NSTimeInterval)interval ofBlock:(void (^)(void))block
{
	[self scheduleDispatchAfterTimeInterval:interval inQueue:dispatch_get_main_queue() ofBlock:block];
}

- (void)scheduleDispatchAfterTimeInterval:(NSTimeInterval)interval inQueue:(dispatch_queue_t)queue ofBlock:(void (^)(void))block
{
	[self setSchedulledBlock:block];
	[self setDispatchQueue:queue];
	
	if (self.dispatchTimer)
	{
		[self.dispatchTimer setFireDate:[[NSDate new] dateByAddingTimeInterval:interval]];
	}
	else
	{
		[self setDispatchTimer:[NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(dispatchBlock) userInfo:nil repeats:NO]];
	}
}

- (void)dispatchBlock
{
	dispatch_async(self.dispatchQueue, ^{
		self.schedulledBlock();
		
		[self setDispatchTimer:nil];
		[self setSchedulledBlock:nil];
	});
}

@end
