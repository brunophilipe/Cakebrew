//
//  BPDoctorController.m
//  Cakebrew
//
//  Created by Bruno Philipe on 4/7/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import "BPDoctorController.h"
#import "BPHomebrewInterface.h"

@interface BPDoctorController ()

@property (strong) NSMutableString *logString;
@property (strong) NSFileHandle *outputHandle;

@property BOOL isRunning;

@end

@implementation BPDoctorController
{
	NSTimer *timer;
}

- (void)setTextView:(NSTextView *)textView
{
	_textView = textView;

	[_textView setFont:[NSFont fontWithName:@"Andale Mono" size:12]];
}

- (void)updateLog
{
	[self.textView setString:[[NSString alloc] initWithData:[self.outputHandle availableData] encoding:NSUTF8StringEncoding]];
}

- (IBAction)runStopDoctor:(id)sender {
	if (!self.isRunning) {
		self.isRunning = YES;

		NSPipe *pipe;
		pipe = [NSPipe pipe];
		self.outputHandle = [pipe fileHandleForReading];

//		timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(updateLog) userInfo:nil repeats:YES];

		[BPHomebrewInterface runDoctorWithOutput:pipe];

		[self.textView setString:[[NSString alloc] initWithData:[self.outputHandle availableData] encoding:NSUTF8StringEncoding]];

//		[timer invalidate];
	} else {
		self.isRunning = NO;
	}
}

- (IBAction)clearLog:(id)sender {
}
@end
