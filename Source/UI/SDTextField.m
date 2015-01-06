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

#import "SDTextField.h"

@interface SDTextField ()
@property (nonatomic, strong, readonly) UILabel *floatingLabel;
@property (nonatomic, strong, readonly) UIToolbar *accessoryToolbar;
@property (nonatomic, getter = isTextManuallySet) BOOL textManuallySet;
@end

@implementation SDTextField
{
    UIToolbar *_accessoryToolbar;
    UIBarButtonItem *_prevItem;
    UIBarButtonItem *_nextItem;
    UIBarButtonItem *_doneItem;
    UISegmentedControl *_segmentedControl;
}

#pragma mark - View setup/configuration

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self configureView];
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    [self configureView];

    // force setter to be called on a placeholder defined in a NIB/Storyboard
    if (self.placeholder)
        self.placeholder = self.placeholder;

    return self;
}

- (void)configureView
{
    self.delegate = self;

    self.validationBlock = ^(SDTextField *textField) {
        if (textField.text.length > 0)
            return YES;
        return NO;
    };
    
    _floatingLabel = [UILabel new];
    _floatingLabel.alpha = 0.0f;
    _floatingLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:_floatingLabel];

    // some basic default fonts/colors
    _floatingLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    _floatingLabelInactiveTextColor = [UIColor grayColor];
    _floatingLabelActiveTextColor = [UIColor blueColor];
    if ([self respondsToSelector:@selector(tintColor)])
        _floatingLabelActiveTextColor = self.tintColor;
    
    _hitInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    _minimumHitSize = CGSizeMake(0, 0);
}

- (void)insertText:(NSString *)text
{
    [super insertText:text];
    if (self.validateWhileTyping && self.validationBlock)
    {
        self.validationBlock(self);
    }
}

- (void)backspaceKeypressFired
{
    if (self.validateWhileTyping && self.validationBlock)
        [self internalValidate];
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    if (self.disableFloatingLabels)
        return [super textRectForBounds:bounds];
    
    return UIEdgeInsetsInsetRect([super textRectForBounds:bounds], UIEdgeInsetsMake(_floatingLabel.font.lineHeight+_floatingLabelYPadding.floatValue, 0.0f, 0.0f, 0.0f));
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    if (self.disableFloatingLabels)
        return [super editingRectForBounds:bounds];
    
    return UIEdgeInsetsInsetRect([super editingRectForBounds:bounds], UIEdgeInsetsMake(_floatingLabel.font.lineHeight+_floatingLabelYPadding.floatValue, 0.0f, 0.0f, 0.0f));
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.disableFloatingLabels)
        return;

    if (self.floatingLabelFont)
        _floatingLabel.font = self.floatingLabelFont;

    if (self.isFirstResponder)
    {
        if (!self.text || 0 == [self.text length])
            [self hideFloatingLabel];
        else
        {
            [self setLabelActiveColor];
            [self showFloatingLabel];
        }
    }
    else
    {
        _floatingLabel.textColor = self.floatingLabelInactiveTextColor;
        if (!self.text || 0 == [self.text length])
            [self hideFloatingLabel];
        else
            [self showFloatingLabel];
    }
}

- (BOOL)resignFirstResponderWithoutValidate
{
    return [super resignFirstResponder];
}

- (BOOL)resignFirstResponder
{
    BOOL result = [super resignFirstResponder];
    
    BOOL valid = [self internalValidate];
    if (!valid)
        [self showFloatingLabel];
    
    return result;
}

- (void)setFloatingLabelsVisible:(BOOL)visible
{
    _floatingLabel.hidden = !visible;
}

- (BOOL)becomeFirstResponder
{
    BOOL result = [super becomeFirstResponder];
    
    self.textManuallySet = NO; // user is about to enter text
        
    [self stripInvalidLabelChar];
    /*BOOL valid = [self internalValidate];
    if (!valid)
        [self showFloatingLabel];*/
    
    return result;
}

#pragma mark - Utilities

- (CGRect)clearButtonRectForBounds:(CGRect)bounds
{
    if (self.disableFloatingLabels)
        return [super clearButtonRectForBounds:bounds];
    
    CGRect rect = [super clearButtonRectForBounds:bounds];
    rect = CGRectMake(rect.origin.x, rect.origin.y + (_floatingLabel.font.lineHeight / 2.0) + (_floatingLabelYPadding.floatValue / 2.0f), rect.size.width, rect.size.height);
    return rect;
}


- (void)showFloatingLabel
{
    if (self.disableFloatingLabels)
        return;
    
    [self setLabelOriginForTextAlignment];
    
    if (![self isFirstResponder])
        [self internalValidate];
    
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
        _floatingLabel.alpha = 1.0f;
        _floatingLabel.frame = CGRectMake(_floatingLabel.frame.origin.x, 2.0f, _floatingLabel.frame.size.width + 30, _floatingLabel.frame.size.height);
    } completion:nil];
}

