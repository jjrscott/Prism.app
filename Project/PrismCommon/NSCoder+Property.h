//
//  NSCoder+Property.h
//  PrismCommon
//
//  Created by John Scott on 01/04/2020.
//  Copyright © 2020 John Scott. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSCoder (Property)

- (void)encodeProperty:(SEL)propertySelector fromObject:(id)object;
- (void)decodeProperty:(SEL)propertySelector toObject:(id)object;


@end
