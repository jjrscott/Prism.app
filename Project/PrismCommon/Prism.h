//
//  Prism.h
//  PrismCommon
//
//  Created by John Scott on 28/03/2020.
//  Copyright © 2020 John Scott. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Prism : NSObject

- (NSArray*)availableLanguages;

- (NSArray*)suggestedLanguagesForPath:(NSString *)path;

- (NSArray*)tokenizePath:(NSString *)path language:(NSString *)language error:(NSError **)error;
- (NSArray*)tokenizeString:(NSString *)input language:(NSString *)language error:(NSError **)error;

@end
