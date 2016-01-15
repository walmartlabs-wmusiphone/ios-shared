//
//  SDCreditCardField.m
//  SetDirection
//
//  Created by Alex MacCaw on 01/22/2013.
//  Copyright (c) 2013 Stripe. All rights reserved.
//
//  Adapted by Steven Woolgar on 02/24/2014
//

#import "SDCreditCardField.h"
#import "SDCCTextField.h"
#import <QuartzCore/QuartzCore.h>
#import "SDMacros.h"

@interface NSString(SDCreditCardField_Security)
- (NSString*)stringByHidingAllButLastFourDigits;
@end

@interface SDCreditCardField () <UITextFieldDelegate>

@property (nonatomic, assign, getter = isInitialState) BOOL initialState;
@property (nonatomic, assign, getter = isValidState) BOOL validState;
@property (nonatomic, strong) UITextField* cardNumberSecurity;

@end

@implementation SDCreditCardField

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self != nil)
    {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder*)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self != nil)
    {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _borderStyle = UITextBorderStyleRoundedRect;

    self.layer.masksToBounds = YES;
    self.backgroundColor = [UIColor whiteColor];

    _initialState = YES;
    _validState   = NO;

    _innerView = [[UIView alloc] initWithFrame:(CGRect){ CGPointZero, { 0.0f, self.frame.size.height } }];
    _innerView.clipsToBounds = YES;

    _defaultTextAttributes = @{ NSFontAttributeName : [UIFont boldSystemFontOfSize:16.0f],
                                NSForegroundColorAttributeName : [UIColor blackColor] };

    [self setupCardNumberField];

    [_innerView addSubview:_cardNumberField];
    [_innerView addSubview:_cardNumberSecurity];

    [self addSubview:_innerView];

    [self stateCardNumber];
}

// TODO: This needs to be broken up so that each time the credit card number is set, this is applied.

- (void)setSecureDisplay:(BOOL)flag
{
    _secureDisplay = flag;

    if(_secureDisplay)
    {
        _cardNumberField.enabled = NO;
        _cardNumberField.hidden = YES;

        _cardNumberSecurity.hidden = NO;
        _cardNumberSecurity.text = [_cardNumberField.text stringByHidingAllButLastFourDigits];
    }
    else
    {
        _cardNumberField.enabled = YES;
        _cardNumberField.hidden = NO;

        _cardNumberSecurity.hidden = YES;
    }
}

- (void)setBorderStyle:(UITextBorderStyle)borderStyle
{
    if(_borderStyle != borderStyle)
    {
        _borderStyle = borderStyle;
        
        if(borderStyle == UITextBorderStyleRoundedRect)
        {
            self.layer.borderColor = [UIColor colorWithRed:191.0f/255.0f green:192.0f/255.0f blue:194.0f/255.0f alpha:1.0f].CGColor;
            self.layer.cornerRadius = 6.0f;
            self.layer.borderWidth = 0.5f;
        }
        else
        {
            self.layer.borderColor = nil;
            self.layer.cornerRadius = 0.0f;
            self.layer.borderWidth = 0.0f;
        }
    }
}

- (void)setDefaultTextAttributes:(NSDictionary*)defaultTextAttributes
{
    if(_defaultTextAttributes != defaultTextAttributes)
    {
        _defaultTextAttributes = [defaultTextAttributes copy];
        
        // We shouldn't need to set the font and textColor attributes, but a bug exists in 7.0 (fixed in 7.1/)

        self.cardNumberField.defaultTextAttributes = _defaultTextAttributes;
        self.cardNumberField.font = _defaultTextAttributes[NSFontAttributeName];
        self.cardNumberField.textColor = _defaultTextAttributes[NSForegroundColorAttributeName];
        self.cardNumberField.textAlignment = NSTextAlignmentLeft;

        [self setNeedsLayout];
    }
}

- (UIFont*)font
{
    return self.defaultTextAttributes[NSFontAttributeName];
}

- (void)setFont:(UIFont*)font
{
    NSMutableDictionary* defaultTextAttributes = [self.defaultTextAttributes mutableCopy];
    defaultTextAttributes[NSFontAttributeName] = font;

    self.defaultTextAttributes = [defaultTextAttributes copy];
}

