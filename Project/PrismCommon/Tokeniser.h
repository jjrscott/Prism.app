//
//  Tokeniser.h
//  PrismCommon
//
//  Created by John Scott on 26/04/2020.
//  Copyright © 2020 John Scott. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Tokeniser <NSObject>

+ (NSArray*)availableLanguages;

//+ (NSArray*)tokenizeString:(NSString *)input language:(NSString *)language error:(NSError **)error;

+ (NSArray*)tokenizeData:(NSData *)data language:(NSString *)language error:(NSError **)error;


@end
