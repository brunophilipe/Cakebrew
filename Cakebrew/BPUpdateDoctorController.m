//
//  BPDoctorController.m
//  Cakebrew
//
//  Created by Bruno Philipe on 4/7/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import "BPUpdateDoctorController.h"
#import "BPHomebrewInterface.h"

@interface BPUpdateDoctorController ()

@property (strong) NSMutableString *logString;
@property (strong) NSFileHandle *outputHandle;

@property BOOL isRunning;

@end

@implementation BPUpdateDoctorController
{
	NSTimer *timer;
}

- (void)setTextView_doctor:(NSTextView *)textView
{
	_textView_doctor = textView;
	[_textView_doctor setFont:[NSFont fontWithName:@"Andale Mono" size:12]];
}

- (void)setTextView_update:(NSTextView *)textView
{
	_textView_update = textView;
	[_textView_update setFont:[NSFont fontWithName:@"Andale Mono" size:12]];
}

- (void)updateLog
{
	[self.textView_doctor setString:[[NSString alloc] initWithData:[self.outputHandle availableData] encoding:NSUTF8StringEncoding]];
}

- (IBAction)runStopDoctor:(id)sender {
	if (!self.isRunning) {
		self.isRunning = YES;

		NSPipe *pipe;
		pipe = [NSPipe pipe];
		self.outputHandle = [pipe fileHandleForReading];

//		timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(updateLog) userInfo:nil repeats:YES];

		[BPHomebrewInterface runDoctorWithOutput:pipe];

		[self.textView_doctor setString:[[NSString alloc] initWithData:[self.outputHandle availableData] encoding:NSUTF8StringEncoding]];

//		[timer invalidate];
	} else {
		self.isRunning = NO;
	}
}

- (IBAction)clearLogDoctor:(id)sender {
	[self.textView_doctor setString:@""];
}

- (IBAction)runStopUpdate:(id)sender {
	NSString *output = [BPHomebrewInterface update];
	[self.textView_update setString:output];
}
@end
