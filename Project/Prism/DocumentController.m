//
//  DocumentController.m
//  Prism
//
//  Created by John Scott on 27/03/2020.
//  Copyright © 2020 John Scott. All rights reserved.
//

#import "DocumentController.h"
#import <PrismCommon/PrismCommon.h>
#import "Document.h"

@implementation DocumentController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [NSDistributedNotificationCenter.defaultCenter addObserver:self
                                                          selector:@selector(distributedNotificationHandler:)
                                                              name:@"PrismCLIOpenDocument"
                                                            object:nil];
    }
    return self;
}

- (void)distributedNotificationHandler:(NSNotification *)aNotification
{
    NSError *error = nil;
    Document *document = [NSDocumentController.sharedDocumentController openUntitledDocumentAndDisplay:YES error:&error];
    document.cliToken = aNotification.object;
    document.localPath = aNotification.userInfo[@"localPath"];
    document.remotePath = aNotification.userInfo[@"remotePath"];
    Print(@"Open document: %@ %@ <=> %@", document.cliToken, document.localPath, document.remotePath);
    [document refreshContent:nil];
}

- (void)addDocument:(NSDocument *)document {
    [super addDocument:document];
}

-(void)removeDocument:(Document *)document
{
    Print(@"Close document: %@", document.cliToken);
    [super removeDocument:document];
    
    if (document.cliToken)
    {
        [NSDistributedNotificationCenter.defaultCenter postNotificationName:@"PrismCLICloseDocument"
                                                                     object:document.cliToken
                                                                   userInfo:nil
                                                                    options:NSDistributedNotificationDeliverImmediately];
    }
}

@end
