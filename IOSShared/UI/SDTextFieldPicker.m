//
//  SDTextFieldPicker.m
//  walmart
//
//  Created by Brandon Sneed on 1/9/14.
//  Copyright (c) 2014 Walmart. All rights reserved.
//

#import "SDTextFieldPicker.h"
#import "SDPickerView.h"
#import "UIDevice+machine.h"
#import "SDMacros.h"

@interface SDPickerView()
@property (nonatomic, readonly) UIToolbar *pickerBar;
@property (nonatomic, readonly) UIPickerView *itemPicker;
@end

@interface SDTextFieldPickerView : SDPickerView
@property (nonatomic, weak) SDTextFieldPicker *owner;
@end

@implementation SDTextFieldPickerView

- (void)drawRect:(CGRect)rect
{
    //// Frames
    CGRect frame = CGRectMake(0, 0, 30, 30);
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.77647 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.38333 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.25686 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.38333 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.51667 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.68333 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.77647 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.38333 * CGRectGetHeight(frame))];
    [bezierPath closePath];
    [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.79951 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.20049 * CGRectGetHeight(frame))];
    [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.79951 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.76618 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.95572 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.35670 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.95572 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.60997 * CGRectGetHeight(frame))];
    [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.23382 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.76618 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.64330 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.92239 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.39003 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.92239 * CGRectGetHeight(frame))];
    [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.23382 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.20049 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.07761 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.60997 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.07761 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.35670 * CGRectGetHeight(frame))];
    [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.79951 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.20049 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.39003 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.04428 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.64330 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.04428 * CGRectGetHeight(frame))];
    [bezierPath closePath];
    
    @strongify(self.owner, strongOwner);
    if (self.isSelected)
    {
        [strongOwner.pickerButtonColor setFill];
        [bezierPath fill];
    }
    else
    {
        [strongOwner.pickerButtonColor setStroke];
        bezierPath.lineWidth = 1;
        [bezierPath stroke];
    }
}

// override the base class trigger.
- (IBAction)startAction:(id)sender
{
    @strongify(self.owner, strongOwner);
    strongOwner.inputView = self.itemPicker;
    strongOwner.inputAccessoryView = self.pickerBar;
    [strongOwner reloadInputViews];
    [strongOwner becomeFirstResponder];
}

@end

@interface SDTextField()
@property (nonatomic, strong, readonly) UIToolbar *accessoryToolbar;
@end

@implementation SDTextFieldPicker
{
    SDTextFieldPickerView *_pickerButton;
}

- (void)configureView
{
    [super configureView];
    
    _pickerButton = [[SDTextFieldPickerView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    _pickerButton.owner = self;

    self.rightView = _pickerButton;
    self.rightViewMode = UITextFieldViewModeAlways;
    if ([UIDevice systemMajorVersion] < 7)
        self.pickerButtonColor = [UIColor blueColor];
    else
        self.pickerButtonColor = self.tintColor;
}

- (void)setPickerItems:(NSArray<NSString> *)pickerItems
{
    [_pickerButton configureAsItemPicker:pickerItems completion:^(BOOL canceled, NSInteger selectedItemIndex, NSString *selectedItem) {
        NSString *otherString = [selectedItem lowercaseString];
        
        // if they selected "Other" or hit cancel, then go back to the text field.
        if (!otherString || [otherString isEqualToString:@"other"])
        {
            //[self becomeFirstResponder];
            self.inputView = nil;
            self.inputAccessoryView = self.accessoryToolbar;
            [self reloadInputViews];
        }
        else
        {
            // if they selected something, lets encourage them to keep the text as-is
            // and move to the next field if we can.
            self.text = selectedItem;
            
            @strongify(self.nextTextField, strongNextField);
            if (strongNextField)
                [strongNextField becomeFirstResponder];
            
            self.inputView = nil;
            self.inputAccessoryView = self.accessoryToolbar;
        }
    }];
}

@end
