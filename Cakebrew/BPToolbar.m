//
//  BPToolbar.m
//
//
//  Created by Marek Hrusovsky on 16/08/15.
//
//

#import "BPToolbar.h"

static NSString *kToolbarIdentifier = @"toolbarIdentifier";

static NSString *kToolbarItemHomebrewUpdateIdentifier = @"toolbarItemHomebrewUpdate";
static NSString *kToolbarItemInstallIdentifier = @"toolbarItemInstall";
static NSString *kToolbarItemUninstallIdentifier = @"toolbarItemUninstall";
static NSString *kToolbarItemTapIdentifier = @"toolbarItemTap";
static NSString *kToolbarItemUntapIdentifier = @"toolbarItemUntap";
static NSString *kToolbarItemUpdateSingleIdentifier = @"toolbarItemUpdateSingle";
static NSString *kToolbarItemUpdateManyIdentifier = @"toolbarItemUpdateMany";
static NSString *kToolbarItemInformationIdentifier = @"toolbarItemInformation";
static NSString *kToolbarItemSearchIdentifier = @"toolbarItemSearch";


@interface BPToolbar() <NSTextFieldDelegate>

@property (assign) BPToolbarMode currentMode;

@end

@implementation BPToolbar

- (instancetype)initWithIdentifier:(NSString *)identifier
{
  self = [super initWithIdentifier:kToolbarIdentifier];
  if (self) {
    _currentMode = BPToolbarModeEmpty;
  }
  return self;
}

- (void)configureForMode:(BPToolbarMode)mode
{
  if (mode == self.currentMode) {
    return;
  } else {
    self.currentMode = mode;
  }
  
  [self removeAllToolbarItems];
  switch (mode) {
    case BPToolbarModeEmpty:
      break;
    case BPToolbarModeDefault:
      [self insertSearchToolbarItem];
      [self insertHomebrewUpdateToolbarItemWithFlexibleSpace];
      break;
    case BPToolbarModeInstall:
      [self insertToolbarItemsForInstallMode];
      break;
    case BPToolbarModeUninstall:
      [self insertToolbarItemsForUninstallMode];
      break;
    case BPToolbarModeTap:
      [self insertToolbarItemsForTapMode];
      break;
    case BPToolbarModeUntap:
      [self insertToolbarItemsForUntapMode];
      break;
    case BPToolbarModeUpdateSingle:
      [self insertToolbarItemsForUpdateSingleMode];
      break;
    case BPToolbarModeUpdateMany:
      [self insertToolbarItemsForUpdateManyMode];
      break;
    default:
      [self insertHomebrewUpdateToolbarItemWithFlexibleSpace];
      break;
  }
}

- (void)setController:(id)controller
{
  if (_controller != controller) {
    _controller = controller;
    [self updateToolbarItemsWithTarget:controller];
  }
}

- (void)updateToolbarItemsWithTarget:(id)target
{
  NSArray *toolbarItems = self.items;
  for (NSToolbarItem *item in toolbarItems) {
    item.target = target;
  }
}

