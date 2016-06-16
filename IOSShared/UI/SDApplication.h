//
//  SDApplication.h
//
//  Created by Brandon Sneed on 1/6/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSObject+SDExtensions.h"

@interface SDApplication : UIApplication

+ (instancetype)sharedApplication;

- (void)addIdleTimeout:(NSTimeInterval)timeoutInterval controller:(UIViewController *)controller handlerBlock:(NSObjectPerformBlock)handlerBlock;
- (void)removeIdleTimeoutsForController:(UIViewController *)controller;
- (void)handleOverdueTimers;
- (void)cleanupIdleTimers;

/*- (void)addActionForNotification:(NSString *)notificationName controller:(UIViewController *)controller actionBlock:(NSObjectPerformBlock)actionBlock;
- (void)removeActionForNotification:(NSString *)notificationName controller:(UIViewController *)controller;
- (void)cleanupActions;*/

@end

int SDApplicationMain(int argc, char *argv[], NSString *delegateClassName);
