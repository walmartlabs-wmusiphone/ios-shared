//
//  SDPullNavigationBar.m
//  ios-shared
//
//  Created by Brandon Sneed on 08/06/2013.
//  Copyright 2013-2014 SetDirection. All rights reserved.
//

#import "SDPullNavigationBar.h"

#import "SDPullNavigationBarAdornmentView.h"
#import "SDPullNavigationBarBackground.h"
#import "SDPullNavigationBarTabButton.h"
#import "SDPullNavigationManager.h"
#import "UIDevice+machine.h"
#import "UIColor+SDExtensions.h"
#import "UIImage+SDExtensions.h"
#import "NSString+SDExtensions.h"

static const CGFloat kDefaultMenuWidth = 320.0f;
static const CGFloat kDefaultMenuHeightBuffer = 44.0f;  // Keeps the bottom of the menu from getting too close to the bottom of the screen
static const CGFloat kDrawerBounceHeight = 85.0f;
static const CGFloat kDrawerTopExtension = 50.0f; // keeps the menu from disconnecting from the nav bar
static const CGFloat kDrawerExpandAnimationDuration = 0.55f;
static const CGFloat kDrawerCollapseAnimationDuration = 0.4f;
static const CGFloat kDrawerAnimationDampening = 0.75f;
static const CGFloat kDrawerExpandAnimationVelocity = 1;
static const CGFloat kDrawerCollapseAnimationVelocity = 5;

static NSCache* sMenuAdornmentImageCache = nil;

typedef NS_ENUM(NSInteger, SDPullNavigationStateEndAction)
{
    SDPullNavigationStateEndNone,
    SDPullNavigationStateEndExpand,
    SDPullNavigationStateEndCollapse
};

typedef NS_ENUM(NSInteger, SDPullNavigationViewTag)
{
    SDPullNavigationNavBarBackgroundViewTag  = 1,
    SDPullNavigationTabButtonViewTag         = 2,
    SDPullNavigationMenuContainerViewTag     = 3,
    SDPullNavigationClientViewTag            = 4,
    SDPullNavigationBackgroundEffectsViewTag = 5,
    SDPullNavigationAdornmentView            = 6
};

typedef struct
{
    CGPoint initialTouchPoint;
    CGPoint currentTouchPoint;
    CGFloat maxMenuY;
    CGFloat minMenuY;
    CGFloat velocity;
    BOOL    isInteracting;
} SDMenuControllerInteractionFlags;

@interface SDPullNavigationMenuContainer : UIView   // This custom class used for debugging purposes.
@end

#pragma mark - SDPullNavigationBar

@interface SDPullNavigationBar()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) SDPullNavigationBarBackground* navbarBackgroundView;
@property (nonatomic, strong) SDPullNavigationBarTabButton* tabButton;
@property (nonatomic, strong) SDPullNavigationMenuContainer* menuContainer;
@property (nonatomic, strong) UIView* backgroundEffectsView;
@property (nonatomic, strong) SDPullNavigationBarAdornmentView* menuBottomAdornmentView;
@property (nonatomic, assign) CGFloat menuAdornmentImageOverlapHeight;
@property (nonatomic, assign) BOOL animating;
@property (nonatomic, assign) BOOL menuOpen;
@property (nonatomic, assign) CGFloat menuWidthForPortrait;
@property (nonatomic, assign) CGFloat menuWidthForLandscape;
@property (nonatomic, assign) CGFloat menuWidthForCurrentOrientation;
@property (nonatomic, assign) Class backgroundViewClass;
@property (nonatomic, strong, readwrite) UIPanGestureRecognizer* revealPanGestureRecognizer;
@property (nonatomic, strong, readwrite) UIPanGestureRecognizer* dismissPanGestureRecognizer;
@property (nonatomic, assign, readwrite) SDMenuControllerInteractionFlags menuInteraction;
@property (nonatomic, assign) BOOL showAdornment;

@property (nonatomic, assign) BOOL implementsWillAppear;
@property (nonatomic, assign) BOOL implementsDidAppear;
@property (nonatomic, assign) BOOL implementsWillDisappear;
@property (nonatomic, assign) BOOL implementsDidDisappear;

@property (nonatomic, assign) BOOL implementsMenuWidth;
@property (nonatomic, assign) BOOL implementsMenuWidthForOrientations;
@property (nonatomic, assign) BOOL implementsBackgroundViewClass;
@property (nonatomic, assign) BOOL implementsLightboxEffectColor;
@property (nonatomic, assign) BOOL implementsTopExtensionBackgroundColor;

@end

@implementation SDPullNavigationBar

