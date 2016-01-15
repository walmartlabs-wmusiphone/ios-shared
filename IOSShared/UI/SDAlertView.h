//
//  SDAlertView.h
//  RxClient
//
//  Created by Brandon Sneed on 10/17/13.
//  Copyright 2013-2014 SetDirection. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SDAlertView;

typedef void(^SDAlertViewCompletionBlock)(UIAlertView *alertView, NSInteger tappedButtonIndex);

@interface SDAlertView : UIAlertView

/**
 *  Show an alert view.
 *
 *  @param title Title of the alert view.
 *
 *  @return An instance of SDAlertView.
 */
+ (SDAlertView *)showAlertWithTitle:(NSString *)title;

/**
 *  Show an alert view.
 *
 *  @param title   Title of the alert view.
 *  @param message Message to be shown in alert view.
 *
 *  @return An instance of SDAlertView.
 */
+ (SDAlertView *)showAlertWithTitle:(NSString *)title message:(NSString *)message;

/**
 *  Show an alert view.
 *
 *  @param title           Title of the alert view.
 *  @param message         Message to be shown in alert view.
 *  @param completionBlock Completion block to be executed when a selection is made.
 *
 *  @return An instance of SDAlertView.
 */
+ (SDAlertView *)showAlertWithTitle:(NSString *)title message:(NSString *)message completion:(SDAlertViewCompletionBlock)completionBlock;

/**
 *  Show an alert view.
 *
 *  @param title             Title of the alert view.
 *  @param message           Message to be shown in the alert view.
 *  @param cancelButtonTitle Title to be used for the cancel button (index 0).
 *  @param completionBlock   Completion block to be executed when a selection is made.
 *
 *  @return An instance of SDAlertView.
 */
+ (SDAlertView *)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle completion:(SDAlertViewCompletionBlock)completionBlock;

/**
 *  Show an alert view.
 *
 *  @param title             Title of the alert view.
 *  @param message           Message to be shown in the alert view.
 *  @param cancelButtonTitle Title to be used for the cancel button (index 0).
 *  @param otherButtonTitle  Title to be used on the non-cancel button (ie: "OK", index 1).
 *  @param completionBlock   Completion block to be executed when a selection is made.
 *
 *  @return An instance of SDAlertView.
 */
+ (SDAlertView *)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle completion:(SDAlertViewCompletionBlock)completionBlock;

/**
 *  Show an alert view.
 *
 *  @param title             Title of the alert view.
 *  @param message           Message to be shown in the alert view.
 *  @param cancelButtonTitle Title to be used for the cancel button (index 0).
 *  @param otherButtonTitles An array of other button titles (indexes > 0).
 *  @param completionBlock   Completion block to be executed when a selection is made.
 *
 *  @return An instance of SDAlertView.
 */
+ (SDAlertView *)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles completion:(SDAlertViewCompletionBlock)completionBlock;

/**
 *  Show an alert view.
 *
 *  @param title             Title of the alert view.
 *  @param message           Message to be shown in the alert view.
 *  @param cancelButtonTitle Title to be used for the cancel button (index 0).
 *  @param otherButtonTitles An array of other button titles (indexes > 0).
 *  @param placeholderText   If not nil, the alert will show as a prompt with the specified placeholder text.
 *  @param completionBlock   Completion block to be executed when a selection is made.
 *
 *  @return An instance of SDAlertView.
 */
+ (SDAlertView *)showAlertWithPromptAndWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle promptPlaceholderText:(NSString *)placeholderText completion:(SDAlertViewCompletionBlock)completionBlock;


/**
 *  Show an alert view with optional prompt and placeholder text.
 *
 *  @param title             Title of the alert view.
 *  @param message           Message to be shown in the alert view.
 *  @param cancelButtonTitle Title to be used for the cancel button (index 0).
 *  @param otherButtonTitles An array of other button titles (indexes > 0).
 *  @param placeholderText   If not nil, the alert will show as a prompt with the specified placeholder text.
 *  @param completionBlock   Completion block to be executed when a selection is made.
 *
 *  @return An instance of SDAlertView.
 */
+ (SDAlertView *)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles promptPlaceholderText:(NSString *)placeholderText completion:(SDAlertViewCompletionBlock)completionBlock;

@end
