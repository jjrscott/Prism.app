//
//  UTType+ObjC.h
//  Shell
//
//  Created by John Scott on 07/02/2020.
//  Copyright © 2020 John Scott. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(FourCharCode, UTTagClass) {
    UTTagClassFilenameExtension,
    UTTagClassMIMEType,
    UTTagClassNSPboardType,
    UTTagClassOSType,
};

@interface UTType : NSObject

+ (NSString* __nullable)createPreferredIdentifierForTagInTagClass:(UTTagClass)inTagClass
                                                           inTag:(NSString* __nonnull)inTag
                                               inConformingToUTI:(NSString* __nullable)inConformingToUTI;

+ (NSArray <NSString *>* __nullable)createAllIdentifiersForTag:(UTTagClass)inTagClass
                                                        inTag:(NSString* __nonnull)inTag
                                            inConformingToUTI:(NSString* __nullable)inConformingToUTI;

+ (NSDictionary <NSString*, id>* __nullable)copyDeclarationInUTI:(NSString* __nonnull)inUTI;

@end