+ (void)setupDefaults
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];

    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(-9999, -9999) forBarMetrics:UIBarMetricsDefault];

    SDPullNavigationBar* pullBarAppearance = [SDPullNavigationBar appearance];
    if ([UIDevice bcdSystemVersion] >= 0x070000)
    {
        pullBarAppearance.barTintColor = [UIColor colorWith8BitRed:29 green:106 blue:166 alpha:1.0f];
        pullBarAppearance.titleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor whiteColor] };
        pullBarAppearance.tintColor = [UIColor whiteColor];
    }
    else
    {
        pullBarAppearance.tintColor = [UIColor colorWith8BitRed:23 green:108 blue:172 alpha:1.0];
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self != nil)
    {
        self.translucent = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(statusBarWillChangeRotationNotification:)
                                                     name:UIApplicationWillChangeStatusBarOrientationNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(statusBarDidChangeRotationNotification:)
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification
                                                   object:nil];
    }

    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// Superview is known, start setting up our subviews.
- (void)willMoveToSuperview:(UIView*)newSuperview
{
    if(self.implementsAdornmentImages)
        self.showAdornment = YES;
    
    if(newSuperview && nil == self.menuContainer)
    {
        // I tagged all of the view to be able to find them quickly when I am viewing the hierarchy in Spark Inspector or Reveal.
        
        // This is a navBar overlay which we can use to change navBar visuals.
        {
            self.navbarBackgroundView = [[SDPullNavigationBarBackground alloc] init];
            self.navbarBackgroundView.autoresizesSubviews = YES;
            self.navbarBackgroundView.userInteractionEnabled = NO;
            self.navbarBackgroundView.opaque = NO;
            self.navbarBackgroundView.backgroundColor = [UIColor clearColor];
            self.navbarBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            self.navbarBackgroundView.delegate = (id<SDPullNavigationBarOverlayProtocol>)self;
            self.navbarBackgroundView.frame = self.bounds;
            self.navbarBackgroundView.tag = SDPullNavigationNavBarBackgroundViewTag;
        }
        
        // This is the hit area for showing the pulldown menu, as well as the area (at the bottom) where the nipple is shown.
        {
            Class tabBarButtonClass = [SDPullNavigationBarTabButton class];
            if([SDPullNavigationManager sharedInstance].pullNavigationBarTabButtonClass)
                tabBarButtonClass = [SDPullNavigationManager sharedInstance].pullNavigationBarTabButtonClass;
            
            self.tabButton = [[tabBarButtonClass alloc] initWithNavigationBar:self];
            self.tabButton.tag = SDPullNavigationTabButtonViewTag;
            
            if ([SDPullNavigationManager sharedInstance].navigationBarAccessibilityLabel) {
                self.tabButton.isAccessibilityElement = YES;
                self.tabButton.accessibilityTraits |= UIAccessibilityTraitButton;
                self.tabButton.accessibilityLabel = [SDPullNavigationManager sharedInstance].navigationBarAccessibilityLabel;
            }
            
            NSAssert([self.tabButton isKindOfClass:[SDPullNavigationBarTabButton class]], @"TabBarButton class must be derived from SDPullNavigationBarTabButton");
        }
        
        // The view that the client's menu lives in.
        {
            self.menuContainer = [[SDPullNavigationMenuContainer alloc] initWithFrame:newSuperview.bounds];
            self.menuContainer.clipsToBounds = YES;
            self.menuContainer.backgroundColor = [UIColor clearColor];
            self.menuContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            self.menuContainer.translatesAutoresizingMaskIntoConstraints = YES;
            self.menuContainer.opaque = NO;

            [self hideMenuContainer];
            
            if([SDPullNavigationManager sharedInstance].disableShadowOnMenuContainer == NO)
            {
                self.menuContainer.layer.shadowColor = [UIColor blackColor].CGColor;
                self.menuContainer.layer.shadowOffset = (CGSize){ 0.0f, -3.0f };
                self.menuContainer.layer.shadowRadius = 3.0f;
                self.menuContainer.layer.shadowOpacity = 1.0;
            }
            self.menuContainer.tag = SDPullNavigationMenuContainerViewTag;
        }
        
        // This is the client's controller for the menu.
        {
            UIStoryboard* menuStoryBoard = [UIStoryboard storyboardWithName:[SDPullNavigationManager sharedInstance].globalMenuStoryboardId bundle:nil];
            self.menuController = [menuStoryBoard instantiateInitialViewController];
            self.menuController.pullNavigationBarDelegate = self;
            
            [self setupProtocolHelpers];
            
            self.menuController.view.clipsToBounds = YES;
            self.menuController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            self.menuController.view.translatesAutoresizingMaskIntoConstraints = YES;
            self.menuController.view.tag = SDPullNavigationClientViewTag;
            
            CGFloat menuHeight = MIN(self.menuController.pullNavigationMenuHeight, self.availableHeight);
            self.menuController.view.frame = (CGRect){ {0, kDrawerTopExtension}, { self.menuWidthForCurrentOrientation, menuHeight } };
        }
        
        // View that darkens the views behind and to the side of the menu.
        {
            self.backgroundEffectsView = [[UIView alloc] initWithFrame:self.menuContainer.bounds];
            self.backgroundEffectsView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            self.backgroundEffectsView.clipsToBounds = YES;
            self.backgroundEffectsView.backgroundColor = [UIColor clearColor];
            self.backgroundEffectsView.opaque = NO;
            self.backgroundEffectsView.tag = SDPullNavigationBackgroundEffectsViewTag;
        }
        
        // The adornmentView should be the exact same size as the menuController's view, except for the area that hangs down below.
        // It should also be the menu controller's superview. That way we just animate the adornment view instead of both.
        // This is the little nubbin' at the bottom of the menu. Don't show this on iPhone, don't show this if client has not set the image.
        
        {
            self.menuAdornmentImageOverlapHeight = [SDPullNavigationManager sharedInstance].menuAdornmentImageOverlapHeight;
            
            CGFloat menuHeight = MIN(self.menuController.pullNavigationMenuHeight, self.availableHeight);
            CGRect frame = (CGRect){ { newSuperview.frame.size.width * 0.5f - self.menuWidthForCurrentOrientation * 0.5f, -(menuHeight - self.navigationBarHeight + kDrawerTopExtension + self.menuAdornmentImageOverlapHeight) },
                                     { self.menuWidthForCurrentOrientation, menuHeight + kDrawerTopExtension } };
            self.menuBottomAdornmentView = [[SDPullNavigationBarAdornmentView alloc] initWithFrame:frame];
            if(self.showAdornment)
                self.menuBottomAdornmentView.adornmentImage = self.adornmentImageForCurrentOrientation;
            if(self.implementsBackgroundViewClass)
                self.menuBottomAdornmentView.backgroundViewClass = self.backgroundViewClass;
            self.menuBottomAdornmentView.tag = SDPullNavigationAdornmentView;
            
            // This could also be inserted in negative coordinate space, but that would require SDPullNavigationBarAdornmentView
            // not to clip to bounds. It would be nicer to not include the extension in origin calculations everywhere
            UIView *menuAdornmentTopExtension = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, kDrawerTopExtension)];
            menuAdornmentTopExtension.backgroundColor = [self topExtensionBackgroundColor];
            [self.menuBottomAdornmentView addSubview:menuAdornmentTopExtension];
        }
        
        [self insertSubview:self.navbarBackgroundView atIndex:1];
        [self addSubview:self.tabButton];
        [self.menuBottomAdornmentView.containerView addSubview:self.menuController.view];
        [self.menuContainer addSubview:self.backgroundEffectsView];
        [self.menuContainer addSubview:self.menuBottomAdornmentView];
        [newSuperview insertSubview:self.menuContainer belowSubview:self];
        
        [self setupGestureRecognizers];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGFloat tabOffset = 8.0f;

    CGPoint navBarCenter = self.center;
    CGRect tabFrame = self.tabButton.frame;
    tabFrame.origin.x = (navBarCenter.x - (tabFrame.size.width * 0.5f));
    tabFrame.origin.y = self.bounds.size.height - (tabFrame.size.height - tabOffset);
    self.tabButton.frame = CGRectIntegral(tabFrame);
    
    [self addSubview:self.tabButton];
}

