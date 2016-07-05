//
//  SDContainerViewController.h
//
//  Created by Brandon Sneed on 1/17/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 SDContainerViewController is effectively a UITabBarController without a tab bar.
 */

@interface SDContainerViewController : UIViewController

/**
 Designated initializer for ContainerViewController. Same as calling init and then setting the viewController array.
 */
- (instancetype)initWithViewControllers:(NSArray *)viewControllers;

/**
 Given an instantiated view controller, find the navigationController in the list of navcontrollers.
 */
- (UINavigationController *)navigationControllerForViewController:(UIViewController *)viewController;

/**
 Given a view controller class, find a matching navigationController with conforming class in the list of navcontrollers.
 */
- (UINavigationController *)navigationControllerForViewControllerClass:(Class)viewControllerClass;

/**
 Returns the selected view controller or sets it. read/write.
 */
@property (nonatomic, assign) UIViewController *selectedViewController;
/**
 Index of the selected view controller.  read/write.
 */
@property (nonatomic, assign) NSUInteger selectedIndex;
/**
 The array of view controllers to be used.
 */
@property (nonatomic, copy) NSArray *viewControllers;
/**
 The container that this controller will be a subview of.  The default is self.view.
 */
@property (nonatomic, strong) IBOutlet UIView *containerView; // defaults to self.view

/**
 Returns the current visible view controller regardless of which view controller is selected.
 This method will dig into containers and navigation controllers by one level to find which
 view controller is on top.
 */
@property (nonatomic, readonly) UIViewController *currentVisibleViewController;

@end
