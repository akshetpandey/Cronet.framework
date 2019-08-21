//
//  CNAppDelegate.m
//  Cronet
//
//  Created by akshetpandey on 08/20/2019.
//  Copyright (c) 2019 akshetpandey. All rights reserved.
//

#import "CNAppDelegate.h"
#import "Cronet/Cronet.h"

@implementation CNAppDelegate {
    NSUInteger _counter;
}

// Returns a file name to save net internals logging. This method suffixes
// the ivar |_counter| to the file name so a new name can be obtained by
// modifying that.
- (NSString*)currentNetLogFileName {
    return [NSString
            stringWithFormat:@"cronet-consumer-net-log%lu.json", (unsigned long)_counter];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [Cronet setHttp2Enabled:YES];
    [Cronet setQuicEnabled:YES];
    [Cronet setBrotliEnabled:YES];
    [Cronet setAcceptLanguages:@"en-US,en"];

    [Cronet setUserAgent:@"CronetTest/1.0.0.0" partial:NO];
    [Cronet addQuicHint:@"www.chromium.org" port:443 altPort:443];

    [Cronet setHttpCacheType:CRNHttpCacheTypeDisabled];
    [Cronet setMetricsEnabled:YES];

    [Cronet start];

    [Cronet startNetLogToFile:[self currentNetLogFileName] logBytes:NO];
    [Cronet registerHttpProtocolHandler];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [Cronet stopNetLog];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    _counter++;
    [Cronet startNetLogToFile:[self currentNetLogFileName] logBytes:NO];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
