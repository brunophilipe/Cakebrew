//
//  BPGenericTextPopoverView.m
//  Cakebrew
//
//  Created by Bruno Philipe on 4/8/14.
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

#import "BPGenericTextPopoverView.h"
#import "BPFormula.h"
#import "BPHomebrewInterface.h"
#import "NSFont+Appearance.h"

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
	NSFont *font = [NSFont bp_defaultFixedWidthFont];
	
	_textView = textView;
	[_textView setFont:font];
	[_textView setTextColor:[NSColor whiteColor]];
}

- (void)setDataObject:(id)dataObject
{
	_dataObject = dataObject;

	if ([dataObject isMemberOfClass:[BPFormula class]]) {
		NSString *string = [[BPHomebrewInterface sharedInterface] informationForFormula:[dataObject performSelector:@selector(name)]];
		if (string) {
			[_textView setString:string];
			[_label_title setStringValue:[NSString stringWithFormat:@"Information for Formula: %@", [dataObject performSelector:@selector(name)]]];
		} else {
			[_textView setString:@"Error retrieving Formula information"];
		}
	}
}

@end
