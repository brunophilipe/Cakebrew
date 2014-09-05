//
//  BPSideBarController.h
//  Cakebrew
//
//  Created by Marek Hrusovsky on 05/09/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import "Frameworks/PXSourceList.framework/Headers/PXSourceList.h"
#import <Foundation/Foundation.h>

@protocol BPSideBarControllerDelegate <NSObject>
- (void)sourceListSelectionDidChange;
@end

@interface BPSideBarController : NSObject <PXSourceListDataSource, PXSourceListDelegate>

@property (unsafe_unretained) id <BPSideBarControllerDelegate>delegate;
- (void)refreshSidebarBadges;

@end
