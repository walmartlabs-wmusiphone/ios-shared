//
//  SDQuantityView.m
//
//  Created by ricky cancro on 10/31/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "SDQuantityView.h"

static const CGFloat kCircularButtonWidth = 29.0f;
static const CGFloat kCircularButtonHeight = 29.0f;

@interface SDShapeView : UIView;
@end

@implementation SDShapeView
+ (Class)layerClass
{
    return [CAShapeLayer class];
}

@end

@interface SDCircularMinusButton()
@end

@implementation SDCircularMinusButton

+ (instancetype)circularMinusButtonWithStrokeColor:(UIColor *)strokeColor;
{
    SDCircularMinusButton *circularButton = [[SDCircularMinusButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, kCircularButtonWidth, kCircularButtonHeight)];
    circularButton.strokeColor = strokeColor;
    [circularButton createButtonStates];
    return circularButton;
}

- (void)setStrokeColor:(UIColor *)strokeColor
{
    if (_strokeColor != strokeColor)
    {
        _strokeColor = strokeColor;
        [self createButtonStates];
    }
}

- (void)setHighlightedColor:(UIColor *)highlightedColor
{
    if (_highlightedColor != highlightedColor)
    {
        _highlightedColor = highlightedColor;
        [self createButtonStates];
    }
}

- (void)drawButtonNormalWithColor:(UIColor *)strokeColor
{
    //// Color Declarations
    UIColor* white = [UIColor whiteColor];
    
    //// Btn-Dec
    {
        //// TrolleyPaddle-CircDec Drawing
        UIBezierPath* trolleyPaddleCircDecPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(0, 0, 29, 29)];
        [strokeColor setFill];
        [trolleyPaddleCircDecPath fill];
        
        
        //// TrolleyPaddle-Icn-Minus Drawing
        UIBezierPath* trolleyPaddleIcnMinusPath = UIBezierPath.bezierPath;
        [trolleyPaddleIcnMinusPath moveToPoint: CGPointMake(8, 13)];
        [trolleyPaddleIcnMinusPath addLineToPoint: CGPointMake(21, 13)];
        [trolleyPaddleIcnMinusPath addLineToPoint: CGPointMake(21, 16)];
        [trolleyPaddleIcnMinusPath addLineToPoint: CGPointMake(8, 16)];
        [trolleyPaddleIcnMinusPath addLineToPoint: CGPointMake(8, 13)];
        [trolleyPaddleIcnMinusPath closePath];
        [white setFill];
        [trolleyPaddleIcnMinusPath fill];
    }
}

- (void)drawButtonNormal
{
    [self drawButtonNormalWithColor:self.strokeColor];
}

- (void)drawButtonDisabled
{
    [self drawButtonNormalWithColor:[self.strokeColor colorWithAlphaComponent:0.4f]];

}

- (void)drawButtonHighlighted
{
    //// Color Declarations
    UIColor* white = [UIColor whiteColor];
    UIColor* pressesGray = self.highlightedColor;
    
    //// Btn-DecPressed
    {
        //// TrolleyPaddle-CircDec2 Drawing
        UIBezierPath* trolleyPaddleCircDec2Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(0, 0, 29, 29)];
        [pressesGray setFill];
        [trolleyPaddleCircDec2Path fill];
        
        
        //// TrolleyPaddle-Icn-Minus 4 Drawing
        UIBezierPath* trolleyPaddleIcnMinus4Path = UIBezierPath.bezierPath;
        [trolleyPaddleIcnMinus4Path moveToPoint: CGPointMake(8, 13)];
        [trolleyPaddleIcnMinus4Path addLineToPoint: CGPointMake(21, 13)];
        [trolleyPaddleIcnMinus4Path addLineToPoint: CGPointMake(21, 16)];
        [trolleyPaddleIcnMinus4Path addLineToPoint: CGPointMake(8, 16)];
        [trolleyPaddleIcnMinus4Path addLineToPoint: CGPointMake(8, 13)];
        [trolleyPaddleIcnMinus4Path closePath];
        [white setFill];
        [trolleyPaddleIcnMinus4Path fill];
    }
}

@end

@interface SDCircularPlusButton()
@end

@implementation SDCircularPlusButton

+ (instancetype)circularPlusButtonWithStrokeColor:(UIColor *)strokeColor;
{
    SDCircularPlusButton *circularButton = [[SDCircularPlusButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, kCircularButtonWidth, kCircularButtonHeight)];
    circularButton.strokeColor = strokeColor;
    [circularButton createButtonStates];
    return circularButton;
}

