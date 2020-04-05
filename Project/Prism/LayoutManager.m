//
//  LayoutManager.m
//  Prism
//
//  Created by John Scott on 31/03/2020.
//  Copyright © 2020 John Scott. All rights reserved.
//

#import "LayoutManager.h"
#import <PrismCommon/PrismCommon.h>

@interface LayoutManager ()

@property (nonatomic, strong) NSMutableDictionary *accumulatedBackgroundFills;

@end

@implementation LayoutManager

- (void)drawBackgroundForGlyphRange:(NSRange)glyphsToShow atPoint:(NSPoint)origin {
    self.accumulatedBackgroundFills = [NSMutableDictionary new];
    [super drawBackgroundForGlyphRange:glyphsToShow atPoint:origin];
    for (NSValue *rectWrapper in self.accumulatedBackgroundFills) {
        NSRect rect = rectWrapper.rectValue;
        NSColor *color = self.accumulatedBackgroundFills[rectWrapper];
        rect.origin.x = 0;
        rect.size.width = CGFLOAT_MAX;
        [self _fillBackgroundRectArray:&rect count:1 forCharacterRange:NSMakeRange(0, 0) color:color];
    }
    for (NSValue *rectWrapper in self.accumulatedBackgroundFills) {
        NSRect rect = rectWrapper.rectValue;
        NSColor *color = self.accumulatedBackgroundFills[rectWrapper];
        @try {
            color = [[color colorWithSaturationComponent:0.5] colorWithBrightnessComponent:0.4];
        } @catch (NSException *exception) {
        } @finally {
        }
        
        if (!color) continue;
        
        CGContextRef context = NSGraphicsContext.currentContext.CGContext;
        rect = CGRectInset(rect, 0, 3);
        CGContextAddRectWithRoundedCorners(context, rect, 3);
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextFillPath(context);
    }
    self.accumulatedBackgroundFills = nil;
}

- (void)fillBackgroundRectArray:(const NSRect *)rectArray count:(NSUInteger)rectCount forCharacterRange:(NSRange)charRange color:(NSColor *)color {
    NSAssert(self.accumulatedBackgroundFills, @"");
    
    for (NSInteger componentIndex=0; componentIndex<rectCount; componentIndex++) {
        self.accumulatedBackgroundFills[@(rectArray[componentIndex])] = color;
    }
}

- (void)_fillBackgroundRectArray:(const NSRect *)rectArray count:(NSUInteger)rectCount forCharacterRange:(NSRange)charRange color:(NSColor *)color {
    [color setFill];
    [super fillBackgroundRectArray:rectArray count:rectCount forCharacterRange:charRange color:NSColor.redColor];
}

@end
