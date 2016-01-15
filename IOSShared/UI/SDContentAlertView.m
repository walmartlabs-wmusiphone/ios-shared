//
//  SDContentAlertView.m
//
//  Created by Brandon Sneed on 11/03/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//
//  Based on PXAlertView by Alex Jarvis under the MIT license.
//  Copyright (c) 2013 Panaxiom Ltd. All rights reserved.

#import "SDContentAlertView.h"
#import "UIDevice+machine.h"
#import "SDLog.h"

static const CGFloat kSDContentAlertViewWidth = 270.0;
static const CGFloat kSDContentAlertViewContentMargin = 9;
static const CGFloat kSDContentAlertViewVerticalElementSpace = 10;
static const CGFloat kSDContentAlertViewButtonHeight = 44;

@interface SDContentAlertViewQueue : NSObject

@property (nonatomic, strong) NSMutableArray *alertViews;
@property (nonatomic, assign, readonly) BOOL anyAlertViewsVisible;

+ (SDContentAlertViewQueue *)sharedInstance;

- (void)add:(SDContentAlertView *)alertView;
- (void)remove:(SDContentAlertView *)alertView;
- (void)setAlertWindowLevel:(UIWindowLevel) alertWindowLevel;

@end

#pragma mark - SDContentAlertView

@interface SDContentAlertView ()

@property (nonatomic, strong) UIWindow *mainWindow;
@property (nonatomic, strong) UIWindow *alertWindow;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *alertView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *otherButton;
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, copy) SDContentAlertViewCompletionBlock completion;

@property (nonatomic, assign) BOOL visible;

@end

@implementation SDContentAlertView
{
    CALayer *_cancelBorderLineLayer;
    CALayer *_otherBorderLineLayer;
}

#pragma mark - Init/Dealloc

