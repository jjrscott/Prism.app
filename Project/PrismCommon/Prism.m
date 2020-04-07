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

@property (nonatomic, strong) JSContext *context;

@end


@implementation Prism

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSURL *prismURL = [[NSBundle bundleForClass:self.class] URLForResource:@"prism"
                                                                 withExtension:@"js"];
        _context = [JSContext new];
        NSString *prismSourcecode = [NSString stringWithContentsOfURL:prismURL encoding:NSUTF8StringEncoding error:NULL];
        [_context evaluateScript:prismSourcecode withSourceURL:prismURL];

    }
    return self;
}

- (NSArray*)availableLanguages {
    JSValue *values = [_context evaluateScript:@"Object.keys(Prism.languages)"];
    NSMutableArray *availableLanguages = NSMutableArray.new;
    [availableLanguages addObject:@"x-plain"];
    [availableLanguages addObjectsFromArray:values.toArray];
    return availableLanguages.copy;
    
}

void Conforms(NSString *uti, NSMutableArray *parentUTIs) {
    
    [parentUTIs addObject:uti];
    [parentUTIs addObject:@"\n"];
    NSArray *parentUtis = [UTType copyDeclarationInUTI:uti][(__bridge id)kUTTypeConformsToKey];
    
    for (NSString* parentUti in parentUtis) {
        Conforms(parentUti, parentUTIs);
    }
}

- (NSArray*)suggestedLanguagesForPath:(NSString *)path {
    NSString *preferredIdentifier = [UTType createPreferredIdentifierForTagInTagClass:UTTagClassFilenameExtension
                                                                                inTag:path.pathExtension
                                                                    inConformingToUTI:nil];

    if ([preferredIdentifier hasPrefix:@"dyn."]) preferredIdentifier = [@"prism.extension" stringByAppendingPathExtension:path.pathExtension];
    
    NSDictionary *prismLanguages = @{
                                     @"public.shell-script" : @"shell",
                                     @"public.yaml" : @"yaml",
                                     @"public.c-header" : @"c",
                                     @"public.objective-c-source" : @"objectivec",
                                     @"public.perl-script" : @"perl",
                                     @"public.xml" : @"xml",
                                     @"com.sun.java-source" : @"java",
                                     @"public.json" : @"json",
                                     @"prism.extension.gradle" : @"groovy",
                                     @"prism.extension.groovy" : @"groovy",
                                     @"prism.extension.gvy" : @"groovy",
                                     @"prism.extension.kt" : @"kotlin",
                                     @"net.daringfireball.markdown" : @"markdown",
                                     @"public.plain-text" : @"x-plain",
                                     };


    NSMutableArray *parentUTIs = [NSMutableArray new];
    Conforms(preferredIdentifier, parentUTIs);
    
    NSMutableArray *suggestedLanguages = [NSMutableArray new];
    for (NSString *conformsToUTI in parentUTIs) {
        NSString *prismLanguage = prismLanguages[conformsToUTI];
        if (prismLanguage) {
            [suggestedLanguages addObject:prismLanguage];
        }
    }
    return suggestedLanguages.copy;
}

- (NSArray*)tokenizePath:(NSString *)path language:(NSString *)language error:(NSError **)error
{
    NSString *content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    
    return [self tokenizeString:content language:language error:NULL];
}

-(NSArray*)splitLines:(NSString*)string {
    NSMutableArray *tokens = [NSMutableArray new];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"([^\n]+|[\n])" options:kNilOptions error:NULL];
    [regex enumerateMatchesInString:string
                            options:kNilOptions
                              range:NSMakeRange(0, string.length)
                         usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
                             [tokens addObject:[string substringWithRange:result.range]];
                         }];
    
    return tokens.copy;
}

- (NSArray*)tokenizeString:(NSString *)input language:(NSString *)language error:(NSError **)error
{
    if ([language isEqual:@"x-plain"]) {
        return [self splitLines:input];
    } else {
        _context[@"input"] = input;
        _context[@"language"] = language;
        JSValue *values = [_context evaluateScript:@"Prism.tokenize(input, Prism.languages[language])"];
        return [self clean:values.toArray];
    }
}

-(NSArray*)clean:(NSArray*)array {
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
