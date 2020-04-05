//
//  Document.h
//  Prism
//
//  Created by John Scott on 27/03/2020.
//  Copyright © 2020 John Scott. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Document : NSDocument

@property (nonatomic, strong) NSString *cliToken;

@property (nonatomic, strong) NSString *localPath;
@property (nonatomic, strong) NSString *remotePath;

- (IBAction)refreshContent:(id)sender;

@end