- (id)initAlertWithTitle:(NSString *)title message:(NSString *)message cancelTitle:(NSString *)cancelTitle otherTitle:(NSString *)otherTitle contentView:(UIView *)contentView completion:(SDContentAlertViewCompletionBlock)completion
{
    self = [super init];

    // Setup our initial colors.
    _backgroundColor = [UIColor colorWithWhite:0.90 alpha:0.98];
    _textColor = [UIColor blackColor];
    _lineColor = [UIColor colorWithWhite:0.7 alpha:1.0];
    _buttonTextColor = [UIColor colorWithRed:0 green:0.46 blue:1.0 alpha:1.0];
    _buttonSelectionTextColor = [UIColor colorWithRed:0 green:0.46 blue:1.0 alpha:1.0];
    _buttonSelectionColor = [UIColor colorWithWhite:0.85 alpha:0.98];

    // Find or create the place to throw down with our content.
    _mainWindow = [self windowWithLevel:UIWindowLevelNormal];
    _alertWindow = [self windowWithLevel:UIWindowLevelAlert];
    if (!_alertWindow)
    {
        _alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _alertWindow.windowLevel = [[self class] defaultAlertWindowLevel];
    }

    self.frame = _alertWindow.bounds;

    // Start setting up our views...
    _backgroundView = [[UIView alloc] initWithFrame:_alertWindow.bounds];
    _backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _backgroundView.alpha = 0;
    [self.alertWindow addSubview:_backgroundView];

    _alertView = [[UIView alloc] init];
    _alertView.opaque = NO;
    _alertView.backgroundColor = _backgroundColor;
    _alertView.layer.cornerRadius = 8.0;
    _alertView.clipsToBounds = YES;
    [self addSubview:_alertView];
    
    // Title
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kSDContentAlertViewContentMargin, kSDContentAlertViewVerticalElementSpace, kSDContentAlertViewWidth - kSDContentAlertViewContentMargin*2, 44)];
    _titleLabel.text = title;
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = _textColor;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font = [UIFont boldSystemFontOfSize:17];
    _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _titleLabel.numberOfLines = 0;
    _titleLabel.frame = [self adjustLabelFrameHeight:self.titleLabel];
    [_alertView addSubview:_titleLabel];
    
    CGFloat messageLabelY = _titleLabel.frame.origin.y + _titleLabel.frame.size.height + kSDContentAlertViewVerticalElementSpace;
    
    // Optional Content View
    if (contentView)
    {
        _contentView = contentView;
        _contentView.frame = CGRectMake(0, messageLabelY, _contentView.frame.size.width, _contentView.frame.size.height);
        _contentView.center = CGPointMake(kSDContentAlertViewWidth/2, _contentView.center.y);

        [_alertView addSubview:_contentView];

        messageLabelY += contentView.frame.size.height + kSDContentAlertViewVerticalElementSpace;
    }
    
    // Message
    _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(kSDContentAlertViewContentMargin, messageLabelY, kSDContentAlertViewWidth - kSDContentAlertViewContentMargin*2, 44)];
    _messageLabel.text = message;
    _messageLabel.backgroundColor = [UIColor clearColor];
    _messageLabel.textColor = _textColor;
    _messageLabel.textAlignment = NSTextAlignmentCenter;
    _messageLabel.font = [UIFont systemFontOfSize:15];
    _messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _messageLabel.numberOfLines = 0;
    _messageLabel.frame = [self adjustLabelFrameHeight:self.messageLabel];
    [_alertView addSubview:_messageLabel];
    
    // Line
    _cancelBorderLineLayer = [CALayer layer];
    _cancelBorderLineLayer.backgroundColor = [_lineColor CGColor];
    _cancelBorderLineLayer.frame = CGRectMake(0, _messageLabel.frame.origin.y + _messageLabel.frame.size.height + kSDContentAlertViewVerticalElementSpace, kSDContentAlertViewWidth, 0.5);
    [_alertView.layer addSublayer:_cancelBorderLineLayer];
    
    // Buttons
    _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    if (cancelTitle)
        [_cancelButton setTitle:cancelTitle forState:UIControlStateNormal];
    else
        [_cancelButton setTitle:NSLocalizedString(@"OK", nil) forState:UIControlStateNormal];

    _cancelButton.backgroundColor = [UIColor clearColor];
    
    [_cancelButton setTitleColor:_buttonTextColor forState:UIControlStateNormal];
    [_cancelButton setTitleColor:_buttonSelectionTextColor forState:UIControlStateHighlighted];
    [_cancelButton addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
    [_cancelButton addTarget:self action:@selector(setBackgroundColorForButton:) forControlEvents:UIControlEventTouchDown];
    [_cancelButton addTarget:self action:@selector(clearBackgroundColorForButton:) forControlEvents:UIControlEventTouchDragExit];

    CGFloat buttonsY = _cancelBorderLineLayer.frame.origin.y + _cancelBorderLineLayer.frame.size.height;
    if (otherTitle)
    {
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:17];
        _cancelButton.frame = CGRectMake(0, buttonsY, kSDContentAlertViewWidth/2, kSDContentAlertViewButtonHeight);
        
        _otherButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_otherButton setTitle:otherTitle forState:UIControlStateNormal];
        _otherButton.backgroundColor = [UIColor clearColor];
        _otherButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        [_otherButton setTitleColor:_buttonTextColor forState:UIControlStateNormal];
        [_otherButton setTitleColor:_buttonSelectionTextColor forState:UIControlStateHighlighted];
        [_otherButton addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
        [_otherButton addTarget:self action:@selector(setBackgroundColorForButton:) forControlEvents:UIControlEventTouchDown];
        [_otherButton addTarget:self action:@selector(clearBackgroundColorForButton:) forControlEvents:UIControlEventTouchDragExit];
        _otherButton.frame = CGRectMake(_cancelButton.frame.size.width, buttonsY, kSDContentAlertViewWidth/2, 44);
        [self.alertView addSubview:_otherButton];
        
        _otherBorderLineLayer = [CALayer layer];
        _otherBorderLineLayer.backgroundColor = [_lineColor CGColor];
        _otherBorderLineLayer.frame = CGRectMake(_otherButton.frame.origin.x, _otherButton.frame.origin.y, 0.5, kSDContentAlertViewButtonHeight);
        [_alertView.layer addSublayer:_otherBorderLineLayer];
        
    }
    else
    {
        _cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        _cancelButton.frame = CGRectMake(0, buttonsY, kSDContentAlertViewWidth, kSDContentAlertViewButtonHeight);
    }
    
    [_alertView addSubview:_cancelButton];
    
    _alertView.bounds = CGRectMake(0, 0, kSDContentAlertViewWidth, 150);
    
    if (completion)
        _completion = [completion copy];
    
    [self setupGestures];
    [self resizeViews];
    
    _alertView.center = CGPointMake(CGRectGetMidX(_alertWindow.bounds), CGRectGetMidY(_alertWindow.bounds));

    return self;
}

- (void)dealloc
{
    [self unregisterForNotifications];
}

