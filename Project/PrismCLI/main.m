//
//  main.m
//  PrismCLI
//
//  Created by John Scott on 27/03/2020.
//  Copyright © 2020 John Scott. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PrismCommon/PrismCommon.h>

@interface DistributedNotificationHandler : NSObject

+ (void)distributedNotificationHandler:(NSNotification *)aNotification;

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {

        NSString *localPath = [NSUserDefaults.standardUserDefaults stringForKey:@"local"];
        NSString *remotePath = [NSUserDefaults.standardUserDefaults stringForKey:@"remote"];
        
        if (!localPath || !remotePath)
        {
            Print(@"%@ -local <local-file> -remote <remote-file>", NSProcessInfo.processInfo.arguments[0].lastPathComponent);
            return 1;
        }
        
        NSMutableDictionary *processInfo = [NSMutableDictionary new];
        processInfo[@"environment"] = NSProcessInfo.processInfo.environment;
        processInfo[@"localPath"] = [[NSURL fileURLWithPath:localPath relativeToURL:[NSURL fileURLWithPath:NSFileManager.defaultManager.currentDirectoryPath]] path];
        processInfo[@"remotePath"] = [[NSURL fileURLWithPath:remotePath relativeToURL:[NSURL fileURLWithPath:NSFileManager.defaultManager.currentDirectoryPath]] path];
        ;

        NSString *executablePath = [NSProcessInfo.processInfo.arguments.firstObject stringByResolvingSymlinksInPath];
        
        while (![executablePath.pathExtension isEqualToString:@"app"])
        {
            executablePath = [executablePath stringByDeletingLastPathComponent];
            if ([executablePath isEqualToString:@"/"])
            {
                Print(@"Could not find enclosing bundle");
                return 1;
            }
        }
        
        NSError *error = nil;
        NSRunningApplication *runningApplication = [NSWorkspace.sharedWorkspace launchApplicationAtURL:[NSURL fileURLWithPath:executablePath]
                                                                                               options:kNilOptions
                                                                                         configuration:@{}
                                                                                                 error:&error];
        
        if (!runningApplication)
        {
            Print(@"%@", error.localizedDescription);
            return 1;
        }

        NSString *object = NSProcessInfo.processInfo.globallyUniqueString;
        
        [NSDistributedNotificationCenter.defaultCenter addObserver:DistributedNotificationHandler.class
                                                          selector:@selector(distributedNotificationHandler:)
                                                              name:@"PrismCLICloseDocument"
                                                            object:object];
        
        [NSDistributedNotificationCenter.defaultCenter postNotificationName:@"PrismCLIOpenDocument"
                                                                     object:object
                                                                   userInfo:processInfo
                                                                    options:NSDistributedNotificationDeliverImmediately];
        
        [NSRunLoop.mainRunLoop run];
    }
    return 0;
}

@implementation DistributedNotificationHandler

+ (void)distributedNotificationHandler:(NSNotification *)aNotification
{
    exit(0);
}

@end
