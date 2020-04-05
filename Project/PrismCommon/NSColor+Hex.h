//
//  NSColor+Hex.h
//  PrismCommon
//
//  Created by John Scott on 29/03/2020.
//  Copyright © 2020 John Scott. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSColor (Hex)

- (NSString *)hexadecimalValue;
+ (NSColor *)colorFromHexadecimalValue:(NSString *)hex;

@end
