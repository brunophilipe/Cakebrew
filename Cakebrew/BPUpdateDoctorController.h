//
//  BPDoctorController.h
//  Cakebrew
//
//  Created by Bruno Philipe on 4/7/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
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
