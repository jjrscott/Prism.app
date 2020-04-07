//
//  NSJSONSerialization+String.h
//  PrismCommon
//
//  Created by John Scott on 06/04/2020.
//  Copyright © 2020 John Scott. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSJSONSerialization (String)

+ (NSString *)stringWithJSONObject:(id)obj options:(NSJSONWritingOptions)opt error:(NSError **)error;

@end