- (UIColor*)textColor
{
    return self.defaultTextAttributes[NSForegroundColorAttributeName];
}

- (void)setTextColor:(UIColor*)textColor
{
    NSMutableDictionary* defaultTextAttributes = [self.defaultTextAttributes mutableCopy];
    defaultTextAttributes[NSForegroundColorAttributeName] = textColor;

    self.defaultTextAttributes = [defaultTextAttributes copy];
}

- (SDCCTextField*)textFieldWithPlaceholder:(NSString*)placeholder
{
    SDCCTextField* textField = [[SDCCTextField alloc] init];

    textField.delegate = self;
    textField.placeholder = placeholder;
    textField.keyboardType = UIKeyboardTypeNumberPad;
    textField.defaultTextAttributes = self.defaultTextAttributes;
    textField.layer.masksToBounds = NO;

    return textField;
}

- (void)setupPlaceholderView
{
    _placeholderView = [[UIImageView alloc] initWithImage:[self imageForCardType:SDCardTypeUnknown]];
    _placeholderView.backgroundColor = [UIColor whiteColor];
}

- (void)setupCardNumberField
{
    _cardNumberField = [self textFieldWithPlaceholder:@"1234 5678 9012 3456"];
    _cardNumberSecurity = [[UITextField alloc] init];
    _cardNumberSecurity.delegate = self;
    _cardNumberSecurity.defaultTextAttributes = self.defaultTextAttributes;
    _cardNumberSecurity.layer.masksToBounds = NO;
    _cardNumberSecurity.enabled = NO;
    _cardNumberSecurity.hidden = YES;
}

// Accessors

- (SDCardNumber*)cardNumber
{
    return [SDCardNumber cardNumberWithString:self.cardNumberField.text];
}

- (void)layoutSubviews
{
    if(self.placeholderView == nil)
    {
        [self setupPlaceholderView];
        [self addSubview:self.placeholderView];
    }

    _placeholderView.frame = CGRectMake(0.0f, ceil((self.frame.size.height - 32.0f) * 0.5f), 51.0f, 32.0f);

    NSDictionary* attributes = self.defaultTextAttributes;

    CGSize lastGroupSize;
    CGSize cardNumberSize;

    if(self.cardNumber.cardType == SDCardTypeAmex)
    {
        cardNumberSize = [@"1234 567890 12345" sizeWithAttributes:attributes];
        lastGroupSize = [@" 00000" sizeWithAttributes:attributes];
    }
    else
    {
        if(self.cardNumber.cardType == SDCardTypeDinersClub)
        {
            cardNumberSize = [@"1234 567890 1234" sizeWithAttributes:attributes];
        }
        else
        {
            cardNumberSize = [_cardNumberField.placeholder sizeWithAttributes:attributes];
        }

        lastGroupSize = [@" 0000" sizeWithAttributes:attributes];
    }

    lastGroupSize = (CGSize){ ceil(lastGroupSize.width), ceil(lastGroupSize.height) };
    cardNumberSize = (CGSize){ ceil(cardNumberSize.width + lastGroupSize.width), ceil(cardNumberSize.height) };

    CGFloat textFieldY = floor((self.frame.size.height - lastGroupSize.height) * 0.5f);
    CGFloat innerWidth = ceil(self.frame.size.width - _placeholderView.frame.size.width);

    _cardNumberField.frame = (CGRect){ { ceil((innerWidth * 0.5f) - (cardNumberSize.width * 0.5f)), textFieldY }, cardNumberSize };
    _cardNumberSecurity.frame = (CGRect){ { ceil((innerWidth * 0.5f) - (cardNumberSize.width * 0.5f)), textFieldY }, cardNumberSize };

    CGFloat x = _innerView.frame.origin.x;

    if(_initialState)
    {
        x = _placeholderView.frame.size.width;
    }

    _innerView.frame = CGRectMake(x, 0.0f, CGRectGetMaxX(self.cardNumberField.frame), self.frame.size.height);
}

// State

