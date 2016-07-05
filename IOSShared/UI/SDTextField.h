//
//  SDTextField.h
//
//  Created by Brandon Sneed on 11/7/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//
//  Copyright (c) 2013 Jared Verdi
//  Original Concept by Matt D. Smith
//  http://dribbble.com/shots/1254439--GIF-Mobile-Form-Interaction?list=users
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//  the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <UIKit/UIKit.h>

@class SDTextField;

typedef BOOL (^SDTextFieldValidationBlock)(SDTextField *textField);


@interface SDTextField : UITextField <UITextFieldDelegate>

/**
 *  Always show the toolbar
 */
@property (nonatomic, assign) BOOL alwaysShowToolbar;
@property (nonatomic, retain) UIColor *toolbarTintColor;

/**
 *  Disable the floating label aspect of the text field.
 */
@property (nonatomic, assign) BOOL disableFloatingLabels;
/**
 *  Adjust the Y padding for the floating label.  The default is 0.0f.
 */
@property (nonatomic, strong) NSNumber *floatingLabelYPadding UI_APPEARANCE_SELECTOR;

/**
 *  Specify the font for the floating label.  The default is boldSystemFont at 12pt.
 */
@property (nonatomic, strong) UIFont *floatingLabelFont UI_APPEARANCE_SELECTOR;

/**
 *  The color to be used for the inactive-state of the floating label.  The default is grayColor.
 */
@property (nonatomic, strong) UIColor *floatingLabelInactiveTextColor UI_APPEARANCE_SELECTOR;

/**
 *  The color to be used for the active-state of the floating label.  The default is the tintColor.
 */
@property (nonatomic, strong) UIColor *floatingLabelActiveTextColor UI_APPEARANCE_SELECTOR; // tint color is used by default if not provided

/**
 *  A pointer to the previous text field.  If these properties are set, a toolbar with
 *  next/previous buttons appears above the keyboard.
 */
@property (nonatomic, weak) IBOutlet SDTextField *previousTextField;

/**
 *  A pointer to the next text field.  If these properties are set, a toolbar with
 *  next/previous buttons appears above the keyboard.
 */
@property (nonatomic, weak) IBOutlet SDTextField *nextTextField;

/**
 * A block to use for field validation.
 */
@property (nonatomic, copy) SDTextFieldValidationBlock validationBlock;

/**
 * Perform validation for this field as typing occurs.
 */
@property (nonatomic, assign) BOOL validateWhileTyping;

/**
 * Performs validation using the validation block on this field and any associated fields (see nextTextField).  If
 * any return FALSE, validateFields will return FALSE as well.  Otherwise, this returns TRUE.
 */
- (BOOL)validateFields;
- (BOOL)validate; // validates just this field, and optionally shows the error label

/**
 * Useful for subclasses that wish to do view configuration after instantiating the view.
 */
- (void)configureView;

- (BOOL)resignFirstResponderWithoutValidate;
- (void)resetTextWithoutValidate; // clear the field, but don't allow validation

- (void)setFloatingLabelsVisible:(BOOL)visible;

- (void)backspaceKeypressFired;

/**
 *  Setting the hitInsets to anything other than UIEdgeInsetsZero overrides minimumHitSize
 *  Specify negative values to increase the hit area
 */
@property (nonatomic, assign) UIEdgeInsets hitInsets;

/**
 *  If hitInsets is not set, then calculate a hit area that is at least this large
 */
@property (nonatomic, assign) CGSize minimumHitSize;


@end

extern SDTextFieldValidationBlock SDTextFieldOptionalFieldValidationBlock;
