//
//  BPToolbar.m
//  Cakebrew
//
//  Created by Marek Hrusovsky on 16/08/15.
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

#import "BPToolbar.h"
#import "BPStyle.h"

static NSString *kToolbarIdentifier = @"toolbarIdentifier";

static NSString *kToolbarItemHomebrewUpdateIdentifier = @"toolbarItemHomebrewUpdate";
static NSString *kToolbarItemInformationIdentifier = @"toolbarItemInformation";
static NSString *kToolbarItemSearchIdentifier = @"toolbarItemSearch";
static NSString *kToolbarItemMultiActionIdentifier = @"toolbarItemMultiAction";

@interface BPToolbar() <NSSearchFieldDelegate>

@property (assign) BPToolbarMode currentMode;
@property (strong) NSSearchField *searchField;

@end

@implementation BPToolbar

- (instancetype)initWithIdentifier:(NSString *)identifier
{
	self = [super initWithIdentifier:kToolbarIdentifier];
	if (self)
	{
		NSToolbarSizeMode mode = [BPStyle toolbarSize];
		[self setSizeMode:mode];
		
		_currentMode = BPToolbarModeInitial;
		[self configureForMode:BPToolbarModeDefault];
		[self lockItems];
		[self setAllowsUserCustomization:YES];
	}
	return self;
}

- (void)configureForMode:(BPToolbarMode)mode
{
	if (self.currentMode == mode)
	{
		return;
	}
	
	self.currentMode = mode;
	NSToolbarItem *moreInfoItem = [self toolbarItemInformation];
	
	if (mode == BPToolbarModeTap ||
		mode == BPToolbarModeUntap ||
		mode == BPToolbarModeUpdateMany ||
		mode == BPToolbarModeDefault)
	{
		//will force toolbar to show empty nonclickable item
		[self reconfigureItem:moreInfoItem
						image:nil
						label:nil
					   action:nil];
	}
	else
	{
		[self reconfigureItem:moreInfoItem
						image:[BPStyle toolbarImageForMoreInformation]
						label:NSLocalizedString(@"Toolbar_More_Information", nil)
					   action:@selector(showFormulaInfo:)];
	}
	
	
	NSToolbarItem *multiActionItem = [self toolbarItemMultiAction];
	switch (mode) {
		case BPToolbarModeDefault:
			[self reconfigureItem:multiActionItem
							image:nil
							label:nil
						   action:nil];
			break;
			
		case BPToolbarModeInstall:
			[self reconfigureItem:multiActionItem
							image:[BPStyle toolbarImageForInstall]
							label:NSLocalizedString(@"Toolbar_Install_Formula", nil)
						   action:@selector(installFormula:)];
			break;
			
		case BPToolbarModeUninstall:
			[self reconfigureItem:multiActionItem
							image:[BPStyle toolbarImageForUninstall]
							label:NSLocalizedString(@"Toolbar_Uninstall_Formula", nil)
						   action:@selector(uninstallFormula:)];
			break;
			
		case BPToolbarModeTap:
			[self reconfigureItem:multiActionItem
							image:[BPStyle toolbarImageForTap]
							label:NSLocalizedString(@"Toolbar_Tap_Repo", nil)
						   action:@selector(tapRepository:)];
			break;
			
		case BPToolbarModeUntap:
			[self reconfigureItem:multiActionItem
							image:[BPStyle toolbarImageForUntap]
							label:NSLocalizedString(@"Toolbar_Untap_Repo", nil)
						   action:@selector(untapRepository:)];
			break;
			
		case BPToolbarModeUpdateSingle:
			[self reconfigureItem:multiActionItem
							image:[BPStyle toolbarImageForUpdate]
							label:NSLocalizedString(@"Toolbar_Update_Formula", nil)
						   action:@selector(upgradeSelectedFormulae:)];
			break;
			
		case BPToolbarModeUpdateMany:
			[self reconfigureItem:multiActionItem
							image:[BPStyle toolbarImageForUpdate]
							label:NSLocalizedString(@"Toolbar_Update_Selected", nil)
						   action:@selector(upgradeSelectedFormulae:)];
			break;
			
		default:
			break;
	}
	[self validateVisibleItems];
}

- (void)setController:(id)controller
{
	if (_controller != controller)
	{
		_controller = controller;
	}
}

