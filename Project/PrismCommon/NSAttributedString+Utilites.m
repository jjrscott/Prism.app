//
//  NSAttributedString+Utilites.m
//  PrismCommon
//
//  Created by John Scott on 15/04/2020.
//  Copyright © 2020 John Scott. All rights reserved.
//

#import "NSAttributedString+Utilites.h"

@implementation NSAttributedString (Utilites)

-(NSAttributedString*)attributedStringWithAttribute:(NSAttributedStringKey)name value:(id)value {
    NSMutableAttributedString* mutableAttributedString = [self mutableCopy];
    [mutableAttributedString addAttribute:name value:value range:NSMakeRange(0, self.length)];
    return [mutableAttributedString copy];
}

@end
