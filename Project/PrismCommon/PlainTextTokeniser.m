//
//  PlainTextTokeniser.m
//  PrismCommon
//
//  Created by John Scott on 26/04/2020.
//  Copyright © 2020 John Scott. All rights reserved.
//

#import "PlainTextTokeniser.h"

@implementation PlainTextTokeniser

+(NSArray *)availableLanguages {
    return @[@"public.plain-text"];
}

+(NSArray *)tokenizeString:(NSString *)input language:(NSString *)language error:(NSError *__autoreleasing *)error {
    NSMutableArray *tokens = [NSMutableArray new];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"([^\n]+\n?|[\n])" options:kNilOptions error:NULL];
    [regex enumerateMatchesInString:input
                            options:kNilOptions
                              range:NSMakeRange(0, input.length)
                         usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
                             [tokens addObject:[input substringWithRange:result.range]];
                         }];
    
    return tokens.copy;
}


@end
