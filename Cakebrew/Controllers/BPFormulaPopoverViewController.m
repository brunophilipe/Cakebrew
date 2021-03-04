//
//  BPFormulaPopoverViewController.m
//  Cakebrew
//
//  Created by Marek Hrusovsky on 05/09/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import "BPFormulaPopoverViewController.h"
#import "BPFormula.h"
#import "BPHomebrewInterface.h"
#import "BPTimedDispatch.h"
#import "BPStyle.h"

@interface BPFormulaPopoverViewController ()

@property (strong) BPTimedDispatch *timedDispatch;

@end

@implementation BPFormulaPopoverViewController

- (void)awakeFromNib
{
	NSFont *font = [BPStyle defaultFixedWidthFont];
	[self.formulaTextView setFont:font];
	[self.formulaTextView setTextColor:[BPStyle popoverTextViewColor]];
	[self.formulaPopover setContentViewController:self];
	[self setTimedDispatch:[BPTimedDispatch new]];
	[self.formulaTitleLabel setTextColor:[BPStyle popoverTitleColor]];
	[self setInfoType:kBPFormulaInfoTypeGeneral];
}

- (void)setFormula:(BPFormula *)formula
{
	if (_formula)
	{
		[[NSNotificationCenter defaultCenter] removeObserver:self
														name:BPFormulaDidUpdateNotification
													  object:_formula];
	}
	
	_formula = formula;
	[_formulaTextView setString:@""];
	
	switch ([self infoType])
	{
		case kBPFormulaInfoTypeGeneral:
		{
			NSString *titleFormat = NSLocalizedString(@"Formula_Popover_Title", nil);
			[self.formulaTitleLabel setStringValue:[NSString stringWithFormat:titleFormat, [formula name]]];

			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateView:)
														 name:BPFormulaDidUpdateNotification
													   object:formula];

			dispatch_async(dispatch_get_main_queue(), ^{
				[self displayConsoleInformationForFormula];
			});

			dispatch_queue_t bgQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);

			[self.timedDispatch scheduleDispatchAfterTimeInterval:0.3 inQueue:bgQueue ofBlock:
				^{
					[formula setNeedsInformation:YES];
				}];
		}
		break;

		case kBPFormulaInfoTypeInstalledDependents:
		case kBPFormulaInfoTypeAllDependents:
			[self displayDependentsInformationForFormula];
			break;
	}
	
}

- (NSString *)nibName
{
	return @"BPFormulaPopoverView";
}

- (void)updateView:(NSNotification *)notification
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[self displayConsoleInformationForFormula];
	});
}

- (void)displayConsoleInformationForFormula
{
	NSString *string = self.formula.information;
	if (string) {
		[self.progressIndicator stopAnimation:nil];
		[self.formulaTextView setString:string];
		
		// Recognize links in info text
		[self.formulaTextView setEditable:YES];
		[self.formulaTextView checkTextInDocument:nil];
		[self.formulaTextView setEditable:NO];
		
		[self.formulaTextView scrollToBeginningOfDocument:nil];
	}
}

- (void)displayDependentsInformationForFormula
{
	NSString *name = [self.formula name];

	[self.formulaTextView setString:@""];
	[self.progressIndicator startAnimation:nil];

	if (self.infoType == kBPFormulaInfoTypeInstalledDependents)
	{
		[self.formulaTitleLabel setStringValue:[NSString stringWithFormat:NSLocalizedString(@"Formula_Installed_Dependents_Title", nil), name]];

		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
			NSString *string = [[BPHomebrewInterface sharedInterface] dependantsForFormulaName:name onlyInstalled:YES];

			dispatch_async(dispatch_get_main_queue(), ^{
				[self.progressIndicator stopAnimation:nil];
				[self.formulaTextView setString:string];
				[self.formulaTextView scrollToBeginningOfDocument:nil];
				[self.formulaTextView setNeedsDisplay:YES];
			});
		});
	}
	else if (self.infoType == kBPFormulaInfoTypeAllDependents)
	{
		[self.formulaTitleLabel setStringValue:[NSString stringWithFormat:NSLocalizedString(@"Formula_All_Dependents_Title", nil), name]];

		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
			NSString *string = [[BPHomebrewInterface sharedInterface] dependantsForFormulaName:name onlyInstalled:NO];

			dispatch_async(dispatch_get_main_queue(), ^{
				[self.progressIndicator stopAnimation:nil];
				[self.formulaTextView setString:string];
				[self.formulaTextView scrollToBeginningOfDocument:nil];
				[self.formulaTextView setNeedsDisplay:YES];
			});

		});
	}
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
