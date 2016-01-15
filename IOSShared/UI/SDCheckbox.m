//
//  SDCheckbox.m
//  ios-shared

//
//  Created by Brandon Sneed on 1/15/14.
//  Copyright 2014 SetDirection. All rights reserved.
//

#import "SDCheckbox.h"

#define DEFAULT_CHECKBOX_WIDTH 20.0f

@interface SDCheckbox()
@property (nonatomic, strong) UILabel *textLabel;
@end

@implementation SDCheckbox

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
    return self;
}

- (void)configureView
{
    self.checkboxWidth = DEFAULT_CHECKBOX_WIDTH;
    self.checkboxColor = [UIColor blueColor];
    self.textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.textLabel.backgroundColor = self.backgroundColor;
    [self addSubview:self.textLabel];
}

#pragma mark - Properties

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    self.textLabel.backgroundColor = backgroundColor;
    [self setNeedsDisplay];
}

- (void)setChecked:(BOOL)checked
{
    _checked = checked;
    [self setNeedsDisplay];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)setCheckboxColor:(UIColor *)checkboxColor
{
    _checkboxColor = checkboxColor;
    [self setNeedsDisplay];
}

#pragma mark - Drawing and Layout

- (void)drawRect:(CGRect)rect
{
    CGRect frame = CGRectIntegral(CGRectMake(0, (rect.size.height - self.checkboxWidth) / 2.0, self.checkboxWidth, self.checkboxWidth));
    
    if (self.checked)
    {
        UIBezierPath *bezierPath = [UIBezierPath bezierPath];
        [bezierPath moveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.75000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.21875 * CGRectGetHeight(frame))];
        [bezierPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.40000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.52500 * CGRectGetHeight(frame))];
        [bezierPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.28125 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.37500 * CGRectGetHeight(frame))];
        [bezierPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.17500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.47500 * CGRectGetHeight(frame))];
        [bezierPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.40000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.75000 * CGRectGetHeight(frame))];
        [bezierPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.81250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.28125 * CGRectGetHeight(frame))];
        [bezierPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.75000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.21875 * CGRectGetHeight(frame))];
        [bezierPath closePath];
        
        [self.checkboxColor setFill];
        [bezierPath fill];
    }
    
    UIBezierPath *roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.05000 + 0.5), CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.05000 + 0.5), floor(CGRectGetWidth(frame) * 0.95000 + 0.5) - floor(CGRectGetWidth(frame) * 0.05000 + 0.5), floor(CGRectGetHeight(frame) * 0.95000 + 0.5) - floor(CGRectGetHeight(frame) * 0.05000 + 0.5)) cornerRadius:4];
    roundedRectanglePath.lineWidth = 2 * (self.checkboxWidth / DEFAULT_CHECKBOX_WIDTH);
    [self.checkboxColor setStroke];
    [roundedRectanglePath stroke];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat textLabelOriginX = self.checkboxWidth + 5.0;
    CGSize textLabelMaxSize = CGSizeMake(CGRectGetWidth(self.bounds) - textLabelOriginX, CGRectGetHeight(self.bounds));
    
    CGSize textLabelSize;
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending) {
        textLabelSize = [self.textLabel.text sizeWithAttributes:@{NSFontAttributeName : self.textLabel.font}];
    } else {
        textLabelSize = [self.textLabel.text sizeWithFont:self.textLabel.font constrainedToSize:textLabelMaxSize lineBreakMode:self.textLabel.lineBreakMode];
    }
    
    self.textLabel.frame = CGRectIntegral(CGRectMake(textLabelOriginX, (CGRectGetHeight(self.bounds) - textLabelSize.height) / 2.0, textLabelSize.width, textLabelSize.height));
}

#pragma clang diagnostic pop

#pragma mark - Touch handling

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location = [touch locationInView:self];
    
    if (CGRectContainsPoint(self.bounds, location))
        self.checked = !self.checked;
}

@end
