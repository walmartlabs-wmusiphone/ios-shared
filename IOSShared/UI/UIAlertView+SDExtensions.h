//
//  UIAlertView+SDExtensions.h
//  SetDirection
//
//  Created by brandon on 2/17/11.
//  Copyright 2011 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIAlertView(SDExtensions)

/**
 A wrapper for alertViewWithTitle:message:buttonTitle: with the button title set to `OK`.
 */
+ (UIAlertView *)alertViewWithTitle:(NSString *)title message:(NSString *)message;

/**
 A convenience method to create and return a single button modal alert view with the given parameters.
 @param title The title of the alert view.
 @param message The message displayed on the alert view.
 @param buttonTitle The title to display on the button.
 */
+ (UIAlertView *)alertViewWithTitle:(NSString *)title message:(NSString *)message buttonTitle:(NSString *)buttonTitle;

@end