- (void)removeAllToolbarItems
{
  NSUInteger numberOfItems = [self.items count];
  for (; numberOfItems > 0; numberOfItems--) {
    [self removeItemAtIndex:0];
  }
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{
  NSDictionary *supportedItems = [self customToolbarItems];
  if (![supportedItems objectForKey:itemIdentifier]){
    return nil;
  }
  return supportedItems[itemIdentifier];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar{
  return @[];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar{
  return @[];
}

- (NSArray *)systemToolbarItems
{
  static NSArray *systemToolbarItems = nil;
  if (!systemToolbarItems) {
    systemToolbarItems =  @[
                            NSToolbarSpaceItemIdentifier,
                            NSToolbarFlexibleSpaceItemIdentifier,
                            NSToolbarSeparatorItemIdentifier
                            ];
  }
  return systemToolbarItems;
}

- (NSDictionary *)customToolbarItems
{
  static NSDictionary *customToolbarItems = nil;
  if (!customToolbarItems) {
    customToolbarItems =  @{
                            kToolbarItemHomebrewUpdateIdentifier : [self toolbarItemHomebrewUpdate],
                            kToolbarItemInstallIdentifier : [self toolbarItemInstall],
                            kToolbarItemUninstallIdentifier : [self toolbarItemUninstall],
                            kToolbarItemTapIdentifier : [self toolbarItemTap],
                            kToolbarItemUntapIdentifier : [self toolbarItemUntap],
                            kToolbarItemUpdateSingleIdentifier : [self toolbarItemUpdateSingle],
                            kToolbarItemUpdateManyIdentifier : [self toolbarItemUpdateMany],
                            kToolbarItemInformationIdentifier : [self toolbarItemInformation],
                            kToolbarItemSearchIdentifier : [self toolbarItemSearch],
                            };
  }
  return customToolbarItems;
}

- (void)insertToolbarItemsForInstallMode
{
  [self insertSearchToolbarItem];
  [self insertInformationToolbarItem];
  [self insertItemWithItemIdentifier:kToolbarItemInstallIdentifier atIndex:0];
  [self insertHomebrewUpdateToolbarItemWithFlexibleSpace];
}

- (void)insertToolbarItemsForUninstallMode
{
  [self insertSearchToolbarItem];
  [self insertInformationToolbarItem];
  [self insertItemWithItemIdentifier:kToolbarItemUninstallIdentifier atIndex:0];
  
  [self insertHomebrewUpdateToolbarItemWithFlexibleSpace];
}

- (void)insertToolbarItemsForTapMode
{
  [self insertSearchToolbarItem];
  [self insertItemWithItemIdentifier:kToolbarItemTapIdentifier atIndex:0];
  [self insertHomebrewUpdateToolbarItemWithFlexibleSpace];
}

- (void)insertToolbarItemsForUntapMode
{
  [self insertSearchToolbarItem];
  [self insertItemWithItemIdentifier:kToolbarItemUntapIdentifier atIndex:0];
  [self insertHomebrewUpdateToolbarItemWithFlexibleSpace];
}

- (void)insertToolbarItemsForUpdateSingleMode
{
  [self insertSearchToolbarItem];
  [self insertInformationToolbarItem];
  [self insertItemWithItemIdentifier:kToolbarItemUpdateSingleIdentifier atIndex:0];
  [self insertHomebrewUpdateToolbarItemWithFlexibleSpace];
}

- (void)insertToolbarItemsForUpdateManyMode
{
  [self insertSearchToolbarItem];
  [self insertItemWithItemIdentifier:kToolbarItemUpdateManyIdentifier atIndex:0];
  [self insertHomebrewUpdateToolbarItemWithFlexibleSpace];
}


- (void)insertHomebrewUpdateToolbarItemWithFlexibleSpace
{
  [self insertItemWithItemIdentifier:NSToolbarFlexibleSpaceItemIdentifier atIndex:0];
  [self insertItemWithItemIdentifier:kToolbarItemHomebrewUpdateIdentifier atIndex:0];
}

- (void)insertSearchToolbarItem
{
  [self insertItemWithItemIdentifier:kToolbarItemSearchIdentifier atIndex:0];
}

- (void)insertInformationToolbarItem
{
  [self insertItemWithItemIdentifier:kToolbarItemInformationIdentifier atIndex:0];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

- (NSToolbarItem *)toolbarItemHomebrewUpdate {
  static NSToolbarItem* toolbarItemHomebrewUpdate = nil;
  if (!toolbarItemHomebrewUpdate) {
  toolbarItemHomebrewUpdate = [self toolbarItemWithIdentifier:kToolbarItemHomebrewUpdateIdentifier
                                    icon:@"globe.icns"
                                   label:NSLocalizedString(@"Toolbar_Homebrew_Update", nil)
                                  action:@selector(updateHomebrew:)];
  }
  return toolbarItemHomebrewUpdate;
}

- (NSToolbarItem *)toolbarItemInstall {
  static NSToolbarItem* toolbarItemInstall = nil;
  if (!toolbarItemInstall) {
    toolbarItemInstall = [self toolbarItemWithIdentifier:kToolbarItemInstallIdentifier
                                    icon:@"download.icns"
                                   label:NSLocalizedString(@"Toolbar_Install_Formula", nil)
                                  action:@selector(installUninstallUpdate:)];
  }
  return toolbarItemInstall;
}

- (NSToolbarItem *)toolbarItemUninstall {
  static NSToolbarItem* toolbarItemUninstall = nil;
  if (!toolbarItemUninstall) {
    toolbarItemUninstall = [self toolbarItemWithIdentifier:kToolbarItemUninstallIdentifier
                                    icon:@"delete.icns"
                                   label:NSLocalizedString(@"Toolbar_Uninstall_Formula", nil)
                                  action:@selector(installUninstallUpdate:)];
  }
  return toolbarItemUninstall;
}

- (NSToolbarItem *)toolbarItemTap {
  static NSToolbarItem* toolbarItemTap = nil;
  if (!toolbarItemTap) {
    toolbarItemTap = [self toolbarItemWithIdentifier:kToolbarItemTapIdentifier
                                    icon:@"download.icns"
                                   label:NSLocalizedString(@"Toolbar_Tap_Repo", nil)
                                  action:@selector(installUninstallUpdate:)];
  }
  return toolbarItemTap;
}

- (NSToolbarItem *)toolbarItemUntap {
  static NSToolbarItem* toolbarItemUntap = nil;
  if (!toolbarItemUntap) {
    toolbarItemUntap = [self toolbarItemWithIdentifier:kToolbarItemUntapIdentifier
                                    icon:@"delete.icns"
                                   label:NSLocalizedString(@"Toolbar_Untap_Repo", nil)
                                  action:@selector(installUninstallUpdate:)];
  }
  return toolbarItemUntap;
}

- (NSToolbarItem *)toolbarItemUpdateSingle {
  static NSToolbarItem* toolbarItemUpdateSingle = nil;
  if (!toolbarItemUpdateSingle) {
    toolbarItemUpdateSingle = [self toolbarItemWithIdentifier:kToolbarItemUpdateSingleIdentifier
                                    icon:@"reload.icns"
                                   label:NSLocalizedString(@"Toolbar_Update_Formula", nil)
                                  action:@selector(installUninstallUpdate:)];
  }
  return toolbarItemUpdateSingle;
}

- (NSToolbarItem *)toolbarItemUpdateMany {
  static NSToolbarItem* toolbarItemUpdateMany = nil;
  if (!toolbarItemUpdateMany) {
    toolbarItemUpdateMany = [self toolbarItemWithIdentifier:kToolbarItemUpdateManyIdentifier
                                    icon:@"reload.icns"
                                   label:NSLocalizedString(@"Toolbar_Update_Selected", nil)
                                  action:@selector(upgradeSelectedFormulae:)];
  }
  return toolbarItemUpdateMany;
}

- (NSToolbarItem *)toolbarItemInformation {
  static NSToolbarItem* toolbarItemInformation = nil;
  if (!toolbarItemInformation) {
    toolbarItemInformation = [self toolbarItemWithIdentifier:kToolbarItemInformationIdentifier
                                    icon:@"label.icns"
                                   label:NSLocalizedString(@"Toolbar_More_Information", nil)
                                  action:@selector(showFormulaInfo:)];
  }
  return toolbarItemInformation;
}

- (NSToolbarItem *)toolbarItemSearch {
  static NSToolbarItem* item = nil;
  if (!item) {
    item = [[NSToolbarItem alloc] initWithItemIdentifier:kToolbarItemSearchIdentifier];
    item.label = NSLocalizedString(@"Toolbar_Search", nil);
    item.paletteLabel = NSLocalizedString(@"Toolbar_Search", nil);
    item.action = @selector(performSearchWithString:);
    NSSearchField *searchField = [[NSSearchField alloc] initWithFrame:NSZeroRect];
    searchField.delegate = self;
    searchField.continuous = YES;
    [item setView:searchField];
  }
  return item;
}

#pragma clang diagnostic pop

- (NSToolbarItem *)toolbarItemWithIdentifier:(NSString *)identifier
                                        icon:(NSString *)iconName
                                       label:(NSString *)label
                                      action:(SEL)action
{
  NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:identifier];
  item.image = [NSImage imageNamed:iconName];
  item.label = label;
  item.paletteLabel = label;
  item.action = action;
  item.autovalidates = NO;
  return item;
}

- (void)makeSearchFieldFirstResponder
{
  NSView *searchView = [[self toolbarItemSearch] view];
  [[searchView window] makeFirstResponder:searchView];
}

#pragma mark - NSTextField Delegate
- (void)controlTextDidChange:(NSNotification *)aNotification
{
  NSSearchField *field = (NSSearchField *)[aNotification object];
  [self.controller performSearchWithString:field.stringValue];
}

@end
