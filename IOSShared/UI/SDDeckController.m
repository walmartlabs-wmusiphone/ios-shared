//
//  SDDeckController.h
//
//  Created by Brandon Sneed on 1/18/12.
//  Copyright (c) 2012 SetDirection. All rights reserved.
//
//  Based on JASidePanels by Jesse Andersen.

/*
 Copyright (c) 2012 Jesse Andersen. All rights reserved.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of
 this software and associated documentation files (the "Software"), to deal in
 the Software without restriction, including without limitation the rights to
 use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 of the Software, and to permit persons to whom the Software is furnished to do
 so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 If you happen to meet one of the copyright holders in a bar you are obligated
 to buy them one pint of beer.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

#import <QuartzCore/QuartzCore.h>
#import "SDDeckController.h"
#include <tgmath.h>

static char wmdeck_kvoContext;

@interface UIView (SDDeckController_Internal)
- (BOOL)isAnyParentViewEditable;
@end

@implementation UIView (SDDeckController)

- (BOOL)isEditable
{
    return FALSE;
}

- (BOOL)isAnyParentViewEditable
{
    BOOL result = NO;
    UIView *parentView = self;
    
    result = [self isEditable];
    
    while (!result && parentView)
    {
        parentView = [parentView superview];
        result = [parentView isEditable];
    }
    
    return result;
}

@end

@interface SDDeckController () {
    CGRect _centerDeckRestingFrame;
    CGPoint _locationBeforePan;
}

@property (nonatomic, readwrite) SDDeckState state;
@property (nonatomic, weak) UIViewController *visibleDeck;
@property (nonatomic, strong) UIView *tapView;

// Deck containers
@property (nonatomic, strong) UIView *leftDeckContainer;
@property (nonatomic, strong) UIView *rightDeckContainer;
@property (nonatomic, strong) UIView *centerDeckContainer;

@end

@implementation SDDeckController

#pragma mark - Icon

+ (UIImage *)defaultImage
{
    static UIImage *defaultImage = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(20.f, 13.f), NO, 0.0f);
        
        [[UIColor blackColor] setFill];
        [[UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 20, 1)] fill];
        [[UIBezierPath bezierPathWithRect:CGRectMake(0, 5, 20, 1)] fill];
        [[UIBezierPath bezierPathWithRect:CGRectMake(0, 10, 20, 1)] fill];
        
        [[UIColor whiteColor] setFill];
        [[UIBezierPath bezierPathWithRect:CGRectMake(0, 1, 20, 2)] fill];
        [[UIBezierPath bezierPathWithRect:CGRectMake(0, 6,  20, 2)] fill];
        [[UIBezierPath bezierPathWithRect:CGRectMake(0, 11, 20, 2)] fill];
        
        defaultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
    });
    return defaultImage;
}

#pragma mark - NSObject

+ (instancetype)sharedInstance
{
	static dispatch_once_t oncePred;
	static id sharedInstance = nil;
	dispatch_once(&oncePred, ^{ sharedInstance = [[[self class] alloc] init]; });
	return sharedInstance;
}

- (void)dealloc
{
    [_centerDeck removeObserver:self forKeyPath:@"view"];
    [_centerDeck removeObserver:self forKeyPath:@"viewControllers"];
}

// Support creating from Storyboard
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
        [self _baseInit];
    return self;
}

- (id)init
{
    if (self = [super init])
        [self _baseInit];
    return self;
}

- (void)_baseInit
{
    self.style = SDDeckSingleActive;
    self.leftGapPercentage = 0.8f;
    self.rightGapPercentage = 0.8f;
    self.minimumMovePercentage = 0.15f;
    self.maximumAnimationDuration = 0.2f;
    self.bounceDuration = 0.1f;
    self.bouncePercentage = 0.075f;
    self.panningLimitedToTopViewController = YES;
    self.recognizesPanGesture = YES;
    self.allowLeftOverpan = YES;
    self.allowRightOverpan = YES;
    self.bounceOnSideDeckOpen = YES;
    self.shouldResizeLeftDeck = YES;
    self.shouldResizeRightDeck = YES;
    self.shouldDelegateAutorotateToVisibleDeck = YES;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    self.centerDeckContainer = [[UIView alloc] initWithFrame:self.view.bounds];
    _centerDeckRestingFrame = self.centerDeckContainer.frame;
    _centerDeckHidden = NO;
    
    self.leftDeckContainer = [[UIView alloc] initWithFrame:self.view.bounds];
    self.leftDeckContainer.hidden = YES;
    
    self.rightDeckContainer = [[UIView alloc] initWithFrame:self.view.bounds];
    self.rightDeckContainer.hidden = YES;
    
    [self _configureContainers];
    
    [self.view addSubview:self.centerDeckContainer];
    [self.view addSubview:self.leftDeckContainer];
    [self.view addSubview:self.rightDeckContainer];
    
    self.state = SDDeckCenterVisible;
    
    [self _swapCenter:nil with:_centerDeck];
    [self.view bringSubviewToFront:self.centerDeckContainer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // ensure correct view dimensions
    [self _layoutSideContainers:NO duration:0.0f];
    [self _layoutSideDecks];
    self.centerDeckContainer.frame = [self _adjustCenterFrame];
    [self styleContainer:self.centerDeckContainer animate:NO duration:0.0f];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self _adjustCenterFrame]; // Account for possible rotation while view appearing
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    __strong UIViewController *visibleDeck = self.visibleDeck;
    
    if (self.shouldDelegateAutorotateToVisibleDeck)
        return [visibleDeck shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
    else
        return YES;
}

#else

- (BOOL)shouldAutorotate
{
    __strong UIViewController *visibleDeck = self.visibleDeck;
    
    if (self.shouldDelegateAutorotateToVisibleDeck && [visibleDeck respondsToSelector:@selector(shouldAutorotate)])
        return [visibleDeck shouldAutorotate];
    else
        return YES;
}


#endif /* if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0 */

