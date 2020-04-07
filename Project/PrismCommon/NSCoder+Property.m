//
//  NSCoder+Property.m
//  PrismCommon
//
//  Created by John Scott on 01/04/2020.
//  Copyright © 2020 John Scott. All rights reserved.
//

#import "NSCoder+Property.h"
#import "PrismCommonUtilities.h"

@implementation NSCoder (Property)

- (NSString*)keyFromPropertySelector:(SEL)propertySelector {
    return NSStringFromSelector(propertySelector);
}

- (void)encodeProperty:(SEL)propertySelector fromObject:(nullable id)object {
    NSString *key = [self keyFromPropertySelector:propertySelector];
    id value = [object valueForKey:key];
//    Print(@"encodeProperty: %@\n         value: %@", key, value);
    [self encodeObject:value forKey:key];
}

- (void)decodeProperty:(SEL)propertySelector toObject:(nullable id)object {
    NSString *key = [self keyFromPropertySelector:propertySelector];
    id value = [self decodeObjectForKey:key];
//    Print(@"decodeProperty: %@\n         value: %@", key, value);
    if (value) [object setValue:value forKey:key];
}

@end