#pragma mark - UIAppearance stuff

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    _backgroundColor = backgroundColor;
    self.alertView.backgroundColor = _backgroundColor;
}

- (void)setLineColor:(UIColor *)lineColor
{
    _lineColor = lineColor;
    _cancelBorderLineLayer.backgroundColor = _lineColor.CGColor;
    _otherBorderLineLayer.backgroundColor = _lineColor.CGColor;
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    self.messageLabel.textColor = _textColor;
    self.titleLabel.textColor = _textColor;
}

- (void)setButtonTextColor:(UIColor *)buttonTextColor
{
    _buttonTextColor = buttonTextColor;
    [_cancelButton setTitleColor:_buttonTextColor forState:UIControlStateNormal];
    [_otherButton setTitleColor:_buttonTextColor forState:UIControlStateNormal];
}

- (void)setButtonSelectionColor:(UIColor *)buttonSelectionColor
{
    // this gets set on touch, so no need to do anything here.
    _buttonSelectionColor = buttonSelectionColor;
}

- (void)setButtonSelectionTextColor:(UIColor *)buttonSelectionTextColor
{
    _buttonSelectionTextColor = buttonSelectionTextColor;
    [_cancelButton setTitleColor:_buttonSelectionTextColor forState:UIControlStateHighlighted];
    [_otherButton setTitleColor:_buttonSelectionTextColor forState:UIControlStateHighlighted];
}

#pragma mark - Notification and Handling

- (void)registerForNotifications
{
    // make sure we don't subscribe twice.
    [self unregisterForNotifications];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRotation:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)unregisterForNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)handleKeyboardShow:(NSNotification *)notification
{
    NSValue *value = [notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = value.CGRectValue;

    UIScreen *screen = [UIScreen mainScreen];
    CGRect screenRect = screen.bounds;

    CGRect visibleRect = screenRect;
    visibleRect.size.height -= keyboardRect.size.height;

    [UIView animateWithDuration:0.2 animations:^{
        self.alertView.center = CGPointMake(visibleRect.size.width / 2, visibleRect.size.height / 2);
        self.alertView.frame = CGRectIntegral(self.alertView.frame);
    }];
}

- (void)handleKeyboardHide:(NSNotification *)notification
{
    UIScreen *screen = [UIScreen mainScreen];
    CGRect screenRect = screen.bounds;

    CGRect visibleRect = screenRect;

    [UIView animateWithDuration:0.2 animations:^{
        self.alertView.center = CGPointMake(visibleRect.size.width / 2, visibleRect.size.height / 2);
        self.alertView.frame = CGRectIntegral(self.alertView.frame);
    }];
}

- (void)handleRotation:(NSNotification *)notification
{
	// Calculate a rotation transform that matches the current interface orientation.
	CGFloat angle = 0.0f;
	UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];

	if (orientation == UIInterfaceOrientationPortraitUpsideDown)
        angle = M_PI;
    else
    if (orientation == UIInterfaceOrientationLandscapeLeft)
        angle = -M_PI_2;
    else
    if (orientation == UIInterfaceOrientationLandscapeRight)
        angle = M_PI_2;

    SDLog(@"alertRect = %@", NSStringFromCGRect(self.alertView.frame));

    [self.layer removeAllAnimations];
    [self.layer setTransform:CATransform3DMakeRotation(angle, 0.0f, 0.0f, 1.0f)];
}

#pragma mark - Utilities

- (UIWindow *)windowWithLevel:(UIWindowLevel)windowLevel
{
    NSArray *windows = [[UIApplication sharedApplication] windows];
    for (UIWindow *window in windows)
        if (window.windowLevel == windowLevel)
            return window;

    return nil;
}

// this method mimics UIAlertView's show.
- (void)show
{
    [[SDContentAlertViewQueue sharedInstance] add:self];
}

// this method is called from SDContentAlertViewQueue
- (void)internalShow
{
    [self handleRotation:nil];
    [self.alertWindow addSubview:self];
    [self.alertWindow makeKeyAndVisible];
    self.visible = YES;
    [self showBackgroundView];
    [self showAlertAnimation];

    [self registerForNotifications];
}

- (void)showBackgroundView
{
    if ([UIDevice systemMajorVersion] >= 7)
    {
        self.mainWindow.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
        [self.mainWindow tintColorDidChange];
    }

    [self.alertWindow addSubview:self.backgroundView];
    [self.alertWindow sendSubviewToBack:self.backgroundView];

    self.backgroundView.alpha = 1;
}

