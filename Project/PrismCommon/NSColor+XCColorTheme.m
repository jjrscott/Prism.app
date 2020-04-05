//
//  NSColor+XCColorTheme.m
//  PrismCommon
//
//  Created by John Scott on 30/03/2020.
//  Copyright © 2020 John Scott. All rights reserved.
//

#import "NSColor+XCColorTheme.h"

@implementation NSColor (XCColorTheme)

+ (NSColor *)colorFromXCColorThemeString:(NSString *)colorThemeString {
    NSArray <NSString*>* componentsAsString = [colorThemeString componentsSeparatedByString:@" "];
    
    NSInteger componentCount = componentsAsString.count;
    
    CGFloat components[componentsAsString.count];
    
    for (NSInteger componentIndex=0; componentIndex<componentCount; componentIndex++) {
        components[componentIndex] = componentsAsString[componentIndex].floatValue;
    }

    return [NSColor colorWithColorSpace:[NSColorSpace genericRGBColorSpace]
                             components:components
                                  count:componentsAsString.count];
}

@end
