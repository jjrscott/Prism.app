//
//  NSObject+Patch.h
//  PrismCommon
//
//  Created by John Scott on 14/04/2020.
//  Copyright © 2020 John Scott. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Patch)

+(__kindof NSObject*)differenceWithLeft:(__kindof NSObject*)leftObject right:(__kindof NSObject*)rightObject;

@end
