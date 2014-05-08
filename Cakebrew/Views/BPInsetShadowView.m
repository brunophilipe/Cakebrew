//
//	BPInsetShadowView.m
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

#import "BPInsetShadowView.h"

@implementation BPInsetShadowView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (BOOL)isOpaque
{
	return NO;
}

- (void)drawRect:(NSRect)dirtyRect
{
	if (_shouldDrawBackground) {
		[[[NSColor controlBackgroundColor] colorWithAlphaComponent:0.5] setFill];
		NSRectFill(dirtyRect);
	}

	NSGraphicsContext *context = [NSGraphicsContext currentContext];
	[context saveGraphicsState];

	[context setCompositingOperation:NSCompositePlusDarker];

	NSBezierPath *path = [NSBezierPath
						  bezierPathWithRoundedRect:[self bounds]
						  xRadius:2.0f
						  yRadius:2.0f];

	[[NSColor whiteColor] setStroke];

	NSShadow * shadow = [[NSShadow alloc] init];
	[shadow setShadowColor:[NSColor colorWithCalibratedWhite:0.0f
													   alpha:0.4f]];
	[shadow setShadowBlurRadius:2.5f];
	[shadow set];

	[path stroke];

	[context restoreGraphicsState];
}

@end