- (void)centerViewsToOrientation
{
    CGFloat menuHeight = MIN(self.menuController.pullNavigationMenuHeight, self.availableHeight);
    self.menuBottomAdornmentView.baseFrame = (CGRect){ { self.superview.frame.size.width * 0.5f - self.menuWidthForCurrentOrientation * 0.5f, -(menuHeight - self.navigationBarHeight + kDrawerTopExtension + self.menuAdornmentImageOverlapHeight) },
                                                       { self.menuWidthForCurrentOrientation, menuHeight + kDrawerTopExtension } };
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.navbarBackgroundView.frame = self.bounds;
}

- (void)setupGestureRecognizers
{
    UITapGestureRecognizer* openTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self.tabButton addGestureRecognizer:openTapGesture];

    self.revealPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didRecognizeRevealPanGesture:)];
    self.revealPanGestureRecognizer.maximumNumberOfTouches = 1;
    [self.tabButton addGestureRecognizer:self.revealPanGestureRecognizer];

    self.dismissPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didRecognizeDismissPanGesture:)];
    self.revealPanGestureRecognizer.maximumNumberOfTouches = 1;
    [self.menuBottomAdornmentView addGestureRecognizer:self.dismissPanGestureRecognizer];

    UITapGestureRecognizer* dismissTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissTapAction:)];
    dismissTapGesture.delegate = self;
    [self.menuContainer addGestureRecognizer:dismissTapGesture];
}

- (void)tapAction:(id)sender
{
    [self togglePullMenuWithCompletionBlock:nil];
}

// Check to see if our menuController implements the @optional methods.
// Set up flags and default values based on this.

