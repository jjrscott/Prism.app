//
//  AppDelegate.m
//  Prism
//
//  Created by John Scott on 27/03/2020.
//  Copyright © 2020 John Scott. All rights reserved.
//

#import "AppDelegate.h"
#import <PrismCommon/PrismCommon.h>
#import "DocumentController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification {
    [DocumentController sharedDocumentController];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application    
}

#pragma mark - NSDistributedNotificationCenter Observer

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender {
    return NO;
}

- (IBAction)installComandLineTools:(id)sender
{
    NSError *error = nil;
    NSURL *url = [NSURL fileURLWithPath:@"/usr/local/bin/prism"];
    
    [NSFileManager.defaultManager removeItemAtURL:url error:&error];
    
    if (error) {
        Print(@"Error when removing prism. Probably doesn't matter: %@", error);
    }
    error = nil;
    
    [NSFileManager.defaultManager createSymbolicLinkAtURL:url
                                       withDestinationURL:[NSBundle.mainBundle URLForAuxiliaryExecutable:@"PrismCLI"]
                                                    error:&error];
    
    if (error) {
        Print(@"Error when removing prism. Probably does matter: %@", error);
    }
}

@end