- (void)willAnimateRotationToInterfaceOrientation:(__unused UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    self.centerDeckContainer.frame = [self _adjustCenterFrame];
    [self _layoutSideContainers:YES duration:duration];
    [self _layoutSideDecks];
    [self styleContainer:self.centerDeckContainer animate:YES duration:duration];
    if (self.centerDeckHidden)
    {
        CGRect frame = self.centerDeckContainer.frame;
        frame.origin.x = self.state == SDDeckLeftVisible ? self.centerDeckContainer.frame.size.width : -self.centerDeckContainer.frame.size.width;
        self.centerDeckContainer.frame = frame;
    }
}

#pragma mark - State

- (void)setState:(SDDeckState)state
{
    if (state != _state)
    {
        _state = state;
        switch (_state)
        {
            case SDDeckCenterVisible: {
                self.visibleDeck = self.centerDeck;
                self.leftDeckContainer.userInteractionEnabled = NO;
                self.rightDeckContainer.userInteractionEnabled = NO;
                break;
            }
            case SDDeckLeftVisible: {
                self.visibleDeck = self.leftDeck;
                self.leftDeckContainer.userInteractionEnabled = YES;
                break;
            }
            case SDDeckRightVisible: {
                self.visibleDeck = self.rightDeck;
                self.rightDeckContainer.userInteractionEnabled = YES;
                break;
            }
        }
    }
}

#pragma mark - Style

- (void)setStyle:(SDDeckStyle)style
{
    if (style != _style)
    {
        _style = style;
        if (self.isViewLoaded)
        {
            [self _configureContainers];
            [self _layoutSideContainers:NO duration:0.0f];
        }
    }
}

- (void)styleContainer:(UIView *)container animate:(BOOL)animate duration:(NSTimeInterval)duration
{
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRoundedRect:container.bounds cornerRadius:0.0f];
    
    if (animate)
    {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
        animation.fromValue = (id) container.layer.shadowPath;
        animation.toValue = (id) shadowPath.CGPath;
        animation.duration = duration;
        [container.layer addAnimation:animation forKey:@"shadowPath"];
    }
    container.layer.shadowPath = shadowPath.CGPath;
    container.layer.shadowColor = [UIColor blackColor].CGColor;
    container.layer.shadowRadius = 10.0f;
    container.layer.shadowOpacity = 0.75f;
    container.clipsToBounds = NO;
}

- (void)styleDeck:(UIView *)Deck
{
    //Deck.layer.cornerRadius = 6.0f;
    //Deck.clipsToBounds = YES;
}

