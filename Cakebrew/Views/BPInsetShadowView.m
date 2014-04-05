//
//  BPInsetShadowView.m
//  Cakebrew
//
//  Created by Bruno Philipe on 4/3/14.
//
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
													   alpha:0.7f]];
	[shadow setShadowBlurRadius:5.0f];
	[shadow set];

	[path stroke];

	[context restoreGraphicsState];
}

@end
