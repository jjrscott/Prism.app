//
//  NSData+STYAdditions.m
//  Staycation
//
//  Created by John Scott on 24/03/2014.
//  Copyright (c) 2014 John Scott. All rights reserved.
//

#import "NSData+STYAdditions.h"

@implementation NSData (STYAdditions)


- (NSString*)STYAdditions_hexEncodedString
{
    NSMutableString *hexEncodedString = [NSMutableString string];

    for (NSInteger byteIndex=0; byteIndex < [self length]; byteIndex++)
    {
        unsigned char byte = 0;
        [self getBytes:&byte range:NSMakeRange(byteIndex, 1)];
        [hexEncodedString appendFormat:@"%02x", byte];
    }

    return [hexEncodedString copy];
}

+ (id)STYAdditions_dataWithHexEncodedString:(NSString*)hexEncodedString
{
    NSMutableData *data = [NSMutableData data];
    for (NSInteger byteIndex=0; byteIndex < [hexEncodedString length]; byteIndex+=2)
    {
        NSScanner *scanner = [NSScanner scannerWithString:[hexEncodedString substringWithRange:NSMakeRange(byteIndex, 2)]];
        unsigned char byte = 0;
        [scanner scanHexInt:(unsigned int *)&byte];
        [data appendBytes:&byte length:1];
    }
    return [data copy];
}

- (NSString*)STYAdditions_dumbEncodedString
{
    NSMutableString *hexEncodedString = [NSMutableString string];

    for (NSInteger byteIndex=0; byteIndex < [self length]; byteIndex++)
    {
        unsigned char byte = 0;
        [self getBytes:&byte range:NSMakeRange(byteIndex, 1)];
        [hexEncodedString appendFormat:@"%c", (byte >= 32 && byte < 127) ? byte : '.'];
    }

    return [hexEncodedString copy];
}


@end
