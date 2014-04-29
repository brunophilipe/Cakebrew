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

@end

@implementation BPUpdateDoctorController
{
	NSTimer *timer;
}

- (void)setTextView_doctor:(NSTextView *)textView
{
	_textView_doctor = textView;

	NSFont *font;
	font = [NSFont fontWithName:@"Andale Mono" size:12];
	if (!font)
		font = [NSFont fontWithName:@"Menlo" size:12];
	if (!font)
		font = [NSFont systemFontOfSize:12];

	[_textView_doctor setFont:font];
}

- (void)setTextView_update:(NSTextView *)textView
{
	_textView_update = textView;

	NSFont *font;
	font = [NSFont fontWithName:@"Andale Mono" size:12];
	if (!font)
		font = [NSFont fontWithName:@"Menlo" size:12];
	if (!font)
		font = [NSFont systemFontOfSize:12];

	[_textView_update setFont:font];
}

- (void)updateLog
{
	[self.textView_doctor setString:[[NSString alloc] initWithData:[self.outputHandle availableData] encoding:NSUTF8StringEncoding]];
}

- (IBAction)runStopDoctor:(id)sender {
	if (!self.isRunning) {
		self.running = YES;

		NSPipe *pipe;
		pipe = [NSPipe pipe];
		self.outputHandle = [pipe fileHandleForReading];

//		timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(updateLog) userInfo:nil repeats:YES];

		[BPHomebrewInterface runDoctorWithOutput:pipe];

		[self.textView_doctor setString:[[NSString alloc] initWithData:[self.outputHandle availableData] encoding:NSUTF8StringEncoding]];

//		[timer invalidate];
	} else {
		self.running = NO;
	}
}

- (IBAction)clearLogDoctor:(id)sender {
	[self.textView_doctor setString:@""];
}

- (IBAction)runStopUpdate:(id)sender {
	[self.textView_update setString:@""];
	[self.button_update_runStop setEnabled:NO];
	[self.progress_update startAnimation:nil];
	NSBlockOperation *block = [NSBlockOperation blockOperationWithBlock:^{
		NSString *output = [BPHomebrewInterface update];
		[self.textView_update setString:output];
		[self.progress_update stopAnimation:nil];
		[self.button_update_runStop setEnabled:YES];
	}];
	[block performSelector:@selector(start) withObject:nil afterDelay:0.1];
}
@end
