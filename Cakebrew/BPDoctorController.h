//
//  BPDoctorController.h
//  Cakebrew
//
//  Created by Bruno Philipe on 4/7/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BPDoctorController : NSViewController

@property (assign, nonatomic) IBOutlet NSTextView *textView;
@property (weak) IBOutlet NSButton *button_runStop;
@property (weak) IBOutlet NSButton *button_clearLog;

- (IBAction)runStopDoctor:(id)sender;
- (IBAction)clearLog:(id)sender;

@end
