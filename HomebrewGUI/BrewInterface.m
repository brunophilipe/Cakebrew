//
//  BrewInterface.m
//  HomebrewGUI
//
//  Created by Vincent Saluzzo on 06/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BrewInterface.h"

@implementation BrewInterface

+(NSArray*) list {
    NSTask *listTask;
    listTask = [[NSTask alloc] init];
    [listTask setLaunchPath: @"/usr/local/bin/brew"];
    
    NSArray *arguments;
    arguments = [NSArray arrayWithObjects:@"list", nil];
    [listTask setArguments: arguments];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [listTask setStandardOutput: pipe];
    [listTask setStandardInput:[NSPipe pipe]];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [listTask launch];
    
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *string;
    /*
    string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    NSLog (@"script returned:\n%@", string);    
    */
    
    [listTask waitUntilExit];
    
    string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    //NSLog (@"script returned:\n%@", string); 
    
    NSMutableArray* array = [string componentsSeparatedByString:@"\n"];
    [array removeLastObject];
    return array;
}

+(NSArray*) search:(NSString*)formula {
    NSTask *listTask;
    listTask = [[NSTask alloc] init];
    [listTask setLaunchPath: @"/usr/local/bin/brew"];
    
    NSArray *arguments;
    arguments = [NSArray arrayWithObjects:@"search", formula, nil];
    [listTask setArguments: arguments];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [listTask setStandardOutput: pipe];
    [listTask setStandardInput:[NSPipe pipe]];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [listTask launch];
    
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *string;
    /*
     string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
     NSLog (@"script returned:\n%@", string);    
     */
    
    [listTask waitUntilExit];
    
    string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    //NSLog (@"script returned:\n%@", string); 
    
    NSMutableArray* array = [string componentsSeparatedByString:@"\n"];
    [array removeLastObject];
    return array;
}

+(NSString*) info:(NSString*)formula {
    NSTask *listTask;
    listTask = [[NSTask alloc] init];
    [listTask setLaunchPath: @"/usr/local/bin/brew"];
    
    NSArray *arguments;
    arguments = [NSArray arrayWithObjects:@"info", formula, nil];
    [listTask setArguments: arguments];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [listTask setStandardOutput: pipe];
    [listTask setStandardInput:[NSPipe pipe]];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [listTask launch];
    
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *string;
    /*
     string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
     NSLog (@"script returned:\n%@", string);    
     */
    
    [listTask waitUntilExit];
    
    string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    //NSLog (@"script returned:\n%@", string); 
    
    return string;
}

+(NSString*) update {
    NSTask *listTask;
    listTask = [[NSTask alloc] init];
    [listTask setLaunchPath: @"/usr/local/bin/brew"];
    
    NSArray *arguments;
    arguments = [NSArray arrayWithObjects:@"update", nil];
    [listTask setArguments: arguments];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [listTask setStandardOutput: pipe];
    [listTask setStandardInput:[NSPipe pipe]];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [listTask launch];
    
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *string;
    /*
     string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
     NSLog (@"script returned:\n%@", string);    
     */
    
    [listTask waitUntilExit];
    
    string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    NSLog (@"script returned:\n%@", string); 
    
    return string;
}

+(NSString*) upgrade:(NSString*)formula {
    NSTask *listTask;
    listTask = [[NSTask alloc] init];
    [listTask setLaunchPath: @"/usr/local/bin/brew"];
    
    NSArray *arguments;
    arguments = [NSArray arrayWithObjects:@"upgrade", formula, nil];
    [listTask setArguments: arguments];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [listTask setStandardOutput: pipe];
    [listTask setStandardInput:[NSPipe pipe]];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [listTask launch];
    
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *string;
    /*
     string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
     NSLog (@"script returned:\n%@", string);    
     */
    
    [listTask waitUntilExit];
    
    string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    NSLog (@"script returned:\n%@", string); 
    
    return string;
}

+(NSString*) install:(NSString*)formula {
    NSTask *listTask;
    listTask = [[NSTask alloc] init];
    [listTask setLaunchPath: @"/usr/local/bin/brew"];
    
    NSArray *arguments;
    arguments = [NSArray arrayWithObjects:@"install", formula, nil];
    [listTask setArguments: arguments];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [listTask setStandardOutput: pipe];
    [listTask setStandardInput:[NSPipe pipe]];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [listTask launch];
    
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *string;
    /*
     string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
     NSLog (@"script returned:\n%@", string);    
     */
    
    [listTask waitUntilExit];
    
    string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    NSLog (@"script returned:\n%@", string); 
    
    return string;
}

+(NSString*) uninstall:(NSString*)formula {
    NSTask *listTask;
    listTask = [[NSTask alloc] init];
    [listTask setLaunchPath: @"/usr/local/bin/brew"];
    
    NSArray *arguments;
    arguments = [NSArray arrayWithObjects:@"uninstall", formula, nil];
    [listTask setArguments: arguments];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [listTask setStandardOutput: pipe];
    [listTask setStandardInput:[NSPipe pipe]];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [listTask launch];
    
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *string;
    /*
     string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
     NSLog (@"script returned:\n%@", string);    
     */
    
    [listTask waitUntilExit];
    
    string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    NSLog (@"script returned:\n%@", string); 
    
    return string;
}
@end
