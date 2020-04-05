//
//  NSColor+Adjustment.m
//  PrismCommon
//
//  Created by John Scott on 29/03/2020.
//  Copyright © 2020 John Scott. All rights reserved.
//

#import "NSColor+Adjustment.h"

@implementation NSColor (Adjustment)

- (NSColor *)colorWithSaturationComponent:(CGFloat)saturation {
    CGFloat hue, brightness, alpha ;
    [self getHue:&hue saturation:NULL brightness:&brightness alpha:&alpha ] ;
    return [NSColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha ] ;
}

- (NSColor *)colorWithBrightnessComponent:(CGFloat)brightness {
    CGFloat hue, saturation, alpha ;
    [self getHue:&hue saturation:&saturation brightness:NULL alpha:&alpha ] ;
    return [NSColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha ] ;
}


@end
