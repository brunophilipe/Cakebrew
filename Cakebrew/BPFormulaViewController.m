//
//  BPFormulaViewController.m
//  Cakebrew
//
//  Created by Marek Hrusovsky on 06/05/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import "BPFormulaViewController.h"
#import "BPFormula.h"
#import "BPHomebrewInterface.h"

@interface BPFormulaViewController ()

@property (strong, nonatomic) IBOutlet NSTextView *textView;
@property (strong, nonatomic) IBOutlet NSTextField *label_title;

@end

@implementation BPFormulaViewController

- (void)awakeFromNib
{
  NSFont *font;
	font = [NSFont fontWithName:@"Andale Mono" size:12];
	if (!font) {
		font = [NSFont fontWithName:@"Menlo" size:12];
  }
	if (!font) {
		font = [NSFont systemFontOfSize:12];
  }
  [self.textView setFont:font];
	[self.textView setTextColor:[NSColor whiteColor]];
  
  [self updateFields];
}

- (NSString *)nibName
{
  return @"BPFormulaView";
}


- (void)setDataObject:(id)dataObject
{
	_dataObject = dataObject;
  [self updateFields];
}

- (void)updateFields {
	if ([self.dataObject isMemberOfClass:[BPFormula class]]) {
		NSString *string = [[BPHomebrewInterface sharedInterface] informationForFormula:[self.dataObject performSelector:@selector(name)]];
		if (string) {
			[self.textView setString:string];
			[self.label_title setStringValue:[NSString stringWithFormat:@"Information for Formula: %@", [self.dataObject performSelector:@selector(name)]]];
		} else {
			[self.textView setString:@"Error retrieving Formula information"];
		}
	} else {
    [self.textView setString:@""];
    [self.label_title setStringValue:@""];
  }
}

@end
