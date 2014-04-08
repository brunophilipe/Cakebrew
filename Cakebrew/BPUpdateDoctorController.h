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
@property (weak) IBOutlet NSButton *button_doctor_runStop;
@property (weak) IBOutlet NSButton *button_doctor_clearLog;
@property (weak) IBOutlet NSButton *button_update_runStop;
@property (weak) IBOutlet NSProgressIndicator *progress_update;

- (IBAction)runStopDoctor:(id)sender;
- (IBAction)clearLogDoctor:(id)sender;

- (IBAction)runStopUpdate:(id)sender;

@end
