//
//  UIViewController+SDExtensions.h
//  Photos
//
//  Created by Brandon Sneed on 5/16/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (SDExtensions)

/**
 Wraps an instance of this UIViewController within a UINavigationController as rootViewController.
 */

+ (UINavigationController *)instanceInNavigationController;

/**
 Wraps an instance of this UIViewController within a UINavigationController as rootViewController.
 
 @param nibName nib to load UIViewController from.
 @param bundle bundle to load UIViewController from.
 */
+ (UINavigationController *)instanceInNavigationControllerWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle;

/**
 Takes an existing instance of a UIViewController and wraps it in a UINavigationController as rootViewController.
 */
- (UINavigationController *)wrapInstanceInNavigationController;

/**
 Loads a UIViewController from a storyboard.  It assumes your controller is the initialViewController.

 The viewController's class name will be used as the storyboard name with _iPhone or _iPad appended to the end.
 */
+ (instancetype)loadFromStoryboard;

/**
 Loads a UIViewController from a storyboard.  It assumes your controller is the initialViewController. 
 
 @param storyboardName the name of the storyboard file to search in.  if nil, the viewController's class name will be used as the name with _iPhone or _iPad appended to the end.
 */
+ (instancetype)loadFromStoryboardNamed:(NSString *)storyboardName;

/**
 Loads a UIViewController with a specific identifier from a storyboard.
 
 @param storyboardName the name of the storyboard file to search in.  if nil, the viewController's class name will be used as the name with _iPhone or _iPad appended to the end.
 @param identifier the identifier of the viewController within the storyboard to load.  If none is specified it'll use the className as an identifier.
 */
+ (instancetype)loadFromStoryboardNamed:(NSString *)storyboardName identifier:(NSString *)identifier;

/**
 Instantiates a UIViewController from a storyboard.  It assumes your controller is the initialViewController.

 @param storyboardName the name of the storyboard file to search in.  if nil, the viewController's class name will be used as the name with _iPhone or _iPad appended to the end.
 @param loadView controls whether the viewcontroller is loaded or not.
 */
+ (instancetype)storyboardNamed:(NSString *)storyboardName loadView:(BOOL)loadView;
/**
 Instantiates a UIViewController with a specific identifier from a storyboard.

 @param storyboardName the name of the storyboard file to search in.  if nil, the viewController's class name will be used as the name with _iPhone or _iPad appended to the end.
 @param identifier the identifier of the viewController within the storyboard to load.  If none is specified it'll use the className as an identifier.
 @param loadView controls whether the viewcontroller is loaded or not.
 */
+ (instancetype)storyboardNamed:(NSString *)storyboardName identifier:(NSString *)identifier loadView:(BOOL)loadView;

/**
 Recursive description for UIViewController hierarchies

 An equivalent of UIView's recursiveDescription method, but for inspecting the view controller hierarchy in an application.
 Taken from jrturton @ https://github.com/jrturton/UIViewController-RecursiveDescription
 */
- (NSString *)recursiveDescription;

/**
 Sets the name of the back button for the pushing view controller to "Back", so that the pushed view controller shows that button.
 */
- (void)useGenericBackButton;

/**
 Property for whether or not the view controller already has global navigation set. (Helps avoid resetting the navigation items
 in "pop" scenarios which messes with the animations
 */
@property (nonatomic, assign) BOOL hasGlobalNavigation;

@end
