//
//  NSArray+LongestCommonSubsequence.m
//  LCSTest
//
//  Created by John Scott on 08/10/2019.
//  Based on https://rosettacode.org/wiki/Longest_common_subsequence#C
//  Copyright © 2019 John Scott. All rights reserved.
//

#import "NSArray+LongestCommonSubsequence.h"

@interface Patch ()

+(instancetype)patchWithLeft:(id)left right:(id)right;

@end

@implementation NSArray (LCS)

-(NSArray<Patch*>*)longestCommonSubsequence:(NSArray*)anArray {
    return [self longestCommonSubsequence:anArray isEqual:^BOOL(id left, id right) {
        return [left isEqual:right];
    }];
}

-(NSArray<Patch*>*)longestCommonSubsequence:(NSArray*)anArray isEqual:(BOOL (^)(id left, id right))isEqual {
    NSArray *a = anArray;
    NSArray *b = self;
    NSInteger n = a.count;
    NSInteger m = b.count;
    NSInteger i, j, t;
    NSInteger *z = calloc((n + 1) * (m + 1), sizeof (NSInteger));
    NSInteger **c = calloc((n + 1), sizeof (NSInteger *));
    for (i = 0; i <= n; i++) {
        c[i] = &z[i * (m + 1)];
    }
    for (i = 1; i <= n; i++) {
        for (j = 1; j <= m; j++) {
            if (isEqual(a[i - 1], b[j - 1])) {
                c[i][j] = c[i - 1][j - 1] + 1;
            }
            else {
                c[i][j] = MAX(c[i - 1][j], c[i][j - 1]);
            }
        }
    }
    t = c[n][m];
    
    NSMutableArray *s = [NSMutableArray new];

    for (i = n, j = m; i > 0 && j > 0;) {
        if (isEqual(a[i - 1], b[j - 1])) {
            [s addObject:[Patch patchWithLeft:a[i - 1] right:b[j - 1]]];
            i--;
            j--;
        }
        else if (c[i][j - 1] <= c[i - 1][j])
        {
            [s addObject:[Patch patchWithLeft:a[i - 1] right:nil]];
            i--;
        }
        else
        {
            [s addObject:[Patch patchWithLeft:nil right:b[j - 1]]];
            j--;
        }
    }
    while (i > 0) {
        [s addObject:[Patch patchWithLeft:a[i - 1] right:nil]];
        i--;
    }
    
    while (j > 0) {
        [s addObject:[Patch patchWithLeft:nil right:b[j - 1]]];
        j--;
    }
    
    free(c);
    free(z);
    return s.reverseObjectEnumerator.allObjects;
}

@end

@implementation Patch

-(instancetype)initWithLeft:(id)left right:(id)right {
    self = [super init];
    if (self) {
        NSAssert(left || right, @"");
        _left = left;
        _right = right;
    }
    return self;
}

+(instancetype)patchWithLeft:(id)left right:(id)right {
    return [[self alloc] initWithLeft:left right:right];
}

#if DEBUG
- (BOOL) isNSDictionary__
{
    return YES;
}
#endif

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level;
{
    return [NSString stringWithFormat:@"%@ {left = %@, right = %@}", super.description, _left, _right];
}

@end
