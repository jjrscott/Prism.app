//
//  NSColor+Adjustment.h
//  PrismCommon
//
//  Created by John Scott on 29/03/2020.
//  Copyright © 2020 John Scott. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSColor (Adjustment)

- (NSColor *)colorWithBrightnessComponent:(CGFloat)brightness;
- (NSColor *)colorWithSaturationComponent:(CGFloat)saturation;

@end