- (void)hide
{
    self.backgroundView.alpha = 0;
    [self removeFromSuperview];
    [_backgroundView removeFromSuperview];
}

- (void)dismiss:(id)sender
{
    self.visible = NO;
    
    if ([[[SDContentAlertViewQueue sharedInstance] alertViews] count] == 1)
    {
        [self dismissAlertAnimation];
        if ([UIDevice systemMajorVersion] >= 7)
        {
            self.mainWindow.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
            [self.mainWindow tintColorDidChange];
        }
        
        self.alertWindow.hidden = YES;

        [UIView animateWithDuration:0.2 animations:^{
            self.backgroundView.alpha = 0;
            [self.mainWindow makeKeyAndVisible];
        }];
    }

    [UIView animateWithDuration:0.2 animations:^{
        self.alertView.alpha = 0;
    } completion:^(BOOL finished) {
        [[SDContentAlertViewQueue sharedInstance] remove:self];
        [self hide];
    }];
    
    BOOL cancelled = NO;
    if (sender == self.cancelButton || sender == self.tap)
        cancelled = YES;
    else
        cancelled = NO;

    if (self.completion)
        self.completion(cancelled);
}

- (void)setBackgroundColorForButton:(id)sender
{
    [sender setBackgroundColor:_buttonSelectionColor];
}

- (void)clearBackgroundColorForButton:(id)sender
{
    [sender setBackgroundColor:[UIColor clearColor]];
}

#pragma mark - Gestures

- (void)setupGestures
{
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
    [self.tap setNumberOfTapsRequired:1];
    [self.backgroundView setUserInteractionEnabled:YES];
    [self.backgroundView setMultipleTouchEnabled:NO];
    [self.backgroundView addGestureRecognizer:self.tap];
}

#pragma mark - View Sizing

- (CGRect)adjustLabelFrameHeight:(UILabel *)label
{
    CGFloat height;
    
    if ([UIDevice systemMajorVersion] < 7)
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        CGSize size = [label.text sizeWithFont:label.font
//TODO 64BIT: Inspect use of MAX/MIN constant; consider one of LONG_MAX/LONG_MIN/ULONG_MAX/DBL_MAX/DBL_MIN, or better yet, NSIntegerMax/Min, NSUIntegerMax, CGFLOAT_MAX/MIN
                             constrainedToSize:CGSizeMake(label.frame.size.width, FLT_MAX)
                                 lineBreakMode:NSLineBreakByWordWrapping];
        
        height = size.height;
#pragma clang diagnostic pop
    }
    else
    {
        NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
        context.minimumScaleFactor = 1.0;
//TODO 64BIT: Inspect use of MAX/MIN constant; consider one of LONG_MAX/LONG_MIN/ULONG_MAX/DBL_MAX/DBL_MIN, or better yet, NSIntegerMax/Min, NSUIntegerMax, CGFLOAT_MAX/MIN
        CGRect bounds = [label.text boundingRectWithSize:CGSizeMake(label.frame.size.width, FLT_MAX)
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName:label.font}
                                        context:context];
        height = bounds.size.height;
    }
    
    return CGRectIntegral(CGRectMake(label.frame.origin.x, label.frame.origin.y, label.frame.size.width, height));
}

- (void)resizeViews
{
    CGFloat totalHeight = 0;
    for (UIView *view in [self.alertView subviews])
        if ([view class] != [UIButton class])
            totalHeight += view.frame.size.height + kSDContentAlertViewVerticalElementSpace;

    totalHeight += kSDContentAlertViewButtonHeight;
    totalHeight += kSDContentAlertViewVerticalElementSpace;
    
    self.alertView.frame = CGRectMake(self.alertView.frame.origin.x,
                                      self.alertView.frame.origin.y,
                                      self.alertView.frame.size.width,
                                      totalHeight);
}

#pragma mark - Animations

- (void)showAlertAnimation
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    animation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1)],
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.05, 1.05, 1)],
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1)]];
    animation.keyTimes = @[@0, @0.5, @1];
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.duration = .3;
    
    [self.alertView.layer addAnimation:animation forKey:@"showAlert"];
}

- (void)dismissAlertAnimation
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    animation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1)],
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.95, 0.95, 1)],
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.8, 0.8, 1)]];
    animation.keyTimes = @[@0, @0.5, @1];
    animation.fillMode = kCAFillModeRemoved;
    animation.duration = .2;
    
    [self.alertView.layer addAnimation:animation forKey:@"dismissAlert"];
}

