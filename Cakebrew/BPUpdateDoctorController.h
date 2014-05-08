//
//  BPDoctorController.h
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

#import <Cocoa/Cocoa.h>

@interface BPUpdateDoctorController : NSViewController

@property (assign, nonatomic) IBOutlet NSTextView *textView_doctor;
@property (assign, nonatomic) IBOutlet NSTextView *textView_update;
@property (assign) IBOutlet NSButton *button_doctor_runStop;
@property (assign) IBOutlet NSButton *button_doctor_clearLog;
@property (assign) IBOutlet NSButton *button_update_runStop;
@property (assign) IBOutlet NSProgressIndicator *progress_update;
@property (assign) IBOutlet NSProgressIndicator *progress_doctor;

@property (getter = isRunning) BOOL running;

- (IBAction)runStopDoctor:(id)sender;
- (IBAction)clearLogDoctor:(id)sender;

- (IBAction)runStopUpdate:(id)sender;
- (IBAction)clearLogUpdate:(id)sender;

@end