- (void)_configureContainers
{
    self.leftDeckContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
    self.rightDeckContainer.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    self.centerDeckContainer.frame =  self.view.bounds;
    self.centerDeckContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)_layoutSideContainers:(BOOL)animate duration:(NSTimeInterval)duration
{
    CGRect leftFrame = self.view.bounds;
    CGRect rightFrame = self.view.bounds;
    
    if (self.style == SDDeckMultipleActive)
    {
        // left Deck container
        leftFrame.size.width = self.leftVisibleWidth;
        leftFrame.origin.x = self.centerDeckContainer.frame.origin.x - leftFrame.size.width;
        
        // right Deck container
        rightFrame.size.width = self.rightVisibleWidth;
        rightFrame.origin.x = self.centerDeckContainer.frame.origin.x + self.centerDeckContainer.frame.size.width;
    }
    self.leftDeckContainer.frame = leftFrame;
    self.rightDeckContainer.frame = rightFrame;
    [self styleContainer:self.leftDeckContainer animate:animate duration:duration];
    [self styleContainer:self.rightDeckContainer animate:animate duration:duration];
}

- (void)_layoutSideDecks
{
    if (self.rightDeck.isViewLoaded)
    {
        CGRect frame = self.rightDeckContainer.bounds;
        if (self.shouldResizeRightDeck)
        {
            frame.origin.x = self.rightDeckContainer.bounds.size.width - self.rightVisibleWidth;
            frame.size.width = self.rightVisibleWidth;
        }
        self.rightDeck.view.frame = frame;
    }
    if (self.leftDeck.isViewLoaded)
    {
        CGRect frame = self.leftDeckContainer.bounds;
        if (self.shouldResizeLeftDeck)
            frame.size.width = self.leftVisibleWidth;
        self.leftDeck.view.frame = frame;
    }
}

#pragma mark - Decks

- (void)setCenterDeck:(UIViewController *)centerDeck
{
    UIViewController *previous = _centerDeck;
    
    if (centerDeck != _centerDeck)
    {
        [_centerDeck removeObserver:self forKeyPath:@"view"];
        [_centerDeck removeObserver:self forKeyPath:@"viewControllers"];
        _centerDeck = centerDeck;
        [_centerDeck addObserver:self forKeyPath:@"viewControllers" options:0 context:&wmdeck_kvoContext];
        [_centerDeck addObserver:self forKeyPath:@"view" options:NSKeyValueObservingOptionInitial context:&wmdeck_kvoContext];
        if (self.state == SDDeckCenterVisible)
            self.visibleDeck = _centerDeck;
    }
    if (self.isViewLoaded && self.state == SDDeckCenterVisible)
        [self _swapCenter:previous with:_centerDeck];
    else if (self.isViewLoaded)
    {
        // update the state immediately to prevent user interaction on the side Decks while animating
        SDDeckState previousState = self.state;
        self.state = SDDeckCenterVisible;
        [UIView animateWithDuration:0.2f animations:^{
            // first move the centerDeck offscreen
            CGFloat x = (previousState == SDDeckLeftVisible) ? self.view.bounds.size.width : -self.view.bounds.size.width;
            _centerDeckRestingFrame.origin.x = x;
            self.centerDeckContainer.frame = _centerDeckRestingFrame;
        } completion:^(__unused BOOL finished) {
            [self _swapCenter:previous with:_centerDeck];
            [self _showCenterDeck:YES bounce:NO];
        }];
    }
}

- (void)_swapCenter:(UIViewController *)previous with:(UIViewController *)next
{
    if (previous != next)
    {
        [previous willMoveToParentViewController:nil];
        [previous.view removeFromSuperview];
        [previous removeFromParentViewController];
        
        if (next)
        {
            [self _loadCenterDeck];
            [self addChildViewController:next];
            [self.centerDeckContainer addSubview:next.view];
            [next didMoveToParentViewController:self];
        }
    }
}

- (void)setLeftDeck:(UIViewController *)leftDeck
{
    if (leftDeck != _leftDeck)
    {
        [_leftDeck willMoveToParentViewController:nil];
        [_leftDeck.view removeFromSuperview];
        [_leftDeck removeFromParentViewController];
        _leftDeck = leftDeck;
        if (_leftDeck)
        {
            [self addChildViewController:_leftDeck];
            [_leftDeck didMoveToParentViewController:self];
            [self _placeButtonForLeftDeck];
        }
        if (self.state == SDDeckLeftVisible)
            self.visibleDeck = _leftDeck;
    }
}