- (void)updateToolbarItemsWithTarget:(id)target
{
	NSDictionary *supportedItems = [self customToolbarItems];
	[supportedItems enumerateKeysAndObjectsUsingBlock:^(id key, NSToolbarItem *object, BOOL *stop) {
		[object setTarget:target];
		[object setEnabled:target != nil]; //Disables the searchbox toolbar item
	}];
}

- (void)lockItems
{
	[self updateToolbarItemsWithTarget:nil];
	[self validateVisibleItems];
}

- (void)unlockItems
{
	[self updateToolbarItemsWithTarget:_controller];
	[self validateVisibleItems];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{
	NSDictionary *supportedItems = [self customToolbarItems];
	if (![supportedItems objectForKey:itemIdentifier])
	{
		return nil;
	}
	return supportedItems[itemIdentifier];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
	if (@available(macOS 11.0, *)) {
		return @[NSToolbarFlexibleSpaceItemIdentifier,
				 kToolbarItemHomebrewUpdateIdentifier,
				 NSToolbarSidebarTrackingSeparatorItemIdentifier,
				 NSToolbarFlexibleSpaceItemIdentifier,
				 kToolbarItemMultiActionIdentifier,
				 kToolbarItemInformationIdentifier,
				 kToolbarItemSearchIdentifier,
		];
	} else {
		return @[kToolbarItemHomebrewUpdateIdentifier,
				 NSToolbarFlexibleSpaceItemIdentifier,
				 kToolbarItemMultiActionIdentifier,
				 kToolbarItemInformationIdentifier,
				 kToolbarItemSearchIdentifier,
				 ];
	}
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
	NSArray *systemToolbarItems = [self systemToolbarItems];
	NSArray *customToolbarItems = @[kToolbarItemHomebrewUpdateIdentifier,
									kToolbarItemInformationIdentifier,
									kToolbarItemSearchIdentifier,
									kToolbarItemMultiActionIdentifier
									];
	return [systemToolbarItems arrayByAddingObjectsFromArray:customToolbarItems];
}

- (NSArray *)systemToolbarItems
{
	static NSArray *systemToolbarItems = nil;
	if (!systemToolbarItems)
	{
		if (@available(macOS 11.0, *)) {
			systemToolbarItems =  @[
				NSToolbarSpaceItemIdentifier,
				NSToolbarFlexibleSpaceItemIdentifier,
				NSToolbarSidebarTrackingSeparatorItemIdentifier,
				NSToolbarSeparatorItemIdentifier
			];
		} else {
			systemToolbarItems =  @[
				NSToolbarSpaceItemIdentifier,
				NSToolbarFlexibleSpaceItemIdentifier,
				NSToolbarSeparatorItemIdentifier
			];
		}
	}
	return systemToolbarItems;
}

- (NSDictionary *)customToolbarItems
{
	static NSDictionary *customToolbarItems = nil;
	if (!customToolbarItems)
	{
		customToolbarItems =  @{
								kToolbarItemHomebrewUpdateIdentifier : [self toolbarItemHomebrewUpdate],
								kToolbarItemInformationIdentifier : [self toolbarItemInformation],
								kToolbarItemSearchIdentifier : [self toolbarItemSearch],
								kToolbarItemMultiActionIdentifier : [self toolbarItemMultiAction]
								};
	}
	return customToolbarItems;
}

- (NSToolbarItem *)toolbarItemHomebrewUpdate
{
	static NSToolbarItem* toolbarItemHomebrewUpdate = nil;
	if (!toolbarItemHomebrewUpdate)
	{
		toolbarItemHomebrewUpdate = [self toolbarItemWithIdentifier:kToolbarItemHomebrewUpdateIdentifier
															  image:[BPStyle toolbarImageForUpgrade]
															  label:NSLocalizedString(@"Toolbar_Homebrew_Update", nil)
															 action:@selector(updateHomebrew:)];
	}
	return toolbarItemHomebrewUpdate;
}

- (NSToolbarItem *)toolbarItemInformation
{
	static NSToolbarItem* toolbarItemInformation = nil;
	if (!toolbarItemInformation)
	{
		toolbarItemInformation = [self toolbarItemWithIdentifier:kToolbarItemInformationIdentifier
														   image:[BPStyle toolbarImageForMoreInformation]
														   label:NSLocalizedString(@"Toolbar_More_Information", nil)
														  action:@selector(showFormulaInfo:)];
	}
	return toolbarItemInformation;
}


- (NSToolbarItem *)toolbarItemMultiAction
{
	static NSToolbarItem* toolbarItemMultiAction = nil;
	if (!toolbarItemMultiAction)
	{
		toolbarItemMultiAction = [self toolbarItemWithIdentifier:kToolbarItemMultiActionIdentifier
														   image:nil
														   label:nil
														  action:nil];
	}
	return toolbarItemMultiAction;
}



- (NSToolbarItem *)toolbarItemSearch
{
	static NSToolbarItem* item = nil;
	if (!item)
	{
		if (@available(macOS 11.0, *)) {
			item = [[NSSearchToolbarItem alloc] initWithItemIdentifier:kToolbarItemSearchIdentifier];
		} else {
			item = [[NSToolbarItem alloc] initWithItemIdentifier:kToolbarItemSearchIdentifier];
		}
		item.label = NSLocalizedString(@"Toolbar_Search", nil);
		item.paletteLabel = NSLocalizedString(@"Toolbar_Search", nil);
		item.action = @selector(performSearchWithString:);
		
		self.searchField = [[NSSearchField alloc] initWithFrame:NSZeroRect];
		self.searchField.delegate = self;
		self.searchField.continuous = YES;
		[self.searchField setRecentsAutosaveName:@"RecentSearches"];

		if (@available(macOS 11.0, *)) {
			[(NSSearchToolbarItem *)item setSearchField:self.searchField];
		} else {
			[item setView:self.searchField];
		}
	}
	return item;
}

- (NSToolbarItem *)toolbarItemWithIdentifier:(NSString *)identifier
									   image:(NSImage *)image
									   label:(NSString *)label
									  action:(SEL)action
{
	NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:identifier];
	if (@available(macOS 11.0, *)) {
		item.view = [self makeButtonForItemImage:image target:[self controller] action:action];
	} else {
		item.image = image;
		item.target = [self controller];
	}
	item.label = label;
	item.paletteLabel = label;
	item.action = action;
	item.autovalidates = YES;
	item.toolTip = label;
	return item;
}