- (void)setupProtocolHelpers
{
    self.implementsMenuWidth = [self.menuController respondsToSelector:@selector(pullNavigationMenuWidth)];
    self.implementsMenuWidthForOrientations = [self.menuController respondsToSelector:@selector(pullNavigationMenuWidthForPortrait)] &&
    [self.menuController respondsToSelector:@selector(pullNavigationMenuWidthForLandscape)];
    if(self.implementsMenuWidthForOrientations)
        self.implementsMenuWidth = NO;
    
    self.menuWidthForPortrait = self.menuWidthForLandscape = kDefaultMenuWidth;
    if(self.implementsMenuWidth)
    {
        self.menuWidthForPortrait = self.menuController.pullNavigationMenuWidth;
        self.menuWidthForLandscape = self.menuWidthForPortrait;
    }
    else if(self.implementsMenuWidthForOrientations)
    {
        self.menuWidthForPortrait = self.menuController.pullNavigationMenuWidthForPortrait;
        self.menuWidthForLandscape = self.menuController.pullNavigationMenuWidthForLandscape;
    }
    self.implementsBackgroundViewClass = [self.menuController respondsToSelector:@selector(pullNavigationMenuBackgroundViewClass)];
    if(self.implementsBackgroundViewClass)
        self.backgroundViewClass = self.menuController.pullNavigationMenuBackgroundViewClass;
    self.implementsLightboxEffectColor = [self.menuController respondsToSelector:@selector(pullNavigationLightboxEffectColor)];
    self.implementsTopExtensionBackgroundColor = [self.menuController respondsToSelector:@selector(pullNavigationMenuTopExtensionBackgroundColor)];
    self.implementsWillAppear = [self.menuController respondsToSelector:@selector(pullNavMenuWillAppear)];
    self.implementsDidAppear = [self.menuController respondsToSelector:@selector(pullNavMenuDidAppear)];
    self.implementsWillDisappear = [self.menuController respondsToSelector:@selector(pullNavMenuWillDisappear)];
    self.implementsDidDisappear = [self.menuController respondsToSelector:@selector(pullNavMenuDidDisappear)];
}

- (CGFloat)menuWidthForCurrentOrientation
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    return UIInterfaceOrientationIsPortrait(orientation) ? self.menuWidthForPortrait : self.menuWidthForLandscape;
}

#pragma mark - Gesture Handling

- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldReceiveTouch:(UITouch*)touch
{
    return ![touch.view isDescendantOfView:self.menuController.view];
}

- (void)dismissTapAction:(UITapGestureRecognizer*)sender
{
    if(self.menuOpen)
        [self dismissPullMenuWithCompletionBlock:nil];
}

- (void)didRecognizeRevealPanGesture:(UIPanGestureRecognizer*)recognizer
{
    switch(recognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            [self centerViewsToOrientation];

            self.tabButton.tuckedTab = !self.menuOpen;
            [self.tabButton setNeedsDisplay];

            [self.superview insertSubview:self.menuContainer belowSubview:self];

            _menuInteraction.initialTouchPoint = [recognizer translationInView:self];
            _menuInteraction.isInteracting = YES;
            _menuInteraction.velocity = 0.0f;
            _menuInteraction.minMenuY = -(MIN(self.menuController.pullNavigationMenuHeight, self.availableHeight) - self.navigationBarHeight + kDrawerTopExtension + self.menuAdornmentImageOverlapHeight);
            _menuInteraction.maxMenuY = self.navigationBarHeight - kDrawerTopExtension;

            [recognizer setTranslation:CGPointZero inView:self];

            [self showMenuContainer];
            [self showBackgroundEffectWithAnimation:YES completion:nil];
            break;
        }

        case UIGestureRecognizerStateChanged:
        {
            _menuInteraction.currentTouchPoint = [recognizer translationInView:self];

            // Peg to the top value
            CGFloat newY = MIN(_menuInteraction.minMenuY + _menuInteraction.initialTouchPoint.y + _menuInteraction.currentTouchPoint.y, _menuInteraction.maxMenuY);
            
            // Peg to the bottom value.
            newY = MAX(newY, _menuInteraction.minMenuY);

            self.menuBottomAdornmentView.baseFrame = (CGRect){ { self.menuBottomAdornmentView.baseFrame.origin.x, newY }, self.menuBottomAdornmentView.baseFrame.size };
            break;
        }

        case UIGestureRecognizerStateEnded:
        {
            _menuInteraction.velocity = [recognizer velocityInView:self].y;

            [UIView animateWithDuration:(self.menuOpen ? kDrawerCollapseAnimationDuration : kDrawerExpandAnimationDuration)
                                  delay:0
                 usingSpringWithDamping:kDrawerAnimationDampening
                  initialSpringVelocity:(self.menuOpen ? kDrawerCollapseAnimationVelocity : kDrawerExpandAnimationVelocity)
                                options:UIViewAnimationOptionBeginFromCurrentState
                             animations:^
            {
                SDPullNavigationStateEndAction action = SDPullNavigationStateEndNone;

                if(fabs(_menuInteraction.velocity) < 100.0f)
                {
                    // Slow drag

                    CGFloat panArea = fabs(_menuInteraction.maxMenuY - _menuInteraction.minMenuY);
                    CGFloat yPositionInPanArea = fabs(_menuInteraction.currentTouchPoint.y - _menuInteraction.initialTouchPoint.y);
                    if(_menuInteraction.velocity < 0.0f)
                    {
                        action = yPositionInPanArea < panArea * 0.66f ? SDPullNavigationStateEndCollapse : SDPullNavigationStateEndExpand;
                    }
                    else
                    {
                        action = yPositionInPanArea < panArea * 0.33f ? SDPullNavigationStateEndCollapse : SDPullNavigationStateEndExpand;
                    }
                }
                else
                {
                    // Fast drag

                    action = _menuInteraction.velocity < 0.0f ? SDPullNavigationStateEndCollapse : SDPullNavigationStateEndExpand;
                }

                if(action == SDPullNavigationStateEndExpand)    [self expandMenu];
                if(action == SDPullNavigationStateEndCollapse)  [self collapseMenuWithCompletion:^{ [self hideMenuContainer]; }];
            }
            completion:^(BOOL finished)
            {
                if(self.menuOpen == NO)
                {
                    self.tabButton.tuckedTab = NO;
                    [self.tabButton setNeedsDisplay];
                }
            }];

            // Falling through on purpose...
        }

        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        default:
        {
            _menuInteraction.isInteracting = NO;
            break;
        }
    }
}

