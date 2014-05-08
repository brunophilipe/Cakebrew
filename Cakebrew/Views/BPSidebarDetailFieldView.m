//
//	BPSidebarDetailFieldView.m
//	Cakebrew – The Homebrew GUI App for OS X 
//
//	Created by Bruno Philipe on 4/3/14.
//	Copyright (c) 2014 Bruno Philipe. All rights reserved.
//
//	This program is free software: you can redistribute it and/or modify
//	it under the terms of the GNU General Public License as published by
//	the Free Software Foundation, either version 3 of the License, or
//	(at your option) any later version.
//
//	This program is distributed in the hope that it will be useful,
//	but WITHOUT ANY WARRANTY; without even the implied warranty of
//	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//	GNU General Public License for more details.
//
//	You should have received a copy of the GNU General Public License
//	along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import "BPSidebarDetailFieldView.h"

@implementation BPSidebarDetailFieldView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[self configure];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self configure];
    }
    return self;
}

- (void)configure
{
	self.textColor = [NSColor whiteColor];
}

- (void)drawRect:(NSRect)dirtyRect
{
	NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:self.bounds xRadius:8 yRadius:8];

	[kBPDetailBackgroundColor setFill];

	[path fill];
    
    // Drawing code here.
	[super drawRect:dirtyRect];
}

- (void)setIntegerValue:(NSInteger)anInteger
{
	[super setIntegerValue:anInteger];
	CGFloat stringWidth = [self.attributedStringValue size].width;
	NSRect frame = self.frame;
	frame.size.width = stringWidth+8;
	[self setFrame:frame];
}

@end