- (void)setStrokeColor:(UIColor *)strokeColor
{
    if (_strokeColor != strokeColor)
    {
        _strokeColor = strokeColor;
        [self createButtonStates];
    }
}


- (void)setHighlightedColor:(UIColor *)highlightedColor
{
    if (_highlightedColor != highlightedColor)
    {
        _highlightedColor = highlightedColor;
        [self createButtonStates];
    }
}

- (void)drawButtonNormalWithColor:(UIColor *)strokeColor
{
    //// Color Declarations
    UIColor* white = [UIColor whiteColor];
    
    //// Btn-Inc
    {
        //// Oval 2 Drawing
        UIBezierPath* oval2Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(0, 0, 29, 29)];
        [strokeColor setFill];
        [oval2Path fill];
        
        
        //// TrolleyPaddle-Icn-Plus Drawing
        UIBezierPath* trolleyPaddleIcnPlusPath = UIBezierPath.bezierPath;
        [trolleyPaddleIcnPlusPath moveToPoint: CGPointMake(7, 13)];
        [trolleyPaddleIcnPlusPath addLineToPoint: CGPointMake(22, 13)];
        [trolleyPaddleIcnPlusPath addLineToPoint: CGPointMake(22, 16)];
        [trolleyPaddleIcnPlusPath addLineToPoint: CGPointMake(7, 16)];
        [trolleyPaddleIcnPlusPath addLineToPoint: CGPointMake(7, 13)];
        [trolleyPaddleIcnPlusPath closePath];
        [trolleyPaddleIcnPlusPath moveToPoint: CGPointMake(16, 7)];
        [trolleyPaddleIcnPlusPath addLineToPoint: CGPointMake(16, 22)];
        [trolleyPaddleIcnPlusPath addLineToPoint: CGPointMake(13, 22)];
        [trolleyPaddleIcnPlusPath addLineToPoint: CGPointMake(13, 7)];
        [trolleyPaddleIcnPlusPath addLineToPoint: CGPointMake(16, 7)];
        [trolleyPaddleIcnPlusPath closePath];
        [white setFill];
        [trolleyPaddleIcnPlusPath fill];
    }
}

- (void)drawButtonNormal
{
    [self drawButtonNormalWithColor:self.strokeColor];
}

- (void)drawButtonDisabled
{
    [self drawButtonNormalWithColor:[self.strokeColor colorWithAlphaComponent:0.4f]];
}

- (void)drawButtonHighlighted
{
    //// Color Declarations
    UIColor* white = [UIColor whiteColor];
    UIColor* pressesGray = self.highlightedColor;
    
    //// Btn-IncPressed
    {
        //// Oval Drawing
        UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(0, 0, 29, 29)];
        [pressesGray setFill];
        [ovalPath fill];
        
        
        //// TrolleyPaddle-Icn-Plus 6 Drawing
        UIBezierPath* trolleyPaddleIcnPlus6Path = UIBezierPath.bezierPath;
        [trolleyPaddleIcnPlus6Path moveToPoint: CGPointMake(7, 13)];
        [trolleyPaddleIcnPlus6Path addLineToPoint: CGPointMake(22, 13)];
        [trolleyPaddleIcnPlus6Path addLineToPoint: CGPointMake(22, 16)];
        [trolleyPaddleIcnPlus6Path addLineToPoint: CGPointMake(7, 16)];
        [trolleyPaddleIcnPlus6Path addLineToPoint: CGPointMake(7, 13)];
        [trolleyPaddleIcnPlus6Path closePath];
        [trolleyPaddleIcnPlus6Path moveToPoint: CGPointMake(16, 7)];
        [trolleyPaddleIcnPlus6Path addLineToPoint: CGPointMake(16, 22)];
        [trolleyPaddleIcnPlus6Path addLineToPoint: CGPointMake(13, 22)];
        [trolleyPaddleIcnPlus6Path addLineToPoint: CGPointMake(13, 7)];
        [trolleyPaddleIcnPlus6Path addLineToPoint: CGPointMake(16, 7)];
        [trolleyPaddleIcnPlus6Path closePath];
        [white setFill];
        [trolleyPaddleIcnPlus6Path fill];
    }
}


@end

@implementation SDPaddleView

- (instancetype) init
{
    self = [super init];
    if ( self != nil )
    {
        [self commonInit];
    }
    return self;
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if ( self != nil )
    {
        [self commonInit];
    }
    return self;
}

- (instancetype) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if ( self != nil )
    {
        [self commonInit];
    }
    return self;
}

- (void) commonInit
{
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
    
    _fillColor = [UIColor colorWithRed: 0.098 green: 0.098 blue: 0.098 alpha: 1];
}

