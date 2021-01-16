//
//  NSData+STYAdditions.h
//  Staycation
//
//  Created by John Scott on 24/03/2014.
//  Copyright (c) 2014 John Scott. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (STYAdditions)

- (NSString*)STYAdditions_hexEncodedString;
- (NSString*)STYAdditions_dumbEncodedString;

+ (id)STYAdditions_dataWithHexEncodedString:(NSString*)hexEncodedString;

@end
