//
//  NSJSONSerialization+String.m
//  PrismCommon
//
//  Created by John Scott on 06/04/2020.
//  Copyright © 2020 John Scott. All rights reserved.
//

#import "NSJSONSerialization+String.h"

@implementation NSJSONSerialization (String)

+ (nullable NSString *)stringWithJSONObject:(id)obj options:(NSJSONWritingOptions)opt error:(NSError **)error {
    NSData *data = [self dataWithJSONObject:obj
                                    options:opt
                                      error:error];
    if (!data) return nil;
    
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return string;
}

@end