- (void) drawRect:(CGRect)rect
{
    CGFloat width = CGRectGetWidth(self.bounds); // default = 67
    
    //// Paddle-Resting
    {
        //// Bezier Drawing
        UIBezierPath* bezierPath = UIBezierPath.bezierPath;
        [bezierPath moveToPoint: CGPointMake(width - 8.0, 14.5)];
        [bezierPath addCurveToPoint: CGPointMake(width - 2.9, 2.1) controlPoint1: CGPointMake(width - 8.0, 9.8) controlPoint2: CGPointMake(width - 6.2, 5.4)];
        [bezierPath addCurveToPoint: CGPointMake(width - 0.3, 0) controlPoint1: CGPointMake(width - 2.1, 1.3) controlPoint2: CGPointMake(width - 1.2, 0.6)];
        [bezierPath addLineToPoint: CGPointMake(0.3, 0)];
        [bezierPath addCurveToPoint: CGPointMake(2.9, 2.1) controlPoint1: CGPointMake(1.2, 0.6) controlPoint2: CGPointMake(2.1, 1.3)];
        [bezierPath addCurveToPoint: CGPointMake(8, 14.5) controlPoint1: CGPointMake(6.2, 5.4) controlPoint2: CGPointMake(8, 9.8)];
        [bezierPath addCurveToPoint: CGPointMake(2.9, 26.9) controlPoint1: CGPointMake(8, 19.2) controlPoint2: CGPointMake(6.2, 23.6)];
        [bezierPath addCurveToPoint: CGPointMake(0.3, 29) controlPoint1: CGPointMake(2.1, 27.7) controlPoint2: CGPointMake(1.2, 28.4)];
        [bezierPath addLineToPoint: CGPointMake(width - 0.3, 29)];
        [bezierPath addCurveToPoint: CGPointMake(width - 2.9, 26.9) controlPoint1: CGPointMake(width - 1.2, 28.4) controlPoint2: CGPointMake(width - 2.1, 27.7)];
        [bezierPath addCurveToPoint: CGPointMake(width - 8.0, 14.5) controlPoint1: CGPointMake(width - 6.2, 23.6) controlPoint2: CGPointMake(width - 8.0, 19.2)];
        [bezierPath closePath];
        bezierPath.miterLimit = 4;
        
        [self.fillColor setFill];
        [bezierPath fill];
    }
}

- (void) setFillColor:(UIColor *)fillColor
{
    if ( _fillColor != fillColor )
    {
        _fillColor = fillColor;
        [self setNeedsDisplay];
    }
}

@end

static const CGFloat kSDQuantityViewBackgroundWidthInset = 14.0f;

@interface SDQuantityView()
@property (nonatomic, assign) BOOL hasSetupConstraints;
@property (nonatomic, strong, readwrite) SDCircularPlusButton *incrementButton;
@property (nonatomic, strong, readwrite) SDCircularMinusButton *decrementButton;
@property (nonatomic, strong, readwrite) SDPaddleView *paddleView;
@property (nonatomic, strong, readwrite) UIImageView *rightImageView;
@property (nonatomic, strong, readwrite) UILabel *quantityLabel;
@property (nonatomic, strong) NSLayoutConstraint *labelWidthConstraint;
@property (nonatomic, strong) SDShapeView *shapeView;
@end

@implementation SDQuantityView

+ (instancetype)quantityView
{
    SDQuantityView *quantityView = [[SDQuantityView alloc] initWithFrame:CGRectMake(0, 0, 110.0f, 29.0f)];
    [quantityView setup];
    return quantityView;
}

- (void)setup
{
    _shapeView = [[SDShapeView alloc] init];
    [self addSubview:_shapeView];

    _paddleView = [[SDPaddleView alloc] init];
    _paddleView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_paddleView];
    
    _incrementButton = [SDCircularPlusButton circularPlusButtonWithStrokeColor:_fillColor];
    _incrementButton.highlightedColor = [UIColor lightGrayColor];
    
    _decrementButton = [SDCircularMinusButton circularMinusButtonWithStrokeColor:_fillColor];
    _decrementButton.highlightedColor = [UIColor lightGrayColor];
    
    _incrementButton.translatesAutoresizingMaskIntoConstraints = NO;
    _decrementButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:_incrementButton];
    [self addSubview:_decrementButton];
    
    _quantityLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _quantityLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _quantityLabel.textAlignment = NSTextAlignmentCenter;
    [_quantityLabel setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [_quantityLabel setContentCompressionResistancePriority:1000 forAxis:UILayoutConstraintAxisHorizontal];
    [_quantityLabel setFont:[UIFont systemFontOfSize:14]];
	[_quantityLabel setBackgroundColor:[UIColor clearColor]];
    [self addSubview:_quantityLabel];
    
    _rightImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _rightImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [_rightImageView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_rightImageView setContentCompressionResistancePriority:0 forAxis:UILayoutConstraintAxisHorizontal];
    
    [self setNeedsUpdateConstraints];
}

