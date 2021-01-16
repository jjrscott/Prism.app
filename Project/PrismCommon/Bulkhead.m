//
//  Bulkhead.m
//  PrismCommon
//
//  Created by John Scott on 09/04/2020.
//  Copyright © 2020 John Scott. All rights reserved.
//

#import "Bulkhead.h"
#import "UTType+ObjC.h"
#import "PrismCommonUtilities.h"
#import "NSFileManager+DirectoryContents.h"
#import "NSJSONSerialization+File.h"

@interface Bulkhead ()

@property (nonatomic, strong) NSMutableDictionary <NSRegularExpression*, NSString*>*types;

@end

@implementation Bulkhead

+ (NSArray *)availableLanguages {
    
    NSDictionary *foo = [NSFileManager.defaultManager mappedContentsOfDirectoryAtPath:[[NSBundle bundleForClass:self.class] pathForResource:@"Bulkhead" ofType:nil]
                                                                                error:NULL];
    return foo.allKeys;
}

-(void)conforms:(NSString*)uti parentUTIs:(NSMutableArray *)parentUTIs {
    
    [parentUTIs addObject:uti];
    NSArray *parentUtis = [UTType copyDeclarationInUTI:uti][(__bridge id)kUTTypeConformsToKey];
    
    for (NSString* parentUti in parentUtis) {
        [self conforms:parentUti parentUTIs:parentUTIs];
    }
}

+ (NSArray *)tokenizeString:(NSString *)input language:(NSString *)language error:(NSError *__autoreleasing *)error {
    return [Bulkhead.new tokenizeString:input language:language error:error];
}

+ (NSArray *)tokenizeData:(NSData *)data language:(NSString *)language error:(NSError *__autoreleasing *)error {
    NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return [self tokenizeString:text language:language error:error];
}

- (NSArray*)tokenizeString:(NSString *)input language:(NSString *)language error:(NSError **)error {
    NSXMLDocument *document = [[NSXMLDocument alloc] initWithXMLString:input
                                                                   options:NSXMLNodeOptionsNone
                                                                     error:error];
    
    
    
    
    NSString *typesPath = [[NSBundle bundleForClass:self.class] pathForResource:language ofType:@"json" inDirectory:@"Bulkhead"];
    
    NSError *foo;
    NSDictionary *types = [NSJSONSerialization JSONObjectWithContentsOfFile:typesPath
                                                                error:&foo];
    
    _types = NSMutableDictionary.new;
    
    for (NSString *pattern in types) {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                               options:kNilOptions
                                                                                 error:&foo];
        
        if (foo) {
            Print(@"error: %@", foo);
            abort();
        }
        self.types[regex] = types[pattern];
    }
    
    return [self convertNode:document.rootElement options:@{}];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
//        _
//        _types = NSMutableDictionary.new;
    }
    return self;
}

-(id)convertNode:(NSXMLNode*)node options:(NSDictionary*)options {
    
    NSString *path = node.XPath;
    __block NSString *type = nil;
    for (NSRegularExpression *regex in self.types) {
        [regex enumerateMatchesInString:path
                                options:kNilOptions
                                  range:NSMakeRange(0, path.length)
                             usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop)
        {
            type = self.types[regex];
            *stop = YES;
        }];
        if (type) break;
    }
    
    if ([type isEqual:@"double"]) {
        return [NSNumber numberWithDouble:node.stringValue.doubleValue];
    } else if ([type isEqual:@"integer"]) {
        return [NSNumber numberWithInteger:node.stringValue.integerValue];
    } else if ([type isEqual:@"boolean"]) {
        return [NSNumber numberWithBool:node.stringValue.boolValue];
    } else if ([node.name isEqual:@"nil"]) {
        return NSNull.null;
    } else if ([type isEqual:@"array"]) {
        NSMutableArray *object = NSMutableArray.new;
        for (NSXMLNode* child in node.children) {
            if ([child isKindOfClass:NSXMLElement.class]) {
                [object addObject:[self convertNode:child options:@{}]];
            }
        }
        return object;
    } else if ([type isEqual:@"set"]) {
        NSMutableSet *object = NSMutableSet.new;
        for (NSXMLNode* child in node.children) {
            if ([child isKindOfClass:NSXMLElement.class]) {
                [object addObject:[self convertNode:child options:@{}]];
            }
        }
        return object;
    } else if ([type isEqual:@"dictionary"] || [type isEqual:@"object"] || [node isKindOfClass:NSXMLElement.class]) {
        if (![node isKindOfClass:NSXMLElement.class]) {
            Print(@"%@ not an element: %@", type, node.XPath);
            abort();
        }
        NSXMLElement *element = (NSXMLElement*) node;
        NSMutableDictionary *object = NSMutableDictionary.new;
        if (!options[@"usedName"]) object[@"$isa"] = node.name;
        for (NSXMLNode* attribute in element.attributes) {
            if (options[@"usedKey"] && [attribute.name isEqual:@"key"]) continue;
            if (object[attribute.name]) Print(@"%@ : array", path);
            object[attribute.name] = [self convertNode:attribute options:@{}];
        }
        
        for (NSXMLNode* child in element.children) {
            
            if ([child isKindOfClass:NSXMLElement.class]) {
                NSXMLElement *childElement = (NSXMLElement *)child;
                
                NSString *key = [[childElement attributeForName:@"key"] stringValue];
                NSDictionary *options;
                if (key) {
                    options = @{@"usedKey" : @YES};
                } else {
                    key = child.name;
                    options = @{@"usedName" : @YES};
                }
                
                if (object[key]) Print(@"%@ : array", path);
                object[key] = [self convertNode:child options:options];
            }
        }
        return object;
    } else {
        if ([node.stringValue isEqual:@"YES"] || [node.stringValue isEqual:@"NO"]) {
//            Print(@"%@ : boolean", path);
            return [NSNumber numberWithBool:node.stringValue.boolValue];
        } else if (node.stringValue.doubleValue != 0 || [node.stringValue isEqual:@"0"]) {
//            Print(@"%@ : double", path);
            return [NSNumber numberWithDouble:node.stringValue.doubleValue];
        }
        return node.stringValue;
    }
}


@end
