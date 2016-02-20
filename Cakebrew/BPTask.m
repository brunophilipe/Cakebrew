
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

#import "BPTask.h"

static BOOL systemHasAppNap;

@interface BPTask()
{
	id activity;
	NSPipe *outputPipe;
	NSPipe *errorPipe;
	NSPipe *inputPipe;
	NSFileHandle *outputFileHandle;
	NSFileHandle *errorFileHandle;
	NSMutableData *outputData;
	NSMutableData *errorData;
	NSObject *outputHandlerObserver;
	NSObject *errorHandlerObserver;
	void (^operationUpdateBlock)(NSString*);
}

@property (strong) NSTask *task;
@property (readwrite) NSString *output;
@property (readwrite) NSString *error;

@end

@implementation BPTask

+ (void)load
{
	systemHasAppNap = [[NSProcessInfo processInfo] respondsToSelector:@selector(beginActivityWithOptions:reason:)];
}

- (instancetype)initWithPath:(NSString *)path arguments:(NSArray *)arguments
{
	self = [super init];
	if (self)
	{
		_task = [self taskWithPath:path arguments:arguments];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(taskDidTerminate:)
													 name:NSTaskDidTerminateNotification object:_task];
		outputData = [[NSMutableData alloc] init];
		errorData = [[NSMutableData alloc] init];
	}
	return self;
}

- (NSTask *)taskWithPath:(NSString *)path arguments:(NSArray *)arguments
{
	if (!path)
	{
		return nil;
	}
	
	NSTask *task = [[NSTask alloc] init];
	[task setLaunchPath:path];
	[task setArguments:arguments];
	return task;
}

- (BOOL)shouldUsePartialUpdates
{
	return self.updateBlock != nil;
}

- (void)configureStandardOutput
{
	outputPipe = [NSPipe pipe];
	[self.task setStandardOutput:outputPipe];
}

- (void)configureStandardError
{
	errorPipe = [NSPipe pipe];
	[self.task setStandardError:errorPipe];
}

- (void)configureOutputFileHandle
{
	outputFileHandle = [outputPipe fileHandleForReading];
	if ([self shouldUsePartialUpdates])
	{
		[outputFileHandle waitForDataInBackgroundAndNotify];
		outputHandlerObserver = [[NSNotificationCenter defaultCenter] addObserverForName:NSFileHandleDataAvailableNotification
																				  object:outputFileHandle
																				   queue:[NSOperationQueue currentQueue]
																			  usingBlock:^(NSNotification *note) {
																				  [self updatedFileHandle:note];
																			  }];
	}
}

- (void)configureErrorFileHandle
{
	errorFileHandle = [errorPipe fileHandleForReading];
	if ([self shouldUsePartialUpdates] )
	{
		[errorFileHandle waitForDataInBackgroundAndNotify];
		errorHandlerObserver = [[NSNotificationCenter defaultCenter] addObserverForName:NSFileHandleDataAvailableNotification
																				 object:errorFileHandle
																				  queue:[NSOperationQueue currentQueue]
																			 usingBlock:^(NSNotification *note) {
																				 [self updatedFileHandle:note];
																			 }];
	}
}

- (void)processStandardOutput
{
	if(![self shouldUsePartialUpdates]) {
		NSData *data = [outputFileHandle readDataToEndOfFile];
		if ([data length]) {
			self.output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		}
		
	} else {
		if ([outputData length]) {
			self.output = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
		}
	}
}

- (void)processStandardError
{
	if(![self shouldUsePartialUpdates]) {
		NSData *data = [errorFileHandle readDataToEndOfFile];
		if ([data length]) {
			self.error = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		}
	} else {
		if ([errorData length]) {
			self.error = [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding];
		}
	}
}

- (int)execute
{
	[self configureStandardOutput];
	[self configureStandardError];
	[self configureOutputFileHandle];
	[self configureErrorFileHandle];
	[self beginActivity];
	@try {
		[self.task launch];
		[self.task waitUntilExit]; //this makes sure that we stay in the same run loop (thread); needed for notifications
		
		return [self.task terminationStatus];
	}
	@catch (NSException *exception) {
		NSLog(@"Exception: %@", exception);
		[self cleanup];
		
		return -1;
	}
}

- (void)updatedFileHandle:(NSNotification*)notification
{
	NSFileHandle *fileHandle = [notification object];
	NSData *data = [fileHandle availableData];
	if (fileHandle == outputFileHandle) {
		[outputData appendData:data];
	}
	if (fileHandle == errorFileHandle) {
		[errorData appendData:data];
	}
	[fileHandle waitForDataInBackgroundAndNotify];
	if (data && data.length > 0) {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
			self.updateBlock([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
		});
	}
}

- (void)taskDidTerminate:(NSNotification *)notification
{
	[self processStandardOutput];
	[self processStandardError];
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:NSTaskDidTerminateNotification
												  object:self.task];
	
	[[NSNotificationCenter defaultCenter] removeObserver:outputHandlerObserver];
	[[NSNotificationCenter defaultCenter] removeObserver:errorHandlerObserver];
	
	outputHandlerObserver = nil;
	errorHandlerObserver = nil;
	
	[self endActivity];
	
	if (self.delegate)
	{
		if ([self.delegate respondsToSelector:@selector(task:didFinishWithOutput:error:)])
		{
			[self.delegate task:self didFinishWithOutput:self.output error:self.error];
		}
	}
}

- (void)beginActivity
{
	if (systemHasAppNap)
	{
		activity = [[NSProcessInfo processInfo] beginActivityWithOptions:NSActivityUserInitiated
																  reason:NSLocalizedString(@"Homebrew_AppNap_Task_Reason", nil)];
	}
}

- (void)endActivity
{
	if (systemHasAppNap)
	{
		[[NSProcessInfo processInfo] endActivity:activity];
		activity = nil;
	}
}

- (void)cleanup
{
	[self.task terminate];
	[self endActivity];
	
	outputData = nil;
	errorData = nil;
	outputFileHandle = nil;
	errorFileHandle = nil;
	
	[[NSNotificationCenter defaultCenter] removeObserver:outputHandlerObserver];
	[[NSNotificationCenter defaultCenter] removeObserver:errorHandlerObserver];
	
	outputHandlerObserver = nil;
	errorHandlerObserver = nil;
}

- (void)dealloc
{
	self.updateBlock = nil;
	[self cleanup];
}


@end