- (void)setRightDeck:(UIViewController *)rightDeck
{
    if (rightDeck != _rightDeck)
    {
        [_rightDeck willMoveToParentViewController:nil];
        [_rightDeck.view removeFromSuperview];
        [_rightDeck removeFromParentViewController];
        _rightDeck = rightDeck;
        if (_rightDeck)
        {
            [self addChildViewController:_rightDeck];
            [_rightDeck didMoveToParentViewController:self];
        }
        if (self.state == SDDeckRightVisible)
            self.visibleDeck = _rightDeck;
    }
}

#pragma mark - Deck Buttons

- (void)_placeButtonForLeftDeck
{
    if (self.leftDeck)
    {
        UIViewController *buttonController = self.centerDeck;
        if ([buttonController isKindOfClass:[UINavigationController class]])
        {
            UINavigationController *nav = (UINavigationController *) buttonController;
            if ([nav.viewControllers count] > 0)
                buttonController = [nav.viewControllers objectAtIndex:0];
        }
        if (!buttonController.navigationItem.leftBarButtonItem)
            buttonController.navigationItem.leftBarButtonItem = [self leftButtonForCenterDeck];
    }
}

#pragma mark - Gesture Recognizer Delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    UIView *gestureView = gestureRecognizer.view;
    if (gestureView == self.tapView)
        return YES;
    else if (self.panningLimitedToTopViewController && ![self _isOnTopLevelViewController:self.centerDeck])
        return NO;
    else if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
    {
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *) gestureRecognizer;
        CGPoint translate = [pan translationInView:self.centerDeckContainer];
        BOOL possible = translate.x != 0 && ((fabs(translate.y) / fabs(translate.x)) < 1.0f);
        if (possible && ((translate.x > 0 && self.leftDeck) || (translate.x < 0 && self.rightDeck)))
            return YES;
    }
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    UIView *touchView = touch.view;
    if ([touchView isKindOfClass:[UISlider class]])
        return NO;
    
    if ([touchView respondsToSelector:@selector(isAnyParentViewEditable)])
    {
        if ([touchView isAnyParentViewEditable])
            return NO;
    }
    
    return YES;
}

#pragma mark - Pan Gestures

- (void)_addPanGestureToView:(UIView *)view
{
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_handlePan:)];
    
    panGesture.delegate = self;
    panGesture.maximumNumberOfTouches = 1;
    panGesture.minimumNumberOfTouches = 1;
    [view addGestureRecognizer:panGesture];
}

- (void)_handlePan:(UIGestureRecognizer *)sender
{
    if ([sender isKindOfClass:[UIPanGestureRecognizer class]])
    {
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *) sender;
        
        if (pan.state == UIGestureRecognizerStateBegan)
            _locationBeforePan = self.centerDeckContainer.frame.origin;
        
        CGPoint translate = [pan translationInView:self.centerDeckContainer];
        CGRect frame = _centerDeckRestingFrame;
        frame.origin.x += [self _correctMovement:translate.x];
        self.centerDeckContainer.frame = frame;
        
        // if center Deck has focus, make sure correct side Deck is revealed
        if (self.state == SDDeckCenterVisible)
        {
            if (frame.origin.x > 0.0f)
                [self _loadLeftDeck];
            else if (frame.origin.x < 0.0f)
                [self _loadRightDeck];
        }
        
        if (sender.state == UIGestureRecognizerStateEnded)
        {
            CGFloat deltaX =  frame.origin.x - _locationBeforePan.x;
            if ([self _validateThreshold:deltaX])
                [self _completePan:deltaX];
            else
                [self _undoPan];
        }
        else if (sender.state == UIGestureRecognizerStateCancelled)
            [self _undoPan];
    }
}