- (void)setRightImage:(UIImage *)image
{
    if (image && [self.rightImageView superview] == nil)
    {
        [self addSubview:self.rightImageView];
    }
    else if (image == nil && [self.rightImageView superview] != nil)
    {
        [self.rightImageView removeFromSuperview];
    }
    self.rightImageView.image = image;
    self.rightImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.hasSetupConstraints = NO;
    [self setNeedsUpdateConstraints];
}

- (void)setFillColor:(UIColor *)fillColor
{
    if (_fillColor != fillColor)
    {
        _fillColor = fillColor;
        
        self.incrementButton.strokeColor = fillColor;
        self.decrementButton.strokeColor = fillColor;
    }
}

- (void)updateConstraints
{
    if (self.hasSetupConstraints == NO)
    {
        [self removeConstraints:[self constraints]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_incrementButton(29)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_incrementButton)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_decrementButton(29)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_decrementButton)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_paddleView(29)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_paddleView)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(24)-[_paddleView]-(24)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_paddleView)]];

        if (self.rightImageView.image)
        {
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_rightImageView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_rightImageView)]];
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_decrementButton(29)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_decrementButton)]];
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_incrementButton(29)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_incrementButton)]];
            
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:[_quantityLabel]-(2)-[_rightImageView(%tu)]", (NSUInteger)self.rightImageView.image.size.width] options:0 metrics:nil views:NSDictionaryOfVariableBindings(_quantityLabel, _rightImageView)]];
            
            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.quantityLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:-self.rightImageView.image.size.width/2.0]];
        }
        else
        {
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_decrementButton(29)][_quantityLabel][_incrementButton(29)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_decrementButton, _quantityLabel, _incrementButton)]];
        }
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.quantityLabel attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:1.0f]];
        
        self.hasSetupConstraints = YES;
    }
    [self updateLabelWidthConstraint];
    [super updateConstraints];
}

- (void) updateLabelWidthConstraint
{
    if (self.labelWidthConstraint != nil)
    {
        [self removeConstraint:self.labelWidthConstraint];
        self.labelWidthConstraint = nil;
    }
    
    if (self.rightImageView.image)
    {
        static const CGFloat kSDQuantityViewLabelMargin = 2.0;
        CGFloat maxLabelWidth = CGRectGetWidth(self.bounds) - (kCircularButtonWidth + 2.0 + self.rightImageView.image.size.width + kCircularButtonWidth + 2 * kSDQuantityViewLabelMargin);
        if ( maxLabelWidth > 1.0 ) {
            self.labelWidthConstraint = [NSLayoutConstraint constraintWithItem:self.quantityLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:maxLabelWidth];
            [self addConstraint:self.labelWidthConstraint];
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setupLayer];
}

- (void)setupLayer
{
    CAShapeLayer *layer = (CAShapeLayer *)self.shapeView.layer;
    CGRect bgRect = CGRectInset(self.bounds, kSDQuantityViewBackgroundWidthInset, 0.0f);
    bgRect.origin.y += 0.5f;
    bgRect.size.height -= 1.0f;

    CGPathRef path = CGPathCreateWithRect(bgRect, NULL);
    layer.path = path;
    CGPathRelease(path);
    
    layer.fillColor = nil;
    layer.strokeColor = nil;
}

- (void) setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    if (self.rightImageView.image)
        [self setNeedsUpdateConstraints];
}

#pragma mark - alpha override for ios 6

- (void) setAlpha:(CGFloat)alpha;
{
    if( floor( NSFoundationVersionNumber ) > NSFoundationVersionNumber_iOS_6_1 ) {
        [super setAlpha:alpha];
    } else {
        self.shapeView.alpha = alpha;
        self.quantityLabel.alpha = alpha;

        // Override alpha handling for ios 6
        // using CAShapeLayer and paint code buttons appear to have an issue with combined opacity.
        CGFloat r, g, b, a;
        [self.fillColor getRed:&r green:&g blue:&b alpha:&a];
        self.incrementButton.strokeColor = [UIColor colorWithRed:r green:g blue:b alpha:alpha];
        self.decrementButton.strokeColor = [UIColor colorWithRed:r green:g blue:b alpha:alpha];
    }
}

@end
