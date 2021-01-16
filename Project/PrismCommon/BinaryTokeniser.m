//
//  BinaryTokeniser.m
//  PrismCommon
//
//  Created by John Scott on 14/07/2020.
//  Copyright © 2020 John Scott. All rights reserved.
//

#import "BinaryTokeniser.h"

#import "NSData+STYAdditions.h"

@implementation BinaryTokeniser

+ (NSArray *)availableLanguages { 
    return @[@"public.data"];
}


+ (NSArray*)tokenizeData:(NSData *)data language:(NSString *)language error:(NSError **)error {
    NSMutableArray *buffer = [NSMutableArray new];
    NSInteger blockLength = 8;
    NSInteger lineLengthInBlocks = 4;
    for (NSInteger location=0; location<data.length; location += blockLength) {
        NSData *subdata = [data subdataWithRange:NSMakeRange(location, MIN(blockLength, data.length - location))];
        NSString *hex = [subdata STYAdditions_hexEncodedString];
        NSString *string = [subdata STYAdditions_dumbEncodedString];

        [buffer addObject:[NSString stringWithFormat:@"%30@", hex]];
    }
    
    
    return buffer;
}

@end
