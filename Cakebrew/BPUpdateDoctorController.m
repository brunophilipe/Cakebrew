//
//  BPDoctorController.m
//  Cakebrew
//
//  Created by Bruno Philipe on 4/7/14.
//	Copyright (c) 2014 Bruno Philipe. All rights reserved.
//
//	This program is free software: you can redistribute it and/or modify
//	it under the terms of the GNU General Public License as published by
//	the Free Software Foundation, either version 3 of the License, or
//	(at your option) any later version.
//
//	This program is distributed in the hope that it will be useful,
//	but WITHOUT ANY WARRANTY; without even the implied warranty of
//	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	See the
//	GNU General Public License for more details.
//
//	You should have received a copy of the GNU General Public License
//	along with this program.	If not, see <http://www.gnu.org/licenses/>.
//

#import "BPUpdateDoctorController.h"
#import "BPHomebrewInterface.h"

@interface BPUpdateDoctorController ()

@property (strong) NSMutableString *logString;
@property (strong) NSFileHandle    *outputHandle;

@end

@implementation BPUpdateDoctorController
{
	NSTimer *timer;
}

- (void)setTextView_doctor:(NSTextView *)textView
{
	NSFont *font = [BPAppDelegateRef defaultFixedWidthFont];

	_textView_doctor = textView;
	[_textView_doctor setFont:font];
}

- (void)setTextView_update:(NSTextView *)textView
{
	NSFont *font = [BPAppDelegateRef defaultFixedWidthFont];
	
	_textView_update = textView;
	[_textView_update setFont:font];
}

- (void)updateLog
{
	[self.textView_doctor setString:[[NSString alloc] initWithData:[self.outputHandle availableData] encoding:NSUTF8StringEncoding]];
}

- (IBAction)runStopDoctor:(id)sender {
	BPAppDelegate *appDelegate = BPAppDelegateRef;

	if (appDelegate.isRunningBackgroundTask)
	{
		[appDelegate displayBackgroundWarning];
		return;
	}
	[appDelegate setRunningBackgroundTask:YES];

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
			[appDelegate setRunningBackgroundTask:NO];
        });
	});
}

- (IBAction)clearLogDoctor:(id)sender {
	[self.textView_doctor setString:@""];
}

- (IBAction)runStopUpdate:(id)sender {
	BPAppDelegate *appDelegate = BPAppDelegateRef;

	if (appDelegate.isRunningBackgroundTask)
	{
		[appDelegate displayBackgroundWarning];
		return;
	}
	[appDelegate setRunningBackgroundTask:YES];

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
			[appDelegate setRunningBackgroundTask:NO];
        });
    });
}

- (IBAction)clearLogUpdate:(id)sender {
	[self.textView_update setString:@""];
}
@end