- (void)didRecognizeDismissPanGesture:(UIPanGestureRecognizer*)recognizer
{
    switch(recognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            [self centerViewsToOrientation];
            
            _menuInteraction.initialTouchPoint = [recognizer translationInView:self];
            _menuInteraction.isInteracting = YES;
            _menuInteraction.velocity = 0.0f;
            _menuInteraction.minMenuY = self.navigationBarHeight - kDrawerTopExtension;
            _menuInteraction.maxMenuY = -(MIN(self.menuController.pullNavigationMenuHeight, self.availableHeight) - self.navigationBarHeight + kDrawerTopExtension + self.menuAdornmentImageOverlapHeight);

            self.menuBottomAdornmentView.baseFrame = (CGRect){ { self.menuBottomAdornmentView.frame.origin.x, _menuInteraction.minMenuY }, self.menuBottomAdornmentView.baseFrame.size };

            [recognizer setTranslation:CGPointZero inView:self];
            break;
        }
            
        case UIGestureRecognizerStateChanged:
        {
            _menuInteraction.currentTouchPoint = [recognizer translationInView:self];

            // Peg to the top value
            CGFloat newY = MAX(_menuInteraction.minMenuY - _menuInteraction.initialTouchPoint.y + _menuInteraction.currentTouchPoint.y, _menuInteraction.maxMenuY);

            // Peg to the bottom value.
            newY = MIN(newY, _menuInteraction.minMenuY);

            self.menuBottomAdornmentView.baseFrame = (CGRect){ { self.menuBottomAdornmentView.baseFrame.origin.x, newY }, self.menuBottomAdornmentView.baseFrame.size };
            break;
        }
            
        case UIGestureRecognizerStateEnded:
        {
            _menuInteraction.velocity = [recognizer velocityInView:self].y;

            [UIView animateWithDuration:(self.menuOpen ? kDrawerCollapseAnimationDuration : kDrawerExpandAnimationDuration)
                                  delay:0
                 usingSpringWithDamping:kDrawerAnimationDampening
                  initialSpringVelocity:(self.menuOpen ? kDrawerCollapseAnimationVelocity : kDrawerExpandAnimationVelocity)
                                options:UIViewAnimationOptionBeginFromCurrentState
                             animations:^
            {
                SDPullNavigationStateEndAction action = SDPullNavigationStateEndNone;

                if(fabs(_menuInteraction.velocity) < 100.0f)
                {
                    // Slow drag

                    CGFloat panArea = fabs(_menuInteraction.maxMenuY - _menuInteraction.minMenuY);
                    CGFloat yPositionInPanArea = fabs(_menuInteraction.currentTouchPoint.y - _menuInteraction.initialTouchPoint.y);
                    if(_menuInteraction.velocity < 0)
                    {
                        action = yPositionInPanArea < panArea * 0.66f ? SDPullNavigationStateEndExpand : SDPullNavigationStateEndCollapse;
                    }
                    else
                    {
                        action = yPositionInPanArea < panArea * 0.33f ? SDPullNavigationStateEndExpand : SDPullNavigationStateEndCollapse;
                    }
                }
                else
                {
                    // Fast drag
                    
                    action = _menuInteraction.velocity < 0 ? SDPullNavigationStateEndCollapse : SDPullNavigationStateEndExpand;
                }

                if(action == SDPullNavigationStateEndExpand)    [self expandMenu];
                if(action == SDPullNavigationStateEndCollapse)  [self collapseMenuWithCompletion:^{ [self hideMenuContainer]; }];
            }
            completion:^(BOOL finished)
            {
                if(self.menuOpen == NO)
                {
                    self.tabButton.tuckedTab = NO;
                    [self.tabButton setNeedsDisplay];
                }
            }];

            // Falling through on purpose...
        }

        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        default:
        {
            _menuInteraction.isInteracting = NO;
            break;
        }
    }
}

