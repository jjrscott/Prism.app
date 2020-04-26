//
//  Prism.m
//  PrismCommon
//
//  Created by John Scott on 28/03/2020.
//  Copyright © 2020 John Scott. All rights reserved.
//

#import "Prism.h"
@import JavaScriptCore;
#import "UTType+ObjC.h"
#import "PrismCommonUtilities.h"

@interface Prism ()

@property (nonatomic, class, readonly) JSContext *context;
@property (nonatomic, class, readonly) NSDictionary *prismLanguages;

@end

@implementation Prism

+ (NSDictionary *)prismLanguages {
    static NSDictionary *prismLanguages;
    static dispatch_once_t onceToken;
    dispatch_once (&onceToken, ^{
        NSURL *prismUTIsURL = [[NSBundle bundleForClass:self] URLForResource:@"PrismUTIs"
                                                               withExtension:@"plist"];
        
        prismLanguages = [NSDictionary dictionaryWithContentsOfURL:prismUTIsURL];
        
        DumpStrings(prismLanguages);
    });
    return prismLanguages;
}

+ (JSContext *)context {
    static JSContext *context;

    static dispatch_once_t onceToken;
    dispatch_once (&onceToken, ^{
        NSURL *prismURL = [[NSBundle bundleForClass:self] URLForResource:@"prism"
                                                           withExtension:@"js"];
        context = [JSContext new];
        NSString *prismSourcecode = [NSString stringWithContentsOfURL:prismURL encoding:NSUTF8StringEncoding error:NULL];
        [context evaluateScript:prismSourcecode withSourceURL:prismURL];
    });
    return context;
    
}


+ (NSArray*)availableLanguages {
    return self.prismLanguages.allKeys;
}

+ (NSArray*)splitLines:(NSString*)string {
    NSMutableArray *tokens = [NSMutableArray new];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"([^\n]+\n?|[\n])" options:kNilOptions error:NULL];
    [regex enumerateMatchesInString:string
                            options:kNilOptions
                              range:NSMakeRange(0, string.length)
                         usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
                             [tokens addObject:[string substringWithRange:result.range]];
                         }];
    
    return tokens.copy;
}

+ (NSArray*)tokenizeString:(NSString *)input language:(NSString *)language error:(NSError **)error
{
    NSString *prismLanguage = self.prismLanguages[language];
    if ([prismLanguage isEqual:@"x-plain"]) {
        return [self splitLines:input];
    } else {
        self.context[@"input"] = input;
        self.context[@"language"] = prismLanguage;
        JSValue *values = [self.context evaluateScript:@"Prism.tokenize(input, Prism.languages[language])"];
        return [self clean:values.toArray];
    }
}

+ (NSArray*)clean:(NSArray*)array {
    NSMutableArray *buffer = [NSMutableArray new];
    for (id token in array)
    {
        if ([token isKindOfClass:NSString.class]) {
            [buffer addObjectsFromArray:[self splitLines:token]];
        } else {
            [buffer addObject:token];
        }
    }
    return buffer.copy;
    
}

@end
