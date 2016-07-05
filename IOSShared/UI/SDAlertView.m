//
//  SDAlertView.m
//  RxClient
//
//  Created by Brandon Sneed on 10/17/13.
//  Copyright 2013-2014 SetDirection. All rights reserved.
//

#import "SDAlertView.h"
#import "UIDevice+machine.h"

@interface SDAlertView () <UIAlertViewDelegate>
@property (nonatomic, copy) SDAlertViewCompletionBlock completionBlock;
@end

@implementation SDAlertView

+ (instancetype)showAlertWithTitle:(NSString *)title
{
    return [[self class] showAlertWithTitle:title message:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil completion:nil];
}

+ (instancetype)showAlertWithTitle:(NSString *)title message:(NSString *)message
{
    return [[self class] showAlertWithTitle:title message:message cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil completion:nil];
}

+ (instancetype)showAlertWithTitle:(NSString *)title message:(NSString *)message completion:(SDAlertViewCompletionBlock)completionBlock
{
    return [[self class] showAlertWithTitle:title message:message cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil completion:completionBlock];
}

+ (instancetype)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle completion:(SDAlertViewCompletionBlock)completionBlock
{
    return [[self class] showAlertWithTitle:title message:message cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil completion:completionBlock];
}

+ (instancetype)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle completion:(SDAlertViewCompletionBlock)completionBlock
{
    return [[self class] showAlertWithTitle:title message:message cancelButtonTitle:cancelButtonTitle otherButtonTitles:@[otherButtonTitle] completion:completionBlock];
}

+ (instancetype)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles completion:(SDAlertViewCompletionBlock)completionBlock
{
    return [[self class] showAlertWithTitle:title message:message cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles promptPlaceholderText:nil completion:completionBlock];
}

+ (instancetype)showAlertWithPromptAndWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle promptPlaceholderText:(NSString *)placeholderText completion:(SDAlertViewCompletionBlock)completionBlock
{
    return [[self class] showAlertWithTitle:title message:message cancelButtonTitle:cancelButtonTitle otherButtonTitles:@[otherButtonTitle] promptPlaceholderText:placeholderText completion:completionBlock];
}

+ (instancetype)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles promptPlaceholderText:(NSString *)placeholderText completion:(SDAlertViewCompletionBlock)completionBlock
{
    // AIOS-570 - iOS 8 hack.  For iOS 8, Apple appears to be pushing us towards always using a title and message.
    // Their punishment if you only provide a message is a really ugly alert.  It looks better if you only
    // provide a title, so we will hijack things here and if title is nil but a message is given, move the message
    // to the title
    if ([UIDevice systemMajorVersion] >= 8) {
        if (!title && message && message.length > 0) {
            title = message;
            message = nil;
        }
    }

    SDAlertView *alertView = [[[self class] alloc] initWithTitle:title ? title : @"" message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
    alertView.delegate = alertView;

    for (NSString *buttonTitle in otherButtonTitles)
        [alertView addButtonWithTitle:buttonTitle];

    alertView.completionBlock = completionBlock;
    
    if (placeholderText) {
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [[alertView textFieldAtIndex: 0] setPlaceholder: placeholderText];
    }

    [alertView show];

    return alertView;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.completionBlock)
        self.completionBlock(alertView, buttonIndex);
}

@end
