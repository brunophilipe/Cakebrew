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
	[self.textView_doctor setString:@""];
	[self.button_doctor_runStop setEnabled:NO];
	[self.progress_doctor startAnimation:sender];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		[[BPHomebrewInterface sharedInterface] runDoctorWithReturnBlock:^(NSString *output) {
			[_textView_doctor setString:[_textView_doctor.string stringByAppendingString:output]];
		}];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.progress_doctor stopAnimation:sender];
            [self.button_doctor_runStop setEnabled:YES];
        });
	});
}

- (IBAction)clearLogDoctor:(id)sender {
	[self.textView_doctor setString:@""];
}

- (IBAction)runStopUpdate:(id)sender {
	[self.textView_update setString:@""];
	[self.button_update_runStop setEnabled:NO];
	[self.progress_update startAnimation:sender];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		[[BPHomebrewInterface sharedInterface] updateWithReturnBlock:^(NSString *output) {
			[_textView_update setString:[_textView_update.string stringByAppendingString:output]];
		}];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.progress_update stopAnimation:sender];
            [self.button_update_runStop setEnabled:YES];
        });
    });
}

- (IBAction)clearLogUpdate:(id)sender {
	[self.textView_update setString:@""];
}
@end
