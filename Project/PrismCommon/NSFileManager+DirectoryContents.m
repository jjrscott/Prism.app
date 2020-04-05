//
//  NSFileManager+DirectoryContents.m
//  Shell
//
//  Created by John Scott on 15/02/2020.
//  Copyright © 2020 John Scott. All rights reserved.
//

#import "NSFileManager+DirectoryContents.h"

#import <Foundation/Foundation.h>


@implementation NSFileManager (DirectoryContents)

- (NSDictionary<NSString *, NSString *> * _Nullable)mappedContentsOfDirectoryAtPath:(NSString * _Nonnull)path error:(NSError *_Nullable*_Nullable)error {
    NSArray <NSString *>* contents = [self contentsOfDirectoryAtPath:path error:error];
    if (!contents || (error && *error)) return nil;
    
    NSMutableDictionary *mappedContents = [NSMutableDictionary new];
    for (NSString *fileName in contents) {
        mappedContents[fileName.stringByDeletingPathExtension] = [path stringByAppendingPathComponent:fileName];
    }
    return [mappedContents copy];
}

@end
