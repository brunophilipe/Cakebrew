//
//  BPGenericTextPopoverView.m
//  Cakebrew
//
//  Created by Bruno Philipe on 4/8/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import "BPGenericTextPopoverView.h"
#import "BPFormula.h"
#import "BPHomebrewInterface.h"

@implementation BPGenericTextPopoverView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)setTextView:(NSTextView *)textView
{
	_textView = textView;
	[_textView setFont:[NSFont fontWithName:@"Andale Mono" size:12]];
	[_textView setTextColor:[NSColor whiteColor]];
}

- (void)setDataObject:(id)dataObject
{
	_dataObject = dataObject;

	if ([dataObject isMemberOfClass:[BPFormula class]]) {
		NSString *string = [BPHomebrewInterface informationForFormula:[dataObject performSelector:@selector(name)]];
		if (string) {
			[_textView setString:string];
			[_label_title setStringValue:[NSString stringWithFormat:@"Information for Formula: %@", [dataObject performSelector:@selector(name)]]];
		} else {
			[_textView setString:@"Error retrieving Formula information"];
		}
	}
}

@end
