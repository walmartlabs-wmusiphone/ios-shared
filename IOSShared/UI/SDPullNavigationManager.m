//
//  SDPullNavigationManager.m
//  ios-shared

//
//  Created by Steven Woolgar on 12/05/2013.
//  Copyright 2013-2014 SetDirection. All rights reserved.
//

#import "SDPullNavigationManager.h"

#import "NSObject+SDExtensions.h"
#import "SDPullNavigationBarControlsView.h"
#import "SDPullNavigationAutomation.h"
#import "UIViewController+SDExtensions.h"
#import "UIDevice+machine.h"

@interface SDPullNavigationManager()

@end

@implementation SDPullNavigationManager

+ (instancetype)sharedInstance
{
    static SDPullNavigationManager* sPullNavigationManager = nil;
    static dispatch_once_t sOnceToken;

    dispatch_once( &sOnceToken, ^
    {
        sPullNavigationManager = [[[self class] alloc] init];
    });

    return sPullNavigationManager;
}

// Create the views that we will be forcing into every single viewController's navigationItem.

- (instancetype)init
{
    self = [super init];
    if(self != nil)
    {
        _showGlobalNavControls = YES;
        
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

- (void)setDelegate:(id)delegate
{
    if(delegate)
    {
        _globalPullNavController = [delegate setupGlobalContainerViewController];
        _delegate = delegate;
    }
    else
    {
        _globalPullNavController = nil;
        _delegate = nil;
    }
}

// Called when the navigation controller shows a new top view controller via a push, pop or setting of the view controller stack.
// This is a great time to nerf what the viewController navigationItem will be displaying in the navigationBar.

- (void)navigationController:(UINavigationController*)navigationController
      willShowViewController:(UIViewController*)viewController
                    animated:(BOOL)animated
{
    viewController.navigationItem.leftItemsSupplementBackButton = YES;

    // Since we don't know the direction of the nav controller movement (push/pop) we use the hasGlobalNavigation
    // which is added via a category to know if we've already added global navigation
    // We do this because resetting the navigation items on a "pop" messes with the animation, and unnecessary
    if(self.showGlobalNavControls && !viewController.hasGlobalNavigation)
    {
        viewController.hasGlobalNavigation = YES;
        // grab a strong reference to the weak delegate
        id <SDPullNavigationSetupProtocol> theDelegate = self.delegate;
        if ([theDelegate respondsToSelector:@selector(globalNavigationBarItemsForSide:withViewController:)]) {
            viewController.navigationItem.leftBarButtonItems = [theDelegate globalNavigationBarItemsForSide:SDPullNavigationBarSideLeft withViewController:viewController];
            viewController.navigationItem.rightBarButtonItems = [theDelegate globalNavigationBarItemsForSide:SDPullNavigationBarSideRight withViewController:viewController];
        }
    }
}

- (void)navigationController:(UINavigationController*)navigationController
       didShowViewController:(UIViewController*)viewController
                    animated:(BOOL)animated
{
//    SDLog(@"navigationController:didShowViewController:animated:");
//    SDLog(@"   viewController = %@", viewController);
}

- (void)statusBarDidChangeRotationNotification:(NSNotification*)notification
{
    // TODO: We will need to update the size of the left and right global nav controls areas.
}

#pragma mark - Navigation Helpers:

- (BOOL)navigateToTopLevelController:(Class)topLevelViewControllerClass
{
    UINavigationController* foundNavController = [self.globalPullNavController navigationControllerForViewControllerClass:topLevelViewControllerClass];
    
    // We reset the hasGlobalNavigation flag because although sharing navigation across VC's in a nav
    // controller works, sharing them across multiple nav controllers doesn't. Want it to reset
    ((UIViewController *)foundNavController.viewControllers.firstObject).hasGlobalNavigation = NO;

    if(foundNavController)
        self.globalPullNavController.selectedViewController = foundNavController;

    return foundNavController != nil;
}

- (void)navigateToTopLevelController:(Class)topLevelViewControllerClass andPopToRootWithAnimation:(BOOL)animate
{
    // Dismiss any modals that might be currently visible.
    UINavigationController* selectedNavController = (UINavigationController*)self.globalPullNavController.selectedViewController;
    if(selectedNavController.visibleViewController.presentingViewController)
        [selectedNavController.visibleViewController.presentingViewController dismissViewControllerAnimated:NO completion:nil];

    // Now navigate.
    if([self navigateToTopLevelController:topLevelViewControllerClass])
        [(UINavigationController*)self.globalPullNavController.selectedViewController popToRootViewControllerAnimated:animate];
}

#pragma mark - Navigation Automation

- (void)navigateWithSteps:(NSArray*)steps
{
    // Dismiss any modals that might be currently visible.
    
    UINavigationController* selectedNavController = (UINavigationController*)self.globalPullNavController.selectedViewController;
    if(selectedNavController.visibleViewController.presentingViewController)
        [selectedNavController.visibleViewController.presentingViewController dismissViewControllerAnimated:NO completion:nil];

    NSAssert(steps, @"Not gonna automate a lot with a nil steps array.");
    NSAssert(steps.count, @"Not gonna automate a lot with no steps in the array.");

    NSDictionary* topLevelStep = steps[0];
    id topLevelController = topLevelStep[SDPullNavigationControllerKey];

    NSAssert(topLevelController, @"The first level of automation needs at least a controller.");

    // Determine where this topLevel is. Is it part of the containerViewController
    // or is it to be found in the navigationBarItems?

    // Check to see if we can find the requested toplevel class somewhere in the list of containerViewControllers

    UINavigationController* foundNavigationController = [self topLevelViewController:topLevelController];
    if(foundNavigationController)
    {
        [self navigateTopLevelViewController:foundNavigationController withSteps:steps];
    }
    else
    {
        // We did not find the supplied controller in the list of top level view controllers in the globalPullNavControllers list.
        // Now start looking through the things on the navigation bar.

        UIControl* foundControl = [self barItemController:topLevelController];
        [self navigateBarItem:foundControl withSteps:steps];
    }
}

- (void)navigateTopLevelViewController:(UINavigationController*)navigationController withSteps:(NSArray*)steps
{
}

- (void)navigateBarItem:(UIControl*)control withSteps:(NSArray*)steps
{
    NSDictionary* firstLevelStep = steps[0];

    control.pullNavigationAutomationCommand = firstLevelStep[SDPullNavigationCommandKey];
    control.pullNavigationAutomationData = firstLevelStep[SDPullNavigationDataKey];

    [control sendActionsForControlEvents:UIControlEventTouchUpInside | UIControlEventEditingDidBegin];
}

#pragma mark - Automation Utilities

- (UINavigationController*)topLevelViewController:(id)controller
{
    UINavigationController* foundNavigationController = nil;
    foundNavigationController = [self.globalPullNavController navigationControllerForViewControllerClass:controller];
    if(foundNavigationController == nil)
        foundNavigationController = [self.globalPullNavController navigationControllerForViewController:controller];

    return foundNavigationController;
}

- (UIControl*)barItemController:(id)controller
{
    UIControl* foundControl = nil;

    UIViewController *topViewController = self.globalPullNavController.selectedViewController;
    if ([topViewController isKindOfClass:[UINavigationController class]]) {
        topViewController = [(UINavigationController*)topViewController topViewController];
    }
    UINavigationItem *navigationItem = topViewController.navigationItem;
    NSArray* barItems = [navigationItem.leftBarButtonItems arrayByAddingObjectsFromArray:navigationItem.rightBarButtonItems];
    for (UIBarButtonItem *item in barItems)
    {
        if (!item.customView) continue;

        Class pullNavigationAutomationClass = item.customView.pullNavigationAutomationClass;
        if(pullNavigationAutomationClass)
        {
            if(pullNavigationAutomationClass == controller || pullNavigationAutomationClass == [controller class])
            {
                // We found the barItem that we want to automate.

                if ([item.customView isKindOfClass:[UIControl class]]) {
                    foundControl = (UIControl*)item.customView;
                    break;
                }
            }
        }
    }

    return foundControl;
}

#pragma mark - menu configuration

- (void)menuAdornmentImageWithStretchImage:(UIImage*)stretchImage
                            andCenterImage:(UIImage*)centerImage
                        compositionOptions:(SDImageCompositionOptions)imageCompositionOptions
{
    _menuAdornmentImageStretch = stretchImage;
    _menuAdornmentImageCenter = centerImage;
    _menuAdornmentImageCompositionOptions = imageCompositionOptions;
}

@end

#pragma mark - Swizzling of UIViewController's UINavigationItem

// This is NOT something I've done lightly. Please talk to Woolie or DrSneed before considering changing.

@implementation UIViewController(SDOverrideOfNavigationItem)

+ (void)load
{
    static dispatch_once_t sOnceToken;
    dispatch_once( &sOnceToken, ^
    {
        [[self class] swizzleMethod:@selector(navigationItem) withMethod:@selector(pullNavigationItem) error:nil];
    });
}

- (UINavigationItem*)pullNavigationItem
{
    UINavigationItem* item = [self pullNavigationItem];

    if([self.navigationController.navigationBar isKindOfClass: [SDPullNavigationBar class]])
    {
        // If this is ipad or if this is iphone and iOS 7, set the back button title to "" to hide it. Keep it on 6 or the back button disappears ...
        if ( [UIDevice iPad] || (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) )
        {
            [item setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@""
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(sdBackAction:)]];
        }
    }

    return item;
}

- (void)sdBackAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