- (void)stateCardNumber
{
    @strongify(self.delegate, delegate);
    if([delegate respondsToSelector:@selector(creditCardFieldDidChangeState:)])
    {
        [delegate creditCardFieldDidChangeState:self];
    }

    if(!_initialState)
    {
        // Animate left
        _initialState = YES;

        [UIView animateWithDuration:0.400
                              delay:0
                            options:(UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction)
                         animations:^
        {
            _innerView.frame = (CGRect){ { _placeholderView.frame.size.width, 0.0f }, _innerView.frame.size };
            _cardNumberField.alpha = 1.0f;
        }
        completion:^(BOOL completed) {}];
    }
    
    if(self.isFirstResponder)
    {
        [self.cardNumberField becomeFirstResponder];
    }
}

- (UIImage*)imageForCardType:(SDCardType)type
{
    UIImage* cardTypeImage = [self.delegate creditCardFieldCardImageForType:type];
    NSAssert(cardTypeImage, @"Protocol not implemented correctly, could not supply card type %tu image", type);
    NSAssert(cardTypeImage.size.width == 51.0f && cardTypeImage.size.height == 32.0f, @"Protocol not implemented correctly, card size for type %tu incorrect", type);

    return cardTypeImage;
}

- (BOOL)isValid
{
    return [self.cardNumber isValid];
}

- (SDCard*)card
{
    SDCard* card = [[SDCard alloc] init];
    card.number   = [self.cardNumber string];

    return card;
}

- (void)setCard:(SDCard*)card
{
    [self reset];
    SDCardNumber* number = [[SDCardNumber alloc] initWithString:card.number];
    self.cardNumberField.text = [number formattedString];
    [self setPlaceholderToCardType];
    self.initialState = NO;
    [self checkValid];
}

- (void)reset
{
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.placeholderView = nil;
    [self commonInit];
    [self layoutSubviews];
}

- (void)setPlaceholderViewImage:(UIImage*)image
{
    NSAssert(image, @"Seeting a nil image for the credit card image.");
    
    {
        if (image != _placeholderView.image)
        {
            __block UIView* previousPlaceholderView = _placeholderView;
            [UIView animateWithDuration:0.25
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^
             {
                 _placeholderView.layer.opacity = 0.0f;
                 _placeholderView.layer.transform = CATransform3DMakeScale(1.2f, 1.2f, 1.2f);
             }
                             completion:^(BOOL finished)
             {
                 [previousPlaceholderView removeFromSuperview];
             }];
            
            _placeholderView = nil;
            
            [self setupPlaceholderView];
            _placeholderView.image = image;
            _placeholderView.layer.opacity = 0.0f;
            _placeholderView.layer.transform = CATransform3DMakeScale(0.8f, 0.8f, 0.8f);
            [self insertSubview:_placeholderView belowSubview:previousPlaceholderView];
            [UIView animateWithDuration:0.25
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^
             {
                 _placeholderView.layer.opacity = 1.0f;
                 _placeholderView.layer.transform = CATransform3DIdentity;
             } completion:^(BOOL finished) {}];
        }
    }
}

- (void)setPlaceholderToCardType
{
    SDCardNumber* cardNumber = [SDCardNumber cardNumberWithString:_cardNumberField.text];
    SDCardType cardType      = [cardNumber cardType];
    UIImage* cardImage = [self imageForCardType:cardType];
    [self setPlaceholderViewImage:cardImage];
}

// Delegates

- (void)textFieldDidBeginEditing:(UITextField*)textField
{
    [self setPlaceholderToCardType];

    if([textField isEqual:self.cardNumberField] && !self.initialState)
    {
        [self stateCardNumber];
    }
}

- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)replacementString
{
    if([textField isEqual:_cardNumberField])
    {
        return [self cardNumberFieldShouldChangeCharactersInRange:range replacementString:replacementString];
    }

    return YES;
}

- (void)ccTextFieldDidBackSpaceWhileTextIsEmpty:(SDCCTextField*)textField
{
    [self stateCardNumber];
}

