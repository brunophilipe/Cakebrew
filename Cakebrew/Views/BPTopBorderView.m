//
//	BPTopMarginView.m
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

#import "BPTopBorderView.h"

@interface BPTopBorderView ()

@property (strong) NSBezierPath *topPath;

@end

@implementation BPTopBorderView

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
	[self setTopPath:[[NSBezierPath alloc] init]];

	[self setBorderColor:kBPViewBorderColor];
	[self setBackgroundColor:kBPViewBackgroundColor];
}

- (void)drawRect:(NSRect)dirtyRect
{
	[self.backgroundColor setFill];
	[self.borderColor setStroke];

	NSRectFill(dirtyRect);

	[_topPath removeAllPoints];
	[_topPath moveToPoint:NSMakePoint(0, self.frame.size.height)];
	[_topPath lineToPoint:NSMakePoint(self.frame.size.width, self.frame.size.height)];
	[_topPath setLineWidth:3];
	[_topPath stroke];
}

@end
