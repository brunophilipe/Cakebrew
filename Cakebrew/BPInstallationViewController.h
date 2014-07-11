//
//  BPInstallationViewController.h
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
#import "BPFormula.h"
#import "BPHomebrewViewController.h"

@interface BPInstallationViewController : NSViewController

@property (strong) IBOutlet NSTextField *label_windowTitle;
@property (strong) IBOutlet NSTextField *label_formulaName;
@property (strong) IBOutlet NSTextView *textView;
@property (strong) IBOutlet NSButton *button_ok;
@property (strong) IBOutlet NSProgressIndicator *progressIndicator;

@property (assign, nonatomic) BPFormula *formula;
@property (strong, nonatomic) NSArray *formulae;
@property (strong, nonatomic) NSArray *options;
@property (assign) NSWindow *window;
@property (weak) NSWindow *parentSheet;

@property (nonatomic) BPWindowOperation windowOperation;

- (void)windowDidAppear;

- (IBAction)ok:(id)sender;

@end
