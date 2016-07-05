//
//  SDContentAlertView.h
//
//  Created by Brandon Sneed on 11/03/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//
//  Based on PXAlertView by Alex Jarvis under the MIT license.
//  Copyright (c) 2013 Panaxiom Ltd. All rights reserved.

#import <UIKit/UIKit.h>

typedef void (^SDContentAlertViewCompletionBlock)(BOOL cancelled);

@interface SDContentAlertView : UIView

/**
 *  Background color of the alert view.
 */
@property (nonatomic, strong) UIColor *backgroundColor UI_APPEARANCE_SELECTOR;
/**
 *  Line separator color, above and between buttons.
 */
@property (nonatomic, strong) UIColor *lineColor UI_APPEARANCE_SELECTOR;
/**
 *  Color to use for the Title and Message labels.
 */
@property (nonatomic, strong) UIColor *textColor UI_APPEARANCE_SELECTOR;
/**
 *  Color for the text on the buttons themselves.
 */
@property (nonatomic, strong) UIColor *buttonTextColor UI_APPEARANCE_SELECTOR;
/**
 *  Background color of the buttons when they are in a selected state.
 */
@property (nonatomic, strong) UIColor *buttonSelectionColor UI_APPEARANCE_SELECTOR;
/**
 *  Text color when the buttons are in a selected state.
 */
@property (nonatomic, strong) UIColor *buttonSelectionTextColor UI_APPEARANCE_SELECTOR;
/**
 *  Tells the caller if the alert view is visible on-screen.
 */
@property (nonatomic, readonly) BOOL visible;

/**
 *  Show an alert view with a title.
 *
 *  @param title Title to display.
 *
 *  @return An instance of SDContentAlertView
 */
+ (SDContentAlertView *)showAlertWithTitle:(NSString *)title;

/**
 *  Show an alert view with a title and message.
 *
 *  @param title   Title to display.
 *  @param message Message to display.
 *
 *  @return An instance of SDContentAlertView
 */
+ (SDContentAlertView *)showAlertWithTitle:(NSString *)title message:(NSString *)message;

/**
 *  Show an alert view with a title and message.
 *
 *  @param title   Title to display.
 *  @param message Message to display.
 *  @param completion The completion block that will be run when a selection is made.
 *
 *  @return An instance of SDContentAlertView
 */
+ (SDContentAlertView *)showAlertWithTitle:(NSString *)title message:(NSString *)message completion:(SDContentAlertViewCompletionBlock)completion;

/**
 *  Show an alert view with a title and message.
 *
 *  @param title   Title to display.
 *  @param message Message to display.
 *  @param cancelTitle Title to be shown for the cancel button.
 *  @param completion The completion block that will be run when a selection is made.
 *
 *  @return An instance of SDContentAlertView
 */
+ (SDContentAlertView *)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelTitle:(NSString *)cancelTitle completion:(SDContentAlertViewCompletionBlock)completion;

/**
 *  Show an alert view with a title and message.
 *
 *  @param title   Title to display.
 *  @param message Message to display.
 *  @param cancelTitle Title to be shown for the cancel button.
 *  @param otherTitle Title to be shown for the OK button.
 *  @param completion The completion block that will be run when a selection is made.
 *
 *  @return An instance of SDContentAlertView
 */
+ (SDContentAlertView *)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelTitle:(NSString *)cancelTitle otherTitle:(NSString *)otherTitle completion:(SDContentAlertViewCompletionBlock)completion;

/**
 *  Show an alert view with a title and message.
 *
 *  @param title   Title to display.
 *  @param message Message to display.
 *  @param cancelTitle Title to be shown for the cancel button.
 *  @param otherTitle Title to be shown for the OK button.
 *  @param contentView Content view to be shown within the alert.
 *  @param completion The completion block that will be run when a selection is made.
 *
 *  @return An instance of SDContentAlertView
 */
+ (SDContentAlertView *)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelTitle:(NSString *)cancelTitle otherTitle:(NSString *)otherTitle contentView:(UIView *)view completion:(SDContentAlertViewCompletionBlock)completion;

/**
 *  Current value of the default windowLevel used when creating new SDContentAlertView instances
 */
+ (UIWindowLevel) defaultAlertWindowLevel;

/**
 *  Change default windowLevel used for newly created or hidden SDContentAlertView instances
 *  to allow user of the class enough control to avoid conflicts with other uses of secondary
 *  UIWindow instances
 */
+ (void) setDefaultAlertWindowLevel:(UIWindowLevel) defaultAlertWindowLevel;

@end
