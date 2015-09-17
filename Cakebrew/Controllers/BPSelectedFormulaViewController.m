//
//  BPSelectedFormulaViewController.m
//  Cakebrew
//
//  Created by Marek Hrusovsky on 05/09/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import "BPSelectedFormulaViewController.h"
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
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updatePreferedWidth:(id)sender
{
	if ([self.formulaDependenciesLabel respondsToSelector:@selector(preferredMaxLayoutWidth)])
	{
		self.formulaDescriptionLabel.preferredMaxLayoutWidth = self.formulaDescriptionLabel.frame.size.width;
		self.formulaDependenciesLabel.preferredMaxLayoutWidth	= self.formulaDependenciesLabel.frame.size.width;
		self.formulaConflictsLabel.preferredMaxLayoutWidth		= self.formulaConflictsLabel.frame.size.width;
		self.formulaVersionLabel.preferredMaxLayoutWidth		= self.formulaVersionLabel.frame.size.width;
		self.formulaPathLabel.preferredMaxLayoutWidth			= self.formulaPathLabel.frame.size.width;
		[[self view] layoutSubtreeIfNeeded];
	}
}

- (NSString *)nibName
{
	return @"BPSelectedFormula";
}

- (void)setFormulae:(NSArray *)formulae
{
	for (BPFormula *formula in _formulae) {
		[[NSNotificationCenter defaultCenter] removeObserver:self
														name:BPFormulaDidUpdateNotification
													  object:formula];
	}
	_formulae = formulae;
	for (BPFormula *formula in formulae) {
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(updateFormulaInformation:)
													 name:BPFormulaDidUpdateNotification
												   object:formula];
	}
	[self displayInformationForFormulae];
	[self.timedDispatch scheduleDispatchAfterTimeInterval:0.3
												  inQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
												  ofBlock:^
	 {
		 BPFormula *formula = [self.formulae firstObject];
		 [formula setNeedsInformation:YES];
	 }];
}

- (void)updateFormulaInformation:(NSNotification *)notification
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[self displayInformationForFormulae];
	});
}

- (void)displayInformationForFormulae
{
	static NSString *emptyString = @"--";
	
	NSString *multipleString = NSLocalizedString(@"Info_View_Multiple_Values", nil);
	
	if (!self.formulae || [self.formulae count] == 0)
	{
		[self.formulaDescriptionLabel	setStringValue:emptyString];
		[self.formulaPathLabel			setStringValue:emptyString];
		[self.formulaVersionLabel		setStringValue:emptyString];
		[self.formulaDependenciesLabel	setStringValue:emptyString];
		[self.formulaConflictsLabel		setStringValue:emptyString];
	}
	
	if ([self.formulae count] == 1)
	{
		BPFormula *formula = [self.formulae firstObject];
		
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
			[self.formulaPathLabel setStringValue:NSLocalizedString(@"Info_View_Formula_Not_Installed", nil)];
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
			[self.formulaDependenciesLabel setStringValue:NSLocalizedString(@"Info_View_Formula_No_Dependencies", nil)];
		}
		
		if (formula.conflicts)
		{
			[self.formulaConflictsLabel setStringValue:formula.conflicts];
		}
		else
		{
			[self.formulaConflictsLabel setStringValue:NSLocalizedString(@"Info_View_Formula_No_Conflicts", nil)];
		}
		
		if (formula.shortDescription)
		{
			[self.formulaDescriptionLabel setStringValue:formula.shortDescription];
		}
		else
		{
			[self.formulaDescriptionLabel setStringValue:NSLocalizedString(@"Info_View_Formula_No_Description", nil)];
		}
		
		if ([self.delegate respondsToSelector:@selector(selectedFormulaViewDidUpdateFormulaInfoForFormula:)])
		{
			[self.delegate selectedFormulaViewDidUpdateFormulaInfoForFormula:formula];
		}
		
		if ([self.formulae count] > 1)
		{
			[self.formulaPathLabel setStringValue:multipleString];
			[self.formulaDependenciesLabel setStringValue:multipleString];
			[self.formulaConflictsLabel setStringValue:multipleString];
			[self.formulaVersionLabel setStringValue:multipleString];
		}
	}
}
@end