#pragma mark - Helpers

- (void)togglePullMenuWithCompletionBlock:(void (^)(void))completion
{
    if(!self.animating)
    {
        self.animating = YES;

        [self.superview insertSubview:self.menuContainer belowSubview:self];
        [self showMenuContainer];
        
        if (!self.menuOpen) {
            [self centerViewsToOrientation];
        }

        [UIView animateWithDuration:(self.menuOpen ? kDrawerCollapseAnimationDuration : kDrawerExpandAnimationDuration)
                              delay:0
             usingSpringWithDamping:kDrawerAnimationDampening
              initialSpringVelocity:(self.menuOpen ? kDrawerCollapseAnimationVelocity : kDrawerExpandAnimationVelocity)
                            options:0
                         animations:^{
            if(self.menuOpen)
                [self collapseMenu];
            else
                [self expandMenu];
        } completion:^(BOOL finished) {
            self.animating = NO;
            
            [self.tabButton setNeedsDisplay];
            
            if(completion)
                completion();
            
            // If we just finished our collapse, tell the controller now
            if(!self.menuOpen)
            {
                [self hideMenuContainer];
                [self notifyPullNavMenuDidDisappear];
            }

        }];
    }
    else
    {
        // Don't forget that if we did not need to dismiss the menu, then we should still call the completion block.
        if(completion)
            completion();
    }
}

- (void)notifyPullNavMenuWillAppear
{
    if(self.implementsWillAppear)
        [self.menuController pullNavMenuWillAppear];
    [self.menuBottomAdornmentView pullNavigationMenuWillAppear];
}

- (void)notifyPullNavMenuDidAppear
{
    if(self.implementsDidAppear)
        [self.menuController pullNavMenuDidAppear];
}

- (void)notifyPullNavMenuWillDisappear
{
    if(self.implementsWillDisappear)
        [self.menuController pullNavMenuWillDisappear];
}

- (void)notifyPullNavMenuDidDisappear
{
    if(self.implementsDidDisappear)
        [self.menuController pullNavMenuDidDisappear];
    [self.menuBottomAdornmentView pullNavigationMenuDidDisappear];
}

- (void)bouncePullMenuWithCompletion:(void (^)(void))completion
{
    if (self.menuOpen || self.animating || _menuInteraction.isInteracting)
    {
        return;
    }
    self.userInteractionEnabled = NO;
    [self centerViewsToOrientation];

    [UIView animateWithDuration:0.45f delay:0.0f usingSpringWithDamping:0.99f initialSpringVelocity:10.0f options:0 animations:^{
        [self.superview insertSubview:self.menuContainer belowSubview:self];
        [self showMenuContainer];
        self.tabButton.tuckedTab = YES;
        [self.tabButton setNeedsDisplay];
        CGRect f = self.menuBottomAdornmentView.frame;
        f.origin.y += kDrawerBounceHeight;
        self.menuBottomAdornmentView.frame = f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3f delay:0.1f usingSpringWithDamping:0.8f initialSpringVelocity:8.0f options:0 animations:^{
            CGRect f = self.menuBottomAdornmentView.frame;
            f.origin.y -= kDrawerBounceHeight;
            self.menuBottomAdornmentView.frame = f;
            self.tabButton.tuckedTab = NO;
        } completion:^(BOOL secondFinished) {
            [self.tabButton setNeedsDisplay];
            [self.menuContainer removeFromSuperview];
            self.userInteractionEnabled = YES;
            if (completion != NULL)
            {
                completion();
            }
        }];
    }];
}
- (void)expandMenu
{
    [self notifyPullNavMenuWillAppear];

    [self centerViewsToOrientation];

    [self showBackgroundEffectWithAnimation:NO completion:nil];

    self.tabButton.tuckedTab = YES;
    [self.tabButton setNeedsDisplay];   // During expand, hide the tab now

    self.menuBottomAdornmentView.baseFrame = (CGRect){ { self.menuBottomAdornmentView.frame.origin.x, self.navigationBarHeight - kDrawerTopExtension }, self.menuBottomAdornmentView.baseFrame.size };

    self.menuOpen = YES;

    [self notifyPullNavMenuDidAppear];
}

- (void)collapseMenu
{
    [self notifyPullNavMenuWillDisappear];

    [self collapseMenuWithCompletion:^
    {
        // If we're animating, then firing did disappear here is a lie. Hold
        //  off until we're actually done animating.
        if(!self.animating)
            [self notifyPullNavMenuDidDisappear];
    }];
}

