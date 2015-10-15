//
//  BPBackgroundView.h
//  Cakebrew
//
//  Created by Bruno Philipe on 10/15/15.
//  Copyright © 2015 Bruno Philipe. All rights reserved.
//

#import <Cocoa/Cocoa.h>

IB_DESIGNABLE
@interface BPBackgroundView : NSView

IBInspectable
@property (strong) NSColor *backgroundColor;

@end
