//
//  NSAttributedString+Utilites.h
//  PrismCommon
//
//  Created by John Scott on 15/04/2020.
//  Copyright © 2020 John Scott. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (Utilites)

-(nonnull NSAttributedString*)attributedStringWithAttribute:(nonnull NSAttributedStringKey)name value:(nonnull id)value;

@end
