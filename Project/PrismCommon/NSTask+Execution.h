//
//  NSTask+Execution.h
//  Shell
//
//  Created by John Scott on 15/02/2020.
//  Copyright © 2020 John Scott. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTask (Execution)

+ (NSTaskTerminationReason)executeTaskWithExecutableURL:(NSURL *_Nonnull)url
                                              arguments:(NSArray<NSString *> *_Nullable)arguments
                                          standardInput:(NSData *_Nullable)standardInput
                                         standardOutput:(NSData *_Nullable*_Nullable)standardOutput
                                          standardError:(NSData *_Nullable*_Nullable)standardError
                                                  error:(NSError *_Nullable* _Nullable)error;

@end