- (void)hideFloatingLabel
{
    if (self.disableFloatingLabels)
        return;
    
    if (![self isFirstResponder])
    {
        BOOL valid = [self internalValidate];
        if (!valid)
            return;
    }

    [self setLabelOriginForTextAlignment];

    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn animations:^{
        _floatingLabel.alpha = 0.0f;
        _floatingLabel.frame = CGRectMake(_floatingLabel.frame.origin.x, _floatingLabel.font.lineHeight+_floatingLabelYPadding.floatValue, _floatingLabel.frame.size.width + 30, _floatingLabel.frame.size.height);
    } completion:nil];
}

- (UIToolbar *)accessoryToolbar
{
    if (!_accessoryToolbar)
    {
        _accessoryToolbar = [[UIToolbar alloc] init];
        _accessoryToolbar.frame = (CGRect){CGPointZero, [_accessoryToolbar sizeThatFits:CGSizeZero]};
        _accessoryToolbar.translucent = YES;
        _accessoryToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        if ([UIDevice systemMajorVersion] >= 7)
            _accessoryToolbar.barStyle = UIBarStyleDefault;
        else
            _accessoryToolbar.barStyle = UIBarStyleBlack;
        
        UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        _doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneEditing:)];
        
        @strongify(self.previousTextField, previousTextField);
        @strongify(self.nextTextField, nextTextField);
        
        if ([UIDevice systemMajorVersion] < 7)
        {
            // handle ios6.
            if (previousTextField || nextTextField)
            {
                _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"Previous", nil), NSLocalizedString(@"Next", nil)]];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                _segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
#pragma clang diagnostic pop
                _segmentedControl.momentary = YES;
                [_segmentedControl addTarget:self action:@selector(selectAdjacentResponder:) forControlEvents:UIControlEventValueChanged];
                UIBarButtonItem *segmentedControlBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_segmentedControl];
                
                [_accessoryToolbar setItems:@[segmentedControlBarButtonItem, spaceItem, _doneItem]];
            }
            else
            {
                [_accessoryToolbar setItems:@[spaceItem, _doneItem]];
            }
            
        }
        else
        {
            // handle ios7.
            _prevItem = [[UIBarButtonItem alloc] initWithTitle:@"  ❮  " style:UIBarButtonItemStylePlain target:self action:@selector(gotoPreviousTextField:)];
            _nextItem = [[UIBarButtonItem alloc] initWithTitle:@"  ❯  " style:UIBarButtonItemStylePlain target:self action:@selector(gotoNextTextField:)];
            NSArray *toolbarItems;
            if (previousTextField || nextTextField)
            {
                toolbarItems = @[_prevItem, _nextItem, spaceItem, _doneItem];
            }
            else
            {
                toolbarItems = @[spaceItem,_doneItem];
            }
            [_accessoryToolbar setItems:toolbarItems];
        }
    }

    [self updateAccessoryButtons];
    
    return _accessoryToolbar;
}

#pragma mark - Accessory navigation

- (void)selectAdjacentResponder:(UISegmentedControl *)sender
{
    @strongify(self.previousTextField, previousTextField);
    @strongify(self.nextTextField, nextTextField);
    
    NSInteger selection = sender.selectedSegmentIndex; // 0 = prev, 1 = next.
    if (selection == 0)
    {
        if (previousTextField)
            [previousTextField becomeFirstResponder];
    }
    else
    {
        if (nextTextField)
            [nextTextField becomeFirstResponder];
    }
}

- (void)gotoPreviousTextField:(id)sender
{
    @strongify(self.previousTextField, previousTextField);
    if (previousTextField)
        [previousTextField becomeFirstResponder];
}

- (void)gotoNextTextField:(id)sender
{
    @strongify(self.nextTextField, nextTextField);
    if (nextTextField)
        [nextTextField becomeFirstResponder];
}

- (void)doneEditing:(id)sender
{
    [self resignFirstResponder];
}

- (void)updateAccessoryButtons
{
    if (self.previousTextField)
    {
        _prevItem.enabled = YES;
        [_segmentedControl setEnabled:YES forSegmentAtIndex:0];
    }
    else
    {
        _prevItem.enabled = NO;
        [_segmentedControl setEnabled:NO forSegmentAtIndex:0];
    }

    if (self.nextTextField)
    {
        _nextItem.enabled = YES;
        [_segmentedControl setEnabled:YES forSegmentAtIndex:1];
    }
    else
    {
        _nextItem.enabled = NO;
        [_segmentedControl setEnabled:NO forSegmentAtIndex:1];
    }
}

#pragma mark - Property Setters

- (void)setPlaceholder:(NSString *)placeholder
{
    [super setPlaceholder:placeholder];

    _floatingLabel.text = placeholder;
    [_floatingLabel sizeToFit];

    CGFloat originX = 0.f;

    if (self.textAlignment == NSTextAlignmentCenter)
        originX = (self.frame.size.width/2) - (_floatingLabel.frame.size.width/2);
    else
    if (self.textAlignment == NSTextAlignmentRight)
        originX = self.frame.size.width - _floatingLabel.frame.size.width;

    _floatingLabel.frame = CGRectMake(originX, _floatingLabel.font.lineHeight+_floatingLabelYPadding.floatValue, _floatingLabel.frame.size.width, _floatingLabel.frame.size.height);
}