- (BOOL)cardNumberFieldShouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)replacementString
{
    NSString* resultString = [self.cardNumberField.text stringByReplacingCharactersInRange:range withString:replacementString];
    resultString = [SDCCTextField textByRemovingUselessSpacesFromString:resultString];
    SDCardNumber* cardNumber = [SDCardNumber cardNumberWithString:resultString];

    BOOL valid = NO;

    if([cardNumber isPartiallyValid])
    {
        if(replacementString.length > 0)
        {
            self.cardNumberField.text = [cardNumber formattedStringWithTrail];
        }
        else
        {
            self.cardNumberField.text = [cardNumber formattedString];
        }

        [self setPlaceholderToCardType];

        if([cardNumber isValid])
        {
            [self textFieldIsValid:self.cardNumberField];
            self.initialState = NO;
        }
        else if([cardNumber isValidLength] && ![cardNumber isValidLuhn])
        {
            [self textFieldIsInvalid:self.cardNumberField withErrors:YES];
        }
        else if(![cardNumber isValidLength])
        {
            [self textFieldIsInvalid:self.cardNumberField withErrors:NO];
        }
    }

    return valid;
}

// Validations

- (void)checkValid
{
    @strongify(self.delegate, delegate);
    if([self isValid])
    {
        self.validState = YES;

        if([delegate respondsToSelector:@selector(creditCardField:withCard:isValid:)])
        {
            [delegate creditCardField:self withCard:self.card isValid:YES];
        }
    }
    else if(![self isValid] && self.validState)
    {
        self.validState = NO;
        
        if([delegate respondsToSelector:@selector(creditCardField:withCard:isValid:)])
        {
            [delegate creditCardField:self withCard:self.card isValid:NO];
        }
    }
}

- (void)textFieldIsValid:(SDCCTextField*)textField
{
    textField.textColor = self.defaultTextAttributes[NSForegroundColorAttributeName];
    [self checkValid];
}

- (void)textFieldIsInvalid:(SDCCTextField*)textField withErrors:(BOOL)errors
{
    if(errors)
    {
        textField.textColor = [UIColor colorWithRed:253.0/255.0 green:0.0 blue:17.0/255.0 alpha:1.0];
    }
    else
    {
        textField.textColor = _defaultTextAttributes[NSForegroundColorAttributeName];
    }

    [self checkValid];
}

#pragma mark - UIResponder

- (UIResponder*)firstResponderField;
{
    return self.cardNumberField.isFirstResponder ? self.cardNumberField : nil;
}

- (SDCCTextField*)firstInvalidField;
{
    SDCCTextField* invalidField = nil;

    if(![[SDCardNumber cardNumberWithString:self.cardNumberField.text] isValid])
    {
        invalidField = self.cardNumberField;
    }

    return invalidField;
}

- (SDCCTextField*)nextFirstResponder;
{
    if(self.firstInvalidField)
    {
        return self.firstInvalidField;
    }

    return self.cardNumberField;
}

- (BOOL)isFirstResponder;
{
    return self.firstResponderField.isFirstResponder;
}

- (BOOL)canBecomeFirstResponder;
{
    return self.nextFirstResponder.canBecomeFirstResponder;
}

- (BOOL)becomeFirstResponder;
{
    return [self.nextFirstResponder becomeFirstResponder];
}

- (BOOL)canResignFirstResponder;
{
    return self.firstResponderField.canResignFirstResponder;
}

- (BOOL)resignFirstResponder;
{
    return [self.firstResponderField resignFirstResponder];
}

@end

#pragma mark - NSString(SDCreditCardField_Security)

@implementation NSString(SDCreditCardField_Security)

- (NSString*)stringByHidingAllButLastFourDigits
{
    NSString* result = nil;
    NSString* strippedString = [self stringByReplacingOccurrencesOfString:@" " withString:@""];

    if (strippedString.length > 4)
    {
        NSCharacterSet* replaceables = [NSCharacterSet decimalDigitCharacterSet];
        NSMutableString* mutableString = [self mutableCopy];
        for (NSUInteger characterIndex = 0; characterIndex < (self.length - 4); ++characterIndex)
        {
            unichar currentChar = [self characterAtIndex:characterIndex];
            if ([replaceables characterIsMember:currentChar])
                [mutableString replaceCharactersInRange:(NSRange){ characterIndex, 1 } withString:@"*"];
        }

        result = [mutableString copy];
    }
    else
    {
        result = [self copy];
    }

    return result;
}

@end
