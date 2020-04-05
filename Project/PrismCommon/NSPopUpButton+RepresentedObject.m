//
//  NSPopUpButton+RepresentedObject.m
//  PrismCommon
//
//  Created by John Scott on 01/04/2020.
//  Copyright © 2020 John Scott. All rights reserved.
//

#import "NSPopUpButton+RepresentedObject.h"

@implementation NSPopUpButton (RepresentedObject)

- (BOOL)selectItemWithRepresentedObject:(nullable id)obj {
    NSInteger index = [self indexOfItemWithRepresentedObject:obj];
    if (index == NSNotFound) return FALSE;
    [self selectItemAtIndex:index];
    return TRUE;
}

@end
