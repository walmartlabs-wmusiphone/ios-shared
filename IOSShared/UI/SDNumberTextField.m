//
//  SDNumberTextField.m
//
//  Created by Brandon Sneed on 11/2/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import "SDNumberTextField.h"
#import "SDMacros.h"
#import "NSString+SDExtensions.h"

@interface SDTextField()
- (void)configureView;
- (void)internalValidate;
@end

@interface SDNumberTextField ()
@property (nonatomic, copy) NSString *currentFormattedText;
@end

@implementation SDNumberTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:(CGRect)frame];
    if (self) {
        self.keyboardType = UIKeyboardTypeNumberPad;
        self.format = @"#";
        [self addTarget:self action:@selector(formatInput:) forControlEvents:UIControlEventEditingChanged];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.keyboardType = UIKeyboardTypeNumberPad;
        self.format = @"#";
        [self addTarget:self action:@selector(formatInput:) forControlEvents:UIControlEventEditingChanged];
    }
    return self;
}

- (void)configureView
{
    [super configureView];
    
    self.validationBlock = ^(SDTextField *textField) {
        SDNumberTextField *numberField = (SDNumberTextField *)textField;
        if (numberField.text.length == numberField.format.length)
            return YES;
        return NO;
    };
}

- (NSString *)string:(NSString *)string withNumberFormat:(NSString *)format
{
    if (!string)
        return @"";

    return [string stringWithNumberFormat:format];
}

- (void)formatInput:(UITextField *)textField
{
    if (![textField.text isEqualToString:self.currentFormattedText])
    {
        @weakify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            textField.text = [self.unformattedText stringWithNumberFormat:self.format];
            self.currentFormattedText = textField.text;
            
            if (self.validateWhileTyping && self.validationBlock)
                [self internalValidate];
        });
    }
}

- (void)backspaceKeypressFired
{
    [super backspaceKeypressFired];
    
    if (self.text.length > 0) {
        NSInteger decimalPosition = NSIntegerMax;
        for (NSInteger i = (NSInteger)self.text.length - 1; i > 0; i--)
        {
            NSString *c = [self.text substringWithRange:NSMakeRange((NSUInteger)i - 1, 1)];
            
            NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
            NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:c];
            BOOL valid = [alphaNums isSupersetOfSet:inStringSet];
            
            if (valid)
            {
                decimalPosition = i;
                break;
            }
        }
        
        if (decimalPosition == NSIntegerMax)
            self.text = @"";
        else
            self.text = [self.text substringWithRange:NSMakeRange(0, (NSUInteger)decimalPosition)];
        
        self.currentFormattedText = self.text;
        [self sendActionsForControlEvents:UIControlEventEditingChanged];
        
        if (self.validateWhileTyping && self.validationBlock)
            [self internalValidate];
    }
}

- (NSString *)unformattedText
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\D" options:NSRegularExpressionCaseInsensitive error:NULL];
    return [regex stringByReplacingMatchesInString:self.text options:0 range:NSMakeRange(0, self.text.length) withTemplate:@""];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)text
{
    BOOL shouldChange = YES;
    
    NSString *resultString = [textField.text stringByReplacingCharactersInRange:range withString:text];
    if ([text isEqualToString:@""] && [[self.text substringToIndex:self.text.length - 1] isEqualToString:resultString]) {
        // Backspace was tapped
        [self backspaceKeypressFired];
        shouldChange = NO;
    }
    
    return shouldChange;
}

@end
