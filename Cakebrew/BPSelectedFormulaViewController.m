//
//  BPSelectedFormulaViewController.m
//  Cakebrew
//
//  Created by Marek Hrusovsky on 05/09/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import "BPSelectedFormulaViewController.h"
#import "BPFormula.h"

@interface BPSelectedFormulaViewController ()

@end

@implementation BPSelectedFormulaViewController

- (void)setFormulae:(NSArray *)formulae
{
  _formulae = formulae;
  [self displayInformationForFormulae];
}

- (void)displayInformationForFormulae
{
	static NSString *emptyString = @"--";
  static NSString *multipleString = @"Multiple values";
  
  if (!self.formulae || [self.formulae count] == 0) {
    [self.formulaPathLabel setStringValue:emptyString];
    [self.formulaVersionLabel setStringValue:emptyString];
    [self.formulaDependenciesLabel setStringValue:emptyString];
    [self.formulaConflictsLabel setStringValue:emptyString];
  }
  if ([self.formulae count] == 1) {
    BPFormula *formula = [self.formulae firstObject];
    [formula getInformation];
    if (formula.isInstalled) {
      [self.formulaPathLabel setStringValue:formula.installPath];
    } else {
      [self.formulaPathLabel setStringValue:@"Formula Not Installed."];
    }
    if (formula.latestVersion) {
      [self.formulaVersionLabel setStringValue:formula.latestVersion];
    } else {
      [self.formulaVersionLabel setStringValue:emptyString];
    }
    
    if (formula.dependencies) {
      [self.formulaDependenciesLabel setStringValue:formula.dependencies];
    } else {
      [self.formulaDependenciesLabel setStringValue:@"This formula has no dependencies!"];
    }
    
    if (formula.conflicts) {
      [self.formulaConflictsLabel setStringValue:formula.conflicts];
    } else {
      [self.formulaConflictsLabel setStringValue:@"This formula has no known conflicts."];
    }
  }
  if ([self.formulae count] > 1) {
    [self.formulaPathLabel setStringValue:multipleString];
    [self.formulaDependenciesLabel setStringValue:multipleString];
    [self.formulaConflictsLabel setStringValue:multipleString];
    [self.formulaVersionLabel setStringValue:multipleString];
  }
}

@end
