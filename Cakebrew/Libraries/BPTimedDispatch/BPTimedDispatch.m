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

@end

@implementation BPTimedDispatch

- (void)scheduleDispatchAfterTimeInterval:(NSTimeInterval)interval ofBlock:(void (^)(void))block
{
	[self setSchedulledBlock:block];
	
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
	[self setDispatchTimer:nil];
	self.schedulledBlock();
	[self setSchedulledBlock:nil];
}

@end
