//
//  SDContainerViewController.m
//
//  Created by Brandon Sneed on 1/17/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import "SDContainerViewController.h"

@implementation SDContainerViewController

/**
 Designated initializer for ContainerViewController. Same as calling init and then setting the viewController array.
 */
- (instancetype)initWithViewControllers:(NSArray *)viewControllers
{
    self = [super initWithNibName:nil bundle:nil];
    if(self != nil)
    {
        _viewControllers = viewControllers;
    }

    return self;
}

- (instancetype)init
{
    return [super initWithNibName:nil bundle:nil];
}

// Leaving in for Legacy support. Use the designated initializer instead.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)loadView
{
    [super loadView];

    self.view.autoresizesSubviews = YES;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    if (!_containerView)
        _containerView = self.view;
}

- (void) viewDidLoad {
    [super viewDidLoad];

    // Someone has set our selectedViewController, but it was before we had a view, make sure it's set up now
    if (_selectedViewController && nil == _selectedViewController.view.superview)
    {
        _selectedViewController.view.frame = self.containerView.bounds;
        [_selectedViewController.view setNeedsUpdateConstraints];

        [self.containerView addSubview:_selectedViewController.view];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.selectedViewController = _selectedViewController;
}

#pragma mark properties

- (void)setContainerView:(UIView *)containerView
{
    if (self.view == _containerView)
        self.view = containerView;
    else
        [self.view addSubview:containerView];
    
    _containerView = containerView;
}

- (void)setViewControllers:(NSArray *)viewControllers
{
    if (_viewControllers == viewControllers)
        return;

    // this will remove any current controller.
    if (_selectedViewController)
        self.selectedViewController = nil;
    
    _viewControllers = viewControllers;
    self.selectedViewController = [viewControllers objectAtIndex:0];
}

- (void)setSelectedIndex:(NSUInteger)index
{
    if (index < _viewControllers.count)
        self.selectedViewController = [_viewControllers objectAtIndex:index];
}

- (NSUInteger)selectedIndex
{
    return [_viewControllers indexOfObject:self.selectedViewController];
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController
{
    NSAssert(_viewControllers.count > 0, @"SDContainerViewController must have view controllers set.");

    NSUInteger index = [_viewControllers indexOfObject:selectedViewController];
    if (index == NSNotFound)
        return;

    if (_selectedViewController != selectedViewController)
    {
        // remove the existing one from the parent controller
        UIViewController *currentController = _selectedViewController;
        [currentController willMoveToParentViewController:nil];
        [currentController.view removeFromSuperview];
        [currentController removeFromParentViewController];

        _selectedViewController = selectedViewController;

        // add the new one to the parent controller (only set frame when not using autolayout)
        [self addChildViewController:_selectedViewController];

        _selectedViewController.view.frame = self.containerView.bounds;
        [_selectedViewController.view setNeedsUpdateConstraints];

        UINavigationController *nc = [_selectedViewController isKindOfClass:[UINavigationController class]] ? (id) _selectedViewController : nil;
        if (nc) {
            [nc.delegate navigationController:nc willShowViewController:_selectedViewController animated:YES];
        }
        [self.containerView addSubview:_selectedViewController.view];
        [_selectedViewController didMoveToParentViewController:self];
    }
}

- (UIViewController *)currentVisibleViewController
{
    UIViewController *result = self.selectedViewController;
    
    if ([result isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *navController = (UINavigationController *)result;
        result = navController.visibleViewController;
    }
    else
    if ([result isKindOfClass:[UITabBarController class]])
    {
        UITabBarController *tabController = (UITabBarController *)result;
        result = tabController.selectedViewController;
        
        if ([result isKindOfClass:[UINavigationController class]])
        {
            UINavigationController *navController = (UINavigationController *)result;
            result = navController.visibleViewController;
        }
    }
    else
    if ([result isKindOfClass:[SDContainerViewController class]])
    {
        SDContainerViewController *containerController = (SDContainerViewController *)result;
        result = containerController.currentVisibleViewController;
    }
    
    return result;
}

- (UINavigationController*)navigationControllerForViewController:(UIViewController*)viewController
{
    return [self navigationControllerForViewControllerClass: [viewController class]];
}

- (UINavigationController*)navigationControllerForViewControllerClass:(Class)viewControllerClass
{
    UINavigationController* foundNavController = nil;
    for(UINavigationController* navController in self.viewControllers)
    {
        for(UIViewController* viewController in navController.viewControllers)
        {
            if([viewController isKindOfClass:viewControllerClass])
            {
                foundNavController = navController;
                break;
            }
        }
        
        if(foundNavController)
            break;
    }
    
    return foundNavController;
}

@end
