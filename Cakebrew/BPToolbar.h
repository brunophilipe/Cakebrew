//
//  BPToolbar.h
//
//
//  Created by Marek Hrusovsky on 16/08/15.
//
//

#import <Cocoa/Cocoa.h>

@protocol BPToolbarProtocol <NSObject>

@required
- (void)performSearchWithString:(NSString *)search;
- (void)updateHomebrew:(id)sender;
- (void)installUninstallUpdate:(id)sender;
- (void)upgradeSelectedFormulae:(id)sender;
- (void)showFormulaInfo:(id)sender;
@end

@interface BPToolbar : NSToolbar <NSToolbarDelegate>

typedef NS_ENUM(NSUInteger, BPToolbarMode) {
  BPToolbarModeEmpty,
  BPToolbarModeDefault,
  BPToolbarModeInstall,
  BPToolbarModeUninstall,
  BPToolbarModeUpdateSingle,
  BPToolbarModeUpdateMany,
  BPToolbarModeTap,
  BPToolbarModeUntap
};

@property (nonatomic, weak) id controller;

- (void)configureForMode:(BPToolbarMode)mode;
- (void)makeSearchFieldFirstResponder;

@end
