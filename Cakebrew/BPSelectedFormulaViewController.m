//
//  BPSelectedFormulaViewController.m
//  Cakebrew
//
//  Created by Marek Hrusovsky on 05/09/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import "BPSelectedFormulaViewController.h"
#import "BPFormula.h"
#import "BPTimedDispatch.h"

@interface BPSelectedFormulaViewController ()

@property (strong) BPTimedDispatch *timedDispatch;

@end

@implementation BPSelectedFormulaViewController

- (void)awakeFromNib
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(updatePreferedWidth:)
												 name:NSViewFrameDidChangeNotification
											   object:self.view];
	
	[self setTimedDispatch:[BPTimedDispatch new]];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:NSViewFrameDidChangeNotification
												  object:self.view];
}

- (void)updatePreferedWidth:(id)sender
{
	if ([self.formulaDependenciesLabel respondsToSelector:@selector(preferredMaxLayoutWidth)])
	{
		self.formulaDependenciesLabel.preferredMaxLayoutWidth = self.formulaDependenciesLabel.frame.size.width;
		self.formulaConflictsLabel.preferredMaxLayoutWidth = self.formulaConflictsLabel.frame.size.width;
		self.formulaVersionLabel.preferredMaxLayoutWidth = self.formulaVersionLabel.frame.size.width;
		self.formulaPathLabel.preferredMaxLayoutWidth = self.formulaPathLabel.frame.size.width;
		[[self view] layout];
	}
}

- (NSString *)nibName
{
	return @"BPSelectedFormula";
}

- (void)setFormulae:(NSArray *)formulae
{
	_formulae = formulae;
	[self displayInformationForFormulae];
}

- (void)displayInformationForFormulae
{
	static NSString *emptyString = @"--";
	static NSString *multipleString = @"Multiple values";
	
	if (!self.formulae || [self.formulae count] == 0)
	{
		[self.formulaPathLabel setStringValue:emptyString];
		[self.formulaVersionLabel setStringValue:emptyString];
		[self.formulaDependenciesLabel setStringValue:emptyString];
		[self.formulaConflictsLabel setStringValue:emptyString];
	}
	
	if ([self.formulae count] == 1)
	{
		BPFormula *formula = [self.formulae firstObject];
		
		[self.timedDispatch scheduleDispatchAfterTimeInterval:0.3 inQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0) ofBlock:^{
			[formula getInformation];
			
			if (formula.isInstalled)
			{
				if ([formula.installPath length])
				{
					[self.formulaPathLabel setStringValue:formula.installPath];
				}
				else
				{
					[self.formulaPathLabel setStringValue:emptyString];
				}
			}
			else
			{
				[self.formulaPathLabel setStringValue:@"Formula Not Installed."];
			}
			
			if (formula.latestVersion)
			{
				[self.formulaVersionLabel setStringValue:formula.latestVersion];
			}
			else
			{
				[self.formulaVersionLabel setStringValue:emptyString];
			}
			
			if (formula.dependencies)
			{
				[self.formulaDependenciesLabel setStringValue:formula.dependencies];
			}
			else
			{
				[self.formulaDependenciesLabel setStringValue:@"This formula has no dependencies!"];
			}
			
			if (formula.conflicts)
			{
				[self.formulaConflictsLabel setStringValue:formula.conflicts];
			}
			else
			{
				[self.formulaConflictsLabel setStringValue:@"This formula has no known conflicts."];
			}
		}];
	}
	
	if ([self.formulae count] > 1)
	{
		[self.formulaPathLabel setStringValue:multipleString];
		[self.formulaDependenciesLabel setStringValue:multipleString];
		[self.formulaConflictsLabel setStringValue:multipleString];
		[self.formulaVersionLabel setStringValue:multipleString];
	}
}

@end
