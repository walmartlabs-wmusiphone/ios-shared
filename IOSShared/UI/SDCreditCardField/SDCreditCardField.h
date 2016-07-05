//
//  SDCreditCardField.h
//  SetDirection
//
//  Created by Alex MacCaw on 01/22/2013.
//  Copyright (c) 2013 Stripe. All rights reserved.
//
//  Adapted by Steven Woolgar on 02/24/2014
//

#import <UIKit/UIKit.h>

#import "SDCard.h"
#import "SDCardNumber.h"
#import "SDCardType.h"

@class SDCreditCardField;
@class SDCCTextField;

@protocol SDCreditCardFieldDelegate <NSObject>
@required
- (UIImage*)creditCardFieldCardImageForType:(SDCardType)type;
@optional
- (void)creditCardField:(SDCreditCardField*)creditCardField withCard:(SDCard*)card isValid:(BOOL)valid;
- (void)creditCardFieldDidChangeState:(SDCreditCardField*)creditCardField;
@end

@interface SDCreditCardField : UIView

- (BOOL)isValid;

@property(nonatomic, assign) BOOL secureDisplay;
@property(nonatomic, assign) UITextBorderStyle borderStyle;
@property(nonatomic, strong) UIFont* font;
@property(nonatomic, strong) UIColor* textColor;
@property(nonatomic, copy) NSDictionary* defaultTextAttributes;

@property (nonatomic, readonly) UIView* opaqueOverGradientView;
@property (nonatomic, readonly) SDCardNumber* cardNumber;

@property (nonatomic, strong) UIView* innerView;
@property (nonatomic, strong) UIView* clipView;
@property (nonatomic, strong) SDCCTextField* cardNumberField;
@property (nonatomic, strong) UIImageView* placeholderView;
@property (nonatomic, strong) SDCard* card;
@property (nonatomic, weak) id<SDCreditCardFieldDelegate> delegate;

@end
