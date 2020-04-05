//
//  NSArray+LongestCommonSubsequence.h
//  LCSTest
//
//  Created by John Scott on 08/10/2019.
//  Copyright © 2019 John Scott. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Patch<Element> : NSObject;

@property (nonatomic, strong, readonly) Element left;
@property (nonatomic, strong, readonly) Element right;

+(instancetype)patchWithLeft:(id)left right:(id)right;

@end

@interface NSArray<Element> (LCS)

-(NSArray<Patch<Element>*>*)longestCommonSubsequence:(NSArray*)anArray;
-(NSArray<Patch<Element>*>*)longestCommonSubsequence:(NSArray*)anArray isEqual:(BOOL (^)(Element left, Element right))isEqual;

@end