- (void)reconfigureItem:(NSToolbarItem *)item image:(NSImage *)image label:(NSString *)label action:(SEL)action
{
	assert([NSThread isMainThread]);

	static BOOL (^staticBlock)(NSRect) = ^BOOL(NSRect dstRect) {
		return YES;
	};
	
	if (!image) {
		if (@available(macOS 11.0, *)) {
			item.view = nil;
		} else {
			item.image = [NSImage imageWithSize:NSMakeSize(32, 32) flipped:NO drawingHandler:staticBlock];
		}

		item.action = action;
	} else {
		if (@available(macOS 11.0, *)) {
			item.view = [self makeButtonForItemImage:image target:[self controller] action:action];
		} else {
			item.image = image;
			item.action = action;
		}
	}

	item.label = label;
	item.toolTip = label;
}

- (NSButton *)makeButtonForItemImage:(NSImage *)image target:(id)target action:(SEL)action
{
	if (image == nil) {
		return nil;
	}
	NSButton *button = [NSButton buttonWithImage:image target:target action:action];
	[button setBezelStyle:NSBezelStyleRegularSquare];
	[button setBordered:NO];
	[button setTranslatesAutoresizingMaskIntoConstraints:NO];
	if (@available(macOS 11, *)) {
		[button setSymbolConfiguration:[NSImageSymbolConfiguration configurationWithPointSize:24
																						  weight:NSFontWeightMedium
																						   scale:NSImageSymbolScaleMedium]];
	}
	[button setImageScaling:NSImageScaleProportionallyUpOrDown];
	return button;
}

- (void)makeSearchFieldFirstResponder
{
	NSView *searchView;

	if (@available(macOS 11.0, *)) {
		searchView = [(NSSearchToolbarItem *)[self toolbarItemSearch] searchField];
	} else {
		searchView = [[self toolbarItemSearch] view];
	}

	[[searchView window] makeFirstResponder:searchView];
}

#pragma mark - NSTextField Delegate
- (void)controlTextDidChange:(NSNotification *)aNotification
{
	NSSearchField *field = (NSSearchField *)[aNotification object];
	[self.controller performSearchWithString:field.stringValue];
}

@end
