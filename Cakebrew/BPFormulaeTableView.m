//
//  BPFormulaeTableView.m
//  Cakebrew
//
//  Created by Marek Hrusovsky on 04/09/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import "BPFormulaeTableView.h"
static void * BPFormulaeTableViewContext = &BPFormulaeTableViewContext;
NSString * const kColumnIdentifierVersion = @"Version";
NSString * const kColumnIdentifierLatestVersion = @"LatestVersion";
NSString * const kColumnIdentifierStatus = @"Status";
NSString * const kColumnIdentifierName = @"Name";

unichar SPACE_CHARACTER = 0x0020;

@implementation BPFormulaeTableView

- (void)awakeFromNib
{
	[self addObserver:self
		   forKeyPath:NSStringFromSelector(@selector(mode))
			  options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
			  context:BPFormulaeTableViewContext];
}

- (instancetype)initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame:frameRect];
	if (self) {
		_mode = kBPListAllFormulae;
	}
	return self;
}

- (void)configureTableForListing
{
	CGFloat totalWidth = 0;
	NSInteger titleWidth = 0;
	
	//OUR superview is NSClipView
	totalWidth = [[self superview] frame].size.width;

	if (@available(macOS 11.0, *)) {
		NSRect marginsFrame = [[[self superview] layoutMarginsGuide] frame];
		totalWidth -= marginsFrame.origin.x * 2;
	}
	
	switch (self.mode) {
		case kBPListAllFormulae:
			titleWidth = (NSInteger)(totalWidth - 125);
			[[self tableColumnWithIdentifier:kColumnIdentifierVersion] setHidden:YES];
			[[self tableColumnWithIdentifier:kColumnIdentifierLatestVersion] setHidden:YES];
			[[self tableColumnWithIdentifier:kColumnIdentifierStatus] setHidden:NO];
			[[self tableColumnWithIdentifier:kColumnIdentifierStatus] setWidth:(NSInteger)((totalWidth-titleWidth)*0.90)];
			[self setAllowsMultipleSelection:NO];
			break;
			
		case kBPListInstalledFormulae:
			titleWidth = (NSInteger)(totalWidth * 0.4);
			[[self tableColumnWithIdentifier:kColumnIdentifierLatestVersion] setHidden:YES];
			[[self tableColumnWithIdentifier:kColumnIdentifierStatus] setHidden:YES];
			[[self tableColumnWithIdentifier:kColumnIdentifierVersion] setHidden:NO];
			[[self tableColumnWithIdentifier:kColumnIdentifierVersion] setWidth:(NSInteger)totalWidth*0.55];
			[self setAllowsMultipleSelection:NO];
			break;
			
		case kBPListLeaves:
			titleWidth = totalWidth - 1;
			[[self tableColumnWithIdentifier:kColumnIdentifierVersion] setHidden:YES];
			[[self tableColumnWithIdentifier:kColumnIdentifierLatestVersion] setHidden:YES];
			[[self tableColumnWithIdentifier:kColumnIdentifierStatus] setHidden:YES];
			[self setAllowsMultipleSelection:NO];
			break;
			
		case kBPListOutdatedFormulae:
			titleWidth = (NSInteger)(totalWidth * 0.4);
			[[self tableColumnWithIdentifier:kColumnIdentifierStatus] setHidden:YES];
			[[self tableColumnWithIdentifier:kColumnIdentifierVersion] setHidden:NO];
			[[self tableColumnWithIdentifier:kColumnIdentifierVersion] setWidth:(totalWidth-titleWidth)*0.48];
			[[self tableColumnWithIdentifier:kColumnIdentifierLatestVersion] setHidden:NO];
			[[self tableColumnWithIdentifier:kColumnIdentifierLatestVersion] setWidth:(totalWidth-titleWidth)*0.48];
			[self setAllowsMultipleSelection:YES];
			break;
			
		case kBPListSearchFormulae:
			titleWidth = (NSInteger)(totalWidth - 90);
			[[self tableColumnWithIdentifier:kColumnIdentifierVersion] setHidden:YES];
			[[self tableColumnWithIdentifier:kColumnIdentifierLatestVersion] setHidden:YES];
			[[self tableColumnWithIdentifier:kColumnIdentifierStatus] setHidden:NO];
			[[self tableColumnWithIdentifier:kColumnIdentifierStatus] setWidth:(totalWidth-titleWidth)*0.90];
			[self setAllowsMultipleSelection:NO];
			break;
			
		case kBPListRepositories:
			titleWidth = totalWidth - 1;
			[[self tableColumnWithIdentifier:kColumnIdentifierVersion] setHidden:YES];
			[[self tableColumnWithIdentifier:kColumnIdentifierLatestVersion] setHidden:YES];
			[[self tableColumnWithIdentifier:kColumnIdentifierStatus] setHidden:YES];
			[self setAllowsMultipleSelection:NO];
			break;
			
		case kBPListAllCasks:
			titleWidth = (NSInteger)(totalWidth - 125);
			[[self tableColumnWithIdentifier:kColumnIdentifierVersion] setHidden:YES];
			[[self tableColumnWithIdentifier:kColumnIdentifierLatestVersion] setHidden:YES];
			[[self tableColumnWithIdentifier:kColumnIdentifierStatus] setHidden:NO];
			[[self tableColumnWithIdentifier:kColumnIdentifierStatus] setWidth:(NSInteger)((totalWidth-titleWidth)*0.90)];
			[self setAllowsMultipleSelection:NO];
			break;
			
		case kBPListInstalledCasks:
			titleWidth = (NSInteger)(totalWidth * 0.4);
			[[self tableColumnWithIdentifier:kColumnIdentifierLatestVersion] setHidden:YES];
			[[self tableColumnWithIdentifier:kColumnIdentifierStatus] setHidden:YES];
			[[self tableColumnWithIdentifier:kColumnIdentifierVersion] setHidden:NO];
			[[self tableColumnWithIdentifier:kColumnIdentifierVersion] setWidth:(NSInteger)totalWidth*0.55];
			[self setAllowsMultipleSelection:NO];
			break;
			
		case kBPListOutdatedCasks:
			titleWidth = (NSInteger)(totalWidth * 0.4);
			[[self tableColumnWithIdentifier:kColumnIdentifierStatus] setHidden:YES];
			[[self tableColumnWithIdentifier:kColumnIdentifierVersion] setHidden:NO];
			[[self tableColumnWithIdentifier:kColumnIdentifierVersion] setWidth:(totalWidth-titleWidth)*0.48];
			[[self tableColumnWithIdentifier:kColumnIdentifierLatestVersion] setHidden:NO];
			[[self tableColumnWithIdentifier:kColumnIdentifierLatestVersion] setWidth:(totalWidth-titleWidth)*0.48];
			[self setAllowsMultipleSelection:YES];
			break;
			
		case kBPListSearchCasks:
			titleWidth = (NSInteger)(totalWidth - 90);
			[[self tableColumnWithIdentifier:kColumnIdentifierVersion] setHidden:YES];
			[[self tableColumnWithIdentifier:kColumnIdentifierLatestVersion] setHidden:YES];
			[[self tableColumnWithIdentifier:kColumnIdentifierStatus] setHidden:NO];
			[[self tableColumnWithIdentifier:kColumnIdentifierStatus] setWidth:(totalWidth-titleWidth)*0.90];
			[self setAllowsMultipleSelection:NO];
			break;
		
		default:
			break;
	}
	
	[[self tableColumnWithIdentifier:kColumnIdentifierName] setWidth:titleWidth];
	[self setNeedsLayout:YES];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (context == BPFormulaeTableViewContext) {
		if ([object isEqualTo:self]) {
			if([keyPath isEqualToString:NSStringFromSelector(@selector(mode))]){
				[self configureTableForListing];
			}
		}
	} else {
		@try {
			[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
		}
		@catch (NSException *exception) {}
		@finally {}
	}
}



- (BOOL)performKeyEquivalent:(NSEvent *)theEvent
{
	id responder = [[self window] firstResponder];
	
	if (responder != self)
	{
		return [super performKeyEquivalent:theEvent];
	}
	
	if (self.selectedRow == -1)
	{
		return NO;
	}
	
	NSUInteger numberOfPressedCharacters = [[theEvent charactersIgnoringModifiers] length];
	NSEventType eventType = [theEvent type];
	
	if (eventType == NSKeyDown && numberOfPressedCharacters == 1)
	{
		unichar key = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
		if (key == SPACE_CHARACTER)
		{
			[self spaceBarPressed];
			return YES;
		}
	}
	
	return NO;
}


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

- (void)spaceBarPressed
{
	//On yosemite or later viewcontroller is part of responder chain
	if (floor(NSAppKitVersionNumber) >= NSAppKitVersionNumber10_10)
	{
		[NSApp sendAction:@selector(showFormulaInfo:) to:nil from:self];
	}
	else
	{
		if ([self.delegate respondsToSelector:@selector(showFormulaInfo:)])
		{
			[self.delegate performSelector:@selector(showFormulaInfo:) withObject:nil];
		}
	}
}

#pragma clang diagnostic pop

- (void)dealloc
{
	[self removeObserver:self
			  forKeyPath:NSStringFromSelector(@selector(mode))
				 context:BPFormulaeTableViewContext];
}

@end
