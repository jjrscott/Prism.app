//
//  NSObject+Difference.h
//  PrismCommon
//
//  Created by John Scott on 10/04/2020.
//  Copyright © 2020 John Scott. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Difference)

-(id)diffWith:(id)anObject;

-(id)diffWith:(id)anObject isEqual:(BOOL (^)(id left, id right))isEqual;

@end
