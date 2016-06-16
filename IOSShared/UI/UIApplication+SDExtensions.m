//
//  UIApplication+SDExtensions.m
//  SetDirection
//
//  Created by Sam Grover on 6/27/13.
//  Copyright (c) 2013-2014 SetDirection All rights reserved.
//

#import "UIApplication+SDExtensions.h"

@implementation UIApplication (SDExtensions)

#pragma mark - Standard iOS File system directories

+ (NSString *)documentsDirectoryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

+ (NSString *)libraryDirectoryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

+ (NSURL *)documentsDirectoryURL
{
    return [NSURL URLWithString:[self documentsDirectoryPath]];
}

+ (NSURL *)libraryDirectoryURL
{
    return [NSURL URLWithString:[self libraryDirectoryPath]];
}

+ (UIWindow *)applicationWindow
{
    NSArray *windows = [[UIApplication sharedApplication] windows];
    for (UIWindow *window in windows)
        if (window.windowLevel == UIWindowLevelNormal)
            return window;
    
    return nil;
}

// Check for Push using isRegisteredForRemoteNotifications if available, otherwise use enabledRemoteNotificationTypes
// Supports backward compatability to iOS 7
+ (BOOL)isPushEnabled
{
    BOOL pushEnabled;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_8_0 // Deployment target < iOS 8.0
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        pushEnabled = [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
    }
    else
    {
        pushEnabled = !([[UIApplication sharedApplication] enabledRemoteNotificationTypes] == UIRemoteNotificationTypeNone);
    }
#else // Deployment target > iOS 8.0
    pushEnabled = [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
#endif

    return pushEnabled;
}

@end