- (void)collapseMenuWithCompletion:(void (^)(void))completion
{
    [self hideBackgroundEffectWithAnimation:!self.animating completion:completion];
    
    self.tabButton.tuckedTab = NO;  // During collapse, hide the tab at animation completion (hence no setNeedsDisplay).
    
    CGFloat menuPositionY = -(MIN(self.menuController.pullNavigationMenuHeight, self.availableHeight) - self.navigationBarHeight + self.menuAdornmentImageOverlapHeight + kDrawerTopExtension);
    self.menuBottomAdornmentView.baseFrame = (CGRect){ { self.menuBottomAdornmentView.frame.origin.x, menuPositionY }, self.menuBottomAdornmentView.baseFrame.size };

    self.menuOpen = NO;
}

- (void)showMenuContainer
{
    // Using alpha instead of hidden fixes a bug that is only evident on the iPad 3.
    // The menu container would remain visible even when hidden.
    self.menuContainer.alpha = 1;
}

- (void)hideMenuContainer
{
    // Using alpha instead of hidden fixes a bug that is only evident on the iPad 3.
    // The menu container would remain visible even when hidden.
    self.menuContainer.alpha = 0;
}

- (void)showBackgroundEffectWithAnimation:(BOOL)animate completion:(void (^)(void))completion
{
    if(animate)
    {
        [UIView animateWithDuration:(self.menuOpen ? kDrawerCollapseAnimationDuration : kDrawerExpandAnimationDuration)
                              delay:0
             usingSpringWithDamping:kDrawerAnimationDampening
              initialSpringVelocity:kDrawerExpandAnimationVelocity
                            options:0
                         animations:^
        {
            self.backgroundEffectsView.backgroundColor = [self backgroundEffectsBackgroundColor];
        }
        completion:^(BOOL finished)
        {
            if(completion)
                completion();
        }];
    }
    else
    {
        self.backgroundEffectsView.backgroundColor = [self backgroundEffectsBackgroundColor];
        if(completion)
            completion();
    }
}

- (UIColor *) backgroundEffectsBackgroundColor
{
    UIColor *backgroundColor = [@"#00000033" uicolor];
    
    if(self.implementsLightboxEffectColor)
    {
        backgroundColor = [self.menuController pullNavigationLightboxEffectColor];
    }
    
    return backgroundColor;
}

- (UIColor *) topExtensionBackgroundColor {
    UIColor *extensionColor = [UIColor whiteColor];
    if (self.implementsTopExtensionBackgroundColor) {
        extensionColor = [self.menuController pullNavigationMenuTopExtensionBackgroundColor];
    }
    return extensionColor;
}

- (void)hideBackgroundEffectWithAnimation:(BOOL)animate completion:(void (^)(void))completion
{
    if(animate)
    {
        [UIView animateWithDuration:(self.menuOpen ? kDrawerCollapseAnimationDuration : kDrawerExpandAnimationDuration)
                              delay:0
             usingSpringWithDamping:kDrawerAnimationDampening
              initialSpringVelocity:kDrawerCollapseAnimationVelocity
                            options:0
                         animations:^
        {
             self.backgroundEffectsView.backgroundColor = [UIColor clearColor];
        }
        completion:^(BOOL finished)
        {
            if(completion)
                completion();
        }];
    }
    else
    {
        self.backgroundEffectsView.backgroundColor = [UIColor clearColor];
        if(completion)
            completion();
    }
}

+ (UINavigationController*)navControllerWithViewController:(UIViewController*)viewController
{
    UINavigationController* navController = [[UINavigationController alloc] initWithNavigationBarClass:[self class] toolbarClass:nil];
    [navController setViewControllers:@[viewController]];
    navController.delegate = [SDPullNavigationManager sharedInstance];
    return navController;
}

- (void)statusBarWillChangeRotationNotification:(NSNotification*)notification
{
    [self hideMenuContainer];
    [self collapseMenu];
    [self.tabButton setNeedsDisplay];
}

- (void)statusBarDidChangeRotationNotification:(NSNotification*)notification
{
    if(self.implementsMenuWidthForOrientations)
    {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        CGSize menuSize = (CGSize){ UIInterfaceOrientationIsPortrait(orientation) ? self.menuWidthForPortrait : self.menuWidthForLandscape,
                                    MIN(self.menuController.pullNavigationMenuHeight, self.availableHeight) };
        self.menuBottomAdornmentView.adornmentImage = [self adornmentImageForOrientation:orientation];
        self.menuBottomAdornmentView.baseFrame = (CGRect){ { self.superview.frame.size.width * 0.5f - menuSize.width * 0.5f, -(menuSize.height - self.navigationBarHeight) }, menuSize };
    }
}

- (void)dismissPullMenuWithCompletionBlock:(void (^)(void))completion
{
    if(self.menuOpen)
    {
        [self togglePullMenuWithCompletionBlock:completion];
    }
}

