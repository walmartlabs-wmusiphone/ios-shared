//
//  UIApplication+SDExtensions.h
//  SetDirection
//
//  Created by Sam Grover on 6/27/13.
//  Copyright (c) 2013-2014 SetDirection All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIApplication (SDExtensions)

/**
 Returns the path to the Documents folder in the application sandbox
 */
+ (NSString *)documentsDirectoryPath;

/**
 Returns the path to the Library folder in the application sandbox
 */
+ (NSString *)libraryDirectoryPath;

/**
 Returns the URL to the Documents folder in the application sandbox
 */
+ (NSURL *)documentsDirectoryURL;

/**
 Returns the URL to the Library folder in the application sandbox
 */
+ (NSURL *)libraryDirectoryURL;

+ (UIWindow *)applicationWindow;

/**
 Whether or not remote push notifications are enabled
 */
+ (BOOL)isPushEnabled;

@end
