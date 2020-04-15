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

@property (nonatomic, strong) NSMutableDictionary *accumulatedActions;

@end

@implementation LayoutManager

- (void)drawBackgroundForGlyphRange:(NSRange)glyphsToShow atPoint:(NSPoint)origin {
    self.accumulatedActions = NSMutableDictionary.new;
    [super drawBackgroundForGlyphRange:glyphsToShow atPoint:origin];
        
    for (NSValue *rectWrapper in self.accumulatedActions) {
        NSRect rect = rectWrapper.rectValue;
        NSString *action = self.accumulatedActions[rectWrapper];
        
        CGContextRef context = NSGraphicsContext.currentContext.CGContext;

        if ([action isEqual:@"insert"]) {
            CGContextSetRGBFillColor(context, 0.28, 0.49, 0.26, 1);
        } else if ([action isEqual:@"remove"]) {
            CGContextSetRGBFillColor(context, 0.49, 0.22, 0.21, 1);
        }
        
        rect = CGRectInset(rect, -2, 1);
        CGContextAddRectWithRoundedCorners(context, rect, 3);

        CGContextDrawPath(context, kCGPathFill);
    }
    self.accumulatedActions = nil;
}

- (void)fillBackgroundRectArray:(const NSRect *)rectArray count:(NSUInteger)rectCount forCharacterRange:(NSRange)charRange color:(NSColor *)color {
    NSAssert(self.accumulatedActions, @"");
    
    NSRect *mutableRectArray = malloc(sizeof(NSRect) * rectCount);
    memcpy(mutableRectArray, rectArray, sizeof(NSRect) * rectCount);
    
    if (![color isEqual:NSColor.selectedTextBackgroundColor])
    {
        [self.textStorage enumerateAttribute:@"PrismPatchAction"
                                     inRange:charRange
                                     options:kNilOptions
                                  usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop)
         {
             if (value) {
                 NSRange actualCharacterRange;
                 NSRange glyphRange = [self glyphRangeForCharacterRange:range actualCharacterRange:&actualCharacterRange];
                 [self enumerateEnclosingRectsForGlyphRange:glyphRange
                                   withinSelectedGlyphRange:NSMakeRange(NSNotFound, 0)
                                            inTextContainer:self.textContainers.firstObject
                                                 usingBlock:^(NSRect rect, BOOL * _Nonnull stop)
                  
                  {
                      
                      self.accumulatedActions[@(rect)] = value;
                  }];
             }
         }];
        
        for (NSInteger componentIndex=0; componentIndex<rectCount; componentIndex++) {
            mutableRectArray->origin.x = 0;
            mutableRectArray->size.width = CGFLOAT_MAX;
        }
    }
    
    [super fillBackgroundRectArray:mutableRectArray count:rectCount forCharacterRange:charRange color:color];
    free(mutableRectArray);
}

@end
