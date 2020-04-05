//
//  NSString+ComposedCharacterSequences.m
//  LCSTest
//
//  Created by John Scott on 08/10/2019.
//  Copyright © 2019 John Scott. All rights reserved.
//

#import "NSString+ComposedCharacterSequences.h"

@implementation NSString (ComposedCharacterSequences)

- (NSArray<NSString*>*)composedCharacterSequences {
    NSMutableArray<NSString*>*components = [NSMutableArray new];
    [self enumerateSubstringsInRange:NSMakeRange(0, self.length)
                             options:NSStringEnumerationByComposedCharacterSequences
                          usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
                              [components addObject:substring];
                          }];
    return components.copy;
}

@end
