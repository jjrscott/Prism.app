//
//  NSTask+Execution.m
//  Shell
//
//  Created by John Scott on 15/02/2020.
//  Copyright © 2020 John Scott. All rights reserved.
//

#import "NSTask+Execution.h"

#import <AppKit/AppKit.h>


@implementation NSTask (Execution)

+ (NSTaskTerminationReason)executeTaskWithExecutableURL:(NSURL *)url
                                              arguments:(NSArray<NSString *> *)arguments
                                          standardInput:(NSData *)standardInput
                                         standardOutput:(NSData **)standardOutput
                                          standardError:(NSData **)standardError
                                                  error:(out NSError ** _Nullable)error {
    NSTask *task = [self new];
    task.executableURL = url;
    task.arguments = arguments;
    
    if (standardInput) {
        NSPipe * pipe = [NSPipe pipe];
        task.standardInput = pipe;
        [pipe.fileHandleForWriting writeData:standardInput];
        [pipe.fileHandleForWriting closeFile];
    }
    
    NSMutableData *standardOutputData = nil;
    if (standardOutput) {
        NSPipe * pipe = [NSPipe pipe];
        task.standardOutput = pipe;
        standardOutputData = [NSMutableData data];
        *standardOutput = standardOutputData;
        pipe.fileHandleForReading.readabilityHandler = ^(NSFileHandle * _Nonnull handle) {
            NSData *data = [handle readDataToEndOfFile];
            [standardOutputData appendData:data];
        };
    }
    
    NSMutableData *standardErrorData = nil;
    if (standardError) {
        NSPipe * pipe = [NSPipe pipe];
        task.standardError = pipe;
        standardErrorData = [NSMutableData data];
        *standardError = standardErrorData;
        pipe.fileHandleForReading.readabilityHandler = ^(NSFileHandle * _Nonnull handle) {
            NSData *data = [handle readDataToEndOfFile];
            [standardErrorData appendData:data];
        };
    }
    
    @try {
        [task launchAndReturnError:error];
        [task waitUntilExit];
    }
    @catch (NSException *exception) {
        [task terminate];
    }
    
    if (standardOutput) *standardOutput = [standardOutputData copy];
    if (standardError) *standardError = [standardErrorData copy];

    return task.terminationReason;
}


@end
