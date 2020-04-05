//
//  NSPopUpButton+RepresentedObject.h
//  PrismCommon
//
//  Created by John Scott on 01/04/2020.
//  Copyright © 2020 John Scott. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSPopUpButton (RepresentedObject)

- (BOOL)selectItemWithRepresentedObject:(nullable id)obj;

@end