- (CGFloat)availableHeight
{
    static CGFloat sBottomSafetyGap = 2.0f;

    // Check to see what kind of gap between the bottom of the screen the client wants. Default to 44.0f
    // Should not do this for iPad. Not going to work out well with the bottom of the screen.

    if(sBottomSafetyGap == 2.0f)
    {
        if([UIDevice iPad])
        {
            sBottomSafetyGap = MAX([SDPullNavigationManager sharedInstance].menuAdornmentBottomGap, kDefaultMenuHeightBuffer);
        }
        else {
            sBottomSafetyGap = MAX([SDPullNavigationManager sharedInstance].menuAdornmentBottomGap, sBottomSafetyGap);
        }
    }

    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    UIWindow *topMostWindow = self.window;
    if ( topMostWindow == nil )
    {
        topMostWindow = [UIApplication sharedApplication].windows.lastObject;
    }

    CGSize topMostWindowSize = topMostWindow.bounds.size;
    CGFloat height = UIInterfaceOrientationIsPortrait(orientation) ? MAX(topMostWindowSize.height, topMostWindowSize.width) : MIN(topMostWindowSize.height, topMostWindowSize.width);

    CGFloat navHeight = self.navigationBarHeight;
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
    {
        navHeight += MIN([UIApplication sharedApplication].statusBarFrame.size.height, [UIApplication sharedApplication].statusBarFrame.size.width);
    }

    // Take into account the menuAdornment at the bottom of the menu and some extra so that the adornment does not butt up against the bottom of the screen.
    if(self.showAdornment)
        navHeight += self.adornmentImageForCurrentOrientation.size.height + sBottomSafetyGap;

    return height - navHeight;
}

- (CGFloat)navigationBarHeight
{
    CGFloat navHeight = self.frame.size.height;
    
    if(navHeight == 0.0f)
        navHeight += 44.0f;

    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        navHeight += MIN([UIApplication sharedApplication].statusBarFrame.size.height, [UIApplication sharedApplication].statusBarFrame.size.width);
    }

    return navHeight;
}

- (UIImage*)adornmentImageForCurrentOrientation
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    return [self adornmentImageForOrientation:orientation];
}

- (void)clearAdornmentImageCache
{
    [sMenuAdornmentImageCache removeAllObjects];
}

- (BOOL)implementsAdornmentImages
{
    BOOL supportsAdornmentImages = NO;

    if([SDPullNavigationManager sharedInstance].menuAdornmentImageStretch && [SDPullNavigationManager sharedInstance].menuAdornmentImageCenter)
    {
        // Supports adornment images through composition.

        supportsAdornmentImages = YES;
    }
    else
    {
        // Supports simple adornment images.

        supportsAdornmentImages = [SDPullNavigationManager sharedInstance].menuAdornmentImage != nil;
    }

    return supportsAdornmentImages;
}

- (UIImage*)adornmentImageForOrientation:(UIInterfaceOrientation)orientation
{
    if(sMenuAdornmentImageCache == nil)
    {
        sMenuAdornmentImageCache = [[NSCache alloc] init];
        sMenuAdornmentImageCache.name = @"bottom-adornment-image-cache";
    }

    // We don't need an image per orientation, just the two different ones. Take these two as representatives.
    if(UIInterfaceOrientationIsPortrait(orientation))
        orientation = UIInterfaceOrientationPortrait;
    else
        orientation = UIInterfaceOrientationLandscapeLeft;

    UIImage* cachedImage = [sMenuAdornmentImageCache objectForKey:@(orientation)];

    // If we don't have an entry for that orientation. Make one and cache it, then return that newly made one.

    if(cachedImage == nil)
    {
        // If we have all of the 3 part images, then use those to make and cache, otherwise use the one size fits all version.

        if([SDPullNavigationManager sharedInstance].menuAdornmentImageStretch && [SDPullNavigationManager sharedInstance].menuAdornmentImageCenter)
        {
            UIImage* stretchImage = [SDPullNavigationManager sharedInstance].menuAdornmentImageStretch;
            UIImage* tabImage = [SDPullNavigationManager sharedInstance].menuAdornmentImageCenter;
            CGFloat width = self.menuWidthForCurrentOrientation;

            cachedImage = [UIImage stretchImage:stretchImage
                                         toSize:(CGSize){ width, stretchImage.size.height }
                                andOverlayImage:tabImage
                                    withOptions:[SDPullNavigationManager sharedInstance].menuAdornmentImageCompositionOptions];
        }
        else
        {
            cachedImage = [SDPullNavigationManager sharedInstance].menuAdornmentImage;
        }

        [sMenuAdornmentImageCache setObject:cachedImage forKey:@(orientation)];
    }

    return cachedImage;
}

#pragma mark - Hit testing

// If user taps in any of my subviews, dismiss the menu. Let the normal events go on as they are wont to do.

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent*)event
{
    UIView* hitView = [super hitTest:point withEvent:event];
    
    if([hitView isDescendantOfView:self])
        [self dismissPullMenuWithCompletionBlock:nil];
    
    return hitView;
}

@end

@implementation SDPullNavigationMenuContainer

#ifdef DEBUG

- (void)layoutSubviews
{
    [super layoutSubviews];

}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
}

#endif

@end
