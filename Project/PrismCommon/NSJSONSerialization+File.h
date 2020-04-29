//
//  NSJSONSerialization+File.h
//  xml2json
//
//  Created by John Scott on 09/04/2020.
//  Copyright © 2020 John Scott. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSJSONSerialization (File)

+ (BOOL)writeJSONObject:(id)obj toFile:(NSString *)path error:(NSError **)error;

+ (id)JSONObjectWithContentsOfFile:(NSString *)path error:(NSError **)error;

@end
