//
//  NSObject+Patch.m
//  PrismCommon
//
//  Created by John Scott on 14/04/2020.
//  Copyright © 2020 John Scott. All rights reserved.
//

#import "NSObject+Patch.h"
#import "NSArray+LongestCommonSubsequence.h"

@implementation NSObject (Patch)

+(__kindof NSObject*)differenceWithLeft:(__kindof NSObject*)leftObject right:(__kindof NSObject*)rightObject {
    if (!leftObject && !rightObject) return nil;
    if (!rightObject || ![leftObject isKindOfClass:rightObject.class]) return [Patch patchWithLeft:leftObject right:rightObject];
    return [leftObject.class _differenceWithLeft:leftObject right:rightObject];
}

+(__kindof NSObject*)_differenceWithLeft:(NSObject*)leftObject right:(NSObject*)rightObject {
    if ([leftObject isEqualTo:rightObject]) return leftObject;
    return [Patch patchWithLeft:leftObject right:rightObject];
}

@end

@implementation NSArray (Patch)

+(__kindof NSObject*)_differenceWithLeft:(NSArray*)leftObject right:(NSArray*)rightObject {
    NSArray *a = rightObject;
    NSArray *b = leftObject;
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
            if ([a[i - 1] isEqual:b[j - 1]]) {
                c[i][j] = c[i - 1][j - 1] + 1;
            }
            else {
                c[i][j] = MAX(c[i - 1][j], c[i][j - 1]);
            }
        }
    }
    t = c[n][m];
    
    NSMutableArray *s = [NSMutableArray new];
    
    NSMutableArray *leftBuffer = NSMutableArray.new;
    NSMutableArray *rightBuffer = NSMutableArray.new;

    for (i = n, j = m; i > 0 && j > 0;) {
        if ([a[i - 1] isEqual:b[j - 1]]) {
            if (leftBuffer.count || rightBuffer.count) {
                [s insertObject:[super differenceWithLeft:leftBuffer right:rightBuffer] atIndex:0];
                [leftBuffer removeAllObjects];
                [rightBuffer removeAllObjects];
            }
            
            [s insertObject:[super differenceWithLeft:a[i - 1] right:b[j - 1]] atIndex:0];
            i--;
            j--;
        }
        else if (c[i][j - 1] <= c[i - 1][j])
        {
            [leftBuffer insertObject:a[i - 1] atIndex:0];
            i--;
        }
        else
        {
            [rightBuffer insertObject:b[j - 1] atIndex:0];
            j--;
        }
    }
    while (i > 0) {
        [leftBuffer insertObject:a[i - 1] atIndex:0];
        i--;
    }
    
    while (j > 0) {
        [rightBuffer insertObject:b[j - 1] atIndex:0];
        j--;
    }
    
    if (leftBuffer.count || rightBuffer.count) [s insertObject:[super _differenceWithLeft:leftBuffer right:rightBuffer] atIndex:0];
    
    free(c);
    free(z);
    return s;
}


@end
