//
//  NSObject+Difference.m
//  PrismCommon
//
//  Created by John Scott on 10/04/2020.
//  Copyright © 2020 John Scott. All rights reserved.
//

#import "NSObject+Difference.h"
#import "NSArray+LongestCommonSubsequence.h"

@implementation NSObject (Difference)

-(id)diffWith:(id)anObject {
    return [self diffWith:anObject isEqual:^BOOL(id left, id right) {
        return [left isEqual:right];
    }];
}

-(id)diffWith:(id)anObject isEqual:(BOOL (^)(id left, id right))isEqual
{
    if (isEqual(self, anObject)) return self;
    return [Patch patchWithLeft:self right:anObject];
}

@end

@implementation NSDictionary (Difference)

- (id)diffWith:(NSDictionary*)anObject isEqual:(BOOL (^)(id left, id right))isEqual
{
    if (![anObject isKindOfClass:NSDictionary.class]) return [super diffWith:anObject isEqual:isEqual];
    if (isEqual(self, anObject)) return self;
    
    NSMutableSet *allKeys = [NSMutableSet new];
    [allKeys addObjectsFromArray:self.allKeys];
    [allKeys addObjectsFromArray:anObject.allKeys];
    
    NSMutableDictionary *diff = [NSMutableDictionary new];
    for (id key in allKeys)
    {
        diff[key] = [self[key] diffWith:anObject[key] isEqual:isEqual];
    }
    return [diff copy];
}

@end

@implementation NSArray (Difference)

-(NSArray<Patch*>*)diffWith:(NSArray*)anArray isEqual:(BOOL (^)(id left, id right))isEqual
{
    if (![anArray isKindOfClass:NSArray.class]) return [super diffWith:anArray isEqual:isEqual];
    return [self longestCommonSubsequence:anArray isEqual:isEqual];
}

@end

@implementation NSSet (Difference)

- (id)diffWith:(NSSet*)anObject isEqual:(BOOL (^)(id left, id right))isEqual
{
    if (![anObject isKindOfClass:NSSet.class]) return [super diffWith:anObject isEqual:isEqual];
    if (isEqual(self, anObject)) return self;
    
    NSMutableSet *diff = [NSMutableSet new];
    
    for (id object in self)
    {
        if ([anObject containsObject:object]) {
            [diff addObject:object];
        } else {
            [diff addObject:[Patch patchWithLeft:object right:nil]];
        }
    }
    
    for (id object in anObject)
    {
        if ([self containsObject:object]) {
            [diff addObject:object];
        } else {
            [diff addObject:[Patch patchWithLeft:nil right:object]];
        }
    }
    return [diff copy];
}

@end

