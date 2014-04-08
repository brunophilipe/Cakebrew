//
//  BPGenericTextPopoverView.h
//  Cakebrew
//
//  Created by Bruno Philipe on 4/8/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BPGenericTextPopoverView : NSView

@property (strong, nonatomic) IBOutlet NSTextView *textView;
@property (strong, nonatomic) IBOutlet NSTextField *label_title;

@property (weak, nonatomic) id dataObject;

@end