- (void)_completePan:(CGFloat)deltaX
{
    switch (self.state)
    {
        case SDDeckCenterVisible: {
            if (deltaX > 0.0f)
                [self _showLeftDeck:YES bounce:self.bounceOnSideDeckOpen];
            else
                [self _showRightDeck:YES bounce:self.bounceOnSideDeckOpen completion:nil];
            break;
        }
        case SDDeckLeftVisible: {
            [self _showCenterDeck:YES bounce:self.bounceOnSideDeckClose];
            break;
        }
        case SDDeckRightVisible: {
            [self _showCenterDeck:YES bounce:self.bounceOnSideDeckClose];
            break;
        }
    }
}

- (void)_undoPan
{
    switch (self.state)
    {
        case SDDeckCenterVisible: {
            [self _showCenterDeck:YES bounce:NO];
            break;
        }
        case SDDeckLeftVisible: {
            [self _showLeftDeck:YES bounce:NO];
            break;
        }
        case SDDeckRightVisible: {
            [self _showRightDeck:YES bounce:NO completion:nil];
        }
    }
}

#pragma mark - Tap Gesture

- (void)setTapView:(UIView *)tapView
{
    if (tapView != _tapView)
    {
        [_tapView removeFromSuperview];
        _tapView = tapView;
        if (_tapView)
        {
            _tapView.frame = self.centerDeckContainer.bounds;
            _tapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [self _addTapGestureToView:_tapView];
            if (self.recognizesPanGesture)
                [self _addPanGestureToView:_tapView];
            [self.centerDeckContainer addSubview:_tapView];
        }
    }
}

- (void)_addTapGestureToView:(UIView *)view
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_centerDeckTapped:)];
    
    [view addGestureRecognizer:tapGesture];
}

- (void)_centerDeckTapped:(__unused UIGestureRecognizer *)gesture
{
    [self _showCenterDeck:YES bounce:NO];
}

#pragma mark - Internal Methods

- (CGFloat)_correctMovement:(CGFloat)movement
{
    CGFloat position = _centerDeckRestingFrame.origin.x + movement;
    
    if (self.state == SDDeckCenterVisible)
    {
        if ((position > 0.0f && !self.leftDeck) || (position < 0.0f && !self.rightDeck))
            return 0.0f;
    }
    else if (self.state == SDDeckRightVisible && !self.allowRightOverpan)
    {
        if ((position + _centerDeckRestingFrame.size.width) < (self.rightDeckContainer.frame.size.width - self.rightVisibleWidth))
            return 0.0f;
        else if (position > self.rightDeckContainer.frame.origin.x)
            return self.rightDeckContainer.frame.origin.x - _centerDeckRestingFrame.origin.x;
    }
    else if (self.state == SDDeckLeftVisible  && !self.allowLeftOverpan)
    {
        if (position > self.leftVisibleWidth)
            return 0.0f;
        else if (position < self.leftDeckContainer.frame.origin.x)
            return self.leftDeckContainer.frame.origin.x - _centerDeckRestingFrame.origin.x;
    }
    return movement;
}

- (BOOL)_validateThreshold:(CGFloat)movement
{
    CGFloat minimum = floor(self.view.bounds.size.width * self.minimumMovePercentage);
    
    switch (self.state)
    {
        case SDDeckLeftVisible: {
            return movement <= -minimum;
        }
        case SDDeckCenterVisible: {
            return fabs(movement) >= minimum;
        }
        case SDDeckRightVisible: {
            return movement >= minimum;
        }
    }
    return NO;
}

