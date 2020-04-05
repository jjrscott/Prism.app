//
//  NSColor+XCColorTheme.h
//  PrismCommon
//
//  Created by John Scott on 30/03/2020.
//  Copyright © 2020 John Scott. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSColor (XCColorTheme)

+ (NSColor *)colorFromXCColorThemeString:(NSString *)colorThemeString;

@end
