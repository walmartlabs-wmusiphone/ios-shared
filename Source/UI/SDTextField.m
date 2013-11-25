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

    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
        _floatingLabel.alpha = 1.0f;
        _floatingLabel.frame = CGRectMake(_floatingLabel.frame.origin.x, 2.0f, _floatingLabel.frame.size.width, _floatingLabel.frame.size.height);
    } completion:nil];
}

- (void)hideFloatingLabel
{
    if (self.disableFloatingLabels)
        return;
    
    [self setLabelOriginForTextAlignment];

    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn animations:^{
        _floatingLabel.alpha = 0.0f;
        _floatingLabel.frame = CGRectMake(_floatingLabel.frame.origin.x, _floatingLabel.font.lineHeight+_floatingLabelYPadding.floatValue, _floatingLabel.frame.size.width, _floatingLabel.frame.size.height);
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

        if ([UIDevice systemMajorVersion] < 7)
        {
            // handle ios6.
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
            // handle ios7.
            _prevItem = [[UIBarButtonItem alloc] initWithTitle:@"❮" style:UIBarButtonItemStylePlain target:self action:@selector(gotoPreviousTextField:)];
            _nextItem = [[UIBarButtonItem alloc] initWithTitle:@"❯" style:UIBarButtonItemStylePlain target:self action:@selector(gotoNextTextField:)];
            [_accessoryToolbar setItems:@[_prevItem, _nextItem, spaceItem, _doneItem]];
        }
    }

    [self updateAccessoryButtons];
    
    return _accessoryToolbar;
}

#pragma mark - Accessory navigation

- (void)selectAdjacentResponder:(UISegmentedControl *)sender
{
    NSInteger selection = sender.selectedSegmentIndex; // 0 = prev, 1 = next.
    if (selection == 0)
    {
        if (self.previousTextField)
            [self.previousTextField becomeFirstResponder];
    }
    else
    {
        if (self.nextTextField)
            [self.nextTextField becomeFirstResponder];
    }
}

- (void)gotoPreviousTextField:(id)sender
{
    if (self.previousTextField)
        [self.previousTextField becomeFirstResponder];
}

- (void)gotoNextTextField:(id)sender
{
    if (self.nextTextField)
        [self.nextTextField becomeFirstResponder];
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

- (void)setPreviousTextField:(UITextField *)previousTextField
{
    _previousTextField = previousTextField;
    if (_previousTextField)
        self.inputAccessoryView = [self accessoryToolbar];
}

- (void)setNextTextField:(UITextField *)nextTextField
{
    _nextTextField = nextTextField;
    if (_nextTextField)
        self.inputAccessoryView = [self accessoryToolbar];
}

@end