- (BOOL)_isOnTopLevelViewController:(UIViewController *)root
{
    if ([root isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *nav = (UINavigationController *) root;
        return [nav.viewControllers count] == 1;
    }
    else if ([root isKindOfClass:[UITabBarController class]])
    {
        UITabBarController *tab = (UITabBarController *) root;
        return [self _isOnTopLevelViewController:tab.selectedViewController];
    }
    return root != nil;
}

#pragma mark - Loading Decks

- (void)_loadCenterDeck
{
    [self _placeButtonForLeftDeck];
    
    _centerDeck.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _centerDeck.view.frame = self.centerDeckContainer.bounds;
    [self styleDeck:_centerDeck.view];
}

- (void)_loadLeftDeck
{
    self.rightDeckContainer.hidden = YES;
    if (self.leftDeckContainer.hidden && self.leftDeck)
    {
        
        if (!_leftDeck.view.superview)
        {
            [self _layoutSideDecks];
            _leftDeck.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [self styleDeck:_leftDeck.view];
            [self.leftDeckContainer addSubview:_leftDeck.view];
        }
        
        self.leftDeckContainer.hidden = NO;
    }
}

- (void)_loadRightDeck
{
    self.leftDeckContainer.hidden = YES;
    if (self.rightDeckContainer.hidden && self.rightDeck)
    {
        
        if (!_rightDeck.view.superview)
        {
            [self _layoutSideDecks];
            _rightDeck.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [self styleDeck:_rightDeck.view];
            [self.rightDeckContainer addSubview:_rightDeck.view];
        }
        
        self.rightDeckContainer.hidden = NO;
    }
}

- (void)_unloadDecks
{
    if (self.canUnloadLeftDeck && self.leftDeck.isViewLoaded)
        [self.leftDeck.view removeFromSuperview];
    if (self.canUnloadRightDeck && self.rightDeck.isViewLoaded)
        [self.rightDeck.view removeFromSuperview];
}

#pragma mark - Animation

- (CGFloat)_calculatedDuration
{
    CGFloat remaining = fabs(self.centerDeckContainer.frame.origin.x - _centerDeckRestingFrame.origin.x);
    CGFloat max = _locationBeforePan.x == _centerDeckRestingFrame.origin.x ? remaining : fabs(_locationBeforePan.x - _centerDeckRestingFrame.origin.x);
    
    return max > 0.0f ? self.maximumAnimationDuration * (remaining / max) : self.maximumAnimationDuration;
}

- (void)_animateCenterDeck:(BOOL)shouldBounce completion:(void (^)(BOOL finished))completion
{
    CGFloat bounceDistance = (_centerDeckRestingFrame.origin.x - self.centerDeckContainer.frame.origin.x) * self.bouncePercentage;
    
    // looks bad if we bounce when the center Deck grows
    if (_centerDeckRestingFrame.size.width > self.centerDeckContainer.frame.size.width)
        shouldBounce = NO;
    
    CGFloat duration = [self _calculatedDuration];
    [UIView animateWithDuration:duration delay:0.0f options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionLayoutSubviews animations:^{
        self.centerDeckContainer.frame = _centerDeckRestingFrame;
        [self styleContainer:self.centerDeckContainer animate:YES duration:duration];
        if (self.style == SDDeckMultipleActive)
            [self _layoutSideContainers:NO duration:0.0f];
    } completion:^(BOOL finished) {
        if (shouldBounce)
        {
            // make sure correct Deck is displayed under the bounce
            if (self.state == SDDeckCenterVisible)
            {
                if (bounceDistance > 0.0f)
                    [self _loadLeftDeck];
                else
                    [self _loadRightDeck];
            }
            // animate the bounce
            [UIView animateWithDuration:self.bounceDuration delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
                CGRect bounceFrame = _centerDeckRestingFrame;
                bounceFrame.origin.x += bounceDistance;
                self.centerDeckContainer.frame = bounceFrame;
            } completion:^(__unused BOOL finished2) {
                [UIView animateWithDuration:self.bounceDuration delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
                    self.centerDeckContainer.frame = _centerDeckRestingFrame;
                } completion:completion];
            }];
        }
        else if (completion)
            completion(finished);
    }];
}

#pragma mark - Deck Sizing

- (CGRect)_adjustCenterFrame
{
    CGRect frame = self.view.bounds;
    
    switch (self.state)
    {
        case SDDeckCenterVisible: {
            frame.origin.x = 0.0f;
            if (self.style == SDDeckMultipleActive)
                frame.size.width = self.view.bounds.size.width;
            break;
        }
        case SDDeckLeftVisible: {
            frame.origin.x = self.leftVisibleWidth;
            if (self.style == SDDeckMultipleActive)
                frame.size.width = self.view.bounds.size.width - self.leftVisibleWidth;
            break;
        }
        case SDDeckRightVisible: {
            frame.origin.x = -self.rightVisibleWidth;
            if (self.style == SDDeckMultipleActive)
            {
                frame.origin.x = 0.0f;
                frame.size.width = self.view.bounds.size.width - self.rightVisibleWidth;
            }
            break;
        }
    }
    _centerDeckRestingFrame = frame;
    return _centerDeckRestingFrame;
}

