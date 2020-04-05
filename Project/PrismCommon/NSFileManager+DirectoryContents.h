//
//  NSFileManager+DirectoryContents.h
//  Shell
//
//  Created by John Scott on 15/02/2020.
//  Copyright © 2020 John Scott. All rights reserved.
//

#import <AppKit/AppKit.h>


#import <Foundation/Foundation.h>

@interface NSFileManager (DirectoryContents)

- (NSDictionary<NSString *, NSString *> * _Nullable)mappedContentsOfDirectoryAtPath:(NSString * _Nonnull)path error:(NSError *_Nullable*_Nullable)error;

@end
