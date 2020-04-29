//
//  NSJSONSerialization+File.m
//  xml2json
//
//  Created by John Scott on 09/04/2020.
//  Copyright © 2020 John Scott. All rights reserved.
//

#import "NSJSONSerialization+File.h"

@implementation NSJSONSerialization (File)

+ (BOOL)writeJSONObject:(id)obj toFile:(NSString *)path error:(NSError **)error
{
    NSData *data = [NSJSONSerialization dataWithJSONObject:obj
                                                   options:NSJSONWritingPrettyPrinted | NSJSONWritingSortedKeys
                                                     error:error];
    
    return [data writeToFile:path
                     options:NSDataWritingAtomic
                       error:error];
}

+ (id)JSONObjectWithContentsOfFile:(NSString *)path error:(NSError **)error {
    
    NSInputStream *inputStream = [NSInputStream inputStreamWithFileAtPath:path];
    [inputStream open];
    return [self JSONObjectWithStream:inputStream
                              options:kNilOptions
                                error:error];    
}



@end