- (CGFloat)leftVisibleWidth
{
    if (self.centerDeckHidden && self.shouldResizeLeftDeck)
        return self.view.bounds.size.width;
    else
        return self.leftFixedWidth ? self.leftFixedWidth : floorf(self.view.bounds.size.width * self.leftGapPercentage);
}

- (CGFloat)rightVisibleWidth
{
    if (self.centerDeckHidden && self.shouldResizeRightDeck)
        return self.view.bounds.size.width;
    else
        return self.rightFixedWidth ? self.rightFixedWidth : floor(self.view.bounds.size.width * self.rightGapPercentage);
}

#pragma mark - Showing Decks

- (void)_showLeftDeck:(BOOL)animated bounce:(BOOL)shouldBounce
{
    self.state = SDDeckLeftVisible;
    [self _loadLeftDeck];
    
    [self _adjustCenterFrame];
    
    if (animated)
        [self _animateCenterDeck:shouldBounce completion:nil];
    else
    {
        self.centerDeckContainer.frame = _centerDeckRestingFrame;
        [self styleContainer:self.centerDeckContainer animate:NO duration:0.0f];
        if (self.style == SDDeckMultipleActive)
            [self _layoutSideContainers:NO duration:0.0f];
    }
    
    if (self.style == SDDeckSingleActive)
        self.tapView = [[UIView alloc] init];
    [self _toggleScrollsToTopForCenter:NO left:YES right:NO];
}

- (void)_showRightDeck:(BOOL)animated bounce:(BOOL)shouldBounce completion:(void (^)(BOOL finished))completion
{
    self.state = SDDeckRightVisible;
    [self _loadRightDeck];
    
    [self _adjustCenterFrame];
    
    if (animated)
        [self _animateCenterDeck:shouldBounce completion:completion];
    else
    {
        self.centerDeckContainer.frame = _centerDeckRestingFrame;
        [self styleContainer:self.centerDeckContainer animate:NO duration:0.0f];
        if (self.style == SDDeckMultipleActive)
            [self _layoutSideContainers:NO duration:0.0f];
    }
    
    if (self.style == SDDeckSingleActive)
        self.tapView = [[UIView alloc] init];
    [self _toggleScrollsToTopForCenter:NO left:NO right:YES];
}

- (void)_showCenterDeck:(BOOL)animated bounce:(BOOL)shouldBounce
{
    self.state = SDDeckCenterVisible;
    
    [self _adjustCenterFrame];
    
    if (animated)
    {
        [self _animateCenterDeck:shouldBounce completion:^(__unused BOOL finished) {
            self.leftDeckContainer.hidden = YES;
            self.rightDeckContainer.hidden = YES;
            [self _unloadDecks];
        }];
    }
    else
    {
        self.centerDeckContainer.frame = _centerDeckRestingFrame;
        [self styleContainer:self.centerDeckContainer animate:NO duration:0.0f];
        if (self.style == SDDeckMultipleActive)
            [self _layoutSideContainers:NO duration:0.0f];
        self.leftDeckContainer.hidden = YES;
        self.rightDeckContainer.hidden = YES;
        [self _unloadDecks];
    }
    
    self.tapView = nil;
    [self _toggleScrollsToTopForCenter:YES left:NO right:NO];
}

- (void)_hideCenterDeck
{
    self.centerDeckContainer.hidden = YES;
    if (self.centerDeck.isViewLoaded)
        [self.centerDeck.view removeFromSuperview];
}

- (void)_unhideCenterDeck
{
    self.centerDeckContainer.hidden = NO;
    if (!self.centerDeck.view.superview)
    {
        self.centerDeck.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.centerDeck.view.frame = self.centerDeckContainer.bounds;
        [self styleDeck:self.centerDeck.view];
        [self.centerDeckContainer addSubview:self.centerDeck.view];
    }
}

- (void)_toggleScrollsToTopForCenter:(BOOL)center left:(BOOL)left right:(BOOL)right
{
    // iPhone only supports 1 active UIScrollViewController at a time
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [self _toggleScrollsToTop:center forView:self.centerDeckContainer];
        [self _toggleScrollsToTop:left forView:self.leftDeckContainer];
        [self _toggleScrollsToTop:right forView:self.rightDeckContainer];
    }
}

