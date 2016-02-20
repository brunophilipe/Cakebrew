//
//  BPBundleWindowController.h
//  Cakebrew
//
//  Created by Bruno Philipe on 20/02/16.
//  Copyright © 2016 Bruno Philipe. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BPBundleWindowController : NSWindowController

+ (BPBundleWindowController*)runImportOperationWithFile:(NSURL*)fileURL;
+ (BPBundleWindowController*)runExportOperationWithFile:(NSURL*)fileURL;

@end
