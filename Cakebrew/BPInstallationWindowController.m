//
//  BPInstallationWindowController.m
//  Cakebrew
//
//  Created by Marek Hrusovsky on 21/08/14.
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

#import "BPInstallationWindowController.h"
#import "BPHomebrewInterface.h"

static void * BPInstallationWindowControllerContext = &BPInstallationWindowControllerContext;

@interface BPInstallationWindowController ()

@property (weak) IBOutlet NSTextField *windowTitleLabel;
@property (weak) IBOutlet NSTextField *formulaNameLabel;
@property (unsafe_unretained) IBOutlet NSTextView *recordTextView; //NSTextView does not support weak in ARC at all (not just 10.7)
@property (weak) IBOutlet NSButton *okButton;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;

@end

@implementation BPInstallationWindowController

- (void)awakeFromNib {
  NSFont *font = [BPAppDelegateRef defaultFixedWidthFont];	
  [self.recordTextView setFont:font];
  [self.recordTextView setSelectable:YES];

  [self addObserver:self forKeyPath:@"windowOperation"
            options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
            context:BPInstallationWindowControllerContext];
  [self addObserver:self forKeyPath:@"formulae"
            options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
            context:BPInstallationWindowControllerContext];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(addObjects:)
                                               name:@""
                                             object:nil];
}

- (instancetype)initWithWindow:(NSWindow *)window {
  self = [super initWithWindow:window];
  if (self) {
    _windowOperation = kBPWindowOperationInstall;
  }
  
  return self;
}

- (NSString *)windowNibName {
  return @"BPInstallationWindow";
}


- (NSArray*)namesOfAllFormulae
{
	NSMutableArray *names = [NSMutableArray arrayWithCapacity:self.formulae.count];
	for (BPFormula *formula in self.formulae) {
		[names addObject:formula.name];
	}
	return [names copy];
}

- (void)executeInstallation
{
  [self.okButton setEnabled:NO];
	[self.progressIndicator startAnimation:nil];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    NSString __block *outputValue;
    BPHomebrewInterface *homebrewInterface = [BPHomebrewInterface sharedInterface];
		if (self.windowOperation == kBPWindowOperationInstall)
		{
			NSString *name = [[self.formulae firstObject] name];
			[homebrewInterface installFormula:name
                            withOptions:self.options
                         andReturnBlock:^(NSString *output) {
                           if (outputValue) {
                             outputValue = [outputValue stringByAppendingString:output];
                           } else {
                             outputValue = output;
                           }
                           [self.recordTextView performSelectorOnMainThread:@selector(setString:)
                                                                 withObject:outputValue
                                                              waitUntilDone:YES];
			}];
		}
		else if (self.windowOperation == kBPWindowOperationUninstall)
		{
			NSString *name = [[self.formulae firstObject] name];
			[homebrewInterface uninstallFormula:name
                          withReturnBlock:^(NSString *output) {
                            if (outputValue) {
                              outputValue = [outputValue stringByAppendingString:output];
                            } else {
                              outputValue = output;
                            }
                            [self.recordTextView performSelectorOnMainThread:@selector(setString:)
                                                                  withObject:outputValue
                                                               waitUntilDone:YES];
			}];
		}
		else if (self.windowOperation == kBPWindowOperationUpgrade)
		{
			if (self.formulae) {
				NSArray *names = [self namesOfAllFormulae];
				[homebrewInterface upgradeFormulae:names
                           withReturnBlock:^(NSString *output) {
                             if (outputValue) {
                               outputValue = [outputValue stringByAppendingString:output];
                             } else {
                               outputValue = output;
                             }
                             [self.recordTextView performSelectorOnMainThread:@selector(setString:)
                                                                   withObject:outputValue
                                                                waitUntilDone:YES];
				}];
			} else {
				[homebrewInterface upgradeFormula:kBP_UPGRADE_ALL_FORMULAS
                          withReturnBlock:^(NSString *output) {
                            if (outputValue) {
                              outputValue = [outputValue stringByAppendingString:output];
                            } else {
                              outputValue = output;
                            }
                            [self.recordTextView performSelectorOnMainThread:@selector(setString:)
                                                            withObject:outputValue
                                                         waitUntilDone:YES];
				}];
			}
		}
		[self.progressIndicator stopAnimation:nil];
		[self.okButton setEnabled:YES];

	});
}



- (IBAction)okAction:(id)sender {
  self.recordTextView.string = @"";
  NSWindow *mainWindow = [NSApp mainWindow];
	if ([mainWindow respondsToSelector:@selector(endSheet:)]) {
		[mainWindow endSheet:self.window];
	} else {
		[[NSApplication sharedApplication] endSheet:self.window];
	}
  
	[[NSNotificationCenter defaultCenter] postNotificationName:kBP_NOTIFICATION_FORMULAS_CHANGED
                                                      object:nil];
}

- (void)dealloc {
  [self removeObserver:self
            forKeyPath:@"windowOperation"
               context:BPInstallationWindowControllerContext];
  [self removeObserver:self
            forKeyPath:@"formulae"
               context:BPInstallationWindowControllerContext];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  
  if (context == BPInstallationWindowControllerContext) {
    
    if ([keyPath isEqualTo:@"windowOperation"]) {
      NSString *message;
      switch (self.windowOperation) {
        case kBPWindowOperationInstall:
          message = @"Installing Formula:";
          break;
          
        case kBPWindowOperationUninstall:
          message = @"Uninstalling Formula:";
          break;
          
        case kBPWindowOperationUpgrade:
          message = @"Upgrading Formula:";
          break;
      }
      [self.windowTitleLabel setStringValue:message];
    }
    if ([keyPath isEqualTo:@"formulae"]) {
      NSUInteger count = [self.formulae count];
      
      if (count == 1) {
        self.formulaNameLabel.stringValue = [(BPFormula*)[self.formulae firstObject] name];
      } else if (count > 1) {
        NSString *formulaeNames = [[self namesOfAllFormulae] componentsJoinedByString:@", "];
        self.formulaNameLabel.stringValue = formulaeNames;
      } else {
        self.formulaNameLabel.stringValue = @"All Outdated Formulae";
      }
    }
    
  } else {
    
    @try {
      [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    @catch (NSException *exception) {
      ;
    }
  }
}

@end
