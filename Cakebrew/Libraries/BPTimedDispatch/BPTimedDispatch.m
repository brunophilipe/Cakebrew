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
		[self.dispatchTimer invalidate];
	}
		 
	[self setDispatchTimer:[NSTimer scheduledTimerWithTimeInterval:interval
															target:self
														  selector:@selector(dispatchBlockTimerDidFire:)
														  userInfo:nil
														   repeats:NO]];
}

- (void)dispatchBlockTimerDidFire:(NSTimer*)sender
{
	void (^localBlock)(void) = self.schedulledBlock;
	[self setSchedulledBlock:nil];
	
	dispatch_async(self.dispatchQueue, ^{
		if (localBlock) localBlock();
	});
}

@end