#pragma mark - Public interfaces

+ (SDContentAlertView *)showAlertWithTitle:(NSString *)title
{
    return [SDContentAlertView showAlertWithTitle:title message:nil cancelTitle:NSLocalizedString(@"Ok", nil) completion:nil];
}

+ (SDContentAlertView *)showAlertWithTitle:(NSString *)title message:(NSString *)message
{
    return [SDContentAlertView showAlertWithTitle:title message:message cancelTitle:NSLocalizedString(@"Ok", nil) completion:nil];
}

+ (SDContentAlertView *)showAlertWithTitle:(NSString *)title message:(NSString *)message completion:(SDContentAlertViewCompletionBlock)completion
{
    return [SDContentAlertView showAlertWithTitle:title message:message cancelTitle:NSLocalizedString(@"Ok", nil) completion:completion];
}

+ (SDContentAlertView *)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelTitle:(NSString *)cancelTitle completion:(SDContentAlertViewCompletionBlock)completion
{
    SDContentAlertView *alertView = [[SDContentAlertView alloc] initAlertWithTitle:title message:message cancelTitle:cancelTitle otherTitle:nil contentView:nil completion:completion];
    [alertView show];
    return alertView;
}

+ (SDContentAlertView *)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelTitle:(NSString *)cancelTitle otherTitle:(NSString *)otherTitle completion:(SDContentAlertViewCompletionBlock)completion
{
    SDContentAlertView *alertView = [[SDContentAlertView alloc] initAlertWithTitle:title message:message cancelTitle:cancelTitle otherTitle:otherTitle contentView:nil completion:completion];
    [alertView show];
    return alertView;
}

+ (SDContentAlertView *)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelTitle:(NSString *)cancelTitle otherTitle:(NSString *)otherTitle contentView:(UIView *)view completion:(SDContentAlertViewCompletionBlock)completion
{
    SDContentAlertView *alertView = [[SDContentAlertView alloc] initAlertWithTitle:title message:message cancelTitle:cancelTitle otherTitle:otherTitle contentView:view completion:completion];
    [alertView show];
    return alertView;
}

static BOOL sDefaultAlertWindowLevelEverSet;
static UIWindowLevel sDefaultAlertWindowLevel;

+ (UIWindowLevel) defaultAlertWindowLevel;
{
    if (!sDefaultAlertWindowLevelEverSet) {
        sDefaultAlertWindowLevel = UIWindowLevelAlert;
        sDefaultAlertWindowLevelEverSet = YES;
    }
    return sDefaultAlertWindowLevel;
}

+ (void) setDefaultAlertWindowLevel:(UIWindowLevel) defaultAlertWindowLevel;
{
    if ([SDContentAlertViewQueue sharedInstance].anyAlertViewsVisible) {
        SDLog(@"***** WARNING: Cannot change defaultAlertWindowLevel while an alert is visible, ignoring change");
        return;
    }
    sDefaultAlertWindowLevel = defaultAlertWindowLevel;
    [[SDContentAlertViewQueue sharedInstance] setAlertWindowLevel:defaultAlertWindowLevel];
}

@end


#pragma mark - SDContentAlertViewQueue
// This queue handles multiple alert scenarios.

@implementation SDContentAlertViewQueue

+ (instancetype)sharedInstance
{
    static SDContentAlertViewQueue *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SDContentAlertViewQueue alloc] init];
        _sharedInstance.alertViews = [NSMutableArray array];
    });
    
    return _sharedInstance;
}

- (void)add:(SDContentAlertView *)alertView
{
    [self.alertViews addObject:alertView];
    [alertView internalShow];
    for (SDContentAlertView *av in self.alertViews)
    {
        if (av != alertView)
            [av hide];
    }
}

- (void)remove:(SDContentAlertView *)alertView
{
    [self.alertViews removeObject:alertView];
    SDContentAlertView *last = [self.alertViews lastObject];
    if (last)
        [last internalShow];
}

- (void)setAlertWindowLevel:(UIWindowLevel) alertWindowLevel;
{
    for (SDContentAlertView *contentAlertView in self.alertViews) {
        contentAlertView.alertWindow.windowLevel = alertWindowLevel;
    }
}

- (BOOL)anyAlertViewsVisible;
{
    BOOL result = NO;
    for (SDContentAlertView *contentAlertView in self.alertViews) {
        if (contentAlertView.visible) {
            result = YES;
            break;
        }
    }
    return result;
}

@end
