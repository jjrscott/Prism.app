//
//  UTType+ObjC.m
//  Shell
//
//  Created by John Scott on 07/02/2020.
//  Copyright © 2020 John Scott. All rights reserved.
//

#import "UTType+ObjC.h"

CFStringRef CFStringFromUTTagClass(UTTagClass inTagClass) {
    switch (inTagClass) {
        case UTTagClassFilenameExtension: return kUTTagClassFilenameExtension;
        case UTTagClassMIMEType: return kUTTagClassMIMEType;
        case UTTagClassNSPboardType: return kUTTagClassNSPboardType;
        case UTTagClassOSType: return kUTTagClassOSType;
    }
    abort();
}

@implementation UTType

+ (NSString* __nullable)createPreferredIdentifierForTagInTagClass:(UTTagClass)inTagClass
                                                            inTag:(NSString* __nonnull)inTag
                                                inConformingToUTI:(NSString* __nullable)inConformingToUTI {
    return (__bridge id)UTTypeCreatePreferredIdentifierForTag(CFStringFromUTTagClass(inTagClass),
                                                                      (__bridge CFStringRef) inTag,
                                                                      (__bridge CFStringRef)inConformingToUTI);
}

+ (NSArray <NSString *>* __nullable)createAllIdentifiersForTag:(UTTagClass)inTagClass
                                             inTag:(NSString* __nonnull)inTag
                                 inConformingToUTI:(NSString* __nullable)inConformingToUTI {
    return (__bridge id)UTTypeCreateAllIdentifiersForTag(CFStringFromUTTagClass(inTagClass),
                                                         (__bridge CFStringRef) inTag,
                                                         (__bridge CFStringRef)inConformingToUTI);
}

+ (NSDictionary <NSString*, id>*)copyDeclarationInUTI:(NSString*)inUTI {
    return (__bridge id) UTTypeCopyDeclaration((__bridge CFStringRef) inUTI);
}

@end