- (BOOL)_toggleScrollsToTop:(BOOL)enabled forView:(UIView *)view
{
    if ([view isKindOfClass:[UIScrollView class]])
    {
        UIScrollView *scrollView = (UIScrollView *) view;
        scrollView.scrollsToTop = enabled;
        return YES;
    }
    else
    {
        for (UIView *subview in view.subviews)
            if ([self _toggleScrollsToTop:enabled forView:subview])
                return YES;
        
    }
    return NO;
}

#pragma mark - Key Value Observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(__unused NSDictionary *)change context:(void *)context
{
    if (context == &wmdeck_kvoContext)
    {
        if ([keyPath isEqualToString:@"view"])
        {
            if (self.centerDeck.isViewLoaded && self.recognizesPanGesture)
                [self _addPanGestureToView:self.centerDeck.view];
        }
        else if ([keyPath isEqualToString:@"viewControllers"] && object == self.centerDeck)
            // view controllers have changed, need to replace the button
            [self _placeButtonForLeftDeck];
    }
    else
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

#pragma mark - Public Methods

- (UIBarButtonItem *)leftButtonForCenterDeck
{
    return [[UIBarButtonItem alloc] initWithImage:[[self class] defaultImage] style:UIBarButtonItemStylePlain target:self action:@selector(toggleLeftDeck:)];
}

- (void)showLeftDeck:(BOOL)animated
{
    [self _showLeftDeck:animated bounce:NO];
}

- (void)showRightDeck:(BOOL)animated
{
	[self showRightDeck:animated completion:nil];
}

- (void)showRightDeck:(BOOL)animated completion:(void (^)(BOOL finished))completion
{
    [self _showRightDeck:animated bounce:NO completion:completion];
}

- (void)showCenterDeck:(BOOL)animated
{
    // make sure center Deck isn't hidden
    if (_centerDeckHidden)
    {
        _centerDeckHidden = NO;
        [self _unhideCenterDeck];
    }
    [self _showCenterDeck:animated bounce:NO];
}

- (void)toggleLeftDeck:(__unused id)sender
{
    if (self.state == SDDeckLeftVisible)
        [self _showCenterDeck:YES bounce:NO];
    else if (self.state == SDDeckCenterVisible)
        [self _showLeftDeck:YES bounce:NO];
}

- (void)toggleRightDeck:(__unused id)sender
{
    if (self.state == SDDeckRightVisible)
        [self _showCenterDeck:YES bounce:NO];
    else if (self.state == SDDeckCenterVisible)
        [self _showRightDeck:YES bounce:NO completion:nil];
}

- (void)setCenterDeckHidden:(BOOL)centerDeckHidden
{
    [self setCenterDeckHidden:centerDeckHidden animated:NO duration:0.0];
}

- (void)setCenterDeckHidden:(BOOL)centerDeckHidden animated:(BOOL)animated duration:(NSTimeInterval)duration
{
    if (centerDeckHidden != _centerDeckHidden && self.state != SDDeckCenterVisible)
    {
        _centerDeckHidden = centerDeckHidden;
        duration = animated ? duration : 0.0f;
        if (centerDeckHidden)
        {
            [UIView animateWithDuration:duration animations:^{
                CGRect frame = self.centerDeckContainer.frame;
                frame.origin.x = self.state == SDDeckLeftVisible ? self.centerDeckContainer.frame.size.width : -self.centerDeckContainer.frame.size.width;
                self.centerDeckContainer.frame = frame;
                if (self.shouldResizeLeftDeck || self.shouldResizeRightDeck)
                    [self _layoutSideDecks];
            } completion:^(__unused BOOL finished) {
                // need to double check in case the user tapped really fast
                if (_centerDeckHidden)
                    [self _hideCenterDeck];
            }];
        }
        else
        {
            [self _unhideCenterDeck];
            [UIView animateWithDuration:duration animations:^{
                if (self.state == SDDeckLeftVisible)
                    [self showLeftDeck:NO];
                else
                    [self showRightDeck:NO];
                if (self.shouldResizeLeftDeck || self.shouldResizeRightDeck)
                    [self _layoutSideDecks];
            }];
        }
    }
}

- (void)shuffleDeck
{
    NSAssert(0 == 1, @"Come on joker.. get out of here!");
}

@end