- (void)setLabelActiveColor
{
    _floatingLabel.textColor = self.floatingLabelActiveTextColor;
}

- (void)setLabelInactiveColor
{
    _floatingLabel.textColor = self.floatingLabelInactiveTextColor;
}

- (void)setLabelOriginForTextAlignment
{
    CGFloat originX = _floatingLabel.frame.origin.x;

    if (self.textAlignment == NSTextAlignmentCenter)
        originX = (self.frame.size.width/2) - (_floatingLabel.frame.size.width/2);
    else
    if (self.textAlignment == NSTextAlignmentRight)
        originX = self.frame.size.width - _floatingLabel.frame.size.width;

    _floatingLabel.frame = CGRectMake(originX, _floatingLabel.frame.origin.y, _floatingLabel.frame.size.width, _floatingLabel.frame.size.height);
}

- (void)setPreviousTextField:(SDTextField *)previousTextField
{
    _previousTextField = previousTextField;
    @strongify(_previousTextField, localTextField);
    if (localTextField)
        self.inputAccessoryView = [self accessoryToolbar];
}

- (void)setNextTextField:(SDTextField *)nextTextField
{
    _nextTextField = nextTextField;
    @strongify(_nextTextField, localTextField);
    if (localTextField)
        self.inputAccessoryView = [self accessoryToolbar];
}

- (void)setAlwaysShowToolbar:(BOOL)alwaysShowToolbar
{
    if (_alwaysShowToolbar != alwaysShowToolbar)
    {
        _alwaysShowToolbar = alwaysShowToolbar;
        if (_alwaysShowToolbar)
        {
            self.inputAccessoryView = [self accessoryToolbar];
        }
    }
}

#pragma mark - Field validation

- (void)stripInvalidLabelChar
{
    NSString *newString = [_floatingLabel.text stringByReplacingOccurrencesOfString:@"✖︎ " withString:@""];
    _floatingLabel.text = newString;
}

- (BOOL)internalValidate
{
    BOOL result = YES;
    
    SDTextFieldValidationBlock validationBlock = self.validationBlock;
    if (validationBlock && !self.isTextManuallySet)
    {
        result = validationBlock(self);
        if (!result)
        {
            [self stripInvalidLabelChar];
            if (!self.validateWhileTyping)
            {
                // if we're validating while typing, there's most likely a button associated with the field.
                // don't show the error marker if that's the case.
                
                _floatingLabel.text = [NSString stringWithFormat:@"✖︎ %@", _floatingLabel.text];
                _floatingLabel.textColor = [UIColor redColor];
            }
        }
        else
        {
            [self stripInvalidLabelChar];
            if ([self isFirstResponder])
                [self setLabelActiveColor];
            else
                [self setLabelInactiveColor];
        }
    }
    
    return result;
}

- (BOOL)validateFields
{
    SDTextField *currentTextField = self;
    BOOL fieldsAreValid = YES;
    
    while (currentTextField)
    {
        BOOL isValid = [currentTextField internalValidate];    
        if (!isValid)
            fieldsAreValid = NO;
        
        currentTextField = currentTextField.nextTextField;
    }
    
    return fieldsAreValid;
}

- (void)resetTextWithoutValidate
{
    self.textManuallySet = YES;
    self.text = @"";
}

#pragma mark - Hit Testing

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    BOOL pointInside = NO;
    
    if (!self.enabled || self.hidden)
    {
        pointInside = [super pointInside:point withEvent:event];
    }
    else if(UIEdgeInsetsEqualToEdgeInsets(self.hitInsets, UIEdgeInsetsZero) && (CGSizeEqualToSize(self.minimumHitSize, CGSizeZero)))
    {
        pointInside = [super pointInside:point withEvent:event];
    }
    else if (!UIEdgeInsetsEqualToEdgeInsets(self.hitInsets, UIEdgeInsetsZero))
    {
        
        CGRect hitFrame = UIEdgeInsetsInsetRect(self.bounds, self.hitInsets);
        pointInside = CGRectContainsPoint(hitFrame, point);
    }
    else
    {
        CGFloat minW = MAX(self.width, self.minimumHitSize.width);
        CGFloat minH = MAX(self.height, self.minimumHitSize.height);
        
        CGFloat insetW = (self.width - minW) / 2.0;
        CGFloat insetH = (self.height - minH) / 2.0;
        CGRect hitFrame = CGRectInset(self.bounds, insetW, insetH);
        pointInside = CGRectContainsPoint(hitFrame, point);
    }
    
    return pointInside;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)text
{
    NSString *resultString = [textField.text stringByReplacingCharactersInRange:range withString:text];
    if ([text isEqualToString:@""] && [[self.text substringToIndex:self.text.length - 1] isEqualToString:resultString]) {
        // Backspace was tapped
        [self backspaceKeypressFired];
    }
    
    return YES;
}

@end
