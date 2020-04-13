//
//  PrismCommonUtilities.m
//  PrismCommon
//
//  Created by John Scott on 27/03/2020.
//  Copyright © 2020 John Scott. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PrismCommonUtilities.h"

void Print(NSString *format, ...)
{
    va_list argList;
    va_start(argList, format);
    NSString *string = [[NSString alloc] initWithFormat:format arguments:argList];
    va_end(argList);
    puts(string.UTF8String);
}

void DumpStrings(NSDictionary *strings)
{
    if ([NSUserDefaults.standardUserDefaults boolForKey:@"prism-dump-strings"]) {
        for (NSString *key in [strings.allKeys sortedArrayUsingSelector:@selector(compare:)]) {
            Print(@"\"%@\" = \"%@\";", key, strings[key]);
        }
    }
}
